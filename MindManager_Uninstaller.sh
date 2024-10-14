#!/bin/bash

# Check if MindManager is installed
if [ ! -d "/Applications/MindManager.app" ]; then
  echo "MindManager is not installed."
fi

# Get the current user's username
USERNAME=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Check if MindManager is running and kill the process if it is
if pgrep -x "MindManager" > /dev/null; then
  echo "MindManager is running. Attempting to kill the process..."
  pkill -x "MindManager"
  echo "MindManager has been stopped."
else
  echo "MindManager is not running."
fi

# Uninstall MindManager
echo "Uninstalling MindManager files..."
sudo rm -rf "/Applications/MindManager.app"
sudo rm -rf /Users/$USERNAME/Library/Preferences/com.mindjet.mindmanager*
sudo rm -rf /Users/$USERNAME/Library/Application\ Support/MindManager
sudo rm -rf /Users/$USERNAME/Library/Application\ Support/Mindjet
sudo rm -rf /Users/$USERNAME/Library/Application\ Scripts/com.mindjet.mindmanager*
sudo rm -rf /Users/$USERNAME/Library/WebKit/com.mindjet.mindmanager*
sudo rm -rf /Users/$USERNAME/Library/HTTPStorages/com.mindjet.mindmanager*
sudo rm -rf /Users/$USERNAME/Library/Preferences/ByHost/com.mindjet.mindmanager*

echo "MindManager has been successfully uninstalled."

exit 0
