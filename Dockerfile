# -------------------------------------------------------------------
# Author: Zenkiet
# -------------------------------------------------------------------

FROM alpine:latest

RUN apk add --no-cache bash curl jq yq ca-certificates gettext && update-ca-certificates && rm -rf /var/cache/apk/*

RUN TRAEFIK_VERSION=$(curl -s https://api.github.com/repos/traefik/traefik/releases/latest | jq -r '.tag_name') && \
  CLOUDFLARED_VERSION=$(curl -s https://api.github.com/repos/cloudflare/cloudflared/releases/latest | jq -r '.tag_name') && \
  curl -fsSL "https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_linux_amd64.tar.gz" \
  | tar -xz -C /usr/local/bin/ && \
  curl -fsSL "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-amd64" \
  -o /usr/local/bin/cloudflared && \
  chmod +x /usr/local/bin/traefik /usr/local/bin/cloudflared

# Copy configuration files
COPY config/ /tmp/tpl/
COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Copy and setup entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose ports
EXPOSE 80 443 8080

CMD ["/app/entrypoint.sh"]