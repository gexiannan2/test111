#!/bin/bash
# 停止服务（稳健版：按 /proc/<pid>/exe 确认实际可执行文件路径）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="test_app"
APP_PATH="$SCRIPT_DIR/$APP_NAME"

# 取真实路径（避免符号链接/相对路径导致匹配不到）
APP_REAL="$(readlink -f "$APP_PATH" 2>/dev/null || echo "$APP_PATH")"

# 候选 PID：按名字先粗筛（避免只按绝对路径匹配不到 ./test_app）
CANDIDATES="$(pgrep -f -- "$APP_NAME" 2>/dev/null || true)"

if [ -z "${CANDIDATES}" ]; then
  echo "未发现包含关键字的进程：$APP_NAME"
  exit 0
fi

# 精筛：只杀 exe 真正指向 APP_REAL 的进程
PIDS=""
for pid in $CANDIDATES; do
  exe="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
  if [ -n "$exe" ] && [ "$exe" = "$APP_REAL" ]; then
    PIDS="$PIDS $pid"
  fi
done

if [ -z "${PIDS// }" ]; then
  echo "发现候选进程：$CANDIDATES，但没有一个 exe 指向：$APP_REAL"
  echo "（说明它们不是这个目录下的 $APP_NAME）"
  exit 0
fi

echo "将停止进程：$PIDS"
echo "目标可执行文件：$APP_REAL"

# 1) 优雅退出
kill $PIDS 2>/dev/null || true

# 2) 等待退出
for i in 1 2 3; do
  sleep 1
  alive=""
  for pid in $PIDS; do
    if kill -0 "$pid" 2>/dev/null; then
      alive="$alive $pid"
    fi
  done
  if [ -z "${alive// }" ]; then
    echo "停止成功（优雅退出）"
    exit 0
  fi
done

# 3) 仍存活则强杀
echo "仍存活，强杀：$PIDS"
kill -9 $PIDS 2>/dev/null || true
sleep 1

# 4) 最终确认
for pid in $PIDS; do
  if kill -0 "$pid" 2>/dev/null; then
    echo "停止失败：PID $pid 仍在运行"
    exit 1
  fi
done

echo "停止成功（强杀）"
