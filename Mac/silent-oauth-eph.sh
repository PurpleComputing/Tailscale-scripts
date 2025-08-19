#!/bin/sh
echo "____________________________________________"
echo "Start: TAILSCALE SILENT AUTH SCRIPT"
###############################################################################################
#
#                                                        ******
#                                        *...../    /    ******
# **************  *****/  *****/*****/***/*************/ ******  /**********
# ******/..*****/ *****/  *****/********//******/ ,*****/******,*****  ,*****/
# *****/    ***** *****/  *****/*****/    *****/   /**************************
# *******//*****/ *************/*****/    *********************/*******./*/*  ())
# *************    ******/*****/*****/    *****/******/. ******   ********** (()))
# *****/                                  *****/                              ())
# *****/                                  *****/
#
###############################################################################################
# NOTICE: MAC SPECIFIC SCRIPT, USING MOSYLE VARIABLES
###############################################################################################

# DEFAULT VARIABLES
APPNA="Tailscale"
DIR="/Applications/$APPNA.app"
IP1=8.8.8.8
IP2=$(echo "$TSSERVERIP")
DT0=$(date "+%D %T")
echo "Execution Record for $DT0"
echo 

# SOURCES USER INFO FOR RUNASUSER COMMAND BELOW
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")

MODEL_INFO=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/^ *//')
PRETTY_MODEL=${MODEL_INFO/"Model Name: "/}
SERIAL_INFO=$(system_profiler SPHardwareDataType | grep "Serial Number (system)" | sed 's/^ *//')
PRETTY_SERIAL=${SERIAL_INFO/"Serial Number (system): "/}


if [ "$USEMODELANDSERIAL" == "Y" ]; then
	echo "• Organisation includes Model and Serial in Hostname"
	if [[ -z "$TSUNAME" ]]; then
		TSUSER=$(echo "$currentUser-$PRETTY_MODEL-$PRETTY_SERIAL" | tr 'A-Z' 'a-z' | sed 's/ /-/g')
	else
		TSUSER=$(echo "$TSUNAME-$PRETTY_MODEL-$PRETTY_SERIAL" | tr 'A-Z' 'a-z' | sed 's/ /-/g')
  		OLDTSUSER=$(echo "$TSUNAME" | tr 'A-Z' 'a-z' | sed 's/ //g')
	fi
else
	echo "• Organisation uses only Username in Hostname"
	if [[ -z "$TSUNAME" ]]; then
		TSUSER=$(echo "$currentUser" | tr 'A-Z' 'a-z' | sed 's/ /-/g')
	else
		TSUSER=$(echo "$TSUNAME" | tr 'A-Z' 'a-z' | sed 's/ /-/g')
  		OLDTSUSER=$(echo "$TSUNAME" | tr 'A-Z' 'a-z' | sed 's/ //g')
	fi
fi

# SIMPLIFIES RUN AS USER COMMAND FOR STANDARD USER ACCOUNTS WITHOUT SUDO RIGHTS
runAsUser() {
  if [ "$currentUser" != "loginwindow" ]; then
	launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
	  echo 
	echo "• No user is logged in"
	echo 
	echo "End: TAILSCALE SILENT AUTH SCRIPT"
	echo "____________________________________________"
	echo 
	exit 1
  fi
}

# CHECKS TAILSCALE IS PRESENT ON THE DEVICE
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "• $APPNA is installed."
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo 
  echo "• $APPNA is not installed."
  echo 
  echo "End: TAILSCALE SILENT AUTH SCRIPT"
  echo "____________________________________________"
  echo 
  exit 1
fi

runAsUser defaults write io.tailscale.ipn.macos TailscaleOnboardingSeen 1
runAsUser defaults write io.tailscale.ipn.macos TailscaleStartOnLogin 1
defaults write io.tailscale.ipn.macos ManagedByOrganizationName "Purple Computing"  

sleep 3

# OPENS TAILSCALE BEFORE CHECKS
runAsUser osascript -e 'tell application "Tailscale"' -e 'activate' -e 'end tell'

# GIVES TAILSCALE TIME TO OPEN AND CONNECT IF EMPLOYEE AUTHED
sleep 2
# PING GOOGLE FOR NEXT CHECK
PING1=$(ping -c 1 "$IP1" | grep -c from)
sleep 2

# PING TAILSCALE VPR FOR FIRST ATTEMPT
echo "• "Tailscale Ping Address":" "$IP2"
PING2=$(ping -c 1 "$IP2" | grep -c from)

# INTERNET CHECK
if [ "$PING1" -eq "1" ]; then
	echo "• Internet is working"
else
	echo 
	echo "• NO INTERNET... Exit.."
	echo 
	echo "End: TAILSCALE SILENT AUTH SCRIPT"
	echo "____________________________________________"
	echo 
	exit 1
fi

