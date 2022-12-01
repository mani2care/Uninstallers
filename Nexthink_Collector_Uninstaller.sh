#!/bin/bash

FILE_NXTSVC_EXIST=0
NEXTHINKVERSIONS_EXIST=0
FILE_NXTDRV_EXIST=0
FILE_NXTPLS_EXIST=0
FILE_NXTCOORDPLS_EXIST=0
FILE_CLTOLD_EXIST=0
UNINSTALL_SMOOTH=1
FORCE_UNLOADING=0
SKIP_HEADER=0

forgetPkg ()
{
    /usr/sbin/pkgutil --pkgs | grep $1 | while read line
    do
        /usr/sbin/pkgutil --forget "$line" > /dev/null
    done
}

function groupExist()
{
    local grp=$(/usr/bin/dscl . list /groups | /usr/bin/grep -w "$1")
    if [[ -z $grp ]]; then
        return 0
    fi
    return 1
}

function deleteGroup()
{
    if [[ $(groupExist $1) ]]; then
        /usr/bin/dscl . delete /Groups/$1
    fi
}

function removeUsersLogs()
{
    /bin/echo "* Removing $1 logs"
    /usr/bin/dscl . list /Users NFSHomeDirectory | /usr/bin/cut -d'/' -f2- | /usr/bin/xargs -L 1 -I {} /bin/sh -c "/bin/rm -f /{}/Library/Logs/$1*.log"
}

