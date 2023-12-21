#!/bin/sh
#sudo sh /Applications/Zscaler/.Uninstaller.sh abbpilot
function removeZscaler () {
PWord=`echo 'abbpilot' | base64 --decode`
/bin/sh /Applications/Zscaler/.Uninstaller.sh $PWord
echo "Successfully uninstalled"
}

	#Is Zscaler installed
	if [ -f "/Applications/Zscaler/Zscaler.app/Contents/Info.plist" ]; then
		echo "Still not uninstalled and re-trying"
		# Stop Service
		sudo launchctl unload /Library/LaunchDaemons/com.zscaler.service.plist
		sudo killall Zscaler

		removeZscaler
		sleep 2

		# Remove Application Files
		sudo rm -rf /Applications/Zscaler

		# Remove Launch Agent
		sudo rm -rf /Library/LaunchAgents/com.zscaler.tray.plist

		# Remove Launch Daemons
		sudo rm -rf /Library/LaunchDaemons/com.zscaler.service.plist
		sudo rm -rf /Library/LaunchDaemons/com.zscaler.tunnel.plist

		# Remove root PLIST
		sudo rm -rf /private/var/root/Library/Preferences/ZscalerService.plist
	else
		echo "Not_Installed"
	fi