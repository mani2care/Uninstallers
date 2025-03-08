#!/bin/sh
# shellcheck disable=SC2039
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

APP_BUNDLE_PATH="/Applications/Personal Print Manager.app"
APP_SUPPORT_DIR_PATH="/Library/Application Support/LRS/Personal Print Manager"
COMMON_APP_DATA_PATH="/Library/Preferences/LRS/Personal Print Manager"
SYSTEM_SERVICE_LOGS_PATH="/Library/Logs/LRS/Personal Print Manager"

KEEPALIVE_FILE_PATH="$COMMON_APP_DATA_PATH/.keepalive"
SERVICE_EXEC_PATH="$APP_BUNDLE_PATH/Contents/MacOS/Service/LRS.PersonalPrint.Service"

CLEANUP_DAEMON_NAME="com.lrs.personalprint.manager.cleanup"
CLEANUP_PLIST_PATH="/Library/LaunchDaemons/com.lrs.personalprint.manager.cleanup.plist"
SYSTEM_SERVICE_PLIST_PATH="/Library/LaunchDaemons/com.lrs.personalprint.system.service.plist"
USER_SERVICE_PLIST_PATH="/Library/LaunchAgents/com.lrs.personalprint.user.service.plist"

PKG_NAME="com.lrs.personal.print.manager"

echo "Starting uninstallation of Personal Print Manager..."

# Remove the application bundle
if [ -d "$APP_BUNDLE_PATH" ]; then
    echo "Removing application bundle: $APP_BUNDLE_PATH"
    rm -rf "$APP_BUNDLE_PATH"
else
    echo "Application bundle not found: $APP_BUNDLE_PATH"
fi

# Remove the keepalive file
if [ -f "$KEEPALIVE_FILE_PATH" ]; then
    echo "Removing keepalive file: $KEEPALIVE_FILE_PATH"
    rm -f "$KEEPALIVE_FILE_PATH"
else
    echo "Keepalive file not found: $KEEPALIVE_FILE_PATH"
fi

# Notify system service about uninstallation
if [ -x "$SERVICE_EXEC_PATH" ]; then
    echo "Notifying system service about uninstallation..."
    "$SERVICE_EXEC_PATH" system uninstall
else
    echo "PersonalPrint service executable not found: $SERVICE_EXEC_PATH"
fi

# Wait for user service instances to shut down
echo "Waiting for user service instances to shut down if exist..."
waitingCount=0
while ps aux | grep '/LRS.PersonalPrint.Service user service' | grep -v grep >/dev/null && [ $waitingCount -lt 100 ]; do
    waitingCount=$((waitingCount+1))
    sleep 0.1
done

# Terminate any running instances of the manager UI
pkill -x "Personal Print Manager"

# Unload and remove the user service
if [ -f "$USER_SERVICE_PLIST_PATH" ]; then
    echo "Unloading and removing user service: $USER_SERVICE_PLIST_PATH"
    who | awk '/console/{print $1}' | sort -u | while read -r USERNAME; do
        launchctl asuser "$(id -u "$USERNAME")" launchctl unload "$USER_SERVICE_PLIST_PATH"
    done
    rm -f "$USER_SERVICE_PLIST_PATH"
else
    echo "User service plist not found: $USER_SERVICE_PLIST_PATH"
fi

# Unload and remove the system service
if [ -f "$SYSTEM_SERVICE_PLIST_PATH" ]; then
    echo "Unloading and removing system service: $SYSTEM_SERVICE_PLIST_PATH"
    launchctl unload "$SYSTEM_SERVICE_PLIST_PATH"
    rm -f "$SYSTEM_SERVICE_PLIST_PATH"
else
    echo "System service plist not found: $SYSTEM_SERVICE_PLIST_PATH"
fi

# Wait for any remaining service instances to terminate
echo "Waiting for any remaining service instances to terminate..."
waitingCount=0
while ps aux | grep '/LRS.PersonalPrint.Service' | grep -v grep >/dev/null && [ $waitingCount -lt 100 ]; do
    waitingCount=$((waitingCount+1))
    sleep 0.1
done

# Forcefully terminate any remaining instances
pkill -9 -x "Personal Print Manager"
pkill -9 -x "LRS.PersonalPrint.Service"

# Remove Preferences
if [ -d "$COMMON_APP_DATA_PATH" ]; then
    echo "Removing Preferences Manager files: $COMMON_APP_DATA_PATH"
    rm -rf "$COMMON_APP_DATA_PATH"
else
    echo "Preferences Manager not found: $COMMON_APP_DATA_PATH"
fi

# Remove Logs
if [ -d "$SYSTEM_SERVICE_LOGS_PATH" ]; then
    echo "Removing log files: $SYSTEM_SERVICE_LOGS_PATH"
    rm -rf "$SYSTEM_SERVICE_LOGS_PATH"
else
    echo "Log files not found: $SYSTEM_SERVICE_LOGS_PATH"
fi

# Forget the package installation
echo "Forgetting package installation: $PKG_NAME"
if pkgutil --pkgs | grep -q "$PKG_NAME"; then
    pkgutil --forget "$PKG_NAME"
else
    echo "Package not found: $PKG_NAME"
fi

# Cleanup the application support directory
if [ -d "$APP_SUPPORT_DIR_PATH" ]; then
    echo "Removing application support directory: $APP_SUPPORT_DIR_PATH"
    rm -rf "$APP_SUPPORT_DIR_PATH"
else
    echo "Application support directory not found: $APP_SUPPORT_DIR_PATH"
fi

# Remove the cleanup launch daemon
if [ -f "$CLEANUP_PLIST_PATH" ]; then
    echo "Unloading and removing cleanup launch daemon: $CLEANUP_PLIST_PATH"
    launchctl remove "$CLEANUP_DAEMON_NAME"
    rm -f "$CLEANUP_PLIST_PATH"
else
    echo "Cleanup launch daemon plist not found: $CLEANUP_PLIST_PATH"
fi

rm -rf /Users/Shared/Personal_Print_Manager_*
echo "Uninstallation completed successfully."
exit 0
