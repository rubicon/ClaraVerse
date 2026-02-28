# =============================================================================
# ClaraVerse All-in-One Docker Image
# =============================================================================
# Multi-stage build that bundles the React frontend + Go backend into a single
# container. Inspired by Open WebUI's approach.
#
# Usage:
#   docker build -t claraverse .
#   docker run -d -p 3000:3000 -v claraverse-data:/app/data claraverse
#
# Or with docker-compose:
#   docker compose -f docker-compose.production.yml up -d
# =============================================================================

# ---- Stage 1: Build Frontend ------------------------------------------------
FROM node:20-alpine AS frontend-build

WORKDIR /frontend

# Copy package files first for better layer caching
COPY frontend/package.json frontend/package-lock.json ./

# Install dependencies
RUN npm ci --legacy-peer-deps

# Copy frontend source
COPY frontend/ .

# Build with empty API URLs (all-in-one mode uses same origin)
ENV VITE_API_BASE_URL="" \
    VITE_WS_URL="" \
    VITE_APP_NAME=ClaraVerse \
    VITE_APP_VERSION=1.0.0 \
    VITE_ENABLE_ANALYTICS=false

RUN npx vite build

# ---- Stage 2: Build Backend -------------------------------------------------
FROM golang:1.25.5-alpine AS backend-build

# Install build dependencies for CGO (required for SQLite)
RUN apk add --no-cache gcc musl-dev

WORKDIR /build

# Copy dependency files first for better layer caching
COPY backend/go.mod backend/go.sum ./

# Download dependencies
RUN go mod download

# Copy backend source (excluding test files via .dockerignore)
COPY backend/ .

# Build the application
# -ldflags "-s -w" strips debug info to reduce binary size
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags "-s -w" -o claraverse ./cmd/server

# ---- Stage 3: Runtime Image -------------------------------------------------
FROM alpine:3.20

LABEL org.opencontainers.image.title="ClaraVerse" \
      org.opencontainers.image.description="Open-source AI platform with chat, agents, workflows, and tools" \
      org.opencontainers.image.source="https://github.com/ClaraVerse/ClaraVerse" \
      org.opencontainers.image.licenses="Apache-2.0"

# Install runtime dependencies
# Chromium + fonts are required for PDF generation
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    wget \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ttf-freefont \
    font-noto \
    font-noto-emoji \
    font-noto-cjk \
    fontconfig && \
    fc-cache -f -v

# Create non-root user
RUN addgroup -g 1000 claraverse && \
    adduser -D -u 1000 -G claraverse claraverse

WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/data /app/uploads /app/logs /app/public /app/config && \
    chown -R claraverse:claraverse /app

# Set environment variables for Chromium
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

# Copy backend binary
COPY --from=backend-build --chown=claraverse:claraverse /build/claraverse /app/claraverse

# Copy built frontend
COPY --from=frontend-build --chown=claraverse:claraverse /frontend/dist /app/public

# Copy configuration files
COPY --chown=claraverse:claraverse backend/providers.example.json /app/providers.example.json
COPY --chown=claraverse:claraverse backend/migrations/ /app/migrations/
COPY --chown=claraverse:claraverse searxng/settings.yml /app/config/searxng-settings.yml

# Copy and configure entrypoint
COPY --chown=claraverse:claraverse docker-entrypoint-unified.sh /app/docker-entrypoint.sh
RUN sed -i 's/\r$//' /app/docker-entrypoint.sh && chmod +x /app/docker-entrypoint.sh

# Default environment - everything works out of the box
ENV PORT=3000 \
    ENVIRONMENT=production \
    SERVE_FRONTEND=true \
    UPLOAD_DIR=/app/uploads \
    PROVIDERS_FILE=/app/data/providers.json \
    ALLOWED_ORIGINS=* \
    DOCKER=true

# Switch to non-root user
USER claraverse

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["/app/claraverse"]
