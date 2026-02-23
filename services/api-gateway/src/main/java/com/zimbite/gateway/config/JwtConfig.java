package com.zimbite.gateway.config;

import com.zimbite.shared.security.JwtProperties;
import com.zimbite.shared.security.JwtValidator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtConfig {

    @Bean
    public JwtProperties jwtProperties(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.access-ttl-seconds:900}") long accessTtl,
            @Value("${jwt.refresh-ttl-seconds:2592000}") long refreshTtl) {
        JwtProperties props = new JwtProperties();
        props.setSecret(secret);
        props.setAccessTtlSeconds(accessTtl);
        props.setRefreshTtlSeconds(refreshTtl);
        return props;
    }

    @Bean
    public JwtValidator jwtValidator(JwtProperties properties) {
        return new JwtValidator(properties);
    }
}
