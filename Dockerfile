# ==========================
# Stage 1: Build the JAR
# ==========================
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory inside the container
WORKDIR /app

# Copy Maven configuration first (for caching)
COPY pom.xml .

# Copy source code
COPY src ./src

# Build the JAR without running tests
RUN mvn clean package -DskipTests

# ==========================
# Stage 2: Runtime
# ==========================
FROM eclipse-temurin:17-jdk-alpine

# Set working directory for runtime
WORKDIR /app

# Copy the JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose container port
EXPOSE 8080

# Optional: allow passing Java options via environment variable
ENV SPRING_PROFILES_ACTIVE=docker

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
