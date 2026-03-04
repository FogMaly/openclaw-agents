# OpenClaw Linux Agent - 完全权限版本

## ⚠️ 安全警告

此版本配置为**完全权限**，可以执行任意命令并访问整个文件系统。
**仅在受信任的环境中使用！**

## 安装

```bash
# 1. 解压
tar -xzf linux-v1.0.tar.gz
cd linux-v1.0

# 2. 首次启动（需要 root 权限配置）
sudo ./start-linux.sh
```

首次启动时会提示输入配置信息，配置文件将保存到 `/opt/openclaw-agent/config.json`

## 配置说明

### 配置文件位置
`/opt/openclaw-agent/config.json`

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
Environment="OC_CONFIG_FILE=/opt/openclaw-agent/config.json"
WorkingDirectory=/opt/openclaw-agent
ExecStart=/opt/openclaw-agent/openclaw-agent
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
- glibc 2.34+
- 网络连接

## 支持的发行版

- Ubuntu 22.04+
- Debian 12+
- Rocky Linux 9+
- Alma Linux 9+
- Fedora 35+
- Arch Linux
- 其他使用 glibc 2.34+ 的现代 Linux 发行版
