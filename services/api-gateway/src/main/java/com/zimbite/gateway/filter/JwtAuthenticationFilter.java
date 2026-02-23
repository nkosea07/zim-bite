package com.zimbite.gateway.filter;

import com.zimbite.shared.security.JwtValidator;
import com.zimbite.shared.security.SecurityHeaders;
import io.jsonwebtoken.Claims;
import java.util.List;
import java.util.Optional;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private static final List<String> OPEN_PATHS = List.of(
            "/api/v1/auth/",
            "/internal/",
            "/actuator/"
    );

    private final JwtValidator jwtValidator;

    public JwtAuthenticationFilter(JwtValidator jwtValidator) {
        this.jwtValidator = jwtValidator;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();

        if (isOpenPath(path)) {
            return chain.filter(exchange);
        }

        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String token = authHeader.substring(7);
        Optional<Claims> claims = jwtValidator.validate(token);

        if (claims.isEmpty()) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String tokenType = claims.get().get("type", String.class);
        if ("refresh".equals(tokenType)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        String userId = claims.get().getSubject();
        ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                .header(SecurityHeaders.USER_ID, userId)
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
}
