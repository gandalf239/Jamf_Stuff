#!/bin/bash

# Stop the NetMotion and Absolute services if they are running
launchctl stop com.netmotionsoftware.nmcService
launchctl stop com.netmotionsoftware.nmcd
launchctl stop com.absolute.amc.agent

# Remove NetMotion and Absolute Secure Mobility profiles
profiles=$(profiles -C | grep "NetMotion\|Absolute Secure Mobility" | awk '{print $4}')
for profile in $profiles; do
    echo "Removing profile: $profile"
    profiles -R -p "$profile"
done

# Remove any residual configuration files
rm -rf /Library/NetMotion
rm -rf /Library/Preferences/com.netmotionsoftware.*
rm -rf /Library/Preferences/com.absolute.*

# Remove VPN network filter driver and kernel extension references from the system network plist file
network_plist="/Library/Preferences/SystemConfiguration/preferences.plist"
if [[ -f "$network_plist" ]]; then
    echo "Removing VPN network filter driver and kernel extension references from the system network plist file..."
    plutil -remove NetworkServices "$network_plist"
fi

# Restart the affected services
launchctl start com.netmotionsoftware.nmcService
launchctl start com.netmotionsoftware.nmcd
launchctl start com.absolute.amc.agent

echo "Cleanup completed successfully."
