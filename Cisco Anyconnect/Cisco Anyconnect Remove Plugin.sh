#!/bin/bash

#This script is a workaround for AnyConnect 4.x, due to Cisco not providing a mechanism to 
# programmatically omit unwanted plugins.  It is intended to run post-install

echo "Beginning removal of AnyConnect plugins"

#remove ISE plugin
echo "Removing ISE plugin"
rm -rf /opt/cisco/anyconnect/bin/plugins/libaciseapi.dylib
rm -rf /opt/cisco/anyconnect/bin/plugins/libaciseshim.dylib

#remove AMP plugin
echo "Removing AMP plugin"
rm -rf /opt/cisco/anyconnect/bin/plugins/libacampctrl.dylib
rm -rf /opt/cisco/anyconnect/bin/plugins/libacampshim.dylib

#remove Roaming plugin
echo "Removing Roaming plugin"
rm -rf /opt/cisco/anyconnect/bin/plugins/libacumbrellaapi.dylib
rm -rf /opt/cisco/anyconnect/bin/plugins/libacumbrellactrl.dylib


#Remove Network Visibility Monitor plugin
echo "Removing NVM plugin"
rm -rf /opt/cisco/anyconnect/bin/plugins/libacnvmctrl.dylib

echo "Finished removing AnyConnect plugins"

exit 0
