---
name: mac-remote-control
description: "Remote control and monitor Mac machines via WebSocket agent. Use when: (1) executing commands on remote Mac, (2) checking Mac agent health, (3) troubleshooting agent connectivity, (4) managing Mac services remotely, (5) viewing Mac logs, (6) restarting Mac services. Provides unified CLI, health monitoring, and production-ready watchdog system."
---

# Mac Remote Control

Remote control Mac machines through a WebSocket-based agent system with automatic failover, monitoring, and logging.

## Quick Start

### Execute commands on Mac

```bash
/usr/local/bin/mac <command> [args...]
```

Examples:
```bash
/usr/local/bin/mac echo "hello"
/usr/local/bin/mac ls -la ~/Desktop
/usr/local/bin/mac bash -c 'cd ~/project && git status'
```

### Check health

```bash
/usr/local/bin/mac-health
```

### Monitor status

```bash
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

## Core Commands

### Remote Execution

The `mac` command provides unified access to the remote Mac:

```bash
# Simple commands
/usr/local/bin/mac pwd
/usr/local/bin/mac whoami

# Complex commands (use bash -c)
/usr/local/bin/mac bash -c 'for i in {1..3}; do echo $i; done'

# File operations
/usr/local/bin/mac cat ~/.openclaw/openclaw.json
/usr/local/bin/mac ls -la /Users/jixiaoyi/openclaw-agent/
```

### Health Check

```bash
/usr/local/bin/mac-health
```

Shows:
- Controller heartbeat status
- Live execution test
- Agent online status

### Monitoring

```bash
/usr/local/bin/mac-monitor
```

Checks:
- Agent registration
- Command execution
- Heartbeat freshness (< 2 minutes)
- Sends Telegram alerts on failure

## Troubleshooting

### Agent not online

**Symptoms**: `❌ 错误: Agent not online`

**Check registration**:
```bash
curl -s http://154.40.43.33:8080/api/agents | jq
```

**Restart agent**:
```bash
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/com.jixiaoyi.openclaw-agent-watchdog'
```

### Agent registered but exec fails

**Cause**: Agent reconnected without sending hello message

**Fix**: Restart controller to force re-registration
```bash
pkill -f '/root/openclaw-ws-server/server.js'
sleep 6
curl -s http://154.40.43.33:8080/api/agents | jq
```

### OpenClaw bot not responding

**Check Gateway**:
```bash
/usr/local/bin/mac bash -c 'ps aux | grep openclaw-gateway | grep -v grep'
```

**Restart Gateway**:
```bash
/usr/local/bin/mac bash -c 'launchctl kickstart -k gui/$(id -u)/ai.openclaw.gateway'
```

**Clear sessions** (if context full):
```bash
/usr/local/bin/mac bash -c 'rm -f ~/.openclaw/agents/main/sessions/*.jsonl && echo "{}" > ~/.openclaw/agents/main/sessions/sessions.json'
```

## Log Locations

### Linux Control Server

- Controller: `/tmp/ws-server.log`
- Monitor alerts: `/tmp/mac-monitor-alerts.log`
- Log rotation: `/tmp/rotate-logs.log`

### Mac Agent

- Watchdog: `~/openclaw-agent/agent-watchdog.log`
- Failures: `~/openclaw-agent/agent-failure.log`
- launchd stdout: `~/openclaw-agent/launchd-watchdog.out.log`
- launchd stderr: `~/openclaw-agent/launchd-watchdog.err.log`

View Mac logs:
```bash
/usr/local/bin/mac tail -50 /Users/jixiaoyi/openclaw-agent/agent-watchdog.log
```

## Configuration

### Mac Agent Config

Location: `~/openclaw-agent/config.json`

Key fields:
- `agent_id`: Must be `"mac"`
- `server_addr`: `"154.40.43.33:8080"`
- `token`: Agent authentication token
- `command_whitelist`: Allowed commands
- `file_path_whitelist`: Allowed paths

### OpenClaw Config

Location: `~/.openclaw/openclaw.json`

Key sections:
- `models.providers.cpamc`: Model provider config
- `agents.list[0]`: Main agent config (Telegram bot)

## Automated Systems

### Monitoring (every 5 minutes)

Cron: `*/5 * * * * /usr/local/bin/mac-monitor`

Checks agent health and sends Telegram alerts on failure.

### Log Rotation (daily 3 AM)

Cron: `0 3 * * * /usr/local/bin/rotate-logs`

Rotates logs when > 100MB, keeps 7 days.

### Watchdog (continuous)

launchd service: `com.jixiaoyi.openclaw-agent-watchdog`

- Auto-restarts agent on exit
- Max 10 restarts per 10 minutes
- Logs failures to `agent-failure.log`

## Reference Documentation

For detailed operations guide, see [references/ops-manual.md](references/ops-manual.md).

For script implementations, see [scripts/](scripts/).

## Key Metrics

**Normal operation**:
- Heartbeat interval: < 30 seconds
- Command response: < 2 seconds
- Monitor success rate: > 95%

**Alert thresholds**:
- Heartbeat > 2 minutes: immediate alert
- 3 consecutive monitor failures: immediate alert
- Watchdog restart limit reached: immediate alert + stop
