FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B      
COPY src ./src
RUN mvn clean package -DskipTests 
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar
USER spring
RUN apk add --no-cache curl
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:9090/actuator/health || exit 1
EXPOSE 9090
ENTRYPOINT ["java", "-jar", "app.jar"]

