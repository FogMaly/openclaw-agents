# OpenClaw Linux Agent - 完全权限版本

## ⚠️ 安全警告

此版本配置为**完全权限**，可以执行任意命令并访问整个文件系统。
**仅在受信任的环境中使用！**

## 安装

```bash
# 1. 解压
tar -xzf linux-v1.0.tar.gz
cd linux-v1.0

# 2. 配置
mkdir -p ~/.openclaw-agent
cat > ~/.openclaw-agent/config.json << 'EOF'
{
  "server_addr": "154.40.43.33:8080",
  "agent_id": "linux-agent-1",
  "token": "0e1243a5240f94e51532cf46f7f30cae6e6558a9097c8145e2f199f26dbe3286",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": ["sh", "bash", "zsh", "sudo", "git", "npm", "node", "cargo", "python", "python3", "ls", "pwd", "echo", "cat", "mkdir", "rm", "cp", "mv", "curl", "wget", "systemctl", "docker", "apt", "yum", "dnf"],
  "file_path_whitelist": ["/"]
}
EOF

# 3. 启动
chmod +x start-linux.sh
./start-linux.sh
```

## 配置说明

### 完全权限配置
- **command_whitelist**: 包含 shell、sudo、包管理器等
- **file_path_whitelist**: `["/"]` = 整个文件系统

### 自定义配置
编辑 `~/.openclaw-agent/config.json`：

```json
{
  "server_addr": "your-vps-ip:8080",
  "agent_id": "your-agent-id",
  "token": "your-token",
  "heartbeat_secs": 20,
  "reconnect_max_secs": 30,
  "command_whitelist": ["sh", "bash", "sudo", ...],
  "file_path_whitelist": ["/"]
}
```

## 后台运行

### 使用 systemd
```bash
sudo tee /etc/systemd/system/openclaw-agent.service << 'EOF'
[Unit]
Description=OpenClaw Agent
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/openclaw-agent
ExecStart=/opt/openclaw-agent/start-linux.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openclaw-agent
sudo systemctl start openclaw-agent
```

### 使用 screen
```bash
screen -dmS openclaw ./start-linux.sh
# 查看: screen -r openclaw
```

### 使用 nohup
```bash
nohup ./start-linux.sh > agent.log 2>&1 &
```

## 测试连接

```bash
# 测试端口
nc -zv 154.40.43.33 8080

# 查看日志
tail -f agent.log
```

## 故障排查

### 连接失败
1. 检查配置文件：`cat ~/.openclaw-agent/config.json`
2. 测试端口：`nc -zv <server-ip> 8080`
3. 检查防火墙：`sudo iptables -L`

### 权限不足
如果需要 sudo 权限，确保：
1. 用户在 sudoers 中
2. 或以 root 运行 agent

## 安全建议

1. **限制命令白名单**：只添加必要的命令
2. **限制路径白名单**：不要用 `["/"]`，指定具体路径
3. **使用专用用户**：不要以 root 运行
4. **定期更换 Token**
5. **启用 TLS**：使用 wss:// 而不是 ws://

## 系统要求

- Linux x86_64
- glibc 2.17+
- 网络连接

## 支持的发行版

- Ubuntu 18.04+
- Debian 9+
- CentOS 7+
- RHEL 7+
- Fedora 30+
- Arch Linux
- 其他现代 Linux 发行版
