#!/bin/bash
####################################################################################################
#
# ABOUT
# https://github.com/dan-snelson/Jamf-Pro-Scripts/blob/master/Recon%20at%20Reboot/Recon%20at%20Reboot.sh
#   Creates a self-destructing LaunchDaemon and script to run a removing the jamf pro.
#   at next Reboot (after confirming your Jamf Pro server is available)
#
####################################################################################################
#
# HISTORY
#
# Version 1.0.0, 10-Nov-2016, Dan K. Snelson (@dan-snelson)
#   Original version
#
# Version 1.0.1, 12-Aug-2022, Dan K. Snelson (@dan-snelson)
#   Added check for Jamf Pro server connection
# Version 1.1, 12-Apr-2023, manikadnan (@mani2care)
#   Added jamf pro remove configuration after recon.
#
####################################################################################################



####################################################################################################
#
# Variables
#
####################################################################################################

scriptVersion="1.1"
plistDomain="com.abb"       # Hard-coded domain name
plistLabel="removejamf"                  # Unique label for this plist
plistLabel="$plistDomain.$plistLabel"       # Prepend domain to label
timestamp=$( /bin/date '+%Y-%m-%d-%H%M%S' ) # Used in log file



####################################################################################################
#
# Program
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Logging preamble
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "JAMF pro removeframework configuration Version: (${scriptVersion})"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create launchd plist to call a shell script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Create the LaunchDaemon ..."

/bin/echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
    <dict>
        <key>Label</key>
        <string>${plistLabel}</string>
        <key>ProgramArguments</key>
        <array>
            <string>/bin/sh</string>
            <string>/private/var/tmp/removejamf.bash</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>" > /Library/LaunchDaemons/$plistLabel.plist



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Set the permission on the file
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Set LaunchDaemon file permissions ..."

/usr/sbin/chown root:wheel /Library/LaunchDaemons/$plistLabel.plist
/bin/chmod 644 /Library/LaunchDaemons/$plistLabel.plist
/bin/chmod +x /Library/LaunchDaemons/$plistLabel.plist



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create reboot script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Create the script ..."

cat << '==endOfScript==' > /private/var/tmp/removejamf.bash
#!/bin/bash
#
# Variables
#
####################################################################################################
scriptVersion="1.1"
plistDomain="com.abb"       # Hard-coded domain name
plistLabel="removejamf"                  # Unique label for this plist
plistLabel="$plistDomain.$plistLabel"       # Prepend domain to label
timestamp=$( /bin/date '+%Y-%m-%d-%H%M%S' ) # Used in log file
scriptResult=""
####################################################################################################
#
# Functions
#
####################################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check for a Jamf Pro server connection
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
jssConnectionStatus () {
    scriptResult+="Check for Jamf Pro server connection; " >> /private/var/tmp/$plistLabel.log
    unset jssStatus
    jssStatus=$( /usr/local/bin/jamf checkJSSConnection 2>&1 | /usr/bin/tr -d '\n' )
    case "${jssStatus}" in
        *"The JSS is available."        )   jssAvailable="yes" ;;
        *"No such file or directory"    )   jssAvailable="not installed" ;;
        *                               )   jssAvailable="unknown" ;;
    esac
}
####################################################################################################
#
# Program
#
####################################################################################################
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Logging preamble
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo "Starting JAMF removeframework validation (${scriptVersion}) at $timestamp" >> /private/var/tmp/$plistLabel.log
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Hard-coded sleep of 25 seconds for auto-launched applications to start
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
echo "Sleep 10 seconds for auto-lanched application to start" >> /private/var/tmp/$plistLabel.log
sleep "10"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check for a Jamf Pro server connection
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
jssConnectionStatus
counter=1
until [[ "${jssAvailable}" == "yes" ]] || [[ "${counter}" -gt "10" ]]; do
    echo "Check ${counter} of 10: Jamf Pro server NOT reachable; waiting to re-check; "
    sleep "30"
    jssConnectionStatus
    ((counter++))
done
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# If Jamf Pro server is available, update inventory
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
if [[ "${jssAvailable}" == "yes" ]]; then
    echo "Jamf Pro server is available, proceeding for the jamf removeframework; " >> /private/var/tmp/$plistLabel.log
    scriptResult+="Resuming Recon at Reboot; "
    scriptResult+="Updating inventory; "
    /usr/local/bin/jamf recon
    echo "Removing the Jamf Pro framework; " >> /private/var/tmp/$plistLabel.log
    echo >> /private/var/tmp/$plistLabel.log
    /usr/local/bin/jamf removeframework >> /private/var/tmp/$plistLabel.log
else
    scriptResult+="Jamf Pro server is NOT available; exiting." >> /private/var/tmp/$plistLabel.log
fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Delete launchd plist
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
scriptResult+="Delete $plistLabel.plist; "
/bin/rm -fv /Library/LaunchDaemons/$plistLabel.plist
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Delete script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
scriptResult+="Delete script; "
/bin/rm -fv /private/var/tmp/removejamf.bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
scriptResult+="End-of-line."
echo "${scriptResult}" >> /private/var/tmp/$plistLabel.log
exit 0
==endOfScript==



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Set the permission on the script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Set script file permissions ..."
/usr/sbin/chown root:wheel /private/var/tmp/removejamf.bash
/bin/chmod 644 /private/var/tmp/removejamf.bash
/bin/chmod +x /private/var/tmp/removejamf.bash



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create Log File
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Create Log File at /private/var/tmp/$plistLabel.log ..."
touch /private/var/tmp/$plistLabel.log
echo "Created $plistLabel.log on $timestamp" > /private/var/tmp/$plistLabel.log



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "LaunchDaemon and Script created."

exit 0
