# OpenClaw NAS Agent v1.0

## 包含内容

- `openclaw-agent` - NAS 平台二进制文件（1.7MB）
- `nas-profile.json` - NAS 配置文件
- `start-nas.sh` - 启动脚本
- `README-nas.md` - NAS 部署说明

## 系统要求

- Linux (x86_64 或 ARM64)
- 适用于 Synology/QNAP/群晖等 NAS 设备
- 网络连接到 VPS QUIC 服务器

## 快速开始

```bash
chmod +x openclaw-agent start-nas.sh
./start-nas.sh
```

详细说明见 README-nas.md

## 版本信息

- 版本：v1.0
- 编译日期：2026-03-02
- 平台：Linux (x86_64/aarch64)
