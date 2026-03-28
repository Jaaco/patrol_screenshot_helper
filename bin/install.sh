#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$SCRIPT_DIR/patrol-screenshot"
LINK_DIR="${1:-/usr/local/bin}"
LINK="$LINK_DIR/patrol-screenshot"

if [[ ! -f "$CLI" ]]; then
  echo "Error: $CLI not found." >&2
  exit 1
fi

chmod +x "$CLI"

if [[ ! -d "$LINK_DIR" ]]; then
  echo "Error: $LINK_DIR does not exist." >&2
  exit 1
fi

if [[ -e "$LINK" || -L "$LINK" ]]; then
  echo "Removing existing $LINK"
  rm "$LINK"
fi

ln -s "$CLI" "$LINK"
echo "Installed: $LINK -> $CLI"
