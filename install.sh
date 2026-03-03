#!/bin/bash
# OpenClaw Agent One-Command Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s [mac|nas|vps]

set -e

PLATFORM="${1:-}"
VERSION="v1.0"
REPO="FogMaly/openclaw-agents"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"

if [ -z "$PLATFORM" ]; then
    echo "Usage: $0 [mac|nas|vps]"
    echo "Example: curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash -s mac"
    exit 1
fi

case "$PLATFORM" in
    mac)
        PACKAGE="mac-v1.0.tar.gz"
        DIR="mac-v1.0"
        START_SCRIPT="start-mac.sh"
        ;;
    nas)
        PACKAGE="nas-v1.0.tar.gz"
        DIR="nas-v1.0"
        START_SCRIPT="start-nas.sh"
        ;;
    vps)
        PACKAGE="vps-v1.0.tar.gz"
        DIR="vps-v1.0"
        START_SCRIPT=""
        ;;
    *)
        echo "Error: Unknown platform '$PLATFORM'"
        echo "Supported: mac, nas, vps"
        exit 1
        ;;
esac

echo "🚀 Installing OpenClaw Agent for $PLATFORM..."
echo ""

# Download
echo "📦 Downloading $PACKAGE..."
curl -fsSL "${BASE_URL}/${PACKAGE}" -o "/tmp/${PACKAGE}"

# Extract
echo "📂 Extracting..."
cd /tmp
tar -xzf "${PACKAGE}"

# Install
INSTALL_DIR="$HOME/openclaw-agent"
echo "📥 Installing to $INSTALL_DIR..."

# Check if already installed
if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  检测到已安装的版本"
    
    # Try to backup existing config
    if [ -f "$INSTALL_DIR/config.json" ]; then
        echo "💾 备份现有配置..."
        cp "$INSTALL_DIR/config.json" "/tmp/openclaw-agent-config-backup.json"
        BACKUP_EXISTS=true
    fi
    
    echo "🔄 移除旧版本..."
    rm -rf "$INSTALL_DIR"
fi

mv "$DIR" "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Set permissions
if [ -f "openclaw-agent" ]; then
    chmod +x openclaw-agent
fi
if [ -n "$START_SCRIPT" ] && [ -f "$START_SCRIPT" ]; then
    chmod +x "$START_SCRIPT"
fi

# VPS special handling
if [ "$PLATFORM" = "vps" ]; then
    SKILLS_DIR="$HOME/.openclaw/workspace-fogid/skills"
    mkdir -p "$SKILLS_DIR"
    if [ -d "skills-auto-retry" ]; then
        echo "📦 Installing Auto-Retry skill..."
        cp -r skills-auto-retry "$SKILLS_DIR/"
    fi
fi

# Cleanup
rm -f "/tmp/${PACKAGE}"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📍 Installed to: $INSTALL_DIR"
echo ""

# Interactive configuration for Mac/NAS
if [ "$PLATFORM" = "mac" ] || [ "$PLATFORM" = "nas" ]; then
    echo "🔧 配置向导"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check if backup config exists
    if [ "$BACKUP_EXISTS" = true ] && [ -f "/tmp/openclaw-agent-config-backup.json" ]; then
        echo "✅ 检测到备份配置，正在恢复..."
        cp "/tmp/openclaw-agent-config-backup.json" "$INSTALL_DIR/config.json"
        rm -f "/tmp/openclaw-agent-config-backup.json"
        echo "✅ 配置已恢复"
    else
        echo "请输入以下信息以连接到 VPS 服务器："
        echo ""
        
        read -p "📡 VPS 服务器地址 (例如: oc.fogidc.com): " SERVER_ADDR < /dev/tty
        read -p "🔑 认证 Token: " TOKEN < /dev/tty
        read -p "🏷️  Agent ID (例如: mac-agent-1): " AGENT_ID < /dev/tty
        
        if [ -z "$SERVER_ADDR" ] || [ -z "$TOKEN" ] || [ -z "$AGENT_ID" ]; then
            echo ""
            echo "⚠️  配置已跳过（输入为空）"
            echo "📝 请手动编辑配置文件: $INSTALL_DIR/config.json"
            echo "📖 参考文档: https://github.com/${REPO}/blob/main/BINDING-GUIDE.md"
        else
            # Detect port and protocol
            if [[ "$SERVER_ADDR" == *":"* ]]; then
                FULL_ADDR="$SERVER_ADDR"
            else
                # Default to QUIC port
                FULL_ADDR="${SERVER_ADDR}:34061"
            fi
            
            # Download CA certificate
            CA_URL="https://${SERVER_ADDR}/ca.pem"
            echo "📥 下载 CA 证书..."
            if curl -fsSL "$CA_URL" -o "$INSTALL_DIR/ca.pem" 2>/dev/null; then
                echo "✅ CA 证书已下载"
                CA_PATH="./ca.pem"
            else
                echo "⚠️  CA 证书下载失败，使用 /dev/null"
                CA_PATH="/dev/null"
            fi
            
            # Create complete config with all required fields
            cat > "$INSTALL_DIR/config.json" << EOF
{
  "server_addr": "$FULL_ADDR",
  "server_name": "$SERVER_ADDR",
  "ca_cert_path": "$CA_PATH",
  "agent_id": "$AGENT_ID",
  "token": "$TOKEN",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": ["git", "npm", "node", "cargo", "python3", "ls", "pwd", "echo", "cat", "mkdir", "rm", "cp", "mv"],
  "file_path_whitelist": ["\$HOME", "/tmp"]
}
EOF
            echo ""
            echo "✅ 配置已保存到 config.json"
        fi
    fi
    
    echo ""
    echo "🎯 启动 Agent："
    echo "   cd $INSTALL_DIR"
    echo "   ./$START_SCRIPT"
else
    echo "🎯 下一步："
    echo "   cd $INSTALL_DIR"
    echo "   查看 RELEASE.md 了解配置方法"
fi

echo ""
echo "📖 项目文档: https://github.com/${REPO}"
echo "📖 绑定指南: https://github.com/${REPO}/blob/main/BINDING-GUIDE.md"
