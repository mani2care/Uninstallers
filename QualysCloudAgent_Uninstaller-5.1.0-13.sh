#!/bin/sh

## This script may also be invoked from cloud-agent daemon
set -e
echo "Uninstalling cloud agent"

cd /

pkgutil --forget com.qualys.cloud-agent || true
# give command to stop the agent and then only delete the files
# launchctl remove com.qualys.cloud.agent-restart
launchctl remove com.qualys.cloud-agent || true

sleep 3

# Unload launch daemon

LAUNCH_AGENT_ID="com.qualys.cloud-agent.gui"
AGENT_PROCESS="${BASE_DIR}/MacOS/QualysCloudAgent"

unload_for_user() {
    bundle_id="$1"
    userid="$2"
    user="$3"

    /bin/launchctl bootout "gui/$userid" "/Library/LaunchAgents/$bundle_id.plist" 1>/dev/null 2>&1 || true
}

uninstall_launchagent() {
    for user in $(/usr/bin/who | grep "console" | cut -d' ' -f1); do
        userid=$(/usr/bin/id -u "$user")
        if [ "$userid" -lt 500 ]; then
            continue
        fi
        unload_for_user "${LAUNCH_AGENT_ID}" "$userid" "$user"
    done
    
    /bin/rm -f "/Library/LaunchAgents/${LAUNCH_AGENT_ID}.plist" 1>/dev/null 2>&1 || true
}

if [ -f "/Library/LaunchAgents/$LAUNCH_AGENT_ID.plist" ]; then
    uninstall_launchagent
fi
pkill -SIGKILL -f "${AGENT_PROCESS}" 1>/dev/null 2>&1 || true

if [ -f "/Library/Qualys/AVP/product/bin/UninstallTool" ]; then
    # Uninstall Bit Defender.
    echo "Uninstalling Qualys EPP"
    sudo /Library/Qualys/AVP/product/bin/UninstallTool 1>/dev/null 2>&1 || true
fi

pkgutil --forget com.qualys.qualys-epp || true

# kill Epp process if running
sudo pkill -SIGKILL -f "${BASE_DIR}/MacOS/qualys-epp" 1>/dev/null 2>&1 || true

# remove the plist file
rm /Library/LaunchDaemons/com.qualys.cloud-agent.plist || true

BASE_DIR=/Applications/QualysCloudAgent.app/Contents/
APP_SUPPORT_DIR="/Library/Application Support/QualysCloudAgent/"
LOG_DIR=/var/log/qualys

# kill Pm process if running
pkill -SIGKILL -f "${BASE_DIR}/MacOS/qualys-patchmgmt-tool" 1>/dev/null 2>&1 || true

# remove all App data under APP_SUPPORT_DIR. 
if [ -d "$APP_SUPPORT_DIR" ];then
   rm -rf "$APP_SUPPORT_DIR" || true
fi

#remove all files except hostid
find /Applications/QualysCloudAgent.app/ ! -name 'hostid' -type f -exec rm -f {} +

rm -rf /etc/qualys/.stage/ || true

#remove qualys spool dir
rm -rf /var/spool/qualys/ || true

#remove all links
find /Applications/QualysCloudAgent.app/ -type l -exec rm -f {} +

#find empty directories under install folders and delete them
find /Applications/QualysCloudAgent.app -empty -type d -delete || true

if [ ! -d "$BASE_DIR" ];then
   rm -rf /Applications/QualysCloudAgent.app || true
fi

if [ -d "$LOG_DIR" ]; then
   rm -rf $LOG_DIR || true
fi
