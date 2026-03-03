# OpenClaw Multi-Platform Release v1.0

发布日期：2026-03-03

## 📦 发布包

### Mac Agent v1.0 (901KB)
- 文件：`mac-v1.0.tar.gz`
- 包含：Agent 二进制 + TuriX Skill + 配置文件
- 平台：macOS 10.15+

### NAS Agent v1.0 (894KB)
- 文件：`nas-v1.0.tar.gz`
- 包含：Agent 二进制 + 配置文件
- 平台：Linux (Synology/QNAP/群晖)

### VPS Server v1.0 (2.3KB)
- 文件：`vps-v1.0.tar.gz`
- 包含：Auto-Retry Skill + 部署文档
- 平台：Linux VPS (Ubuntu 20.04+)

## 🚀 快速部署

### Mac
```bash
tar -xzf mac-v1.0.tar.gz
cd mac-v1.0
chmod +x openclaw-agent start-mac.sh
./start-mac.sh
```

### NAS
```bash
tar -xzf nas-v1.0.tar.gz
cd nas-v1.0
chmod +x openclaw-agent start-nas.sh
./start-nas.sh
```

### VPS
```bash
tar -xzf vps-v1.0.tar.gz
cd vps-v1.0
cp -r skills-auto-retry ~/.openclaw/workspace-fogid/skills/
```

## 📋 版本说明

- 首次正式发布
- 支持 Mac/NAS/VPS 三平台
- 包含 TuriX 和 Auto-Retry Skills
- QUIC 服务器配置（端口 34061）

## 🔗 下一步

1. 在 Mac 上部署并测试 TuriX
2. 在 NAS 上部署 Agent
3. 测试 VPS ↔ Mac/NAS 连接
4. 配置 Brave Search API

## 📝 已知问题

- 心跳机制需要优化
- QUIC 服务器未包含在发布包中（需手动配置）
- Brave Search API 需要手动注册

---

生成位置：`/root/openclaw-releases/`
