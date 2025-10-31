### Multi-stage Dockerfile for auth-service with Security Hardening
# Stage 1: Dependencies installation with cache optimization
FROM node:18-alpine AS build
WORKDIR /app
ENV NODE_ENV=production

# Security: Update packages and remove cache
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# Install dependencies with npm ci for reproducible builds
COPY package*.json ./
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# Copy application source
COPY . .

# Stage 2: Minimal runtime image with security enhancements
FROM node:18-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

# Security: Apply latest security patches
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# Create non-root user with specific UID/GID for consistency
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy only necessary production files from build stage
COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package*.json ./
COPY --chown=appuser:appgroup ./src ./src

# Security: Run as non-root user
USER appuser

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8000/api/auth/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

EXPOSE 8000
CMD ["node", "src/server.js"]
