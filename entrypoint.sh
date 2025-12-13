#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Traefik Tunnel Expose...${NC}"

# Function to install traefik and cloudflared binaries
install_binaries() {
    local traefik_version="${TRAEFIK_VERSION:-v3.6.4}"
    local cloudflared_version="${CLOUDFLARED_VERSION:-2025.11.1}"
    local os="linux"
    local arch
    local traefik_arch
    local cf_arch

    arch="$(uname -m)"
    case "$arch" in
        x86_64 | amd64) traefik_arch="amd64"; cf_arch="amd64" ;;
        aarch64 | arm64) traefik_arch="arm64"; cf_arch="arm64" ;;
        armv7l | armv7 | armhf) traefik_arch="armv7"; cf_arch="arm" ;;
        *)
            echo -e "${RED}❌ Unsupported architecture: $arch${NC}"
            exit 1
            ;;
    esac

    if command -v traefik >/dev/null 2>&1 && command -v cloudflared >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Traefik & Cloudflared already installed${NC}"
        return
    fi

    echo -e "${BLUE}⬇️  Installing Traefik ${traefik_version} and Cloudflared ${cloudflared_version} for ${os}/${traefik_arch}...${NC}"

    local tmp_dir
    tmp_dir="$(mktemp -d)"

    curl -fsSL "https://github.com/traefik/traefik/releases/download/${traefik_version}/traefik_${traefik_version}_${os}_${traefik_arch}.tar.gz" \
        -o "${tmp_dir}/traefik.tar.gz" &&
        tar -xzf "${tmp_dir}/traefik.tar.gz" -C /usr/local/bin traefik

    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-${os}-${cf_arch}" \
        -o /usr/local/bin/cloudflared

    chmod +x /usr/local/bin/traefik /usr/local/bin/cloudflared
    rm -rf "${tmp_dir}"

    echo -e "${GREEN}✅ Binaries installed${NC}"
}

# Function to install bun runtime
install_bun() {
    if command -v bun >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Bun already installed${NC}"
        return
    fi
    echo -e "${BLUE}⬇️  Installing Bun runtime...${NC}"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    echo -e "${GREEN}✅ Bun installed${NC}"
}

