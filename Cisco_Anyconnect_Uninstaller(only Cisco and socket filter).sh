#!/bin/bash

LEGACY_INSTPREFIX=/opt/cisco/vpn
LEGACY_UNINST="/opt/cisco/vpn/bin/vpn_uninstall.sh"

INSTPREFIX=/opt/cisco/anyconnect
PLUGINDIR=${INSTPREFIX}/bin/plugins
UNINST="/opt/cisco/anyconnect/bin/vpn_uninstall.sh"

UNINST_NVM="${INSTPREFIX}/NVM/bin/nvm_uninstall.sh"

LEGACY_UNINST_NVM="/opt/cisco/anyconnect/bin/nvm_uninstall.sh"
if [ -x ${LEGACY_UNINST_NVM} ]; then
  sed -i '' -e 's/libboost_/libboostx_/' ${LEGACY_UNINST_NVM}
fi

# if Standalone NVM is installed then call its uninstall script
# and pass a flag to save config files
if [ -x ${UNINST_NVM} ] && [ ! -e "${PLUGINDIR}/libacnvmctrl.dylib" ] ; then
    ${UNINST_NVM} -saveconfig
    if [ "$?" -ne "0" ]; then
        echo "Error removing Standalone NVM. Continuing..."
    fi
fi

UNINST_WEBSEC="/opt/cisco/anyconnect/bin/websecurity_uninstall.sh"
if [ -x ${UNINST_WEBSEC} ]; then
  sed -i '' -e 's/libboost_/libboostx_/' ${UNINST_WEBSEC}
fi

if [ -x ${UNINST} ]; then
  ${UNINST} true
  if [ "$?" -ne "0" ]; then
    echo "Error removing previous version!  Continuing..."
  fi
elif [ -x ${LEGACY_UNINST} ]; then
  ${LEGACY_UNINST}
  if [ "$?" -ne "0" ]; then
    echo "Error removing previous legacy version!  Continuing..."
  fi

  # migrate the /opt/cisco/vpn directory to /opt/cisco/anyconnect directory
  echo "Migrating ${LEGACY_INSTPREFIX} directory to ${INSTPREFIX} directory"

  mkdir -p ${INSTPREFIX}

  # local policy file
  if [ -f "${LEGACY_INSTPREFIX}/AnyConnectLocalPolicy.xml" ]; then
    mv -f ${LEGACY_INSTPREFIX}/AnyConnectLocalPolicy.xml ${INSTPREFIX}/ >/dev/null 2>&1
  fi

  # global preferences
  if [ -f "${LEGACY_INSTPREFIX}/.anyconnect_global" ]; then
    mv -f ${LEGACY_INSTPREFIX}/.anyconnect_global ${INSTPREFIX}/ >/dev/null 2>&1
  fi

  # logs
  mv -f ${LEGACY_INSTPREFIX}/*.log ${INSTPREFIX}/ >/dev/null 2>&1

  # VPN profiles
  if [ -d "${LEGACY_INSTPREFIX}/profile" ]; then
    mkdir -p ${INSTPREFIX}/profile
    tar cf - -C ${LEGACY_INSTPREFIX}/profile . | (cd ${INSTPREFIX}/profile; tar xf -)
    rm -rf ${LEGACY_INSTPREFIX}/profile
  fi

  # VPN scripts
  if [ -d "${LEGACY_INSTPREFIX}/script" ]; then
    mkdir -p ${INSTPREFIX}/script
    tar cf - -C ${LEGACY_INSTPREFIX}/script . | (cd ${INSTPREFIX}/script; tar xf -)
    rm -rf ${LEGACY_INSTPREFIX}/script
  fi

  # localization
  if [ -d "${LEGACY_INSTPREFIX}/l10n" ]; then
    mkdir -p ${INSTPREFIX}/l10n
    tar cf - -C ${LEGACY_INSTPREFIX}/l10n . | (cd ${INSTPREFIX}/l10n; tar xf -)
    rm -rf ${LEGACY_INSTPREFIX}/l10n
  fi
fi

exit 0
