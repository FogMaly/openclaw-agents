# OpenClaw VPS Server v1.0

## 包含内容

- `skills-auto-retry/` - 自动重试 Skill
- VPS 配置说明
- QUIC 服务器部署指南

## 系统要求

- Linux VPS (Ubuntu 20.04+ 推荐)
- 公网 IP
- 开放端口：34061 (QUIC)

## 服务组件

### 1. QUIC 服务器
- 端口：34061
- 协议：QUIC over UDP
- 用途：Mac/NAS Agent 连接中继

### 2. Auto-Retry Skill
- 自动重试失败的子 agent
- 支持超时、中止、无响应等错误
- 配置文件：`skills-auto-retry/config.json`

## 部署步骤

```bash
# 1. 安装 OpenClaw Gateway
npm install -g openclaw

# 2. 配置 QUIC 服务器
# (需要手动配置，见 DEPLOYMENT.md)

# 3. 安装 Auto-Retry Skill
cp -r skills-auto-retry ~/.openclaw/workspace-fogid/skills/

# 4. 启动服务
openclaw gateway start
```

## 版本信息

- 版本：v1.0
- 发布日期：2026-03-03
- 平台：Linux (x86_64)
