#!/bin/bash
#set -x

############################################################################################
##
## Script to enable Extensions
##
############################################################################################
#
# NOTE
# Script must run as root
#
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Original script source: 
## Feedback: 
## Modified for X Company
## Author: X
## 

## Define variables
appname="AppExtensions"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"
log="$logandmetadir/$appname.log"
currentUser=$(stat -f%Su /dev/console)
uid=$(id -u "$currentUser")
Application="/Applications/OneDrive.app"
Application1="/Applications/Microsoft OneNote.app"
# Application2="/Applications/Company Portal.app"
Application3="/Applications/Secure Access.app"
ExtensionName1="com.microsoft.OneDrive-mac.FinderSync"
ExtensionName2="com.microsoft.onenote.mac.shareextension"
# ExtensionName3="com.microsoft.CompanyPortalMac.ssoextension"
# ExtensionName4="com.microsoft.CompanyPortalMac.Mac-Autofill-Extension"
ExtensionName5="SecureAccessVpnExtension.appex"
ExtensionName6="com.apple.bird"

## Check if the log directory has been created
if [ -d $logandmetadir ]; then
    ## Already created
    echo "# $(date) | Log directory already exists - $logandmetadir"
else
    ## Creating Metadirectory
    echo "# $(date) | creating log directory - $logandmetadir"
    mkdir -p $logandmetadir
fi

## Function to delay until the user has finished setup assistant.
waitforSetupAssistant () {
  until [[ -f /var/db/.AppleSetupDone ]]; do
    delay=$(( $RANDOM % 50 + 10 ))
    echo "$(date) |  + Setup Assistant not done, waiting [$delay] seconds"
    sleep $delay
  done
  echo "$(date) | Setup Assistant is done, lets carry on"
}

## Start logging
# exec 1>> $log 2>&1

## Begin script body
echo ""
echo "############################################################################"
echo "# $(date) | Starting Script to Enable app extensions for logged in user"
echo "############################################################################"
echo ""

echo "# $(date) | Waiting for SetupAssistant to finish"
waitforSetupAssistant

echo "# $(date) | Checking variables"
echo "# $(date) | whoami is $(whoami)"
echo "# $(date) | currentUser is $currentUser"
echo "# $(date) | uid is $uid"

echo ""
echo "############################################################################"
echo "# $(date) | Waiting for Applications to be installed"
echo "############################################################################"
echo ""

echo "$(date) | Looking for $Application"

# wait for $Application to be installed
while [[ $ready -ne 1 ]];do

    if [[ -a "$Application" ]]; then
        ready=1
        echo "$(date) | $Application found!"
    else
        echo "$(date) | $Application not installed yet"  
        echo "$(date) | Waiting for 60 seconds" 
        sleep 60
    fi

done

echo "$(date) | Looking for $Application1"

# wait for $Application1 to be installed
while [[ $ready -ne 1 ]];do

    if [[ -a "$Application1" ]]; then
        ready=1
        echo "$(date) | $Application1 found!"
    else
        echo "$(date) | $Application1 not installed yet"  
        echo "$(date) | Waiting for 60 seconds" 
        sleep 60
    fi

done

# wait for $Application2 to be installed
# while [[ $ready -ne 1 ]];do

#    if [[ -a "$Application2" ]]; then
#        ready=1
#        echo "$(date) | $Application2 found!"
#    else
#        echo "$(date) | $Application2 not installed yet"  
#        echo "$(date) | Waiting for 60 seconds" 
#        sleep 60
#    fi
#
# done

# wait for $Application3 to be installed
while [[ $ready -ne 1 ]];do

    if [[ -a "$Application3" ]]; then
        ready=1
        echo "$(date) | $Application3 found!"
    else
        echo "$(date) | $Application3 not installed yet"  
        echo "$(date) | Waiting for 60 seconds" 
        sleep 60
    fi

done

echo "$(date) | All Applications have been located!"

## Begin second phase
echo ""
echo "############################################################################"
echo "# $(date) | Continuing to enable the app extensions for the logged on user"
echo "############################################################################"
echo ""

