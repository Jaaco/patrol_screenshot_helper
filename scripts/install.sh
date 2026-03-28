#!/bin/bash
set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

APP_NAME="patrol-screenshot"
APP_NAME_UI="patrol-screenshot-ui"
REPO_URL="https://github.com/Jaaco/patrol_screenshot_helper.git"

# Where the source code will live on the user's machine
SOURCE_DIR="$HOME/.patrol_screenshot_helper"

# Where the global shortcut command will be created
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# ==============================================================================
# INSTALLATION LOGIC
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fatal() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# 1. Check dependencies
if ! command -v git >/dev/null 2>&1; then
  fatal "'git' is required but not installed."
fi

if ! command -v dart >/dev/null 2>&1; then
  fatal "'dart' is required but not installed. Please install the Dart SDK."
fi

# 2. Determine sudo requirements for the shortcut
SUDO=""
if [ ! -w "$INSTALL_DIR" ]; then
  SUDO="sudo"
  info "Elevated permissions required to create shortcut in $INSTALL_DIR."
  $SUDO -v || fatal "Failed to obtain sudo credentials."
fi

# 3. Download / Update the source code
if [ -d "$SOURCE_DIR" ]; then
  info "Updating existing repository in $SOURCE_DIR..."
  cd "$SOURCE_DIR"
  git pull origin main --quiet || git pull origin master --quiet
else
  info "Cloning repository to $SOURCE_DIR..."
  git clone "$REPO_URL" "$SOURCE_DIR" --quiet
fi

# 4. Fetch Dart dependencies
info "Fetching Dart dependencies..."
cd "$SOURCE_DIR"
dart pub get

# 5. Create the global shortcut wrapper
SHORTCUT_PATH="$INSTALL_DIR/$APP_NAME"
info "Creating global shortcut at $SHORTCUT_PATH..."

# We create a bash wrapper that calls the dart script. 
# This is safer than symlinking, as it ensures 'dart' executes it correctly 
# regardless of where the user's current working directory is.

# Create a temporary file for the wrapper
TMP_WRAPPER="$(mktemp)"
cat << 'EOF' > "$TMP_WRAPPER"
#!/bin/bash
# Wrapper for patrol-screenshot
EOF

# Append the execution command pointing to the cloned repo
echo "dart \"$SOURCE_DIR/bin/patrol_screenshot.dart\" \"\$@\"" >> "$TMP_WRAPPER"

# Move wrapper to destination and make it executable
if [ ! -d "$INSTALL_DIR" ]; then
  $SUDO mkdir -p "$INSTALL_DIR"
fi

$SUDO mv "$TMP_WRAPPER" "$SHORTCUT_PATH"
$SUDO chmod +x "$SHORTCUT_PATH"

# 6. Create the UI shortcut wrapper
SHORTCUT_PATH_UI="$INSTALL_DIR/$APP_NAME_UI"
info "Creating global shortcut at $SHORTCUT_PATH_UI..."

TMP_WRAPPER_UI="$(mktemp)"
cat << 'EOF' > "$TMP_WRAPPER_UI"
#!/bin/bash
# Wrapper for patrol-screenshot-ui
EOF

echo "dart \"$SOURCE_DIR/bin/patrol_screenshot_ui.dart\" \"\$@\"" >> "$TMP_WRAPPER_UI"

$SUDO mv "$TMP_WRAPPER_UI" "$SHORTCUT_PATH_UI"
$SUDO chmod +x "$SHORTCUT_PATH_UI"

info "Successfully installed $APP_NAME and $APP_NAME_UI!"
echo ""
echo -e "${GREEN}You can now use the commands from anywhere:${NC}"
echo "  $APP_NAME --help"
echo "  $APP_NAME_UI"