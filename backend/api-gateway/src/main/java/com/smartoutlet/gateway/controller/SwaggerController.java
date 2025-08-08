
package com.smartoutlet.gateway.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.Map;

@RestController
public class SwaggerController {

    @Autowired
    private WebClient webClient;

    @GetMapping("/v3/api-docs/user-service")
    public Mono<Object> getUserServiceApiDocs() {
        return getServiceApiDocs("http://localhost:8081/v3/api-docs", "User Service");
    }

    @GetMapping("/v3/api-docs/product-service")
    public Mono<Object> getProductServiceApiDocs() {
        return getServiceApiDocs("http://localhost:8082/v3/api-docs", "Product Service");
    }

    @GetMapping("/v3/api-docs/order-service")
    public Mono<Object> getOrderServiceApiDocs() {
        return getServiceApiDocs("http://localhost:8083/v3/api-docs", "Order Service");
    }

    private Mono<Object> getServiceApiDocs(String url, String serviceName) {
        return webClient.get()
                .uri(url)
                .retrieve()
                .bodyToMono(Object.class)
                .onErrorReturn(createErrorResponse(serviceName));
    }

    private Map<String, Object> createErrorResponse(String serviceName) {
        Map<String, Object> error = new HashMap<>();
        error.put("error", serviceName + " not available");
        error.put("status", 503);
        return error;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "API Gateway");
        return ResponseEntity.ok(health);
    }
}