set -- $(/usr/bin/getopt sf : "$@")
while [ $# -gt 0 ]
do
    case "$1" in
    (-s) SKIP_HEADER=1;;
    (-f) FORCE_UNLOADING=1;;
    esac
    shift
done

if [ $SKIP_HEADER -eq 0 ]
then
    /bin/echo "+ Collector Uninstaller Tool"
    /bin/echo "+ Copyright Nexthink S.A. 2021"
    /bin/echo "  "
fi

if [[ $EUID -ne 0 ]]; then
   /bin/echo "Error: Only root can uninstall Nexthink Collector";
   exit 1;
fi

if [ -f /Library/LaunchDaemons/com.nexthink.collector.driver.nxtsvc.plist ]
then
    FILE_NXTPLS_EXIST=1
fi

if [ -f /Library/LaunchDaemons/com.nexthink.collector.nxtcoordinator.plist ]
then
    FILE_NXTCOORDPLS_EXIST=1
fi

if [ -d /Library/Extensions/nxtdrv.kext ]
then
    FILE_NXTDRV_EXIST=1
fi

if [ -d "/Library/Application Support/Nexthink" ]
then
    FILE_NXTSVC_EXIST=1
fi

if [ -d "/Library/Application Support/NexthinkVersions" ]
then
    NEXTHINKVERSIONS_EXIST=1
fi

if [ -d "/Library/Application Support/NEXThink/" ]
then
    FILE_CLTOLD_EXIST=1
fi

if [ $NEXTHINKVERSIONS_EXIST -eq 0 ] && [ $FILE_NXTSVC_EXIST -eq 0 ] && [ $FILE_NXTPLS_EXIST -eq 0 ] && [ $FILE_CLTOLD_EXIST -eq 0 ] && [ $FILE_NXTCOORDPLS_EXIST -eq 0 ]; then
    /bin/echo "* No Collector detected. Nothing to uninstall"
    exit 0
fi

/bin/echo "* Unloading nxtsvc"

/bin/launchctl unload -w /Library/LaunchDaemons/com.nexthink.collector.driver.nxtsvc.plist

if (($? > 0));
then
    /bin/echo "Cannot unload nxtsvc";
    UNINSTALL_SMOOTH=0
fi

/bin/echo "* Unloading nxtaccfg"

/bin/launchctl unload -w /Library/LaunchDaemons/com.nexthink.audit.config.plist

if (($? > 0));
then
    /bin/echo "Cannot unload nxtaccfg";
    UNINSTALL_SMOOTH=0
fi

/bin/echo "* Unloading nxtcoordinator"
/bin/launchctl unload -w /Library/LaunchDaemons/com.nexthink.collector.nxtcoordinator.plist
if (($? > 0));
then
    /bin/echo "Cannot unload nxtcoordinator";
    UNINSTALL_SMOOTH=0
fi

/bin/echo "* Unloading nxtupdater"
/bin/launchctl unload -w /Library/LaunchDaemons/com.nexthink.collector.nxtupdater.plist
if (($? > 0));
then
    /bin/echo "Cannot unload nxtupdater";
    UNINSTALL_SMOOTH=0
fi

/bin/echo "* Unloading nxteufb"
if [ -f /Library/LaunchDaemons/com.nexthink.collector.nxteufb.plist ]; then
    /bin/launchctl unload -w /Library/LaunchDaemons/com.nexthink.collector.nxteufb.plist
fi

if (($? > 0));
then
    /bin/echo "Cannot unload nxteufb";
    UNINSTALL_SMOOTH=0
fi

/bin/echo "* Unloading nxtbsm"
if [ -f /Library/LaunchDaemons/com.nexthink.collector.nxtbsm.plist ]; then
    /bin/launchctl unload -w /Library/LaunchDaemons/com.nexthink.collector.nxtbsm.plist
fi

if (($? > 0));
then
    /bin/echo "Cannot unload nxtbsm";
    UNINSTALL_SMOOTH=0
fi

/bin/echo "* Unloading nxtcod"
if [ -f "/Library/LaunchDaemons/com.nexthink.collector.nxtcod.plist" ]; then
    /bin/launchctl unload -w "/Library/LaunchDaemons/com.nexthink.collector.nxtcod.plist"
fi

if (($? > 0));
then
    /bin/echo "Cannot unload nxtcod";
    UNINSTALL_SMOOTH=0
fi

if [ -f /Library/LaunchAgents/com.nexthink.collector.nxtray.plist ]; then
    /bin/echo "* Unloading nxtray"
    /usr/bin/who | /usr/bin/grep -i console | /usr/bin/awk 'system("/usr/bin/id -u " $1)' | /usr/bin/xargs -I{} /bin/launchctl asuser {} /bin/launchctl unload -w /Library/LaunchAgents/com.nexthink.collector.nxtray.plist
fi

if (($? > 0));
then
    /bin/echo "Cannot unload nxtray";
    UNINSTALL_SMOOTH=0
fi

if [ -f /Library/LaunchAgents/com.nexthink.collector.nxtusm.plist ]; then
    /bin/echo "* Unloading nxtusm"
    /usr/bin/who | /usr/bin/grep -i console | /usr/bin/awk 'system("/usr/bin/id -u " $1)' | /usr/bin/xargs -I{} /bin/launchctl asuser {} /bin/launchctl unload -w /Library/LaunchAgents/com.nexthink.collector.nxtusm.plist
fi

if (($? > 0));
then
    /bin/echo "Cannot unload nxtusm";
    /usr/bin/killall nxtusm
    UNINSTALL_SMOOTH=0
fi



/bin/echo "* Removing nxtsvc plist file"

/bin/rm /Library/LaunchDaemons/com.nexthink.collector.driver.nxtsvc.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtsvc plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtaccfg plist file"

/bin/rm /Library/LaunchDaemons/com.nexthink.audit.config.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtaccfg plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtcoordinator plist file"

/bin/rm /Library/LaunchDaemons/com.nexthink.collector.nxtcoordinator.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtcoordinator plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtupdater plist file"

/bin/rm /Library/LaunchDaemons/com.nexthink.collector.nxtupdater.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtupdater plist file";
     UNINSTALL_SMOOTH=0
fi


/bin/echo "* Removing nxteufb plist file"

/bin/rm /Library/LaunchDaemons/com.nexthink.collector.nxteufb.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxteufb plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtbsm plist file"

/bin/rm -f /Library/LaunchDaemons/com.nexthink.collector.nxtbsm.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtbsm plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtcod plist file"
/bin/rm -f /Library/LaunchDaemons/com.nexthink.collector.nxtcod.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtcod plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtray plist file"
/bin/rm -f /Library/LaunchAgents/com.nexthink.collector.nxtray.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtray plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtusm plist file"
/bin/rm -f /Library/LaunchAgents/com.nexthink.collector.nxtusm.plist

if (($? > 0));
then
     /bin/echo "Cannot remove nxtusm plist file";
     UNINSTALL_SMOOTH=0
fi

/bin/rm -f /Library/Google/Chrome/NativeMessagingHosts/com.nexthink.chrome.extension.json

if (($? > 0));
then
     /bin/echo "Cannot remove chrome extension manifest file";
     UNINSTALL_SMOOTH=0
fi

/bin/rm -f "/Library/Microsoft/Edge/NativeMessagingHosts/com.nexthink.edge.extension.json"
if (($? > 0));
then
     /bin/echo "Cannot remove Edge extension manifest file";
     UNINSTALL_SMOOTH=0
fi

/bin/rm -f "/Library/Application Support/Mozilla/NativeMessagingHosts/com.nexthink.firefox.extension.json"
if (($? > 0));
then
     /bin/echo "Cannot remove firefox extension manifest file";
     UNINSTALL_SMOOTH=0
fi

/bin/rm -f "/Library/Application Support/Google/Chrome/External Extensions/miinajhilmmkpdoaimnoncdiliaejpdk.json"

if (($? > 0));
then
     /bin/echo "Cannot remove chrome extension auto install file";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "* Removing nxtsvc folder"

/bin/rm -rf "/Library/Application Support/Nexthink"
/bin/rm -rf "/Library/Application Support/NexthinkVersions"

if (($? > 0));
then
     /bin/echo "Cannot remove nxtsvc folder";
     UNINSTALL_SMOOTH=0
fi

/bin/echo "stopping all chrome browser extension hostapps if running"
/usr/bin/pkill -9 -f "/Library/Application Support/Nexthink/nxtchrome .*chrome-extension://miinajhilmmkpdoaimnoncdiliaejpdk/.*"
/usr/bin/pkill -9 -f "/Library/Application Support/Nexthink/nxthostapp .*chrome-extension://miinajhilmmkpdoaimnoncdiliaejpdk/.*"
/usr/bin/pkill -9 -f "/Library/Application Support/Nexthink/nxthostapp .*chrome-extension://higleibocjmgcnbikjneplkibiopjnkp/.*"
/usr/bin/pkill -9 -f "/Library/Application Support/Nexthink/nxthostapp .*393c57f8-28d9-11eb-8f58-3b6871335926.*"

if [ $FILE_CLTOLD_EXIST -eq 1 ]
then
    /bin/rm -rf "/Library/Application Support/NEXThink/"

    if (($? > 0));
    then
        /bin/echo "Cannot remove nxtsvc folder for Collector macOS Beta1";
        UNINSTALL_SMOOTH=0
    fi
fi

/bin/echo "* Removing nxtsvc logs"

if [ -f /Library/Logs/nxtsvc.log ]
then
    /bin/rm -f /Library/Logs/nxtsvc*.log
fi

if [ -f /Library/Logs/nxtsvc.log.bk ]
then
    /bin/rm /Library/Logs/nxtsvc.log.bk
fi

/bin/echo "* Removing nxtsvgen logs"
if [ -f /Library/Logs/nxtsvcgen.log ]
then
    /bin/rm /Library/Logs/nxtsvcgen.log
    /bin/rm -f /Library/Logs/nxtsvcgen.*.log
fi

/bin/echo "* Removing nxtcoordinator logs"
if [ -f /Library/Logs/nxtcoordinator.log ]
then
    /bin/rm /Library/Logs/nxtcoordinator.log
    /bin/rm -f /Library/Logs/nxtcoordinator.*.log
fi

/bin/echo "* Removing nxtupdater logs"
if [ -f /Library/Logs/nxtupdater.log ]
then
    /bin/rm /Library/Logs/nxtupdater.log
    /bin/rm -f /Library/Logs/nxtupdater.*.log
fi

# these logs are generated by the Mac command-line installer (CSI.app)
/bin/echo "* Removing nxtcsi logs"
if [ -f /Library/Logs/nxtcsi.log ]
then
    /bin/rm /Library/Logs/nxtcsi.log
    /bin/rm -f /Library/Logs/nxtcsi.*.log
fi

/bin/echo "* Removing nxteufb logs"
if [ -f /Library/Logs/nxteufb.log ]
then
    /bin/rm /Library/Logs/nxteufb.log
    /bin/rm -f /Library/Logs/nxteufb.*.log
fi

/bin/echo "* Removing nxtbsm logs"
if [ -f /Library/Logs/nxtbsm.log ]
then
    /bin/rm /Library/Logs/nxtbsm.log
    /bin/rm -f /Library/Logs/nxtbsm.*.log
fi

/bin/echo "* Removing nxtextension logs"
if [ -f /Library/Logs/nxtextension.log ]
then
    /bin/rm /Library/Logs/nxtextension.log
    /bin/rm -f /Library/Logs/nxtextension.*.log
fi

removeUsersLogs "nxtchrome"
removeUsersLogs "nxthostapp"
removeUsersLogs "nxtray"
removeUsersLogs "nxtusm"

/bin/echo "* Removing nxtcod logs"
if [ -f /Library/Logs/nxtcod.log ]
then
    /bin/rm /Library/Logs/nxtcod.log
    /bin/rm -f /Library/Logs/nxtcod.*.log
fi

if [ $FILE_NXTDRV_EXIST -eq 0 ] ; then
    /bin/echo "* Unloading nxtdrv"

    if [ $FORCE_UNLOADING -eq 1 ]
    then
        /bin/sleep 10
        /sbin/kextunload /Library/Extensions/nxtdrv.kext &>/dev/null
    else
        /bin/echo "Cannot unload the nxtdrv.kext"
    fi

    /bin/rm -rf /Library/Extensions/nxtdrv.kext

    if (($? > 0));
    then
        /bin/echo "Cannot remove nxtdrv.kext";
    fi
fi

/bin/echo "* Unlinking packages"
/bin/echo " "

forgetPkg "com.nexthink.nexthinkCollectorInstaller"

deleteGroup nexthink

exit 0
