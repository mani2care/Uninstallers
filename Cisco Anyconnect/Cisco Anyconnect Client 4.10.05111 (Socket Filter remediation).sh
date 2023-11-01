#!/bin/bash

###########################################################################
# Check if the Cisco VPN is connected. If not, validate the Cisco AnyConnect Socket Filter.
# If not installed, install the socket filter using the Jamf Pro policy.
###########################################################################

eventpolicy="$4"

testFile="/opt/cisco/anyconnect/bin/vpn" # Cisco VPN binary

if [[ -f "${testFile}" ]]; then
    # Cisco AnyConnect is installed; read the current IP Address
    RESULT=$(/opt/cisco/anyconnect/bin/vpn stats | grep "Client Address (IPv4):" | awk '{print $4}')

    if [[ "${RESULT}" == "Not" || "${RESULT}" == "" ]]; then
        echo "Cisco VPN Not Connected"

        if [ ! -d "/Applications/Cisco/Cisco AnyConnect Socket Filter.app" ]; then
            echo "Cisco AnyConnect Socket Filter is not installed. Installing now..."
            sudo /usr/local/bin/jamf policy -event "$eventpolicy"
            exit
        fi
    else
        echo "Cisco VPN Connected: $RESULT"
        exit
    fi
else
    echo "Cisco AnyConnect is not installed."
    exit
fi
