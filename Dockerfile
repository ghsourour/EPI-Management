FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app
RUN apk update && apk upgrade

COPY pom.xml .
RUN mvn dependency:go-offline -B      
COPY src ./src
RUN mvn clean package -DskipTests 
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN apk update && apk upgrade

RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=builder --chown=spring:spring /app/target/*.jar app.jar
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD nc -z localhost 9090 || exit 1

USER spring
EXPOSE 9090
ENTRYPOINT ["java", "-jar", "app.jar"]

