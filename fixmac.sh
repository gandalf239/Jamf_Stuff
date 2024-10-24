#!/bin/bash -v

# Function to clear system caches
clear_system_caches() {
    echo "Clearing system caches..."
    sudo rm -rf /Library/Caches/*
    sudo rm -rf /System/Library/Caches/*
    echo "System caches cleared."
}

# Function to repair disk permissions
repair_disk_permissions() {
    echo "Repairing disk permissions..."
    diskutil resetUserPermissions / $(id -u)
    echo "Disk permissions repaired."
}

# Function to check and repair disk
check_and_repair_disk() {
    echo "Checking and repairing disk..."
    diskutil verifyVolume /
    diskutil repairVolume /
    echo "Disk checked and repaired."
}

# Function to reset NVRAM and SMC
reset_nvram_smc() {
    echo "Resetting NVRAM and SMC..."
    sudo nvram -c
    sudo rm /Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist
    sudo rm /Library/Preferences/SystemConfiguration/com.apple.AutoWake.plist
    sudo shutdown -r now
    echo "NVRAM and SMC reset. System will restart."
}

# Function to detect CPU architecture
detect_cpu_architecture() {
    echo "Detecting CPU architecture..."
    cpu_arch=$(uname -m)
    if [[ "$cpu_arch" == "x86_64" ]]; then
        echo "Intel-based Mac detected."
    elif [[ "$cpu_arch" == "arm64" ]]; then
        echo "Apple Silicon Mac detected."
    else
        echo "Unknown CPU architecture: $cpu_arch"
    fi
}

# Main script
echo "Attempting to rectify GUI slowness and beachballing issues..."

# Detect CPU architecture
detect_cpu_architecture

# Clear system caches
clear_system_caches

# Repair disk permissions
repair_disk_permissions

# Check and repair disk
check_and_repair_disk

# Reset NVRAM and SMC
reset_nvram_smc

echo "GUI slowness and beachballing issues may have been addressed. System will restart."
