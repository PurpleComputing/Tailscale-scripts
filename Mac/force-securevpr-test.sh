#!/bin/sh
echo "*** PURPLE LAUNCH TAILSCALE SCRIPT ***"
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

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")
runAsUser() {  
  if [ "$currentUser" != "loginwindow" ]; then
	launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
	echo "no user logged in"
	exit 1
  fi
}
defaults write io.tailscale.ipn.macos ManagedByOrganizationName "Purple Computing"  

TSUSER=$(echo $TSUNAME | sed 's/_//g' | sed 's/ //g')

sudo -u $(stat -f "%Su" /dev/console) osascript <<EOF
tell application "Tailscale"
	activate
end tell
EOF

runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale up --exit-node secure-vpr  --hostname "$TSUSER"
