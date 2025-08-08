
package com.smartoutlet.gateway.config;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.servers.Server;

import java.util.List;

@Configuration
public class SwaggerConfig {

    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }

    @Bean
    public WebClient webClient(WebClient.Builder builder) {
        return builder.build();
    }

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("SmartOutlet API Gateway")
                        .version("1.0.0")
                        .description("API Gateway for SmartOutlet POS System - Aggregates all microservices")
                        .contact(new Contact()
                                .name("SmartOutlet Team")
                                .email("support@smartoutlet.com")))
                .servers(List.of(
                        new Server().url("http://0.0.0.0:8080").description("Gateway Server")
                ));
    }

    @Bean
    public GroupedOpenApi gatewayApi() {
        return GroupedOpenApi.builder()
                .group("gateway")
                .pathsToMatch("/health", "/v3/api-docs/**")
                .build();
    }

    @Bean
    public GroupedOpenApi authServiceApi() {
        return GroupedOpenApi.builder()
                .group("auth-service")
                .pathsToMatch("/auth/**")
                .build();
    }

    @Bean
    public GroupedOpenApi productServiceApi() {
        return GroupedOpenApi.builder()
                .group("product-service")
                .pathsToMatch("/products/**")
                .build();
    }

    @Bean
    public GroupedOpenApi outletServiceApi() {
        return GroupedOpenApi.builder()
                .group("outlet-service")
                .pathsToMatch("/outlets/**")
                .build();
    }

    @Bean
    public GroupedOpenApi expenseServiceApi() {
        return GroupedOpenApi.builder()
                .group("expense-service")
                .pathsToMatch("/expenses/**")
                .build();
    }

    @Bean
    public GroupedOpenApi salesServiceApi() {
        return GroupedOpenApi.builder()
                .group("sales-service")
                .pathsToMatch("/sales/**")
                .build();
    }
}
