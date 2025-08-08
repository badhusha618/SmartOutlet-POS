
# Multi-stage build for inventory service with common module dependency
FROM openjdk:17-jdk-slim as build

WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Copy parent pom and common module first
COPY ../pom.xml ./parent-pom.xml
COPY ../common-module/ ./common-module/

# Build common module
WORKDIR /app/common-module
RUN mvn clean install -DskipTests

# Copy inventory service source
WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build the inventory service
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:17-jre-slim

WORKDIR /app

# Copy the built JAR file
COPY --from=build /app/target/*.jar app.jar

# Expose the port
EXPOSE 8086

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8086/api/inventory/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
