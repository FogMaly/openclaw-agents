# Mac Remote Control Skill

Production-ready Mac remote control system for OpenClaw with monitoring, auto-restart, and Telegram alerts.

## Features

- 🎯 **Unified CLI** - Single command to control remote Mac
- 💓 **Health Monitoring** - Automatic checks every 5 minutes
- 🚨 **Telegram Alerts** - Instant notifications on failures
- 🔄 **Auto-Restart** - Watchdog system with smart retry logic
- 📝 **Log Management** - Automatic rotation and cleanup
- 📚 **Complete Documentation** - Operations manual included

## Quick Start

### Installation

```bash
# Install the skill
openclaw skills install mac-remote-control.skill

# Or manually extract
unzip mac-remote-control.skill -d ~/.openclaw/skills/
```

### Basic Usage

```bash
# Execute commands on Mac
/usr/local/bin/mac echo "hello"
/usr/local/bin/mac ls -la ~/Desktop

# Check health
/usr/local/bin/mac-health

# Monitor status
/usr/local/bin/mac-monitor
```

## Architecture

```
Linux Control Server (154.40.43.33:8080)
    ↓ WebSocket
Mac Agent (openclaw-agent)
    ↓ launchd
Watchdog (auto-restart)
    ↓
OpenClaw Gateway (Telegram bot)
```

## What's Included

### Scripts

- `mac` - Unified remote control CLI
- `mac-health` - Health check script
- `mac-monitor` - Monitoring with Telegram alerts
- `rotate-logs` - Automatic log rotation

### Documentation

- `SKILL.md` - Quick start guide and troubleshooting
- `references/ops-manual.md` - Complete operations manual (6700+ words)

## Key Features

### Automated Monitoring

- Runs every 5 minutes via cron
- Checks agent online status
- Verifies command execution
- Validates heartbeat freshness
- Sends Telegram alerts on failure

### Auto-Restart System

- launchd service for persistence
- Watchdog with smart retry (max 10 restarts per 10 minutes)
- Automatic failure logging
- Clean process management

### Log Management

- Daily rotation at 3 AM
- Size-based rotation (100MB threshold)
- 7-day retention
- Covers both Linux and Mac logs

## Requirements

- Linux control server with curl, jq, python3
- Mac with launchd support
- WebSocket connectivity between servers
- Telegram bot token (for alerts)

## Configuration

### Control Server

Edit scripts to set:
- `API_URL` - WebSocket server address
- `AGENT_ID` - Mac agent identifier
- `CONTROL_TOKEN` - Authentication token

### Telegram Alerts

Edit `mac-monitor` script:
- `TELEGRAM_BOT_TOKEN` - Your bot token
- `TELEGRAM_CHAT_ID` - Alert destination

## Troubleshooting

### Agent Not Online

```bash
# Check registration
curl -s http://154.40.43.33:8080/api/agents | jq

# Restart agent
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/com.jixiaoyi.openclaw-agent-watchdog'
```

### View Logs

```bash
# Linux logs
tail -100 /tmp/ws-server.log
cat /tmp/mac-monitor-alerts.log

# Mac logs
/usr/local/bin/mac tail -50 /Users/jixiaoyi/openclaw-agent/agent-watchdog.log
```

## Documentation

Full operations manual included in `references/ops-manual.md` covering:

- System architecture
- Health check procedures
- Restart commands
- Log locations
- Common issues and solutions
- Configuration file locations
- Backup and recovery
- Maintenance schedules

## Version

- **Version**: 1.0.0
- **Created**: 2026-03-09
- **Status**: Production Ready

## License

MIT

## Author

Created by OpenClaw Assistant for FogMaly
