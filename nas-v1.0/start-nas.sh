#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$SCRIPT_DIR/target/release/openclaw-agent"
PROFILE="$SCRIPT_DIR/config/nas-profile.json"
RUNTIME_DIR="${OC_CONFIG_DIR:-$HOME/.openclaw-agent}"
RUNTIME_CONFIG="$RUNTIME_DIR/config.json"

if [ ! -x "$BINARY" ]; then
  echo "Error: binary not found at $BINARY"
  echo "Build first: cargo build --release"
  exit 1
fi

if [ ! -f "$PROFILE" ]; then
  echo "Error: profile not found at $PROFILE"
  exit 1
fi

mkdir -p "$RUNTIME_DIR"

if [ ! -f "$RUNTIME_CONFIG" ]; then
  cat > "$RUNTIME_CONFIG" <<'JSON'
{
  "server_addr": "127.0.0.1:4433",
  "server_name": "localhost",
  "ca_cert_path": "ca.pem",
  "agent_id": "nas-agent-001",
  "token": "change-me",
  "heartbeat_secs": 30,
  "reconnect_max_secs": 45,
  "command_whitelist": ["rsync", "tar", "zip"],
  "file_path_whitelist": ["/mnt/storage", "/backup"]
}
JSON
fi

echo "Starting OpenClaw NAS Agent"
echo "- binary: $BINARY"
echo "- profile: $PROFILE"
echo "- runtime config: $RUNTIME_CONFIG"

echo "Note: NAS profile disables generic code execution."

exec "$BINARY"
