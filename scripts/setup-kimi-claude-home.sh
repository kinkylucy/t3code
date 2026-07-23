#!/bin/bash
# Setup a dedicated Claude Code home for T3 Code that routes through CLIProxyAPI to Kimi K3.
# This avoids polluting your normal Claude account/configuration.
#
# Usage:
#   scripts/setup-kimi-claude-home.sh
#
# Then in T3 Code Settings add a Claude provider:
#   Display name:   Claude → Kimi K3
#   Binary path:    claude
#   Claude HOME:    ~/.claude_kimi_proxy
#   Environment variables:
#     ANTHROPIC_API_KEY   <your-cliproxy-api-key>
#     ANTHROPIC_BASE_URL  http://127.0.0.1:8317

set -euo pipefail

PROXY_HOST="${CLIPROXY_HOST:-127.0.0.1}"
PROXY_PORT="${CLIPROXY_PORT:-8317}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude_kimi_proxy}"
API_KEY="${CLIPROXY_API_KEY:-cliproxy-local-key}"
MODEL="${CLAUDE_MODEL:-kimi-k3}"

echo "Creating dedicated Claude home: $CLAUDE_HOME"
mkdir -p "$CLAUDE_HOME"

cat > "$CLAUDE_HOME/settings.json" <<EOF
{
  "env": {
    "ANTHROPIC_API_KEY": "$API_KEY",
    "ANTHROPIC_BASE_URL": "http://$PROXY_HOST:$PROXY_PORT"
  },
  "model": "$MODEL"
}
EOF

echo "Wrote $CLAUDE_HOME/settings.json"
echo ""
echo "Next steps:"
echo "  1. Make sure CLIProxyAPI is running on http://$PROXY_HOST:$PROXY_PORT"
echo "  2. In T3 Code Settings, add a Claude provider with:"
echo "       Binary path:    claude"
echo "       Claude HOME:    $CLAUDE_HOME"
echo "  3. Optional: set provider env vars in T3 Code too:"
echo "       ANTHROPIC_API_KEY=$API_KEY"
echo "       ANTHROPIC_BASE_URL=http://$PROXY_HOST:$PROXY_PORT"
