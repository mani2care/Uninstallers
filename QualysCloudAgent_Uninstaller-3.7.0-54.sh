#!/bin/sh
BASE_DIRe=/Applications/QualysCloudAgent.app
if [ -d "$BASE_DIRe" ];then
echo "QualysCloudAgent found"
## This script may also be invoked from cloud-agent daemon
    #remove the plist file
      set -e
      echo "Uninstalling cloud agent"
      cd /
      pkgutil --forget com.qualys.cloud-agent
    # give command to stop the agent and then only delete the files
    # launchctl remove com.qualys.cloud.agent-restart
      launchctl remove com.qualys.cloud-agent
      sleep 3
      rm /Library/LaunchDaemons/com.qualys.cloud-agent.plist
      
BASE_DIR=/Applications/QualysCloudAgent.app/Contents/
APP_SUPPORT_DIR="/Library/Application Support/QualysCloudAgent/"
LOG_DIR=/var/log/qualys

# remove all App data under APP_SUPPORT_DIR. 
if [ -d "$APP_SUPPORT_DIR" ];then
   rm -rf "$APP_SUPPORT_DIR"
fi

#remove all files except hostid
find /Applications/QualysCloudAgent.app/ ! -name 'hostid' -type f -exec rm -f {} +

rm -rf /etc/qualys/.stage/

#remove all links
find /Applications/QualysCloudAgent.app/ -type l -exec rm -f {} +

#find empty directories under install folders and delete them
find /Applications/QualysCloudAgent.app -empty -type d -delete || true

if [ ! -d "$BASE_DIR" ];then
   rm -rf /Applications/QualysCloudAgent.app
fi

if [ -d "$LOG_DIR" ]; then
   rm -rf $LOG_DIR
fi
else
   echo "QualysCloudAgent Not found"
fi
exit 
