#!/bin/zsh -v

# Get the username of the currently logged-in user
loggedInUser=$( /usr/bin/stat -f %Su "/dev/console" )

# Check if the logged-in user variable is empty
if [[ -z "$loggedInUser" ]]; then
    echo "Error: Unable to determine the currently logged-in user."
    exit 1
fi

# Print the username of the currently logged-in user
echo "Currently logged-in user: $loggedInUser"

# Get the real name of the logged-in user
loggedinusername=$( /usr/libexec/PlistBuddy -c "print :dsAttrTypeStandard\:RealName:0" /dev/stdin <<< $(dscl -plist . read /Users/$loggedInUser RealName) )

# Check if the real name variable is empty
if [[ -z "$loggedinusername" ]]; then
    echo "Error: Unable to retrieve the real name of the logged-in user."
    exit 1
fi

# Print the real name of the logged-in user
echo "Real name of the logged-in user: $loggedinusername"

# Change ownership of the logged-in user's home directory recursively
chownResult=$(sudo chown -R $loggedInUser /Users/$loggedInUser 2>&1)

# Check the exit status of the chown command
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to change ownership of the user's home directory."
    echo "Error message: $chownResult"
    exit 1
fi

echo "Ownership of the user's home directory successfully changed."
