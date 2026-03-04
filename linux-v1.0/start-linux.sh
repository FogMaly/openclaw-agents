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

# 检查是否已有运行的实例
if pgrep -f "openclaw-agent" > /dev/null; then
    echo "⚠️  检测到已运行的 Agent 实例"
    read -p "是否停止并重启？[y/N]: " RESTART
    if [ "$RESTART" = "y" ] || [ "$RESTART" = "Y" ]; then
        pkill -f openclaw-agent
        sleep 2
    else
        echo "退出"
        exit 0
    fi
fi

# 选择运行模式
echo "请选择运行模式："
echo "------------------------"
echo "1. 前台运行（测试模式）"
echo "   - 直接在终端运行"
echo "   - 可以看到实时日志"
echo "   - Ctrl+C 停止"
echo ""
echo "2. 后台运行（推荐）"
echo "   - 使用 systemd 管理"
echo "   - 自动重启"
echo "   - 开机自启"
echo "------------------------"
read -p "请选择 [1/2]: " RUN_MODE

if [ "$RUN_MODE" = "1" ]; then
    # 前台运行
    echo ""
    echo "🚀 启动 Agent（前台模式）..."
    echo "   按 Ctrl+C 停止"
    echo ""
    exec "$BINARY"
else
    # 后台运行 - 配置 systemd
    echo ""
    echo "📦 配置 systemd 服务..."
    
    # 复制二进制到 /opt
    cp "$BINARY" /opt/openclaw-agent/
    chmod +x /opt/openclaw-agent/openclaw-agent
    
    # 创建 systemd 服务
    cat > /etc/systemd/system/openclaw-agent.service << EOF
[Unit]
Description=OpenClaw Agent
After=network.target

[Service]
Type=simple
User=root
Environment="OC_CONFIG_FILE=/opt/openclaw-agent/config.json"
WorkingDirectory=/opt/openclaw-agent
ExecStart=/opt/openclaw-agent/openclaw-agent
Restart=always
RestartSec=10
StandardOutput=append:/opt/openclaw-agent/agent.log
StandardError=append:/opt/openclaw-agent/agent.log

[Install]
WantedBy=multi-user.target
EOF
    
    # 启动服务
    systemctl daemon-reload
    systemctl enable openclaw-agent
    systemctl start openclaw-agent
    
    echo ""
    echo "✅ Agent 已启动（systemd 管理）"
    echo ""
    echo "管理命令："
    echo "  查看状态: sudo systemctl status openclaw-agent"
    echo "  查看日志: sudo tail -f /opt/openclaw-agent/agent.log"
    echo "  停止服务: sudo systemctl stop openclaw-agent"
    echo "  重启服务: sudo systemctl restart openclaw-agent"
    echo ""
    
    # 显示状态
    systemctl status openclaw-agent --no-pager | head -15
fi
