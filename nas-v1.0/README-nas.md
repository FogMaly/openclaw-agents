# OpenClaw Agent (NAS Version)

## Overview
This package provides a NAS-oriented profile for storage and backup operations.

## Files
- `target/release/openclaw-agent`: agent binary
- `config/nas-profile.json`: NAS profile
- `start-nas.sh`: startup script

## Quick Start
1. Build binary:
   ```bash
   cargo build --release
   ```
2. Start agent:
   ```bash
   ./start-nas.sh
   ```

## Runtime Config
The startup script auto-creates `~/.openclaw-agent/config.json` if it does not exist.

Update before production use:
- `server_addr`
- `server_name`
- `token`
- `agent_id`

## Profile
`config/nas-profile.json` defines:
- Features: file storage and backup enabled, code execution disabled
- Limits: lower CPU/memory thresholds and disk usage cap
- Whitelist: NAS-safe commands and storage paths

## Security Notes
- Keep command whitelist restricted to backup/storage tooling.
- Ensure mounted paths (`/mnt/storage`, `/backup`) have correct permissions.
- Run under a dedicated low-privilege service account when possible.
