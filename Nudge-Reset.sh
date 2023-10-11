#!/bin/sh

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

# global check if there is a user logged in
if [ -z "$currentUser" -o "$currentUser" = "loginwindow" ]; then
	echo "no user logged in, cannot proceed"
	exit 1
fi
# now we know a user is logged in

# Killing the process
    /usr/bin/killall Nudge
    /usr/bin/pgrep -i Nudge | /usr/bin/xargs kill
    
# get the current user's UID
uid=$(id -u "$currentUser")

# convenience function to run a command as the current user
# usage:
#   runAsUser command arguments...
runAsUser() {  
	if [ "$currentUser" != "loginwindow" ]; then
		launchctl asuser "$uid" sudo -u "$currentUser" "$@"
	else
		echo "no user logged in"
		exit 1
	fi
}

# variables
locationLaunchAgent="/Library/LaunchAgents/com.github.macadmins.Nudge.plist"
locationLaunchDaemon="/Library/LaunchDaemons/com.github.macadmins.Nudge.logger.plist"
locationApp="/Applications/Utilities/Nudge.app"
launchAgentPlistRunning=$(runAsUser /bin/launchctl list | grep "com.github.macadmins.Nudge")
launchDaemonPlistRunning=$(/bin/launchctl list | grep "com.github.macadmins.Nudge.Logger")

# check if the launchAgent is Running and if so, unload it.
if [[ -z $launchAgentPlistRunning ]]; then
	echo "Nudge launchAgent is not loaded"
elif [[ ! -z $launchAgentPlistRunning ]]; then
	echo "Nudge launchAgent is loaded, need to unload"
	runAsUser /bin/launchctl unload "$locationLaunchAgent"
fi

# check if the launchDaemon is Running and if so, unload it.
if [[ -z $launchDaemonPlistRunning ]]; then
	echo "Nudge Logger launchDaemon is not loaded"
elif [[ ! -z $launchDaemonPlistRunning ]]; then
	echo "Nudge Logger launchDaemon is loaded, need to unload"
	/bin/launchctl unload "$locationLaunchDaemon"
fi

# removal of files and the Nudge app:
if [[ -e "$locationLaunchAgent" ]]; then
	echo "$locationLaunchAgent found, need to remove"
	/bin/rm "$locationLaunchAgent"
fi

if [[ -e "$locationLaunchDaemon" ]]; then
	echo "$locationLaunchDaemon found, need to remove"
	/bin/rm "$locationLaunchDaemon"
fi

if [[ -e "$locationApp" ]]; then
	echo "$locationApp found, need to remove"
	/bin/rm -r "$locationApp"
fi
