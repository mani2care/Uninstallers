#!/bin/bash
## RipOff-McAfee.sh
## version 2.3
## 
## Author: Adam Scheblein, McAfee IT
## E-Mail: adam_scheblein@mcafee.com
##
## version 2.1 mods by Steve Dagley <@sdagley Jamf Nation/Twitter/MacAdmins Slack>
## 	Updated launchctl calls to use bootout instead of unload
##	Remove Privileged HelperTool added with ENS 10.7.1
##	Kill McAfee Agent Status Monitor when unloading launch items
##
## version 2.2 mods by Adam Scheblein
##  Removes system extension 
##  Kill McAfee Reporter when unloading launch items
##
## version 2.3 mods by Steve Dagley <@sdagley Jamf Nation/Twitter/MacAdmins Slack>
##	If McAfee Network Extension is loaded remove it without prompting for user approval
##		on macOS Catalina, Big Sur, or Monterey. Uses method documented by @rtrouten's post:
##		https://derflounder.wordpress.com/2021/10/26/silently-uninstalling-system-extensions-on-macos-monterey-and-earlier/

# Temp plist files used for import and export from authorization database.
management_db_original_setting="$(mktemp).plist"
management_db_edited_setting="$(mktemp).plist"
management_db_check_setting="$(mktemp).plist"

# Expected settings from management database for com.apple.system-extensions.admin
original_setting="authenticate-admin-nonshared"
updated_setting="allow"

ManagementDatabaseUpdatePreparation() {
# Create temp plist files
touch "$management_db_original_setting"
touch "$management_db_edited_setting"
touch "$management_db_check_setting"

# Create backup of the original com.apple.system-extensions.admin settings from the management database
/usr/bin/security authorizationdb read com.apple.system-extensions.admin > "$management_db_original_setting"

# Create copy of the original com.apple.system-extensions.admin settings from the management database for editing.
/usr/bin/security authorizationdb read com.apple.system-extensions.admin > "$management_db_edited_setting"
}

UpdateManagementDatabase() {
if [[ -r "$management_db_edited_setting" ]] && [[ $(/usr/libexec/PlistBuddy -c "Print rule:0" "$management_db_edited_setting") = "$original_setting" ]]; then
   /usr/libexec/PlistBuddy -c "Set rule:0 $updated_setting" "$management_db_edited_setting"
   if [[ $(/usr/libexec/PlistBuddy -c "Print rule:0" "$management_db_edited_setting" ) = "$updated_setting" ]]; then
      echo "Edited $management_db_edited_setting is set to allow system extensions to be uninstalled without password prompt."
      echo "Now importing setting into authorization database."
      /usr/bin/security authorizationdb write com.apple.system-extensions.admin < "$management_db_edited_setting"
      if [[ $? -eq 0 ]]; then
         echo "Updated setting successfully imported."
         UpdatedAuthorizationSettingInstalled="true"
      fi
    else
      echo "Failed to update $management_db_edited_setting file with the correct setting to allow system extension uninstallation without prompting for admin credentials."
    fi
fi
}

RestoreManagementDatabase() {
/usr/bin/security authorizationdb read com.apple.system-extensions.admin > "$management_db_check_setting"
if [[ ! $(/usr/libexec/PlistBuddy -c "Print rule:0" "$management_db_check_setting") = "$original_setting" ]]; then
   if [[ -r "$management_db_original_setting" ]] && [[ $(/usr/libexec/PlistBuddy -c "Print rule:0" "$management_db_original_setting") = "$original_setting" ]]; then
      echo "Restoring original settings to allow system extension uninstallation only after prompting for admin credentials."
      echo "Now importing setting into authorization database."
      /usr/bin/security authorizationdb write com.apple.system-extensions.admin < "$management_db_original_setting"
            if [[ $? -eq 0 ]]; then
         echo "Original setting successfully imported."
         OriginalAuthorizationSettingInstalled=1
      fi

    else
      echo "Failed to update the authorization database with the correct setting to allow system extension uninstallation only after prompting for admin credentials."
    fi
fi
}

# This script has been verified to work on McAfee Endpoint Security 10 for Mac.
# It supports uninstalls through ENSM 10.7.5, and removes all McProducts.
#get current user name and ID
userName=$(/bin/echo 'show State:/Users/ConsoleUser' | /usr/sbin/scutil | /usr/bin/awk '/Name / { print $3 }')

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

echo "uninstalling system extensions"
if [ -e /Applications/McAfeeSystemExtensions.app ] ; then
	McAfeeNetworkExtensionLoaded=$(/usr/bin/systemextensionsctl list | /usr/bin/grep "McAfee Network Extension")
	
	if [[ -n "$McAfeeNetworkExtensionLoaded" ]]; then

		# Prepare to update authorization database to allow system extensions to be uninstalled without password prompt.
		ManagementDatabaseUpdatePreparation
	
		# Update authorization database with new settings.
		UpdateManagementDatabase
		
		# Uninstall the System Extension
		/usr/bin/sudo -u $userName /usr/local/McAfee/fmp/AAC/bin/deactivatesystemextension com.mcafee.CMF.networkextension
		
		# Once the system extensions are uninstalled, the relevant settings for the authorization database will be restored from backup to their prior state.
		if [[ -n "$UpdatedAuthorizationSettingInstalled" ]]; then 
			RestoreManagementDatabase
	
			if [[ -n "$OriginalAuthorizationSettingInstalled" ]]; then
				echo "com.apple.system-extensions.admin settings in the authorization database successfully restored to $original_setting."
				rm -rf "$management_db_original_setting"
				rm -rf "$management_db_edited_setting"
				rm -rf "$management_db_check_setting"
			fi
	
		fi
	fi
fi
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
/usr/bin/killall -c McAfee\ Reporter
echo ""

# rm program dirs
echo "removing program dirs"
/bin/rm -rf /usr/local/McAfee/
/bin/rm -rf /opt/McAfee/
/bin/rm -rf /Applications/DataLossPrevention.app/
/bin/rm -rf /Applications/McAfee\ Endpoint\ Security\ for\ Mac.app/
/bin/rm -rf /Applications/McAfee\ Endpoint\ Protection\ for\ Mac.app/
/bin/rm -rf /Applications/McAfeeSystemExtensions.app/
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
/bin/rm -f /Library/Logs/FRP.log
/bin/rm -f /private/var/log/McAfeeSecurity.log*
/bin/rm -f /private/var/log/mcupdater*
/bin/rm -f /private/var/log/MFEdx*
echo ""

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
