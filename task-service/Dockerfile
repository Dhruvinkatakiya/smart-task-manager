### Multi-stage Dockerfile for task-service with Security Hardening
# Stage 1: Dependencies installation
FROM node:18-alpine AS build
WORKDIR /app
ENV NODE_ENV=production

# Security: Update packages
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

COPY package*.json ./
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

COPY . .

# Stage 2: Minimal runtime with security
FROM node:18-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package*.json ./
COPY --chown=appuser:appgroup ./src ./src

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8001/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

EXPOSE 5001
CMD ["node", "src/server.js"]
