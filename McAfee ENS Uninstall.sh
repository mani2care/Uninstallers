#!/bin/sh

## RipOff-McAfee.sh
## version 2.0
## 
## Author: Adam Scheblein, McAfee IT
## E-Mail: adam_scheblein@mcafee.com
##
## version 2.1 mods by Steve Dagley <@sdagley Jamf Nation/Twitter/MacAdmins Slack>
## 	Updated launchctl calls to use bootout instead of unload
##	Remove Privileged HelperTool added with ENS 10.7.1
##	Kill McAfee Agent Status Monitor when unloading launch items

# This script has been verified to work on McAfee Endpoint Security 10 for Mac.
# It supports uninstalls through ENSM 10.6.x, and removes all McProducts.

#get current user name and ID
userName=$(/bin/echo 'show State:/Users/ConsoleUser' | /usr/sbin/scutil | /usr/bin/awk '/Name / { print $3 }')
currentUserID=$(/usr/bin/id -u "$userName")


# stop running processes
echo "stopping running processes"
/usr/local/McAfee/DlpAgent/bin/DlpAgentControl.sh mastop
/usr/local/McAfee/AntiMalware/VSControl mastop
/usr/local/McAfee/StatefulFirewall/bin/StatefullFirewallControl mastop
/usr/local/McAfee/WebProtection/bin/WPControl mastop
/usr/local/McAfee/atp/bin/ATPControl mastop
/usr/local/McAfee/FRP/bin/FRPControl mastop
/usr/local/McAfee/Mar/MarControl stop
/usr/local/McAfee/mvedr/MVEDRControl stop
/usr/local/McAfee/Mcp/bin/mcpcontrol.sh mastop
/usr/local/McAfee/MNE/bin/MNEControl mastop
/usr/local/McAfee/fmp/bin/fmp stop
/opt/McAfee/dx/bin/dxlservice stop
/Library/McAfee/agent/bin/maconfig -stop
echo ""

# unload kexts
echo "unloading kexts"
/sbin/kextunload /Library/Application\ Support/McAfee/AntiMalware/AVKext.kext
/sbin/kextunload /Library/Application\ Support/McAfee/FMP/mfeaac.kext
/sbin/kextunload /Library/Application\ Support/McAfee/FMP/FileCore.kext
/sbin/kextunload /Library/Application\ Support/McAfee/FMP/FMPSysCore.kext
/sbin/kextunload /Library/Application\ Support/McAfee/StatefulFirewall/SFKext.kext
/sbin/kextunload /usr/local/McAfee/AntiMalware/Extensions/AVKext.kext
/sbin/kextunload /usr/local/McAfee/StatefulFirewall/Extensions/SFKext.kext
/sbin/kextunload /usr/local/McAfee/Mcp/MCPDriver.kext
/sbin/kextunload /usr/local/McAfee/DlpAgent/Extensions/DLPKext.kext
/sbin/kextunload /usr/local/McAfee/DlpAgent/Extensions/DlpUSB.kext
/sbin/kextunload /usr/local/McAfee/fmp/Extensions/FileCore.kext
/sbin/kextunload /usr/local/McAfee/fmp/Extensions/NWCore.kext
/sbin/kextunload /usr/local/McAfee/fmp/Extensions/FMPSysCore.kext
echo ""

# unload launch items
echo "unloading launch items"
/bin/launchctl bootout system /Library/LaunchAgents/com.mcafee.McAfeeSafariHost.plist
/bin/launchctl bootout system /Library/LaunchAgents/com.mcafee.menulet.plist
/bin/launchctl bootout system /Library/LaunchAgents/com.mcafee.reporter.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.aac.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.agent.ma.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.agent.macmn.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.agent.macompat.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.dxl.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.ssm.Eupdate.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.ssm.ScanFactory.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.ssm.ScanManager.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.virusscan.fmpcd.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.virusscan.fmpd.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.agentMonitor.helper.plist
/usr/bin/killall -c Menulet
/usr/bin/killall -c "McAfee Agent Status Monitor"
echo ""

# TODO: Unload safari/finder/chrome extensions

