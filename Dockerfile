# ベースは公式の crawl4ai イメージを利用
FROM unclecode/crawl4ai:0.7.4

# Railway は $PORT を割り当てる。Gunicorn の bind を ENV で上書き
# IPv4/IPv6 デュアルバインド（万一失敗したら [::] 単独に切替）
ENV GUNICORN_CMD_ARGS="--bind 0.0.0.0:${PORT} --bind [::]:${PORT} --workers 2 --threads 4 --timeout 120"

# Redis環境変数をマッピング（Railway -> crawl4ai標準形式）
ENV REDIS_HOST="${QUEUE_BULL_REDIS_HOST}"
ENV REDIS_PORT="${QUEUE_BULL_REDIS_PORT}"
ENV REDIS_PASSWORD="${QUEUE_BULL_REDIS_PASSWORD}"
ENV REDIS_USER="${QUEUE_BULL_REDIS_USERNAME}"

# エントリーポイントスクリプトをコピー（実行権限付き）
COPY --chmod=755 entrypoint.sh /app/entrypoint.sh

# Playwright の Chromium をビルド時に取得（初回起動の失敗を防ぐ）
RUN python -m playwright install chromium

# ヘルスチェック（任意、/health がある前提）
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT:-11235}/health || exit 1

# エントリーポイントで環境変数を処理
ENTRYPOINT ["/app/entrypoint.sh"]