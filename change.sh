MACADDRESS=$(networksetup -getmacaddress en0 | awk '{ print $3 }')
JSS=
API_USER=
API_PASS=
# request auth token
authToken=$( /usr/bin/curl \
--request POST \
--silent \
--url "$JSS/api/v1/auth/token" \
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

ASSET_TAG_INFO=$(curl -s -k -H "Authorization: Bearer $token" $JSS/JSSResource/computers/macaddress/$MACADDRESS | xmllint --xpath '/computer/general/asset_tag/text()' -)
SERIAL_NUMBER=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
currentmodel=$( /usr/sbin/system_profiler SPHardwareDataType | grep "Model Name" | grep "MacBook" )

if [[ $currentmodel == *'MacBook'* ]];
then
   model="L"
else
   model="D"
fi

if [ -n "$ASSET_TAG_INFO" ]; then
  echo "Processing new name for this client..."
  echo "Changing name..."
  /usr/sbin/scutil --set HostName ITS-"$ASSET_TAG_INFO"-$model
  /usr/sbin/scutil --set ComputerName ITS-"$ASSET_TAG_INFO"-$model
  /usr/sbin/scutil --set LocalHostName ITS-"$ASSET_TAG_INFO"-$model
  echo "Name change complete. (ITS-$ASSET_TAG_INFO-$model)"
  jamf recon --verbose
  
  
else
  echo "Asset Tag information was unavailable. Using Serial Number instead."
  echo "Changing Name..."
  /usr/sbin/scutil --set HostName ITS-$SERIAL_NUMBER-$model
  /usr/sbin/scutil --set ComputerName ITS-$SERIAL_NUMBER-$model
  /usr/sbin/scutil --set LocalHostName ITS-$SERIAL_NUMBER-$model
  echo "Name Change Complete (ITS-$SERIAL_NUMBER-$model)"
  jamf recon -verbose

fi

# Disable hostname modification
sudo scutil --set HostName "$(scutil --get ComputerName)"
sudo scutil --set LocalHostName "$(scutil --get ComputerName)"
sudo scutil --set ComputerName "$(scutil --get ComputerName)"
