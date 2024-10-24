#!/bin/bash -v
loggedInUser=$( /bin/stat -f%Su "/dev/console" )
# Define the user name and directory paths
USERNAME="$loggedInUser"
echo $USERNAME
HOME_DIR="/Users/$loggedInUser"

# Function to reset network settings
# reset_network_settings() {
# echo "Resetting network settings..."

# Remove network preferences
# rm -rf /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist
# rm -rf /Library/Preferences/SystemConfiguration/com.apple.network.identification.plist
# rm -rf /Library/Preferences/SystemConfiguration/com.apple.wifi.message-tracer.plist
# rm -rf /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist
# rm -rf /Library/Preferences/SystemConfiguration/preferences.plist

# Restart network services
# echo "Restarting network services..."
# networksetup -detectnewhardware
# }

# Function to clear caches
clear_caches() {
   echo "Clearing caches..."

# Clear user caches
rm -rf $HOME_DIR/Library/Caches/*
rm -rf $HOME_DIR/Library/Containers/com.apple.systempreferences/Data/Library/Caches/*

# Clear system caches
rm -rf /Library/Caches/*
rm -rf /System/Library/Caches/*
}

# Function to reset home directory permissions
reset_home_permissions() {
  echo "Resetting home permissions..."

# Reset ownership of the home directory
chown -R admin:staff $HOME_DIR

# Set proper permissions for the home directory and subdirectories
find $HOME_DIR -type d -exec chmod 755 {} \;

# Set proper permissions for files in the home directory
find $HOME_DIR -type f -exec chmod 644 {} \;

# Special handling for specific directories which require differing permissions
chmod 700 $HOME_DIR/Library
chmod 700 $HOME_DIR/.ssh
chmod 700 $HOME_DIR/.gnupg
}

# Run the functions
# reset_network_settings
clear_caches
reset_home_permissions

# Inform the user
echo "Network settings reset, caches cleared, and hom directory permssions reset."
echo "Please restart your MacBook and try logging in with the primary user account again."
