#!/bin/bash
# Exit immediately if a command exits with a non-zero status, 
# treat unset variables as an error, and fail pipelines if any command fails.
set -euo pipefail

APP_NAME="patrol-screenshot"

DOWNLOAD_URL="https://raw.githubusercontent.com/Jaaco/patrol_screenshot_helper/main/bin/patrol_screenshot.dart"

# The directory where the executable will be installed.
# Allows users to override it like:
# curl ... | INSTALL_DIR=~/.local/bin bash
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Helper functions for logging
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fatal() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# 1. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
  fatal "curl is required to download $APP_NAME. Please install it first."
fi

# 2. Determine if we need sudo to write to the installation directory
SUDO=""
if [ ! -w "$INSTALL_DIR" ]; then
  # If the directory doesn't exist, check if we can write to its parent
  if [ ! -d "$INSTALL_DIR" ]; then
    PARENT_DIR="$(dirname "$INSTALL_DIR")"
    if [ ! -w "$PARENT_DIR" ]; then
      SUDO="sudo"
    fi
  else
    SUDO="sudo"
  fi
fi

if [ -n "$SUDO" ]; then
  info "Elevated permissions are required to install to $INSTALL_DIR."
  if ! command -v sudo >/dev/null 2>&1; then
    fatal "sudo is required to install to $INSTALL_DIR, but it is not installed."
  fi
  # Pre-authenticate sudo
  sudo -v || fatal "Failed to obtain sudo credentials."
fi

# 3. Create install directory if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
  info "Creating directory $INSTALL_DIR..."
  $SUDO mkdir -p "$INSTALL_DIR"
fi

# 4. Download the application
TMP_FILE="$(mktemp)"
info "Downloading $APP_NAME from $DOWNLOAD_URL..."

# Download silently (-s), fail on HTTP errors (-f), follow redirects (-L)
if ! curl -sfL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
  rm -f "$TMP_FILE"
  fatal "Failed to download $APP_NAME from $DOWNLOAD_URL. Please check the URL."
fi

# 5. Install the application
TARGET_PATH="$INSTALL_DIR/$APP_NAME"
info "Installing $APP_NAME to $TARGET_PATH..."

# Move the downloaded file and make it executable
$SUDO mv "$TMP_FILE" "$TARGET_PATH"
$SUDO chmod +x "$TARGET_PATH"

# 6. Verify Installation and PATH
if [ -x "$TARGET_PATH" ]; then
  info "Successfully installed $APP_NAME!"
else
  fatal "Installation failed. $TARGET_PATH is not executable."
fi

# Check if the installation directory is in the user's PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  warn "The directory $INSTALL_DIR is not in your PATH."
  warn "You may need to add it to your ~/.bashrc or ~/.zshrc file:"
  warn "  export PATH=\"\$PATH:$INSTALL_DIR\""
fi

echo ""
echo -e "${GREEN}$APP_NAME is ready to use!${NC}"
echo "Run '$APP_NAME --help' to get started."