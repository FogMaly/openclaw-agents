#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$SCRIPT_DIR/openclaw-agent"
CONFIG="/opt/openclaw-agent/config.json"
LOG_FILE="/opt/openclaw-agent/agent.log"

echo "🚀 Starting OpenClaw Linux Agent"
echo "   - Binary: $BINARY"
echo "   - Config: $CONFIG"
echo ""

# 检查配置文件是否存在
if [ ! -f "$CONFIG" ]; then
    echo "⚠️  未检测到配置文件，开始配置向导..."
    echo ""
    
    # 创建配置目录（需要 root 权限）
    if [ "$EUID" -ne 0 ]; then
        echo "❌ 首次配置需要 root 权限创建 /opt/openclaw-agent 目录"
        echo "请使用: sudo ./start-linux.sh"
        exit 1
    fi
    
    mkdir -p /opt/openclaw-agent
    
    # 选择版本
    echo "请选择 Agent 版本："
    echo "------------------------"
    echo "1. 标准版（受限控制）"
    echo "   - 只能执行白名单命令"
    echo "   - 只能访问指定目录"
    echo "   - 适合生产环境"
    echo ""
    echo "2. 完全控制版（Full Control）"
    echo "   - 可执行任意命令（包括 sudo）"
    echo "   - 可访问整个文件系统"
    echo "   - 适合个人 VPS"
    echo "------------------------"
    read -p "请选择 [1/2]: " VERSION_CHOICE
    
    # 交互式配置
    read -p "📡 VPS 服务器地址 (IP 或域名，例如: oc.fogidc.com): " SERVER_HOST
    read -p "🔌 服务器端口 (默认: 8080): " SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-8080}
    
    read -p "🏷️  Agent ID (例如: linux-agent-1): " AGENT_ID
    read -p "🔑 认证 Token: " TOKEN
    
    if [ -z "$SERVER_HOST" ] || [ -z "$AGENT_ID" ] || [ -z "$TOKEN" ]; then
        echo "❌ 配置信息不完整，退出"
        exit 1
    fi
    
    FULL_ADDR="${SERVER_HOST}:${SERVER_PORT}"
    
    # 根据选择生成配置
    if [ "$VERSION_CHOICE" = "1" ]; then
        echo ""
        echo "📋 配置摘要（标准版）："
        echo "   服务器: $FULL_ADDR"
        echo "   Agent ID: $AGENT_ID"
        echo "   权限: 受限控制"
        echo ""
        
        cat > "$CONFIG" << EOF
{
  "server_addr": "$FULL_ADDR",
  "agent_id": "$AGENT_ID",
  "token": "$TOKEN",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": ["echo", "ls", "pwd", "cat", "grep", "find", "git", "npm", "node", "python3", "systemctl", "docker"],
  "file_path_whitelist": ["/home", "/var/www", "/opt"]
}
EOF
    else
        echo ""
        echo "📋 配置摘要（完全控制版）："
        echo "   服务器: $FULL_ADDR"
        echo "   Agent ID: $AGENT_ID"
        echo "   权限: 完全控制"
        echo ""
        
        cat > "$CONFIG" << EOF
{
  "server_addr": "$FULL_ADDR",
  "agent_id": "$AGENT_ID",
  "token": "$TOKEN",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": ["sh", "bash", "zsh", "sudo", "git", "npm", "node", "cargo", "python", "python3", "ls", "pwd", "echo", "cat", "mkdir", "rm", "cp", "mv", "curl", "wget", "systemctl", "docker", "apt", "yum", "dnf"],
  "file_path_whitelist": ["/"]
}
EOF
    fi
    
    chmod 600 "$CONFIG"
    echo "✅ 配置已保存到 $CONFIG"
    echo ""
fi

# 导出配置路径
export OC_CONFIG_FILE="$CONFIG"

# 测试连接（前台运行 10 秒）
echo "🔍 测试连接中..."
timeout 10 "$BINARY" > "$LOG_FILE" 2>&1 &
PID=$!

# 等待 10 秒
sleep 10

# 检查进程是否还在运行
if kill -0 $PID 2>/dev/null; then
    echo "✅ 连接成功！Agent 已在后台运行"
    echo "   - PID: $PID"
    echo "   - 日志: $LOG_FILE"
    echo ""
    echo "管理命令："
    echo "  查看日志: tail -f $LOG_FILE"
    echo "  停止服务: kill $PID"
    echo "  或使用 systemd 管理（推荐）"
    
    # 后台运行
    disown $PID
else
    echo "❌ 连接失败，查看日志："
    echo "------------------------"
    cat "$LOG_FILE"
    echo "------------------------"
    exit 1
fi
