#!/bin/bash

# Auto-Retry Script for Subagent Failures
# Usage: ./auto_retry.sh <subagent_id> <error_type>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SKILL_DIR/config.json"

# 参数检查
if [ $# -lt 2 ]; then
    echo "Usage: $0 <subagent_id> <error_type>"
    exit 1
fi

SUBAGENT_ID="$1"
ERROR_TYPE="$2"
LOG_FILE="/tmp/auto-retry-${SUBAGENT_ID}.log"

# 读取配置
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

MAX_RETRIES=$(jq -r '.max_retries' "$CONFIG_FILE")
RETRY_DELAYS=$(jq -r '.retry_delays | @json' "$CONFIG_FILE")
RETRY_ON_ERRORS=$(jq -r '.retry_on_errors | @json' "$CONFIG_FILE")

# 初始化日志
if [ ! -f "$LOG_FILE" ]; then
    echo "0" > "$LOG_FILE"
fi

# 读取当前重试次数
CURRENT_RETRIES=$(cat "$LOG_FILE")

# 检查错误类型是否在重试列表中
SHOULD_RETRY=$(echo "$RETRY_ON_ERRORS" | jq --arg err "$ERROR_TYPE" 'any(.[]; . == $err)')

if [ "$SHOULD_RETRY" != "true" ]; then
    echo "Error type '$ERROR_TYPE' is not configured for retry"
    exit 1
fi

# 检查是否超过最大重试次数
if [ "$CURRENT_RETRIES" -ge "$MAX_RETRIES" ]; then
    echo "Max retries ($MAX_RETRIES) reached for subagent $SUBAGENT_ID"
    echo "Error: $ERROR_TYPE"
    echo "Please check the subagent configuration or task requirements"
    rm -f "$LOG_FILE"
    exit 1
fi

# 获取当前重试的延迟时间
DELAY=$(echo "$RETRY_DELAYS" | jq -r ".[$CURRENT_RETRIES] // 5")

# 增加重试计数
NEW_RETRY_COUNT=$((CURRENT_RETRIES + 1))
echo "$NEW_RETRY_COUNT" > "$LOG_FILE"

# 记录重试信息
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Retry $NEW_RETRY_COUNT/$MAX_RETRIES for subagent $SUBAGENT_ID (Error: $ERROR_TYPE, Delay: ${DELAY}s)" | tee -a "${LOG_FILE}.history"

# 延迟
if [ "$DELAY" -gt 0 ]; then
    echo "Waiting ${DELAY} seconds before retry..."
    sleep "$DELAY"
fi

# 返回成功，表示可以重试
echo "Retry approved: attempt $NEW_RETRY_COUNT/$MAX_RETRIES"
exit 0
