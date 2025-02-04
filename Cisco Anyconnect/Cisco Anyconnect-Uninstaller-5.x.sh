#!/bin/bash
​
# Uninstalls Cisco Secure Client
​
# run the Cisco-provided uninstallers if available
​
if [[ -x /opt/cisco/secureclient/bin/cisco_secure_client_uninstall.sh ]]; then
	/opt/cisco/secureclient/bin/cisco_secure_client_uninstall.sh
fi
​
if [[ -x /opt/cisco/secureclient/bin/dart_uninstall.sh ]]; then
	/opt/cisco/secureclient/bin/dart_uninstall.sh
fi
​
# unload the Cisco launchagents for the current user
​
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
if [[ -n "$currentUser" && "$currentUser" != "root" ]]; then
    allLaunchAgents=$(/usr/bin/sudo -u "$currentUser" /bin/launchctl list | awk '/com.cisco.anyconnect|com.cisco.secureclient/{print $3}')
    for aLaunchAgent in ${allLaunchAgents}; do
	   /bin/launchctl bootout gui/$(/usr/bin/id -u "$currentUser") "$aLaunchAgent" >/dev/null 2>&1
    done
fi
​
# unload the Cisco launchdaemons
​
allLaunchDaemons=$(/bin/launchctl list | awk '/com.cisco.anyconnect|com.cisco.secureclient/{print $3}')
​
for aLaunchDaemon in ${allLaunchDaemons}; do
	/bin/launchctl bootout system "$aLaunchDaemon" >/dev/null 2>&1
done
​
# Deactivate and uninstall the network system extension
​
ACSOCKEXTACTIVE=$(/usr/bin/systemextensionsctl list | grep acsockext)
​
if [[ -n $(echo "$ACSOCKEXTACTIVE" | grep "terminated") ]]; then
  echo "Network system extension unloaded."
else
  "/Applications/Cisco/Cisco Secure Client - Socket Filter.app/Contents/MacOS/Cisco Secure Client - Socket Filter" -deactivateExt
fi
​
# kill all running allProcesses
allProcesses=$(/bin/ps ax | /usr/bin/grep "[/]Applications/Cisco/Cisco Secure Client" | /usr/bin/awk '{ print $1 }')
for aProcess in ${allProcesses}; do
	kill -9 "$aProcess"
done
​
/bin/rm -rf /opt/cisco/anyconnect \
			/opt/cisco/hostscan \
			/opt/cisco/secureclient \
			"/Applications/Cisco/Cisco Secure Client - DART.app" \
			"/Applications/Cisco/Cisco Secure Client.app" \
			"/Applications/Cisco/Uninstall Cisco Secure Client.app" \
			"/Applications/Cisco/Uninstall Cisco Secure Client - DART.app" \
			/Library/LaunchAgents/com.cisco.anyconnect.* \
			/Library/LaunchAgents/com.cisco.secureclient.* \
			/Library/LaunchDaemons/com.cisco.anyconnect.* \
			/Library/LaunchDaemons/com.cisco.secureclient.*
			
# remove the Cisco folder from Applications if empty		
if [[ -z "$(/bin/ls -A /Applications/Cisco 2>/dev/null | /usr/bin/grep -v .DS_Store)" ]]; then
	/bin/rm -rf /Applications/Cisco
fi
​
# remove /opt/cisco if empty		
if [[ -z "$(/bin/ls -A /opt/cisco 2>/dev/null | /usr/bin/grep -v .DS_Store)" ]]; then
	/bin/rm -rf /opt/cisco
fi
			
localUsers=$(/usr/bin/dscl . -list /Users | /usr/bin/grep -v "^_")
​
for userName in ${localUsers}; do
​
	if [ $(id -u "$userName") -ge 500 ]; then
	
		# get path to user's home directory
		userHome=$(/usr/bin/dscl . -read "/Users/$userName" NFSHomeDirectory | /usr/bin/sed 's/^[^\/]*//g')
		if [[ -d "$userHome" && "$userHome" != "/var/empty" ]]; then
​
			/bin/rm -rf "${userHome}/Library/Saved Application State/com.cisco.anyconnect"* \
					    "${userHome}/Library/Saved Application State/com.cisco.anyconnect"* \
					    "${userHome}/Library/Preferences/com.cisco.anyconnect"* \
					    "${userHome}/Library/Preferences/com.cisco.secureclient"* \
					    "${userHome}/.cisco/anyconnect" \
					    "${userHome}/.cisco/secureclient" \
					    "${userHome}/.cisco/iseposture" \
					    "${userHome}/.cisco/vpn"
			# remove ~/.cisco if empty		
			if [[ -z "$(/bin/ls -A "${userHome}"/.cisco 2>/dev/null | /usr/bin/grep -v .DS_Store)" ]]; then
				/bin/rm -rf "$userHome/.cisco"
			fi
		fi
	fi
done
​
# forget the packages
allPackages=$(/usr/sbin/pkgutil --pkgs | /usr/bin/grep -i "anyconnect\|secureclient")
for aPackage in ${allPackages}; do
	/usr/sbin/pkgutil --forget "$aPackage" >/dev/null 2>&1
done
​
exit 0
