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

# Copy dependency
COPY package.json ./
COPY bun.lock* ./
COPY src ./

# Install dependencies
RUN bun install --frozen-lockfile

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

# Install runtime dependencies
RUN set -eux; \
    if command -v apk >/dev/null 2>&1; then \
      apk add --no-cache bash curl jq yq ca-certificates gettext; \
      update-ca-certificates; \
    elif command -v apt-get >/dev/null 2>&1; then \
      apt-get update; \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        curl \
        jq \
        yq \
        ca-certificates \
        gettext; \
      update-ca-certificates; \
      rm -rf /var/lib/apt/lists/*; \
    else \
      echo "Unsupported base image: ${BUN_IMAGE}" >&2; \
      exit 1; \
    fi

ENV TRAEFIK_VERSION=${TRAEFIK_VERSION} \
    CLOUDFLARED_VERSION=${CLOUDFLARED_VERSION} \
    NODE_ENV=production

WORKDIR /app

COPY --link config/ /tmp/tpl/
COPY --link --chmod=755 scripts/ /opt/scripts/
COPY --link --chmod=755 entrypoint.sh ./entrypoint.sh

COPY --link --from=builder /app/build /opt/dashboard/

EXPOSE 80 443 8080 3000

CMD ["./entrypoint.sh"]
