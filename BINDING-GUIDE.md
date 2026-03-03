# OpenClaw Agent 绑定指南

## 安装后绑定到服务端

### 1. 获取配置信息

在 VPS 服务端获取连接信息：
```bash
# 查看 QUIC 服务器地址和端口
# 默认：你的VPS_IP:34061
```

### 2. 配置 Agent

安装完成后，编辑配置文件：

**Mac/NAS:**
```bash
cd ~/openclaw-agent
nano config.json  # 或用 vim/vi
```

**需要修改的字段：**
```json
{
  "server_addr": "你的VPS_IP:34061",
  "server_name": "openclaw-vps",
  "token": "你的认证token",
  "agent_id": "mac-agent-1"  // 或 nas-agent-1
}
```

### 3. 获取 Token

在 VPS 上生成 token：
```bash
# 方法1：使用 OpenClaw CLI
openclaw token generate

# 方法2：手动生成（随机字符串）
openssl rand -hex 32
```

### 4. 启动并验证连接

**启动 Agent:**
```bash
cd ~/openclaw-agent
./start-mac.sh  # Mac
# 或
./start-nas.sh  # NAS
```

**检查连接状态:**
```bash
# 查看日志
tail -f ~/openclaw-agent/logs/agent.log

# 应该看到类似输出：
# [INFO] Connected to server: 你的VPS_IP:34061
# [INFO] Agent registered: mac-agent-1
```

### 5. 在 VPS 上验证

在 VPS 上检查已连接的 agents：
```bash
openclaw nodes status
# 或
openclaw gateway status
```

## 常见问题

### 连接失败
1. 检查防火墙是否开放 34061 端口（UDP）
2. 确认 VPS IP 地址正确
3. 验证 token 是否匹配

### Token 在哪里？
- VPS 配置文件：`~/.openclaw/config.json`
- 查找 `gateway.token` 或 `agents.token` 字段

### 修改配置后
重启 agent：
```bash
pkill openclaw-agent
./start-mac.sh  # 或 start-nas.sh
```

## 完整流程示例

```bash
# 1. 在 VPS 上
openclaw token generate
# 输出：abc123def456...

# 2. 在 Mac/NAS 上安装
curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s mac

# 3. 配置
cd ~/openclaw-agent
cat > config.json << EOF
{
  "server_addr": "123.45.67.89:34061",
  "server_name": "openclaw-vps",
  "token": "abc123def456...",
  "agent_id": "mac-agent-1"
}
EOF

# 4. 启动
./start-mac.sh

# 5. 验证（在 VPS 上）
openclaw nodes status
```

## 安全建议

- 不要在公开场合分享 token
- 定期轮换 token
- 使用防火墙限制连接来源
- 启用 TLS/SSL（如果支持）

---

更多信息：https://docs.openclaw.ai
