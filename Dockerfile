# syntax=docker/dockerfile:1.19.0
# -------------------------------------------------------------------
# Author: Zenkiet
# -------------------------------------------------------------------

ARG BUN_IMAGE=oven/bun:alpine
ARG TRAEFIK_VERSION=v3.6.4
ARG CLOUDFLARED_VERSION=2025.11.1

# Stage 1: Build Frontend
FROM ${BUN_IMAGE} AS builder

WORKDIR /app

# Copy dependency files first
COPY package.json bun.lock* ./

# Install ALL dependencies (including devDependencies for build)
RUN --mount=type=cache,id=bun,target=/root/.bun/install/cache \
  bun install --frozen-lockfile

# Copy source and build
COPY . .
RUN bun run build

# Remove devDependencies after build
RUN bun install --frozen-lockfile --production && \
  rm -rf .cache

# Stage 2: Runtime
FROM ${BUN_IMAGE}

LABEL maintainer="Zenkiet" \
  description="Traefik reverse proxy with Cloudflared tunnel and Svelte dashboard"

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Install all runtime dependencies in one layer
RUN apk add --no-cache \
  bash \
  curl \
  jq \
  yq \
  ca-certificates \
  gettext && \
  update-ca-certificates && \
  rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENV TRAEFIK_VERSION=${TRAEFIK_VERSION} \
  CLOUDFLARED_VERSION=${CLOUDFLARED_VERSION}

# Copy application files
COPY --link config/ /tmp/tpl/
COPY --link --chmod=755 scripts/ /opt/scripts/
COPY --link --chmod=755 entrypoint.sh /app/entrypoint.sh

# Copy built frontend + dependencies from builder
COPY --from=builder --link /app/build /opt/dashboard/
COPY --from=builder --link /app/package.json /app/package.json

WORKDIR /app

EXPOSE 80 443 8080 3000

CMD ["/app/entrypoint.sh"]