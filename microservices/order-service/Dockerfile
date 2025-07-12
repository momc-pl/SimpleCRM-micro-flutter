FROM openjdk:11-jre-slim

WORKDIR /app

COPY target/order-service-1.0.0.jar order-service.jar

EXPOSE 8084

ENTRYPOINT ["java", "-jar", "order-service.jar"]