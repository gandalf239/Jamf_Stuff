#!/bin/zsh -v


#	This script was written when I noticed a number of machines with no Last-Check-in date in the JSS. Depending 
#	on the size of your enterprise and the number of enrolled computers, this script will take some time to complete.
#	You can pipe the results to a file to save the results. Otherwise the output is to stdout. 

#	Author:		Andrew Thomson
#	Date:		08-10-2016


loggedInUser=$( /usr/bin/stat -f %Su "/dev/console" )
JSS_USER=$( /usr/libexec/PlistBuddy -c "print :dsAttrTypeStandard\:RealName:0" /dev/stdin <<< $(dscl -plist . read /Users/$loggedInUser RealName) )
JSS_URL=""
API_USER=""
API_PASS=""
if ! JSS_URL=`/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url`; then
	echo "ERROR: Unable to read default url."
	exit $LINENO
fi


if [ -z $JSS_USER ]; then
	JSS_USER=$JSS_USER
fi 


if [ -z $JSS_PASSWORD ]; then 
	echo "Please enter JSS password for account: $JSS_USER."
	read -s JSS_PASSWORD
fi

# request auth token
authToken=$( /usr/bin/curl \
--request POST \
--silent \
--url "$JSS_URL/api/v1/auth/token" \
--user "$API_USER:$API_PASS" )

echo "$authToken"

# parse auth token
token=$( /usr/bin/plutil \
-extract token raw - <<< "$authToken" )

tokenExpiration=$( /usr/bin/plutil \
-extract expires raw - <<< "$authToken" )

localTokenExpirationEpoch=$( TZ=GMT /bin/date -j \
-f "%Y-%m-%dT%T" "$tokenExpiration" \
+"%s" 2> /dev/null )

echo Token: "$token"
echo Expiration: "$tokenExpiration"
echo Expiration epoch: "$localTokenExpirationEpoch"

#	get computers ids
COMPUTERS=(`/usr/bin/curl -X GET -H "Accept: application/xml" -s -H "Authorization: Bearer $token" $JSS_URL/JSSResource/computers | /usr/bin/xpath -e "//id" 2> /dev/null | awk -F'</?id>' '{for(i=2;i<=NF;i++) print $i}'`)


#	enumerate computers for last check-in time
for COMPUTER in ${COMPUTERS[@]}; do
	LAST_CONTACT_TIME=`/usr/bin/curl -X GET -H "Accept: application/xml" -s -H "Authorization: Bearer $token" $JSS_URL/JSSResource/computers/id/$COMPUTER/subset/general | /usr/bin/xpath -e "/computer/general/last_contact_time/text()" 2> /dev/null`
        echo $LAST_CONTACT_TIME
	if [ "$LAST_CONTACT_TIME" == "" ]; then 
		/usr/bin/curl -X GET -H 
        
"Accept: application/xml" -s -H "Authorization: Bearer $token" $JSS_URL%/JSSResource/computers/id/$COMPUTER/subset/general | /usr/bin/xpath -e "/computer/general/name/text()" >> /private/var/tmp/computer.txt
		echo $'\r'
	fi
done


#	audible completion sound
/usr/bin/afplay /System/Library/Sounds/Glass.aiff

