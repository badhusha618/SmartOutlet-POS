
package com.smartoutlet.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.ServerResponse;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.server.RouterFunctions;

import static org.springframework.web.reactive.function.server.RequestPredicates.GET;

@Configuration
public class SwaggerUIConfig {

    @Bean
    public RouterFunction<ServerResponse> swaggerRouterFunction() {
        return RouterFunctions.route(GET("/swagger-ui.html"), 
            request -> ServerResponse.temporaryRedirect(java.net.URI.create("/swagger-ui/index.html")).build());
    }
}
