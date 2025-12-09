FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

COPY pom.xml .
RUN mvn dependency:go-offline -B      
COPY src ./src
RUN mvn clean package -DskipTests 
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

COPY --from=builder  /app/target/*.jar app.jar
RUN chown spring:spring app.jar
USER spring

#HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
#  CMD nc -z localhost 9090 || exit 1

EXPOSE 9090
ENTRYPOINT ["java", "-jar", "app.jar"]

