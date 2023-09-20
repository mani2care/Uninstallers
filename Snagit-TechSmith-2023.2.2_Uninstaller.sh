#!/bin/bash

#app_path="/Applications/Snagit 2023.app" # Define the path to the application
LicenseKeyFile="/Users/Shared/TechSmith*" # Define the path to the LicenseKey file

# Function to uninstall an application
uninstall_app() {
    local app_name="$1"
    
    # Stop the application if it's running
    echo "Checking for application status $app_name"

    # Get the process IDs of the application
    app_pids=($(pgrep -f "$app_name"))

    # Check if there are any running processes
    #if [[ -${#app_pids[@]} -gt 0 && ${#app_pids[@]} -ne "" ]]; then

    if [ ${#app_pids[@]} -gt 0 ]; then
        # Terminate all running processes forcefully
        for pid in "${app_pids[@]}"; do
            kill -9 "$pid"
            echo "The application has been forcefully terminated =$pid"
        done
    else 
    echo "Application Process not found $app_name"
    fi
    sleep 5
    echo "Removing the $app_name LicenseKey file..."
    rm -f "$LicenseKeyFile"

    # Remove the application and its associated files
    rm -rf /Applications/$app_name
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

    echo "The $app_name has been uninstalled from your Mac"
    echo
}

# List of applications to uninstall
applications=("Snagit 2023" "Snagit 2022" "Snagit 2021")

# Loop through the list and uninstall each application
for app in "${applications[@]}"; do
    uninstall_app "$app"
done