#!/bin/bash

# Check if MindManager is installed
if [ ! -d "/Applications/MindManager.app" ]; then
  echo "MindManager is not installed."
fi

# Get the current user's username
USERNAME=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Uninstall MindManager
echo "Uninstalling MindManager files..."
sudo rm -rf "/Applications/MindManager.app"
sudo rm -rf "/Users/$USERNAME/Library/Preferences/com.mindjet.mindmanager*"
sudo rm -rf "/Users/$USERNAME/Library/Application Support/MindManager"
sudo rm -rf "/Users/$USERNAME/Library/Application Support/Mindjet"
sudo rm -rf "/Users/$USERNAME/Library/WebKit/com.mindjet.mindmanager.23"
sudo rm -rf "/Users/$USERNAME/Library/HTTPStorages/com.mindjet.mindmanager.23"
sudo rm -rf "/Users/$USERNAME/Library/HTTPStorages/com.mindjet.mindmanager.23.binarycookies"
echo "MindManager has been successfully uninstalled."

exit 0