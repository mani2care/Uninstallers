#!/bin/bash

# Get the current logged-in user
CURRENT_USER=$(id -un)
USER_HOME="/Users/$CURRENT_USER"

echo "Starting Zoom removal process for user: $CURRENT_USER"

# Define the Zoom app and package names
ZOOM_APP="/Applications/zoom.us.app"
ZOOM_PKG="us.zoom.pkg.videomeetings"
DESKTOP_SHORTCUT_PATH="/Users/Shared/Desktop/Zoom.us.app"

# Quit Zoom if running
if pgrep -x "zoom.us" >/dev/null; then
    echo "Closing Zoom..."
    pkill "zoom.us"
    sleep 3
fi

# Remove Zoom application
if [ -d "$ZOOM_APP" ]; then
    echo "Removing Zoom app..."
    rm -rf "$ZOOM_APP"
fi

# Remove Zoom desktop shortcut if it exists
if [ -f "$DESKTOP_SHORTCUT_PATH" ]; then
    echo "Removing Zoom desktop shortcut..."
    rm -f "$DESKTOP_SHORTCUT_PATH"
fi

# Forget Zoom package from receipts
if pkgutil --pkg-info "$ZOOM_PKG" >/dev/null 2>&1; then
    echo "Forgetting Zoom package..."
    pkgutil --forget "$ZOOM_PKG"
fi

# Remove Zoom-related files for the logged-in user
echo "Removing Zoom files for user: $CURRENT_USER"

USER_ZOOM_FILES=(
    "$USER_HOME/Library/Application Support/zoom.us"
    "$USER_HOME/Library/Caches/us.zoom.xos"
    "$USER_HOME/Library/Logs/zoom.us"
    "$USER_HOME/Library/Preferences/us.zoom.*"
    "$USER_HOME/Library/Preferences/ZoomChat.plist"
    "$USER_HOME/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin"
    "$USER_HOME/Library/Saved Application State/us.zoom.xos.savedState"
    "$USER_HOME/.zoomus"  # Additional potential Zoom directory
)

for file in "${USER_ZOOM_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "Removing: $file"
        rm -rf "$file"
    fi
done

# Remove system-wide Zoom files
echo "Removing system-wide Zoom files..."

SYSTEM_ZOOM_FILES=(
    "/Library/Application Support/zoom.us"
    "/Library/Caches/us.zoom.xos"
    "/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin"
    "/Library/Logs/zoom.us"
    "/Library/Preferences/us.zoom.*"
    "/Library/LaunchAgents/us.zoom.*"
    "/Library/LaunchDaemons/us.zoom.*"
)

for file in "${SYSTEM_ZOOM_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "Removing: $file"
        rm -rf "$file"
    fi
done

echo "Zoom has been successfully uninstalled."

exit 0
