#!/bin/zsh
#set -x

rm_if_exists(){
    if [ -e "${1}" ]; then
        rm -rf "${1}"
    fi
}

forget_pkg(){
    pkgutil --forget "${1}" / > /dev/null 2>&1
}

# check we are running as root
if [[ $(id -u) -ne 0 ]]; then
  echo "ERROR: This script must be run as root **EXITING**"
  exit 1
fi

# Current console user information
console_user=$(/usr/bin/stat -f "%Su" /dev/console)
console_user_uid=$(/usr/bin/id -u "$console_user")

# Only unload the LaunchAgent if there is a user logged in, otherwise
if [[ -z "$console_user" ]]; then
echo "Did not detect user"
elif [[ "$console_user" == "loginwindow" ]]; then
echo "Detected Loginwindow Environment"
elif [[ "$console_user" == "_mbsetupuser" ]]; then
echo "Detect SetupAssistant Environment"
elif [[ "$console_user" == "root" ]]; then
echo "Detect root as currently logged-in user"
else

# Unload the agent so it can be triggered on re-install
/bin/launchctl asuser "${console_user_uid}" /bin/launchctl unload -w /Library/LaunchAgents/com.github.macadmins.Nudge.plist  > /dev/null 2>&1
# Kill Nudge just in case (say someone manually opens it and not launched via launchagent
/usr/bin/killall Nudge  > /dev/null 2>&1
fi

# Unload the Nudge Logger launchdaemon (if its running)
if launchctl list | grep -q "/Library/LaunchDaemons/com.github.macadmins.Nudge.logger"; then
    launchctl unload "/Library/LaunchDaemons/com.github.macadmins.Nudge.logger.plist"
fi

# Delete the Nudge app bundle
rm_if_exists "/Applications/Utilities/Nudge.app"

# Delete the Nudge LaunchAgent
rm_if_exists "/Library/LaunchAgents/com.github.macadmins.Nudge.plist"

# Delete the Nudge Logger LaunchDaemon
rm_if_exists "/Library/LaunchDaemons/com.github.macadmins.Nudge.logger.plist"

forget_pkg com.github.macadmins.Nudge.Suite
forget_pkg com.github.macadmins.Nudge
forget_pkg com.github.macadmins.Nudge.LaunchAgent
forget_pkg com.github.macadmins.Nudge.Logger

# Cycle through user home folders and delete deferral plists
users=($(dscl . list /Users UniqueID | awk '$2 >= 501 {print $1}'))

for user in "${users[@]}"
do	
	user_id=$(id -u "${user}")
	user_home=$(dscl . -read /Users/"${user}" NFSHomeDirectory | awk {'print$NF'})
	nudge_user_plist="${user_home}/Library/Preferences/com.github.macadmins.Nudge.plist" 
	rm_if_exists "${nudge_user_plist}"	
done

echo "Nudge has been fully uninstalled"
