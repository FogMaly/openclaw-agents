# OpenClaw Agents

Multi-platform OpenClaw agent releases for Mac, NAS, and VPS deployments.

## 🚀 Quick Start

### One-Command Install

**Mac:**
```bash
curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s mac
```

**NAS (Linux):**
```bash
curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s nas
```

**VPS:**
```bash
curl -fsSL https://raw.githubusercontent.com/FogMaly/openclaw-agents/main/install.sh | bash -s vps
```

## 📦 Manual Installation

### Mac
```bash
wget https://github.com/FogMaly/openclaw-agents/releases/download/v1.0/mac-v1.0.tar.gz
tar -xzf mac-v1.0.tar.gz
cd mac-v1.0
chmod +x openclaw-agent start-mac.sh
./start-mac.sh
```

### NAS
```bash
wget https://github.com/FogMaly/openclaw-agents/releases/download/v1.0/nas-v1.0.tar.gz
tar -xzf nas-v1.0.tar.gz
cd nas-v1.0
chmod +x openclaw-agent start-nas.sh
./start-nas.sh
```

### VPS
```bash
wget https://github.com/FogMaly/openclaw-agents/releases/download/v1.0/vps-v1.0.tar.gz
tar -xzf vps-v1.0.tar.gz
cd vps-v1.0
cp -r skills-auto-retry ~/.openclaw/workspace-fogid/skills/
```

## 📋 What's Included

### Mac Agent v1.0 (901KB)
- OpenClaw Agent binary for macOS
- TuriX automation skill
- Configuration files
- Auto-start script

### NAS Agent v1.0 (894KB)
- OpenClaw Agent binary for Linux
- Configuration files for Synology/QNAP/群晖
- Auto-start script

### VPS Server v1.0 (2.3KB)
- Auto-Retry skill for failed sub-agents
- Deployment documentation
- QUIC server configuration guide

## 🔧 System Requirements

**Mac:**
- macOS 10.15+ (Catalina or later)
- Network access to VPS QUIC server

**NAS:**
- Linux (x86_64 or ARM64)
- Synology DSM 6.0+ / QNAP QTS 4.0+ / 群晖
- Network access to VPS QUIC server

**VPS:**
- Linux (Ubuntu 20.04+ recommended)
- Public IP address
- Open port: 34061 (QUIC/UDP)

## 📖 Documentation

- [Mac Deployment Guide](mac-v1.0/README-mac.md)
- [NAS Deployment Guide](nas-v1.0/README-nas.md)
- [VPS Setup Guide](vps-v1.0/RELEASE.md)
- [Release Notes](RELEASE-NOTES.md)

## 🐛 Known Issues

- Heartbeat mechanism needs optimization
- QUIC server binary not included (manual setup required)
- Brave Search API requires manual registration

## 📝 Version History

### v1.0 (2026-03-03)
- Initial release
- Mac/NAS/VPS platform support
- TuriX and Auto-Retry skills included
- QUIC server configuration (port 34061)

## 🔗 Links

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Community Discord](https://discord.com/invite/clawd)

## 📄 License

See individual component licenses in each platform directory.
