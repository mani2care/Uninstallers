#!/bin/sh

ANYCONNECT_APPLICATIONNAME="Cisco AnyConnect Secure Mobility Client"
INSTPREFIX="/opt/cisco/anyconnect"
POSTURE_BINDIR="/opt/cisco/hostscan/bin64/"
ANYCONNECT_BINDIR=${INSTPREFIX}/bin
NVM_BINDIR=${INSTPREFIX}/NVM/bin

VPN_UNINST=${ANYCONNECT_BINDIR}/vpn_uninstall.sh
FIREAMP_UNINST=${ANYCONNECT_BINDIR}/amp_uninstall.sh
POSTURE_UNINST=${POSTURE_BINDIR}/posture_uninstall.sh
ISEPOSTURE_UNINST=${ANYCONNECT_BINDIR}/iseposture_uninstall.sh
ISECOMPLIANCE_UNINST=${ANYCONNECT_BINDIR}/isecompliance_uninstall.sh
NVM_UNINST=${NVM_BINDIR}/nvm_uninstall.sh
OPENDNS_UNINST=${ANYCONNECT_BINDIR}/umbrella_uninstall.sh
Dart_UNINST=${ANYCONNECT_BINDIR}/dart_uninstall.sh

# Uninstall Cisco AnyConnect Socket Filter app
#if [[ -e "/Applications/Cisco/Cisco AnyConnect Socket Filter.app" ]]; then
 #   echo "Uninstalling Cisco AnyConnect Socket Filter app..."
 #   /bin/rm -rf "/Applications/Cisco/Cisco AnyConnect Socket Filter.app"
  #  echo "Cisco AnyConnect Socket Filter app uninstalled successfully."
#else
 #   echo "Cisco AnyConnect Socket Filter app not found on this machine."
#fi

# Gracefully quit the AnyConnect App prior to running uninstall script(s)
echo "Exiting ${ANYCONNECT_APPLICATIONNAME}"
osascript -e "quit app \"${ANYCONNECT_APPLICATIONNAME}\"" > /dev/null 2>&1

# Force Quit AnyConnect
pkill -x "Cisco AnyConnect Secure Mobility Client"

# Gracefully quit the AnyConnect App prior to running uninstall script(s)
echo "Exiting ${ANYCONNECT_APPLICATIONNAME}"
osascript -e "quit app \"${ANYCONNECT_APPLICATIONNAME}\"" > /dev/null 2>&1

# Uninstall AnyConnect Dart Module
if [ -x "${Dart_UNINST}" ]; then
  sudo "${Dart_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Dart Module."
  fi
fi

# Uninstall AnyConnect ISE Posture Module
if [ -x "${ISEPOSTURE_UNINST}" ]; then
  sudo "${ISEPOSTURE_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect ISE Posture Module."
  fi
fi

# Uninstall AnyConnect ISE Compliance Module
if [ -x "${ISECOMPLIANCE_UNINST}" ]; then
  sudo "${ISECOMPLIANCE_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect ISE Compliance Module."
  fi
fi

# Uninstall AnyConnect Posture Module
if [ -x "${POSTURE_UNINST}" ]; then
  sudo "${POSTURE_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Posture Module."
  fi
fi

# Uninstall AnyConnect Roaming Security Module
if [ -x "${OPENDNS_UNINST}" ]; then
  sudo "${OPENDNS_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Roaming Security Module."
  fi
fi

# Uninstall AMP Enabler Module
if [ -x "${FIREAMP_UNINST}" ]; then
  sudo "${FIREAMP_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AMP Enabler Module."
  fi
fi

# Uninstall Network Visibility Module
if [ -x "${NVM_UNINST}" ]; then
  sudo "${NVM_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Network Visibility Module."
  fi
fi

# Uninstall AnyConnect Secure Mobility Client
if [ -x "${VPN_UNINST}" ]; then
  sudo "${VPN_UNINST}"
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Secure Mobility Client."
  fi
fi

# Remove remaining AnyConnect files
sudo rm -rf /Applications/Cisco*
sudo rm -rf /opt/cisco*

exit 0
