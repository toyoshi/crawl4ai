# ベースは公式の crawl4ai イメージを利用
FROM unclecode/crawl4ai:0.7.4

# Railway は $PORT を割り当てる。Gunicorn の bind を ENV で上書き
ENV GUNICORN_CMD_ARGS="--bind 0.0.0.0:${PORT:-11235} --workers 2 --threads 4 --timeout 120"

# 既定の config を上書き
COPY app/config.yml /app/config.yml

# Playwright の Chromium をビルド時に取得（初回起動の失敗を防ぐ）
RUN python -m playwright install chromium

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT:-11235}/health || exit 1