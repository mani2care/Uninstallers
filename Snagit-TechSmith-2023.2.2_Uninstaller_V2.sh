#!/bin/bash

# Function to uninstall Snagit 2023
uninstall_snagit_2023() {
    local app_name="$1"
    
    # Stop the application if it's running
    echo "Checking for application running status Snagit $app_name"

    # Get the process IDs of the application
    app_pids=($(pgrep -f "Snagit $app_name"))

    if [ ${#app_pids[@]} -gt 0 ]; then
        # Terminate all running processes forcefully
        for pid in "${app_pids[@]}"; do
            kill -9 "$pid"
            echo "The application has been forcefully terminated =$pid"
        done
    else 
        echo "Application Process not found Snagit $app_name"
    fi
    sleep 5

    echo "Removing the Snagit $app_name LicenseKey file..."
    rm -f "/Users/Shared/TechSmith*"

    echo "The Snagit $app_name has been uninstalled from your Mac"

    # Remove the application and its associated files
    rm -rf /Applications/Snagit\ $app_name*
    rm -rf /Users/Shared/TechSmith
    rm -rf ~/Library/Group\ Containers/*.com.techsmith.snagit
    rm -rf ~/Library/Caches/com.techsmith.snagit*
    rm -rf ~/Library/Caches/com.TechSmith.Snagit*
    rm -rf ~/Library/Logs/TechSmith
    rm -rf ~/Library/Preferences/com.TechSmith.Snagit*
    rm -rf ~/Library/Preferences/com.techsmith.snagit.capturehelper*
    rm -rf ~/Library/Saved\ Application\ State/com.TechSmith.Snagit*
    rm -rf ~/Library/WebKit/com.TechSmith.Snagit*
    rm -rf ~/Library/HTTPStorages/com.TechSmith.Snagit*
    rm -rf ~/Library/Application\ Support/TechSmith
    rm -rf ~/Library/Application\ Support/CrashReporter/Snagit* 

    #Exception
    #rm -rf ~/Pictures/Snagit  
}

# Function to uninstall Snagit 2022
#uninstall_snagit_2022() {
  #  local app_name="Snagit 2022"
    # Add the uninstallation logic for Snagit 2022 here
#}

# Function to uninstall Snagit 2021
#uninstall_snagit_2021() {
 #   local app_name="Snagit 2021"
    # Add the uninstallation logic for Snagit 2021 here
#}

# Check for the presence of Snagit 2023 and uninstall it
if [ -e "/Applications/Snagit 2023.app" ]; then
    uninstall_snagit_2023 "2023"
    exit 0
elif [ -e "/Applications/Snagit 2022.app" ]; then
    uninstall_snagit_2023 "2022"
    exit 0
elif [ -e "/Applications/Snagit 2021.app" ]; then
    uninstall_snagit_2023 "2021"
    exit 0
else
    echo "None of the Snagit versions are installed on your Mac."
    exit 1
fi
