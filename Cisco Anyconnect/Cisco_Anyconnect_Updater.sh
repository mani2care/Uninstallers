#!/bin/bash

###########################################################################
# Check the VPN status & if in case lower version then install the latest verion & VPN is connected then cancell the update#
###########################################################################

Targetversion="$4"
eventpolicy="$5"

RESULT="Not_Installed"

testFile="/opt/cisco/anyconnect/bin/vpn" # Cisco VPN binary

if [[ -f "${testFile}" ]] ; then
	# Cisco AnyConnect installed; read current IP Address
	RESULT=$( /opt/cisco/anyconnect/bin/vpn stats | /usr/bin/grep "Client Address (IPv4):" | /usr/bin/awk '{print $4}' )

	if [[ "${RESULT}" == "Not" || "${RESULT}" == "" ]]; then
		RESULT="Cisco VPN Not Connected"

		if [ -d /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app ]; then 
		Version=$(/usr/bin/defaults read /Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app/Contents/Info.plist CFBundleShortVersionString)
		echo "Current AnyConnect version is : $Version" 
			if [[ "$Version" == "$Targetversion" ]]; then
				echo "Cisco Anyconnect Upto date Hence cancelling the Update: $Version" 
				exit
				else 
				echo "Installing the latest cisco AnyConnect $Targetversion"
				sudo /usr/local/bin/jamf policy -event $eventpolicy
				exit
			fi 

		else 
			echo "Anyconnect_Not_Installed" 
			exit

		fi 
		
	fi

fi
echo "Cisco VPN Connected :$RESULT So the Update is cancelled"

exit
