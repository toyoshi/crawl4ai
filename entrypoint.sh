#!/bin/sh
set -e

# 環境変数をconfig.ymlに適用
cat > /app/config_runtime.yml <<EOF
# Application Configuration
app:
  title: "Crawl4AI API"
  version: "1.0.0"
  host: "0.0.0.0"
  port: 11234
  reload: False
  workers: 1
  timeout_keep_alive: 300

# Default LLM Configuration
llm:
  provider: "openai/gpt-4o-mini"
  api_key_env: "OPENAI_API_KEY"

# Redis Configuration
redis:
  host: "${REDIS_HOST:-localhost}"
  port: ${REDIS_PORT:-6379}
  db: 0
  password: "${REDIS_PASSWORD:-}"
  ssl: False
  ssl_cert_reqs: None
  ssl_ca_certs: None
  ssl_certfile: None
  ssl_keyfile: None

# Rate Limiting Configuration
rate_limiting:
  enabled: ${RATE_LIMIT_ENABLED:-true}
  default_limit: "1000/minute"
  trusted_proxies: []
  storage_uri: "redis://${REDIS_USER:-default}:${REDIS_PASSWORD:-}@${REDIS_HOST:-localhost}:${REDIS_PORT:-6379}/1"

# Security Configuration
security:
  enabled: false
  jwt_enabled: false
  https_redirect: false
  trusted_hosts: ["*"]
  headers:
    x_content_type_options: "nosniff"
    x_frame_options: "DENY"
    content_security_policy: "default-src 'self'"
    strict_transport_security: "max-age=63072000; includeSubDomains"

# Crawler Configuration
crawler:
  base_config:
    simulate_user: true
  memory_threshold_percent: 95.0
  rate_limiter:
    enabled: true
    base_delay: [1.0, 2.0]
  timeouts:
    stream_init: 30.0
    batch_process: 300.0
  pool:
    max_pages: 30
    idle_ttl_sec: 1800
  browser:
    kwargs:
      headless: true
      text_mode: true
    extra_args:
      - "--no-sandbox"
      - "--disable-dev-shm-usage"
      - "--disable-gpu"
      - "--disable-software-rasterizer"
      - "--disable-web-security"
      - "--allow-insecure-localhost"
      - "--ignore-certificate-errors"

# Logging Configuration
logging:
  level: "INFO"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Observability Configuration
observability:
  prometheus:
    enabled: false
    endpoint: "/metrics"
  health_check:
    endpoint: "/health"

# Defaults
defaults:
  extraction_strategy: "markdown"
  render_js: false
  wait_for: 0
  timeout: 30000
EOF

# 設定ファイルを適切な場所にコピー
mv /app/config_runtime.yml /app/config.yml

# supervisordを起動
exec supervisord -c supervisord.conf