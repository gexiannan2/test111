#!/bin/bash
# 停止服务

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="test_app"
APP_PATH="$SCRIPT_DIR/$APP_NAME"

# 找到旧进程（可能不止一个 PID）
PIDS=$(pgrep -f -- "$APP_PATH" 2>/dev/null)

if [ -z "$PIDS" ]; then
  echo "未发现运行中的进程：$APP_PATH"
  exit 0
fi

echo "发现进程：$PIDS"
echo "开始停止..."

# 1) 先尝试优雅退出
for pid in $PIDS; do
  kill "$pid" 2>/dev/null
done

# 2) 等待最多 3 秒让进程自行退出
for i in 1 2 3; do
  sleep 1
