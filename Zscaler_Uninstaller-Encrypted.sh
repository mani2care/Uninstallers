#!/bin/sh

#provide your input 
encryptedPassword="yourencpassword"
decryptionSalt="yourencsalt"
decryptionPassphrase="yourencpassphrase"

function removeZscaler () {
PWord=$(echo "$encryptedPassword" | /usr/bin/openssl enc -aes256 -md md5 -d -a -A -S "$decryptionSalt" -k "$decryptionPassphrase")
/bin/sh /Applications/Zscaler/.Uninstaller.sh "$PWord"
echo "Successfully uninstalled"
}

#Is Zscaler installed
if [ -f "/Applications/Zscaler/Zscaler.app/Contents/Info.plist" ]; then
removeZscaler
else
echo "Not Installed"
fi
