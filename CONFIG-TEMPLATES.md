# OpenClaw Agent 配置模板

## 标准版（受限控制）

适用于：生产环境、共享服务器、需要安全限制的场景

```json
{
  "server_addr": "oc.fogidc.com:8080",
  "agent_id": "agent-standard",
  "token": "YOUR_TOKEN_HERE",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": [
    "echo", "ls", "pwd", "cat", "grep", "find",
    "git", "npm", "node", "python3",
    "systemctl status", "docker ps"
  ],
  "file_path_whitelist": [
    "/home",
    "/var/www",
    "/opt/app"
  ]
}
```

**特点：**
- ✅ 只能执行白名单中的命令
- ✅ 只能访问指定目录
- ✅ 无法执行 sudo、rm -rf 等危险命令
- ✅ 适合多人共享环境

---

## 完全控制版（Full Control）

适用于：个人 VPS、开发环境、需要完全接管的场景

```json
{
  "server_addr": "oc.fogidc.com:8080",
  "agent_id": "agent-fullcontrol",
  "token": "YOUR_TOKEN_HERE",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": [
    "sh", "bash", "zsh", "sudo",
    "git", "npm", "node", "cargo", "python", "python3",
    "ls", "pwd", "echo", "cat", "mkdir", "rm", "cp", "mv",
    "curl", "wget", "systemctl", "docker",
    "apt", "yum", "dnf", "pacman"
  ],
  "file_path_whitelist": ["/"]
}
```

**特点：**
- ⚠️ 可以执行任意命令（包括 sudo）
- ⚠️ 可以访问整个文件系统
- ⚠️ 可以删除、修改任何文件
- ⚠️ 完全接管服务器

---

## 安装时选择

### 标准版安装
```bash
curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s linux
cd ~/openclaw-agent
sudo ./start-linux.sh
# 配置时选择标准版模板
```

### 完全控制版安装
```bash
curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s linux-full
cd ~/openclaw-agent
sudo ./start-linux.sh
# 配置时选择完全控制版模板
```

---

## 安全建议

### 标准版
- ✅ 适合生产环境
- ✅ 可以给团队成员使用
- ✅ 降低误操作风险

### 完全控制版
- ⚠️ 仅用于个人 VPS
- ⚠️ 定期更换 Token
- ⚠️ 使用 TLS 加密（wss://）
- ⚠️ 限制 API 访问 IP
