#!/bin/bash

# Uninstalling Hello IT in /Applications

#killall cfprefsd
original_app_path="/Applications/Utilities/Hello IT.app"

while read shortname
do
    uid=$(id -u "$shortname")

    if [ -n "$uid" ]
    then
        /bin/launchctl asuser "$uid" /bin/launchctl unload /Library/LaunchAgents/com.github.ygini.hello-it.plist
        
    fi
done < <(ps aux | grep "MacOS/[F]inder" | awk '{print $1}')

if [ -d "$original_app_path" ]
then
    rm -rf /Applications/Utilities/Hello\ IT.app
    rm -rf /Library/LaunchAgents/com.github.ygini.hello-it.plist
fi

exit 0