## Get Extension Name Finder Sync (differs between standalone and VPP version)
echo "$(date) | Finding installed OneDrive type (VPP or standalone)" 
if launchctl asuser "$uid" bash -c 'pluginkit -m | grep "com.microsoft.OneDrive-mac.FinderSync"'; then
    echo "$(date) | OneDrive installed via VPP. Extension name is com.microsoft.OneDrive-mac.FinderSync" 
    ExtensionName="com.microsoft.OneDrive-mac.FinderSync"
fi

if launchctl asuser "$uid" bash -c 'pluginkit -m | grep "com.microsoft.OneDrive.FinderSync"'; then
    echo "$(date) | OneDrive installed standalone. Extension name is com.microsoft.OneDrive.FinderSync" 
    ExtensionName="com.microsoft.OneDrive.FinderSync"
fi

## Check if the Finder Sync extension is already enabled and if not enable it
echo "$(date) | Checking $ExtensionName status" 
if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName\""; then
    echo "$(date) | $ExtensionName already enabled" 
else
    echo "$(date) | Enabling $ExtensionName" 
    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName"'"'"

    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName"'"'

    echo "$(date) | Command executed"
fi

## Check if the File Provider extension is already enabled and if not enable it
echo "$(date) | Checking $ExtensionName1 status" 
if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName1\""; then
    echo "$(date) | $ExtensionName1 already enabled" 
else
    echo "$(date) | Enabling $ExtensionName1" 
    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName1"'"'"

    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName1"'"'

    echo "$(date) | Command executed"
fi

## Check if the OneNote sharing extension is already enabled and if not enable it
echo "$(date) | Checking $ExtensionName2 status" 
if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName2\""; then
    echo "$(date) | $ExtensionName2 already enabled" 
else
    echo "$(date) | Enabling $ExtensionName2" 
    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName2"'"'"

    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName2"'"'

    echo "$(date) | Command executed"
fi

## Check if the CompanyPortal SSO extension is already enabled and if not enable it
# echo "$(date) | Checking $ExtensionName3 status" 
# if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName3\""; then
#    echo "$(date) | $ExtensionName3 already enabled" 
# else
#    echo "$(date) | Enabling $ExtensionName3" 
#    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName3"'"'"
#
#    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName3"'"'
#
#    echo "$(date) | Command executed"
# fi

## Check if the MS Entra password autofill extension is already enabled and if not enable it
#echo "$(date) | Checking $ExtensionName4 status" 
# if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName4\""; then
#    echo "$(date) | $ExtensionName4 already enabled" 
# else
#    echo "$(date) | Enabling $ExtensionName4" 
#    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName4"'"'"
#
#    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName4"'"'
#
#    echo "$(date) | Command executed"
# fi
#
## Check if the Absolute Secure Access network extension is already enabled and if not enable it
echo "$(date) | Checking $ExtensionName5 status" 
if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName5\""; then
    echo "$(date) | $ExtensionName5 already enabled" 
else
    echo "$(date) | Enabling $ExtensionName5" 
    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName5"'"'"

    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName5"'"'

    echo "$(date) | Command executed"
fi

## Check if the iCloud network extension is already enabled and if not enable it
echo "$(date) | Checking $ExtensionName6 status"  
if launchctl asuser "$uid" bash -c "pluginkit -m | grep \"+    $ExtensionName6\""; then  
    echo "$(date) | $ExtensionName6 already enabled" 
else  
    echo "$(date) | Enabling $ExtensionName6" 
    echo "$(date) | Running launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName6"'"'" 
 
    launchctl asuser "$uid" bash -c 'pluginkit -e use -i "'"$ExtensionName6"'"' 
    
    echo "$(date) | Command executed"
fi  

## Check results
echo "$(date) | Checking extension results" 
launchctl asuser "$uid" bash -c 'pluginkit -m | grep "com.microsoft.OneDrive.FinderSync"'
launchctl asuser "$uid" bash -c 'pluginkit -m | grep "com.netmotionwireless.MobilityOSX.Extension"'
launchctl asuser "$uid" bash -c 'pluginkit -m | grep "com.apple.bird"'

## End Script
echo ""
echo "############################################################################"
echo "# $(date) | End of Script"
echo "############################################################################"
echo ""
