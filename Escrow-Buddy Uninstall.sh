#!/bin/bash
#  This script uninstalls Escrow Buddy.

AuthDBTeardown() {
    # Create temporary directory for storage of authorization database files
    # Using hyphen to prevent escape issues in PlistBuddy commands
    EB_DIR="${TMPDIR:=/private/tmp}/com.netflix.Escrow-Buddy"
    mkdir -pv "$EB_DIR"
    AUTH_DB="$EB_DIR/auth.db"

    # Output current loginwindow auth database
    echo "Reading system.login.console section of authorization database..."
    /usr/bin/security authorizationdb read system.login.console > "$AUTH_DB"
    if [[ ! -f "$AUTH_DB" ]]; then
        echo "ERROR: Unable to save the current authorization database."
        exit 1
    fi

    # Check current loginwindow auth database for desired entry
    if ! grep -q '<string>Escrow Buddy:Invoke,privileged</string>' "$AUTH_DB"; then
        echo "Escrow Buddy is not configured in the loginwindow authorization database."
        return
    fi

    # Create a backup copy
    cp "$AUTH_DB" "$AUTH_DB.backup"

    echo "Removing Escrow Buddy from authorization database..."
    INDEX=$(/usr/libexec/PlistBuddy -c "Print :mechanisms:" "$AUTH_DB" 2>/dev/null | grep -n "Escrow Buddy:Invoke,privileged" | awk -F ":" '{print $1}')
    if [[ -z $INDEX ]]; then
        echo "ERROR: Unable to index current loginwindow authorization database."
        exit 1
    fi

    # Subtract 2 from the index to account for PlistBuddy output format
    INDEX=$((INDEX-2))

    # Remove Escrow Buddy mechanism
    /usr/libexec/PlistBuddy -c "Delete :mechanisms:$INDEX" "$AUTH_DB"

    # Save authorization database changes
    if ! security authorizationdb write system.login.console < "$AUTH_DB"; then
        echo "ERROR: Unable to save changes to authorization database."
        exit 1
    fi
}

# If in-bundle AuthDB teardown script exists on disk, prefer using that
echo "Removing Escrow Buddy from authorization database..."
"/Library/Security/SecurityAgentPlugins/Escrow Buddy.bundle/Contents/Resources/AuthDBTeardown.sh" || AuthDBTeardown

echo "Deleting Escrow Buddy bundle..."
rm -rf "/Library/Security/SecurityAgentPlugins/Escrow Buddy.bundle"

echo "Deleting Escrow Buddy preferences..."
defaults delete "/Library/Preferences/com.netflix.Escrow-Buddy.plist"

echo "Forgetting receipt..."
pkgutil --forget "com.netflix.Escrow-Buddy" 2>/dev/null

echo "Escrow Buddy successfully uninstalled."
