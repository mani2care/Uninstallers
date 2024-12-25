#!/bin/bash

# Logging function
log() {
    echo "$(date) [INFO] $1"
}

# Uninstall Visual Studio Code and its components
log "Starting the uninstallation of Visual Studio Code and its components."

# Remove the Visual Studio Code application
if [ -d "/Applications/Visual Studio Code.app" ]; then
    log "Removing Visual Studio Code application."
    rm -rf "/Applications/Visual Studio Code.app"
else
    log "Visual Studio Code application not found. Skipping."
fi

# Remove user configuration and data
log "Removing user configurations and data."
rm -rf ~/Library/Application\ Support/Code
rm -rf ~/Library/Caches/com.microsoft.VSCode
rm -rf ~/Library/Caches/com.microsoft.VSCode.ShipIt
rm -rf ~/Library/Preferences/com.microsoft.VSCode.plist
rm -rf ~/Library/Saved\ Application\ State/com.microsoft.VSCode.savedState
rm -rf ~/.vscode

# Remove system-wide configurations if present
log "Checking for system-wide configurations."
sudo rm -rf /Library/Application\ Support/Code
sudo rm -rf /Library/Caches/com.microsoft.VSCode
sudo rm -rf /Library/Preferences/com.microsoft.VSCode.plist

log "Uninstallation of Visual Studio Code completed."

# Download and install the latest version of Visual Studio Code
log "Downloading the latest version of Visual Studio Code."

# Define download URL
DOWNLOAD_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
TEMP_FILE="/tmp/VSCode-darwin-universal.zip"

# Download the installer
log "Downloading Visual Studio Code from: $DOWNLOAD_URL"
curl -L -o "$TEMP_FILE" "$DOWNLOAD_URL"

if [ $? -eq 0 ]; then
    log "Download completed successfully."
else
    log "Failed to download Visual Studio Code. Exiting."
    exit 1
fi

# Extract and install
log "Installing Visual Studio Code."
unzip -q "$TEMP_FILE" -d /Applications

if [ $? -eq 0 ]; then
    log "Visual Studio Code installed successfully."
else
    log "Failed to install Visual Studio Code. Exiting."
    exit 1
fi

# Clean up
log "Cleaning up temporary files."
rm -f "$TEMP_FILE"

log "Visual Studio Code installation process completed."

exit 0
