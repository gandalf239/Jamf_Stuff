#!/bin/sh

# Set Result to "Not Installed"
result="Not Installed"

# If the Thycotic binary is installed, return the version
if [ -d "/usr/local/thycotic" ] ; then

result=$( cat "/Library/Application Support/Delinea/Agent/com.apple.desktopservices" )

fi

echo "<result>${result}</result>"

exit 0
