### Multi-stage Dockerfile for board-service with Security Hardening
# Stage 1: Dependencies
FROM node:18-alpine AS build
WORKDIR /app
ENV NODE_ENV=production

RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

COPY package*.json ./
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

COPY . .

# Stage 2: Runtime
FROM node:18-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/package*.json ./
COPY --chown=appuser:appgroup ./src ./src

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8002/', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

EXPOSE 8002
CMD ["node", "src/server.js"]