# rm program dirs
echo "removing program dirs"
/bin/rm -rf /usr/local/McAfee/
/bin/rm -rf /opt/McAfee/
/bin/rm -rf /Applications/DataLossPrevention.app/
/bin/rm -rf /Applications/McAfee\ Endpoint\ Security\ for\ Mac.app/
/bin/rm -rf /Applications/McAfee\ Endpoint\ Protection\ for\ Mac.app/
/bin/rm -rf /Applications/Utilities/McAfee\ ePO\ Remote\ Provisioning\ Tool.app/
echo ""

# rm support dirs
echo "removing support dirs"
/bin/rm -rf /Users/Shared/.mcafee
/bin/rm -rf /Library/Application\ Support/McAfee/
/bin/rm -rf /Library/Documentation/Help/McAfeeSecurity*
/bin/rm -rf /Library/Frameworks/AVEngine.framework/
/bin/rm -rf /Library/Frameworks/VirusScanPreferences.framework/
/bin/rm -rf /Library/Internet\ Plug-Ins/Web\ Control.plugin/
/bin/rm -rf /Library/McAfee/
/bin/rm -rf /Quarantine/
echo ""

# rm prefs/launch items
echo "removing prefs and launch items"
/bin/rm -f /Library/Preferences/com.mcafee*
/bin/rm -f /Library/Preferences/.com.mcafee*
/bin/rm -f /Library/LaunchDaemons/com.mcafee*
/bin/rm -f /Library/LaunchAgents/com.mcafee*
/bin/rm -rf /Library/StartupItems/cma/
/bin/rm -f /private/etc/cma.conf
/bin/rm -rf /private/etc/cma.d/
/bin/rm -rf /private/etc/ma.d/
/bin/rm -f /private/etc/init.d/dx
/bin/rm -rf /private/var/McAfee/
/bin/rm -rf /private/var/tmp/.msgbus/
/bin/rm -rf /Users/$userName/Library/Containers/com.McAfee*
/bin/rm -rf /Users/$userName/Library/Application\ Scripts/com.McAfee*
/bin/rm -rf /Users/$userName/Library/Group\ Containers/group.com.Mcafee*
/bin/rm -rf /Users/$userName/Library/Preferences/com.mcafee*
/bin/rm -f /Library/Google/Chrome/NativeMessagingHosts/siteadvisor.mcafee.chrome.extension.json
/bin/rm -f /Library/PrivilegedHelperTools/com.mcafee.agentMonitor.helper
echo ""

# rm logs
echo "removing logs"
/bin/rm -f /Library/Logs/Native\ Encryption.log
/bin/rm -f /private/var/log/McAfeeSecurity.log*
echo ""

# TODO: loop through and get all hotfix receipts to remove

# forget receipts
echo "forgetting receipts"
/usr/sbin/pkgutil --forget com.mcafee.dxl
/usr/sbin/pkgutil --forget com.mcafee.mscui
/usr/sbin/pkgutil --forget com.mcafee.mar
/usr/sbin/pkgutil --forget com.mcafee.mvedr
/usr/sbin/pkgutil --forget com.mcafee.pkg.FRP
/usr/sbin/pkgutil --forget com.mcafee.pkg.MNE
/usr/sbin/pkgutil --forget com.mcafee.pkg.StatefulFirewall
/usr/sbin/pkgutil --forget com.mcafee.pkg.utility
/usr/sbin/pkgutil --forget com.mcafee.pkg.WebProtection
/usr/sbin/pkgutil --forget com.mcafee.ssm.atp
/usr/sbin/pkgutil --forget com.mcafee.ssm.fmp
/usr/sbin/pkgutil --forget com.mcafee.ssm.mcp
/usr/sbin/pkgutil --forget com.mcafee.ssm.dlp
/usr/sbin/pkgutil --forget com.mcafee.virusscan
/usr/sbin/pkgutil --forget comp.nai.cmamac
echo ""

# remove users/groups
echo "removing user and groups"
/usr/bin/dscl . delete /Users/mfe
/usr/bin/dscl . delete /Groups/mfe
/usr/bin/dscl . delete /Groups/Virex
echo ""

##mcafee support article: KB88461
#cd  /usr/local/
#rm –rf McAfee/
#cd /Library/Application\ Support/
#rm –rf McAfee/
#cd /Library/LaunchDaemons/
#rm –rf com.mcafee.*
#cd /Library/LaunchAgents/
#rm –rf com.mcafee.*
#cd /Library/Preferences/
#rm –rf com.mcafee.*

exit 0
