package com.zimbite.gateway.filter;

import com.zimbite.gateway.config.GatewayRateLimitProperties;
import com.zimbite.shared.security.JwtValidator;
import com.zimbite.shared.security.Role;
import com.zimbite.shared.security.SecurityHeaders;
import io.jsonwebtoken.Claims;
import java.net.InetSocketAddress;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.util.AntPathMatcher;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();

    private static final List<String> OPEN_PATHS = List.of(
            "/api/v1/auth/",
            "/internal/",
            "/actuator/"
    );

    private static final List<RbacRule> RBAC_RULES = List.of(
        new RbacRule("POST", "/api/v1/vendors/**", EnumSet.of(Role.VENDOR_ADMIN, Role.SYSTEM_ADMIN)),
        new RbacRule("PATCH", "/api/v1/vendors/**", EnumSet.of(Role.VENDOR_ADMIN, Role.SYSTEM_ADMIN)),
        new RbacRule("GET", "/api/v1/vendors/*/stats", EnumSet.of(Role.VENDOR_ADMIN, Role.VENDOR_STAFF, Role.SYSTEM_ADMIN)),
        new RbacRule("PATCH", "/api/v1/deliveries/**", EnumSet.of(Role.RIDER, Role.SYSTEM_ADMIN)),
        new RbacRule("POST", "/api/v1/payments/refunds/**", EnumSet.of(Role.VENDOR_ADMIN, Role.SYSTEM_ADMIN)),
        new RbacRule("GET", "/api/v1/analytics/admin/**", EnumSet.of(Role.SYSTEM_ADMIN)),
        new RbacRule("GET", "/api/v1/analytics/**", EnumSet.of(Role.VENDOR_ADMIN, Role.VENDOR_STAFF, Role.SYSTEM_ADMIN))
    );

    private final JwtValidator jwtValidator;
    private final List<RateLimitRule> rateLimitRules;
    private final Map<String, WindowBucket> rateLimitBuckets = new ConcurrentHashMap<>();

    public JwtAuthenticationFilter(JwtValidator jwtValidator, GatewayRateLimitProperties rateLimitProperties) {
        this.jwtValidator = jwtValidator;
        this.rateLimitRules = rateLimitProperties.getRules().stream()
                .map(r -> new RateLimitRule(r.getMethod(), r.getPattern(), r.getLimit(), r.getWindowSeconds()))
                .toList();
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();
        String method = exchange.getRequest().getMethod() == null ? "GET" : exchange.getRequest().getMethod().name();
        String traceId = resolveTraceId(exchange.getRequest().getHeaders().getFirst(SecurityHeaders.TRACE_ID));
        exchange.getResponse().getHeaders().set(SecurityHeaders.TRACE_ID, traceId);

        Optional<Claims> claims = validateAccessToken(exchange);
        String principalForRateLimit = claims.map(Claims::getSubject).orElseGet(() -> extractClientIp(exchange));
        RateLimitRule rateLimitRule = resolveRateLimitRule(method, path);
        if (isRateLimitExceeded(principalForRateLimit + "|" + rateLimitRule.pattern(), rateLimitRule)) {
            exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
            return exchange.getResponse().setComplete();
        }

        if (isOpenPath(path)) {
            ServerHttpRequest openRequest = exchange.getRequest().mutate()
                .header(SecurityHeaders.TRACE_ID, traceId)
                .build();
            return chain.filter(exchange.mutate().request(openRequest).build());
        }

        if (claims.isEmpty()) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String tokenType = claims.get().get("type", String.class);
        if ("refresh".equals(tokenType)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        Role role = resolveRole(claims.get().get("role", String.class));
        if (role == null) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        if (!isAuthorized(method, path, role)) {
            exchange.getResponse().setStatusCode(HttpStatus.FORBIDDEN);
            return exchange.getResponse().setComplete();
        }

        String userId = claims.get().getSubject();
        ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                .header(SecurityHeaders.USER_ID, userId)
                .header(SecurityHeaders.USER_ROLE, role.name())
                .header(SecurityHeaders.TRACE_ID, traceId)
                .build();

        return chain.filter(exchange.mutate().request(mutatedRequest).build());
    }

    @Override
    public int getOrder() {
        return -1;
    }

    private boolean isOpenPath(String path) {
        for (String prefix : OPEN_PATHS) {
            if (path.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    private Optional<Claims> validateAccessToken(ServerWebExchange exchange) {
        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return Optional.empty();
        }
        return jwtValidator.validate(authHeader.substring(7));
    }

    private String resolveTraceId(String incomingTraceId) {
        if (incomingTraceId == null || incomingTraceId.isBlank()) {
            return UUID.randomUUID().toString();
        }
        return incomingTraceId.trim();
    }

    private String extractClientIp(ServerWebExchange exchange) {
        InetSocketAddress remoteAddress = exchange.getRequest().getRemoteAddress();
        return remoteAddress == null ? "unknown" : remoteAddress.getAddress().getHostAddress();
    }

    private RateLimitRule resolveRateLimitRule(String method, String path) {
        for (RateLimitRule rule : rateLimitRules) {
            if (rule.matches(method, path)) {
                return rule;
            }
        }
        return rateLimitRules.isEmpty()
                ? new RateLimitRule(null, "/**", 120, 60)
                : rateLimitRules.get(rateLimitRules.size() - 1);
    }

    private boolean isRateLimitExceeded(String key, RateLimitRule rule) {
        WindowBucket bucket = rateLimitBuckets.computeIfAbsent(key, ignored -> new WindowBucket());
        long now = System.currentTimeMillis();
        long windowMs = rule.windowSeconds() * 1000L;
        synchronized (bucket) {
            if ((now - bucket.windowStartMs) >= windowMs) {
                bucket.windowStartMs = now;
                bucket.count = 0;
            }
            bucket.count += 1;
            return bucket.count > rule.limit();
        }
    }

    private boolean isAuthorized(String method, String path, Role role) {
        for (RbacRule rule : RBAC_RULES) {
            if (rule.matches(method, path) && !rule.roles().contains(role)) {
                return false;
            }
        }
        return true;
    }

    private Role resolveRole(String rawRole) {
        if (rawRole == null || rawRole.isBlank()) {
            return null;
        }
        try {
            return Role.valueOf(rawRole);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private record RbacRule(String method, String pattern, Set<Role> roles) {
        private boolean matches(String requestMethod, String path) {
            if (method != null && !method.equalsIgnoreCase(requestMethod)) {
                return false;
            }
            return PATH_MATCHER.match(pattern, path);
        }
    }

    private record RateLimitRule(String method, String pattern, int limit, int windowSeconds) {
        private boolean matches(String requestMethod, String path) {
            if (method != null && !method.equalsIgnoreCase(requestMethod)) {
                return false;
            }
            return PATH_MATCHER.match(pattern, path);
        }
    }

    private static final class WindowBucket {
        private long windowStartMs = System.currentTimeMillis();
        private int count = 0;
    }
}