# Function to validate environment variables
validate_env() {
    local required_vars=("CONFIG_PATH" "DATA_PATH" "HOST" "BASE_DOMAIN" "CF_ZONE_ID" "CF_TUNNEL_ID" "BASE_DOMAIN" "HOST" "CF_API_EMAIL" "ACME_CA_SERVER")
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if [[ ${#missing_vars[@]} -ne 0 ]]; then
        echo -e "${RED}❌ Missing required environment variables:${NC}"
        printf '%s\n' "${missing_vars[@]}"
        echo -e "${YELLOW}Please check your .env file or environment variables${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Required environment variables are set${NC}"
}

# Function to set default environment variables
set_default_env_vars() {
    echo -e "${BLUE}🔧 Setting default environment variables...${NC}"

    # ===== CLOUDFLARE TUNNEL =====
    #--DNS Proxy Configuration--
    export CF_PROXY_DNS=${CF_PROXY_DNS:-"true"}
    export CF_PROXY_DNS_ADDRESS=${CF_PROXY_DNS_ADDRESS:-"0.0.0.0"}
    export CF_PROXY_DNS_PORT=${CF_PROXY_DNS_PORT:-"53"}
    export CF_PROXY_DNS_MAX_CONNS=${CF_PROXY_DNS_MAX_CONNS:-"10"}

    export CF_TUNNEL_PROTOCOL=${CF_TUNNEL_PROTOCOL:-"quic"}
    export CF_HA_CONNECTIONS=${CF_HA_CONNECTIONS:-"6"}

    #--Cloudflare Tunnel Logging--
    export CF_LOG_LEVEL=${CF_LOG_LEVEL:-"info"}


    #--Connection Settings--
    export CF_NO_AUTOUPDATE=${CF_NO_AUTOUPDATE:-"false"}
    export CF_GRACE_PERIOD=${CF_GRACE_PERIOD:-"30s"}
    export CF_CATCHALL_SERVICE=${CF_CATCHALL_SERVICE:-"http_status:404"}

    # ===== TRAEFIK CONFIGURATION =====
    #--Global Settings--
    export CHECK_NEW_VERSION=${CHECK_NEW_VERSION:-"true"}
    export SEND_ANONYMOUS_USAGE=${SEND_ANONYMOUS_USAGE:-"false"}

    #--API & Dashboard--
    export TRAEFIK_DASHBOARD=${TRAEFIK_DASHBOARD:-"true"}
    export TRAEFIK_API_INSECURE=${TRAEFIK_API_INSECURE:-"true"}
    export TRAEFIK_DEBUG=${TRAEFIK_DEBUG:-"false"}

    #--Providers--
    export PROVIDERS_THROTTLE=${PROVIDERS_THROTTLE:-"5s"}
    export TRAEFIK_CONFIG_DIR=${TRAEFIK_CONFIG_DIR:-"/etc/traefik/conf.d"}
    export TRAEFIK_WATCH_CONFIG=${TRAEFIK_WATCH_CONFIG:-"true"}

    #--Docker Provider--
    export DOCKER_ENDPOINT=${DOCKER_ENDPOINT:-"unix:///var/run/docker.sock"}
    export DOCKER_EXPOSED_DEFAULT=${DOCKER_EXPOSED_DEFAULT:-"false"}
    export DOCKER_WATCH=${DOCKER_WATCH:-"true"}

    #--SSL/TLS Configuration--
    export CERT_RESOLVER=${CERT_RESOLVER:-"internal"}
    export ACME_STORAGE=${ACME_STORAGE:-"/etc/traefik/ssl/acme.json"}
    export DNS_PROVIDER=${DNS_PROVIDER:-"cloudflare"}
    export DNS_RESOLVER_1=${DNS_RESOLVER_1:-"1.1.1.1:53"}
    export DNS_RESOLVER_2=${DNS_RESOLVER_2:-"1.0.0.1:53"}
    export DNS_DELAY=${DNS_DELAY:-"30"}

    #--Logging Configuration--
    export LOG_LEVEL=${LOG_LEVEL:-"INFO"}
    export LOG_FORMAT=${LOG_FORMAT:-"json"}
    export ACCESS_LOG_FORMAT=${ACCESS_LOG_FORMAT:-"json"}
    export LOG_RETRY_ATTEMPTS=${LOG_RETRY_ATTEMPTS:-"true"}
    export LOG_MIN_DURATION=${LOG_MIN_DURATION:-"10ms"}
    export LOG_BUFFER_SIZE=${LOG_BUFFER_SIZE:-"0"}

    #--Header Logging--
    export HEADER_LOG_MODE=${HEADER_LOG_MODE:-"drop"}
    export LOG_USER_AGENT=${LOG_USER_AGENT:-"keep"}
    export LOG_AUTHORIZATION=${LOG_AUTHORIZATION:-"drop"}
    export LOG_COOKIE=${LOG_COOKIE:-"drop"}
    export LOG_SET_COOKIE=${LOG_SET_COOKIE:-"drop"}

    #--Security--
    export INSECURE_SKIP_VERIFY=${INSECURE_SKIP_VERIFY:-"true"}

    #--Metrics--
    METRICS_OTLP=${METRICS_OTLP}

    #--Health Check--
    export PING_ENTRYPOINT=${PING_ENTRYPOINT:-"traefik"}

    # --Traefik API URL--
    export TRAEFIK_API_URL=http://${BASE_DOMAIN}:8080
}

# Function to setup directories and permissions
setup_directories() {
    echo -e "${BLUE}📁 Setting up directories and permissions...${NC}"

    # Create directories if they don't exist
    mkdir -p /etc/traefik/conf.d
    mkdir -p /etc/traefik/ssl
    mkdir -p /var/logs/traefik
    mkdir -p /var/logs/cloudflared
    mkdir -p /etc/cloudflared

    # Set proper permissions
    chmod 755 /etc/traefik/conf.d
    chmod 700 /etc/traefik/ssl
    chmod 755 /var/logs/traefik
    chmod 755 /var/logs/cloudflared
    chmod 755 /etc/cloudflared

    # Ensure acme.json exists and has correct permissions
    touch /etc/traefik/ssl/acme.json
    chmod 600 /etc/traefik/ssl/acme.json

    echo -e "${GREEN}✅ Directories and permissions set up${NC}"
}

# Function to create cloudflared credentials from token
create_cloudflared_credentials() {
    echo -e "${BLUE}🔐 Setting up Cloudflare Tunnel credentials...${NC}"

    local cred_file="/etc/cloudflared/credentials.json"

    [[ ! -f "$cred_file" ]] && {
        echo '{"AccountTag":"'$CF_ACCOUNT_ID'","TunnelSecret":"'$CF_TUNNEL_SECRET'","TunnelID":"'$CF_TUNNEL_ID'","Endpoint":""}' >$cred_file
        chmod 600 $cred_file
        echo -e "${GREEN}✅ Cloudflare Tunnel credentials created${NC}"
    }
}

# Function to create DNS routes for Cloudflare tunnel
create_dns_tunnel() {
    echo -e "${BLUE}🌐 Setting up DNS routes...${NC}"

    local config_data='{
        "config": {
            "ingress": [
                {
                    "hostname": "'${BASE_DOMAIN}'",
                    "service": "http://'${HOST}':'${80}'",
                    "originRequest": {}
                },
                {
                    "hostname": "*.'${BASE_DOMAIN}'",
                    "service": "http://'${HOST}':'${443}'",
                    "originRequest": {}
                },
                {
                    "service": "http_status:404"
                }
            ]
        }
    }'

    curl -s --request PUT \
        "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/cfd_tunnel/${CF_TUNNEL_ID}/configurations" \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer ${CLOUDFLARE_DNS_API_TOKEN}" \
        --data "$config_data" >/dev/null &&
        echo -e "${GREEN}✅ DNS routes configured${NC}" ||
        echo -e "${RED}❌ Failed to configure DNS routes${NC}"
}

# Function to update traefik config with environment variables
update_traefik_config() {
    echo -e "${BLUE}⚙️  Updating Traefik configuration...${NC}"

    local config_file="/etc/traefik/traefik.yaml"
    local template_file="/tmp/tpl/traefik.yaml"

    [[ -f "$config_file" ]] && {
        echo -e "${YELLOW}✅ Traefik Config exists${NC}"
        return 0
    }

    [[ ! -f "$template_file" ]] && {
        echo -e "${RED}❌ Traefik Config file does not exist${NC}"
        exit 1
    }

    envsubst <$template_file >$config_file

    # Remove unused entrypoints if ports are not set
    if [[ -z "$DOT_TCP_PORT" ]]; then
        sed -i '/dot-tcp:/,/^$/d' $config_file
    fi
    if [[ -z "$DOT_UDP_PORT" ]]; then
        sed -i '/dot-udp:/,/^$/d' $config_file
    fi
    if [[ -z "$DOQ_PORT" ]]; then
        sed -i '/doq:/,/^$/d' $config_file
    fi
    if [[ -z "$DTLS_PORT" ]]; then
        sed -i '/dtls:/,/^$/d' $config_file
    fi

    # Add insecureSkipVerify to config if set to true
    if [[ "$INSECURE_SKIP_VERIFY" == "true" ]]; then
        echo "serversTransport:" >>$config_file
        echo "  insecureSkipVerify: true" >>$config_file
    fi

    # Add metrics configuration if METRICS_OTLP is set
    if [[ -n "$METRICS_OTLP" ]]; then
        echo "" >>$config_file
        echo "metrics:" >>$config_file
        echo "  otlp:" >>$config_file
        echo "    grpc:" >>$config_file
        echo "      insecure: false" >>$config_file
        echo "      endpoint: $METRICS_OTLP" >>$config_file
    fi

    # Add Trace Configuration if TRACING_OTLP is set
    if [[ -n "$TRACING_OTLP" ]]; then
        echo "" >>$config_file
        echo "tracing:" >>$config_file
        echo "  otlp:" >>$config_file
        echo "    grpc:" >>$config_file
        echo "      insecure: false" >>$config_file
        echo "      endpoint: $TRACING_OTLP" >>$config_file
    fi

    # Add ping entrypoint if PING_ENTRYPOINT is set
    if [[ -n "$PING_ENTRYPOINT" ]]; then
        echo "ping:" >>$config_file
        echo "  entryPoint: $PING_ENTRYPOINT" >>$config_file
    fi

    rm -f $template_file

    echo -e "${GREEN}✅ Traefik configuration updated${NC}"
}

# Function to update cloudflared config with environment variables
update_cloudflared_config() {
    echo -e "${BLUE}🌐 Updating Cloudflare Tunnel configuration...${NC}"

    local config_file="/etc/cloudflared/config.yml"
    local template_file="/tmp/tpl/cloudflared.yml"

    [[ -f "$config_file" ]] && {
        echo -e "${YELLOW}✅ Cloudflare Tunnel Config exists${NC}"
        return 0
    }

    [[ ! -f "$template_file" ]] && {
        echo -e "${RED}❌ Cloudflare Tunnel Config file does not exist${NC}"
        exit 1
    }

    envsubst <$template_file >$config_file
    rm -f $template_file

    echo -e "${GREEN}✅ Cloudflare Tunnel configuration updated${NC}"
}

# Function to update DNS script with environment variables
update_dns_script() {
    echo -e "${BLUE}🔧 Updating DNS automation script...${NC}"

    local script_file="/opt/scripts/auto-dns.sh"
    local temp_file="/tmp/auto-dns.sh"

    if [[ -f "$script_file" ]]; then
        return 0
    fi

    envsubst <$script_file >$temp_file
    mv $temp_file $script_file
    rm -f $temp_file

    echo -e "${GREEN}✅ DNS script updated${NC}"
}

# Function to update traefik dynamic configuration
update_traefik_dynamic_config() {
    echo -e "${BLUE}🔧 Updating Traefik dynamic configurations...${NC}"

    local config_dir="/etc/traefik/conf.d"

    [[ ! -d "$config_dir" ]] && {
        echo -e "${YELLOW}⚠️  No dynamic config directory found${NC}"
        return 0
    }

    # Find and process all YAML files
    find "$config_dir" -name "*.yml" -o -name "*.yaml" | while read -r config_file; do
        echo -e "${BLUE}  📝 Processing: $(basename "$config_file")${NC}"

        # Use sed to replace environment variables
        sed -i \
            -e "s/\${BASE_DOMAIN}/$BASE_DOMAIN/g" \
            "$config_file" && echo -e "${GREEN}  ✅ Updated: $(basename "$config_file")${NC}" || echo -e "${RED}  ❌ Failed: $(basename "$config_file")${NC}"
    done

    echo -e "${GREEN}✅ Dynamic configurations updated${NC}"
}

# Function to display startup information
display_info() {
    # Print title
    echo -e "\n${BLUE}🚀 Traefik Tunnel Expose${NC}\n"

    # Print configuration info
    printf "%-20s %s\n" "🌐 Domain:" "${BASE_DOMAIN}"
    printf "%-20s %s\n" "📧 ACME Email:" "${CF_API_EMAIL:-Not Set}"
    printf "%-20s %s\n" "🔧 Log Level:" "${LOG_LEVEL:-Not Set}"
    printf "%-20s %s\n" "🔒 Cert Resolver:" "${CERT_RESOLVER:-Not Set}"
    if [[ -z "$CF_ENABLED" || "$CF_ENABLED" == "false" ]]; then
        printf "%-20s %s\n" "🚇 Tunnel:" "❌ DISABLED"
    else
        printf "%-20s %s\n" "🚇 Tunnel:" "✅ ENABLED${CF_TUNNEL_ID:+ (ID: $CF_TUNNEL_ID)}"
    fi
    printf "%-20s %s\n" "⏰ Started At:" "$(date '+%Y-%m-%d %H:%M:%S UTC')"

    # Print status info
    echo -e "\n${GREEN}🎯 Container Status: ${BLUE}READY${NC}"
    echo -e "${GREEN}📊 Access Dashboard: ${BLUE}${HOST}:8080${NC}"
    echo -e "${GREEN}📁 Config Directory: ${BLUE}/etc/traefik/conf.d${NC}"
    echo -e "${GREEN}📝 Log Directory: ${BLUE}/var/logs/traefik${NC}\n"
}

# Main execution
main() {
    echo -e "${GREEN}🎯 Initializing Traefik Tunnel Expose Container...${NC}"

    # Run initialization steps
    install_binaries
    install_bun
    validate_env
    set_default_env_vars
    setup_directories
    create_cloudflared_credentials
    create_dns_tunnel
    update_traefik_config
    update_cloudflared_config
    update_traefik_dynamic_config
    update_dns_script
    display_info

    echo -e "${GREEN}🎉 Initialization complete! ${NC}"

    # Start services
    sh /opt/scripts/services.sh
}

# Run main function
main "$@"
