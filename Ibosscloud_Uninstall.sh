#!/bin/bash

# **********************************************************************
# * Created Manikandan (mani2care) 1-Dec-2022
# * Filename:    iboss cloud uninstall.sh
# *
# * Description:
# *
# * Notes:
# *
# *
# *
# *
# * Copyright (c) 2021 iboss, Inc. All rights reserved.
# * This software may not be published, distributed or reproduced in any
# * manner for any purpose without the express written consent of
# * iboss, Inc.
# **********************************************************************/

UUID=`uuidgen`
USER=`stat -f "%Su" /dev/console`
ID=`id -u $USER`

OLD_AGENT="/Applications/Utilities/iboss.app/gen4agent"
RECONFIGURE="/Applications/Utilities/iboss.app/gen4agent/reconfigure.sh"

AGENTS=/Library/LaunchAgents/com.iboss.macos.plist
DAEMONS=/Library/LaunchDaemons/com.iboss.macos.plist
OSX="/Applications/iboss/iboss\\ cloud\\ connector\\ service.app"
UI="/Applications/iboss/iboss\\ cloud\\ connector\\ ui.app"
CLI="/Applications/iboss/iboss\\ cloud\\ connector\\ cli.app"

OSX_OLD=/Applications/ibossCloudTunnelClientOSX.app
UI_OLD=/Applications/ibossCloudTunnelClientUI.app
CLI_OLD=/Applications/ibossCloudTunnelClientCLI.app

CLI_COMMAND="/Applications/iboss/iboss\ cloud\ connector\ cli.app/Contents/MacOS/iboss\ cloud\ connector\ cli"

sudo /bin/launchctl bootout gui/$ID /Library/LaunchAgents/com.iboss.macos.ui.plist &> /dev/null
sudo /bin/launchctl bootout system/com.iboss.macos.plist &> /dev/null
sudo /bin/launchctl bootout system/com.iboss.startup.plist &> /dev/null

eval sudo ${CLI_COMMAND} stop &> /dev/null

sudo rm -rf /Library/LaunchAgents/com.iboss.macos.plist 
sudo rm -rf /Library/LaunchDaemons/com.iboss.macos.plist
sudo rm -rf /Library/LaunchDaemons/com.iboss.startup.plist
sudo rm -rf /Library/LaunchAgents/com.iboss.macos.ui.plist

# remove agent
eval sudo ${CLI_COMMAND} remove &> /dev/null
eval sudo ${CLI_COMMAND} clearcache &> /dev/null

eval sudo mv ${OSX_OLD}  ~/.Trash/ibossCloudTunnelClientOSX-${UUID}.app &> /dev/null
eval sudo mv ${UI_OLD}  ~/.Trash/ibossCloudTunnelClientUI-${UUID}.app &> /dev/null
eval sudo mv ${CLI_OLD}  ~/.Trash/ibossCloudTunnelClientCLI-${UUID}.app &> /dev/null

eval sudo mv -f ${OSX}  ~"/.Trash/iboss\\ cloud\\ connector\\ service-${UUID}.app" &> /dev/null
eval sudo mv -f ${UI}  ~"/.Trash/iboss\\ cloud\\ connector\\ ui-${UUID}.app" &> /dev/null
eval sudo mv -f ${CLI}  ~"/.Trash/iboss\\ cloud\\ connector\\ cli-${UUID}.app" &> /dev/null
eval sudo mv "/Applications/iboss/*"  ~/.Trash/ &> /dev/null
eval sudo rm -rf "/Applications/iboss" &> /dev/null


if [ -d "$OLD_AGENT" ]; then
        eval sudo ${RECONFIGURE} unload &> /dev/null
fi

sudo pkgutil --forget com.iboss.ibossCloudTunnelForIOSEnterprise &> /dev/null

# Remove firefox related files.
sudo chflags nouchg /Applications/Firefox.app/Contents/Resources/iboss.cfg &> /dev/null
sudo chflags nouchg /Applications/Firefox.app/Contents/Resources/defaults/pref/firefox_iboss.js &> /dev/null
sudo rm -rf /Applications/Firefox.app/Contents/Resources/iboss.cfg &> /dev/null
sudo rm -rf /Applications/Firefox.app/Contents/Resources/defaults/pref/firefox_iboss.js &> /dev/null
pkill -f firefox &> /dev/null

exit 0
