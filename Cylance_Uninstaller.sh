#!/bin/sh
#sudo /Applications/Cylance/Uninstall\ CylancePROTECT.app/Contents/MacOS/Uninstall\ CylancePROTECT --noui
installStatus=$(ls -1 /Applications/ | grep "Cylance")

if [[ $installStatus == "Cylance" ]]; then
    echo "Cylance will be removed."
    /Applications/Cylance/Uninstall\ CylancePROTECT.app/Contents/MacOS/Uninstall\ CylancePROTECT
    echo "Cylance has been removed."
    jamf recon
else
    echo "Cylance was not detected."
fi

exit 0
