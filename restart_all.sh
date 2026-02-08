#!/bin/bash
# 重启服务

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="test_app"
APP_PATH="$SCRIPT_DIR/$APP_NAME"

# 1. 编译
g++ -o "$APP_PATH" "$SCRIPT_DIR/main.cpp" || { echo "编译失败"; exit 1; }

# 2. 停止旧进程
OLD_PID=$(pgrep -f "$APP_PATH" 2>/dev/null)
if [ -n "$OLD_PID" ]; then
    kill $OLD_PID 2>/dev/null
    sleep 1
    kill -9 $OLD_PID 2>/dev/null
fi

# 3. 启动新进程
nohup "$APP_PATH" >> "$SCRIPT_DIR/app.log" 2>&1 &
NEW_PID=$!
sleep 1

if kill -0 $NEW_PID 2>/dev/null; then
    echo "重启成功 PID:$NEW_PID"
else
    echo "重启失败"
    exit 1
fi
