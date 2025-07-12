FROM openjdk:11-jre-slim

# Install dependencies and create app user
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r app && useradd -r -g app app

# Set working directory
WORKDIR /app

# Copy the built jar file
COPY target/product-service-*.jar app.jar

# Change ownership to app user
RUN chown -R app:app /app

# Switch to app user
USER app

# Expose the port
EXPOSE 8083

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8083/products/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]