# TAILSCALE ALREADY AUTHED CHECK
if [ "$PING2" -eq "1" ]; then
	#runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --hostname "$TSUSER"
	echo "• Tailscale Ping Address: $IP2 is reachable"
	echo "• Internet is working"
	TSMNetName="$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale status | head -n 1 | awk '{print $3}' | awk -F'.' '{print $2}')"
	TSMHostname="$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale status | head -n 1 | awk '{print $2}' | awk -F'.' '{print $1}')"
	TSMIP="$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale status | head -n 1 | awk '{print $1}')"
	echo "• User is Authenticated"
 	if [ "$TSEXITNODE" == "N" ]; then
		echo "• Exit Node NOT Enforced"
	else
 sleep 75
  #runAsUser defaults write com.tailscale.ipn.macsys AuthKey -string "tskey-auth-00000000" && killall cfprefsd
		if [[ -z "$TSEXITNODE" ]]; then
			echo "• Exit Node NOT Enforced"
		else
			echo "• Exit Node Enforced"
			runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --exit-node=$TSEXITNODE
		fi
	fi
	echo 
	echo NO INTERVENTION WAS NEEDED
	 echo
	 echo "Tailnet: $TSMNetName"
	  echo "Hostname: $TSMHostname"
	   echo "IP: $TSMIP"
	echo 
	echo "End: TAILSCALE SILENT AUTH SCRIPT"
	echo "____________________________________________"
	echo 
	exit 0

else
	echo 
	echo ATTEMPT"1:" NO AUTH AUTHENTICATING...
	# killall Tailscale
	sleep 3
	runAsUser osascript -e 'tell application "Tailscale"' -e 'activate' -e 'end tell'
	sleep 6
  	runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale switch "$TAILSCALENET"
   	sleep 1
    	runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --hostname "$TSUSER"
	echo 
fi
sleep 7
# PING TAILSCALE VPR AFTER THE FIRST ATTEMPT
PING3=$(ping -c 1 "$IP2" | grep -c from)

# TAILSCALE FINAL AUTH CHECK
if [ "$PING3" -eq "1" ]; then
	echo "• Tailscale Ping Address: $IP2 is reachable"
	 echo "• Internet is working"
	 TSMNetName="$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale status | head -n 1 | awk '{print $3}' | awk -F'.' '{print $2}')"
	  TSMHostname="$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale status | head -n 1 | awk '{print $2}' | awk -F'.' '{print $1}')"
	   TSMIP="$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale status | head -n 1 | awk '{print $1}')"
	echo "• User is Authenticated"
	if [ "$TSEXITNODE" == "N" ]; then
		echo "• Exit Node NOT Enforced"
	else
		if [[ -z "$TSEXITNODE" ]]; then
			echo "• Exit Node NOT Enforced"
		else
			echo "• Exit Node Enforced"
			runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --exit-node=$TSEXITNODE
		fi
	fi
 	echo 
	echo "ATTEMPT 1:" AUTHENTICATED SUCCESSFULLY
	echo
	echo "Tailnet: $TSMNetName"
	echo "Hostname: $TSMHostname"
	echo "IP: $TSMIP"
	echo 
	echo "End: TAILSCALE SILENT AUTH SCRIPT"
	echo "____________________________________________"
	echo 
	exit 0
else
	echo 
	echo ATTEMPT"2:" NO AUTH... AUTHING WITH RESET...
	sleep 2.5
	runAsUser osascript -e 'tell application "Tailscale"' -e 'activate' -e 'end tell'
	if [[ -z "$HOOKHELPER" ]]; then
		echo "• No Webhooks to Fire. Continuing..."
	else
		echo "• Cleaning up Existing Node in TS Admin Portal"
		curl -s --request POST "$HOOKHELPER" -H "Content-Type: application/json; charset=UTF-8" -d '{"tailnet": "'"$TAILSCALENET"'", "apikey": "'"$TAILSCALEAPIKEY"'", "targetname": "'"$TSUSER"'"}'
		curl -s --request POST "$HOOKHELPER" -H "Content-Type: application/json; charset=UTF-8" -d '{"tailnet": "'"$TAILSCALENET"'", "apikey": "'"$TAILSCALEAPIKEY"'", "targetname": "'"$OLDTSUSER"'"}'
	fi
	sleep 1
 	#curl -s https://raw.githubusercontent.com/PurpleComputing/Tailscale-scripts/main/Mac/logout-all.sh | bash
  #runAsUser defaults delete com.tailscale.ipn.macsys AuthKey && killall cfprefsd
  	runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale up --authkey "$TAILSCALEAUTHKEY?ephemeral=true&preauthorized=true" --hostname "$TSUSER" --advertise-tags=tag:$TSTAG --reset
   	sleep 1
 	runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --hostname "$TSUSER"
	echo 
fi
 	
if [ "$TSEXITNODE" == "N" ]; then
	echo "• Exit Node NOT Enforced"
else
	if [[ -z "$TSEXITNODE" ]]; then
	 echo "• Exit Node NOT Enforced"
	else
	 echo "• Exit Node Enforced"
	 runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --exit-node=$TSEXITNODE
	fi
fi
 
echo "End: TAILSCALE SILENT AUTH SCRIPT"
echo "____________________________________________"


exit 0
