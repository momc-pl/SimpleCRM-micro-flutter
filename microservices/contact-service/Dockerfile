FROM openjdk:11-jre-slim

WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy the jar file
COPY target/contact-service-*.jar app.jar

# Create a non-root user
RUN groupadd -r spring && useradd -r -g spring spring
RUN chown spring:spring /app
USER spring

EXPOSE 8083

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8083/api/v1/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]