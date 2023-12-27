#!/bin/sh
echo "Start: *** PURPLE LAUNCH TAILSCALE SILENT AUTH SCRIPT ***"
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

# VARIABLES IN USE FROM CONSOLE
# TAILSCALEAUTHKEY
# TSSERVERIP

# DEFAULT VARIABLES
APPNA="Tailscale"
DIR="/Applications/$APPNA.app"
IP1=8.8.8.8
IP2=$(echo "$TSSERVERIP")
DT0=$(date)
echo "Execution Record for $DT0"

# SOURCES USER INFO FOR RUNASUSER COMMAND BELOW
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")

MODEL_INFO=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/^ *//')
PRETTY_MODEL=${MODEL_INFO/"Model Name: "/}
SERIAL_INFO=$(system_profiler SPHardwareDataType | grep "Serial Number (system)" | sed 's/^ *//')
PRETTY_SERIAL=${SERIAL_INFO/"Serial Number (system): "/}

if [[ -z "$TSUNAME" ]]; then
	TSUSER=$(echo "$currentUser-$PRETTY_MODEL-$PRETTY_SERIAL" | tr 'a-z' 'A-Z' | sed 's/ /-/g')
else
	TSUSER=$(echo "$TSUNAME-$PRETTY_MODEL-$PRETTY_SERIAL" | tr 'a-z' 'A-Z' | sed 's/ /-/g')
fi

# SIMPLIFIES RUN AS USER COMMAND FOR STANDARD USER ACCOUNTS WITHOUT SUDO RIGHTS
runAsUser() {
  if [ "$currentUser" != "loginwindow" ]; then
	launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
  	echo 
	echo "no user logged in"
	echo 
	echo "End: *** PURPLE LAUNCH TAILSCALE FORCE AUTH SCRIPT ***"
	echo 
	exit 1
  fi
}

# CHECKS TAILSCALE IS PRESENT ON THE DEVICE
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo 
  echo "$APPNA is installed."
  echo 
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo 
  echo "$APPNA is not installed."
  echo 
  echo "End: *** PURPLE LAUNCH TAILSCALE FORCE AUTH SCRIPT ***"
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
sleep 12

# PING GOOGLE FOR NEXT CHECK
PING1=$(ping -c 1 "$IP1" | grep -c from)

echo Using "$IP2" as Tailscale connected check
# PING TAILSCALE VPR FOR FIRST ATTEMPT
PING2=$(ping -c 1 "$IP2" | grep -c from)

# INTERNET CHECK
if [ "$PING1" -eq "1" ]; then
	echo 
	echo Internet is working
	echo 
else
	echo 
	echo NO INTERNET... Exit..
	echo 
	echo "End: *** PURPLE LAUNCH TAILSCALE FORCE AUTH SCRIPT ***"
	echo 
	exit 1
fi

# TAILSCALE ALREADY AUTHED CHECK
if [ "$PING2" -eq "1" ]; then
	echo 
	echo Server $IP2 is reachable, internet is working
	echo and the user is already authenticated
	echo 
	echo NO INTERVENTION WAS NEEDED
	echo 
	echo "End: *** PURPLE LAUNCH TAILSCALE FORCE AUTH SCRIPT ***"
	echo 
	exit 0

else
	echo 
	echo ROUND"1:"NO AUTH AUTHENTICATING...
	killall Tailscale
	sleep 5
	runAsUser osascript -e 'tell application "Tailscale"' -e 'activate' -e 'end tell'
	sleep 7
	runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale up --authkey "$TAILSCALEAUTHKEY" --hostname "$TSUSER"
	echo 
fi
sleep 25
# PING TAILSCALE VPR AFTER THE FIRST ATTEMPT
PING3=$(ping -c 1 "$IP2" | grep -c from)

# TAILSCALE FINAL AUTH CHECK
if [ "$PING3" -eq "1" ]; then
	echo 
	echo Server $IP2 is now reachable 
	echo "internet is working, and the user is authenticated"
	echo 
	echo "End: *** PURPLE LAUNCH TAILSCALE FORCE AUTH SCRIPT ***"
	echo 
	exit 0
else
	echo 
	echo ROUND"2:" NO AUTH AUTHENTICATING WITH RESET...
	sleep 5
	runAsUser osascript -e 'tell application "Tailscale"' -e 'activate' -e 'end tell'
	if [[ -z "$HOOKHELPER" ]]; then
		echo No Webhooks to Fire. Continuing...
	else
		curl -s --request POST "$HOOKHELPER" -H "Content-Type: application/json; charset=UTF-8" -d '{"tailnet": "'"$TAILSCALENET"'", "apikey": "'"$TAILSCALEAPIKEY"'", "targetname": "'"$TSUSER"'"}'
		curl -s --request POST "$HOOKHELPER" -H "Content-Type: application/json; charset=UTF-8" -d '{"tailnet": "'"$TAILSCALENET"'", "apikey": "'"$TAILSCALEAPIKEY"'", "targetname": "'"$TSUNAME"'"}'
	fi
 	sleep 5
	runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale up --authkey "$TAILSCALEAUTHKEY" --hostname "$TSUSER" --reset
	echo 
fi

echo "End: *** PURPLE LAUNCH TAILSCALE FORCE AUTH SCRIPT ***"

exit 0
