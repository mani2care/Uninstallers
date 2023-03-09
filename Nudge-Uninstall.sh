#!/bin/zsh

    console_user=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
    userID=$(/usr/bin/id "${console_user}" | /usr/bin/awk '{print $1}' | /usr/bin/sed 's/[=()a-zA-Z]//g')
    userHomeDir=$(dscacheutil -q user | grep $console_user | awk 'NR==2 {print $2}')
    deferralFile="$userHomeDir/Library/Preferences/com.github.macadmins.Nudge.plist"

# Killing the process
    /usr/bin/killall Nudge
    /usr/bin/pgrep -i Nudge | /usr/bin/xargs kill

  if [[ -e /Applications/Utilities/Nudge.app ]]; then
    echo "Launch agent running under signed in user, unloading it."
    /bin/launchctl asuser "$userID" /bin/launchctl unload /Library/LaunchAgents/com.github.macadmins.Nudge.plist
    echo "Removing Nudge.app"
    rm -rf /Applications/Utilities/Nudge.app
    rm -rf /Library/LaunchAgents/com.github.macadmins.Nudge.plist
    rm -rf /Library/LaunchDaemons/com.github.macadmins.Nudge.logger.plist
    rm -rf $deferralFile
  else
    echo "No Nudge.app"
  fi
exit 0
