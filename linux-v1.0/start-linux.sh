#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$SCRIPT_DIR/openclaw-agent"
CONFIG="$HOME/.openclaw-agent/config.json"

echo "🚀 Starting OpenClaw Linux Agent"
echo "   - Binary: $BINARY"
echo "   - Config: $CONFIG"
echo ""

# Export config path
export OC_CONFIG_FILE="$CONFIG"

# Run agent
exec "$BINARY"
