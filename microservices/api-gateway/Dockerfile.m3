# ARM64 Optimized Dockerfile for API Gateway on MacBook Pro M3
FROM --platform=linux/arm64 openjdk:17-jre-alpine

LABEL maintainer="SimpleCRM Team - M3 Optimized"
LABEL platform="ARM64/M3"
LABEL service="api-gateway"

# Install dependencies optimized for ARM64
RUN apk add --no-cache \
    wget \
    curl \
    tzdata \
    && rm -rf /var/cache/apk/*

# Set timezone
ENV TZ=UTC

# Create non-root user for security
RUN addgroup -g 1001 -S appuser && \
    adduser -S -u 1001 -G appuser appuser

# Set working directory
WORKDIR /app

# Copy the application JAR file
COPY target/api-gateway-1.0.0.jar app.jar

# Change ownership to appuser
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8090

# ARM64 optimized JVM settings for gateway (higher memory allocation)
ENV JAVA_OPTS="-Xmx768m -Xms384m \
    -XX:+UseG1GC \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+AlwaysPreTouch \
    -XX:+UseStringDeduplication \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.profiles.active=production"

# Health check with wget (more lightweight than curl)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8090/actuator/health || exit 1

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]