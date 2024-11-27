#!/bin/zsh

# Unload the Kerberos helper from versions of EC prior to 1.6
if [[ -e /Library/LaunchDaemons/com.apple.Enterprise-Connect.kerbHelper.plist ]]; then
  echo "Unloading Kerberos helper..."
  launchctl bootout system /Library/LaunchDaemons/com.apple.Enterprise-Connect.kerbHelper.plist
  rm /Library/LaunchDaemons/com.apple.Enterprise-Connect.kerbHelper.plist
fi

# Remove the privileged helper from versions of EC prior to 1.6
if [[ -e /Library/PrivilegedHelperTools/com.apple.Enterprise-Connect.kerbHelper ]]; then
  echo "Removing privileged helper..."
  rm /Library/PrivilegedHelperTools/com.apple.Enterprise-Connect.kerbHelper
fi

# Remove the authorization database entry from versions of EC prior to 1.6
if /usr/bin/security authorizationdb read com.apple.Enterprise-Connect.writeKDCs &>/dev/null; then
  echo "Removing authorization database entry..."
  /usr/bin/security authorizationdb remove com.apple.Enterprise-Connect.writeKDCs
fi

# Check if the launch agent exists for versions 2.0 or greater
if [[ -e /Library/LaunchAgents/com.abb.enterprise-connect.plist ]]; then
  echo "Unloading Enterprise Connect LaunchAgent..."

  # Get the logged-in user
  loggedInUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
  if [[ -n $loggedInUser ]]; then
    loggedInUID=$(id -u "$loggedInUser")
    
    # Unload the LaunchAgent for the logged-in user
    launchctl bootout gui/$loggedInUID /Library/LaunchAgents/com.abb.enterprise-connect.plist
    rm /Library/LaunchAgents/com.abb.enterprise-connect.plist
  else
    echo "No logged-in user found."
  fi

  # Quit the Enterprise Connect menu extra and app
  echo "Stopping Enterprise Connect processes..."
  killall "Enterprise Connect Menu" &>/dev/null
  killall "Enterprise Connect" &>/dev/null
fi

# Finally, remove the Enterprise Connect app bundle
if [[ -d "/Applications/Enterprise Connect.app" ]]; then
  echo "Removing Enterprise Connect app..."
  rm -rf "/Applications/Enterprise Connect.app/"
else
  echo "Enterprise Connect app not found."
fi

echo "Cleanup completed."
