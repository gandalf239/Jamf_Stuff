#!/bin/bash -v
	loggedInUser=$( /usr/bin/stat -f %Su "/dev/console" )
    echo $loggedInUser
    loggedinusername=$( /usr/libexec/PlistBuddy -c "print :dsAttrTypeStandard\:RealName:0" /dev/stdin <<< $(dscl -plist . read /Users/$loggedInUser RealName) )
	# This script uses the Jamf Pro API to get an authentication token
	
	# Set default exit code
	exitCode=0
	
	# Explicitly set initial value for the api_token variable to null:
	
	api_token=""
	
	# Explicitly set initial value for the token_expiration variable to null:
	
	token_expiration=""
	
	# If you choose to hardcode API information into the script, set one or more of the following values:
	#
	# The username for an account on the Jamf Pro server with sufficient API privileges
	# The password for the account
	# The Jamf Pro URL
	
	# Set the Jamf Pro URL here if you want it hardcoded.
	jamfpro_url=""	    
	
	# Set the username here if you want it hardcoded.
	jamfpro_user="admin"
	
	# Set the password here if you want it hardcoded.
	jamfpro_password=""	
	
	# Read the appropriate values from ~/Library/Preferences/com.github.jamfpro-info.plist
	# if the file is available. To create the file, run the following commands:
	#
	defaults write /Users/$loggedInUser/Library/Preferences/com.github.jamfpro-info jamfpro_url
	defaults write /Users/$loggedInUser/Library/Preferences/com.github.jamfpro-info jamfpro_user
	defaults write /Users/$loggedInUser/Library/Preferences/com.github.jamfpro-info jamfpro_password
	#
	
	if [[ -f "$HOME/Library/Preferences/com.github.jamfpro-info.plist" ]]; then
	
	     if [[ -z "$jamfpro_url" ]]; then
	          jamfpro_url=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
	     fi
	
	     if [[ -z "$jamfpro_user" ]]; then
	          jamfpro_user=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user)
	     fi
	
	     if [[ -z "$jamfpro_password" ]]; then
	          jamfpro_password=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password)
	     fi
	
	fi
	
	# If the Jamf Pro URL, the account username or the account password aren't available
	# otherwise, you will be prompted to enter the requested URL or account credentials.
	
	if [[ -z "$jamfpro_url" ]]; then
	     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
	fi
	
	if [[ -z "$jamfpro_user" ]]; then
	     read -p "Please enter your Jamf Pro user account : " jamfpro_user
	fi
	
	if [[ -z "$jamfpro_password" ]]; then
	     read -p "Please enter the password for the $jamfpro_user account: " -s jamfpro_password
	fi
	
	echo
	
	# Remove the trailing slash from the Jamf Pro URL if needed.
	jamfpro_url=${jamfpro_url%%/}
	
	GetJamfProAPIToken() {
	
	# This function uses Basic Authentication to get a new bearer token for API authentication.
	
	# Create base64-encoded credentials from user account's username and password.
	
	encodedCredentials=$(printf "${jamfpro_user}:${jamfpro_password}" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i -)
			
	# Use the encoded credentials with Basic Authorization to request a bearer token
	
	authToken=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/token" –silent –request POST –header "Authorization: Basic ${encodedCredentials}")
		
	# Parse the returned output for the bearer token and store the bearer token as a variable.
	
	if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
	   api_token=$(/usr/bin/awk -F \" 'NR==2{print $4}' <<< "$authToken" | /usr/bin/xargs)
	else
	   api_token=$(/usr/bin/plutil -extract token raw -o – – <<< "$authToken")
	fi
	
	}
	
	APITokenValidCheck() {
	
	# Verify that API authentication is using a valid token by running an API command
	# which displays the authorization details associated with the current API user. 
	# The API call will only return the HTTP status code.
	
	api_authentication_check=$(/usr/bin/curl –write-out %{http_code} –silent –output /dev/null "${jamfpro_url}/api/v1/auth" –request GET –header "Authorization: Bearer ${api_token}")
	
	}
	
	CheckAndRenewAPIToken() {
	
	# Verify that API authentication is using a valid token by running an API command
	# which displays the authorization details associated with the current API user. 
	# The API call will only return the HTTP status code.
	
	APITokenValidCheck
	
	# If the api_authentication_check has a value of 200, that means that the current
	# bearer token is valid and can be used to authenticate an API call.
	
	
	if [[ ${api_authentication_check} == 200 ]]; then
	
	# If the current bearer token is valid, it is used to connect to the keep-alive endpoint. This will
	# trigger the issuing of a new bearer token and the invalidation of the previous one.
	#
	# The output is parsed for the bearer token and the bearer token is stored as a variable.
	
	      authToken=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/keep-alive" –silent –request POST –header "Authorization: Bearer ${api_token}")
	      if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
	         api_token=$(/usr/bin/awk -F \" 'NR==2{print $4}' <<< "$authToken" | /usr/bin/xargs)
	      else
	         api_token=$(/usr/bin/plutil -extract token raw -o – – <<< "$authToken")
	      fi
	else
	
	# If the current bearer token is not valid, this will trigger the issuing of a new bearer token
	# using Basic Authentication.
	
	   GetJamfProAPIToken
	fi
	}
	
	InvalidateToken() {
	
	# Verify that API authentication is using a valid token by running an API command
	# which displays the authorization details associated with the current API user. 
	# The API call will only return the HTTP status code.
	
	APITokenValidCheck
	
	# If the api_authentication_check has a value of 200, that means that the current
	# bearer token is valid and can be used to authenticate an API call.
	
	if [[ ${api_authentication_check} == 200 ]]; then
	
	# If the current bearer token is valid, an API call is sent to invalidate the token.
	
	      authToken=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/invalidate-token" –silent  –header "Authorization: Bearer ${api_token}" -X POST)
	      
	# Explicitly set value for the api_token variable to null.
	
	      api_token=""
	
	fi
	}
	
	GetJamfProAPIToken
	
	APITokenValidCheck
	
	echo "$api_authentication_check"
	
	echo "$api_token"
	
	CheckAndRenewAPIToken
	
	APITokenValidCheck
	
	echo "$api_authentication_check"
	
	echo "$api_token"
	
	InvalidateToken
	
	APITokenValidCheck
	
	echo "$api_authentication_check"
	
	echo "$api_token"