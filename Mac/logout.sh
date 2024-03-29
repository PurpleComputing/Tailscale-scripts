#!/bin/bash
# SOURCES USER INFO FOR RUNASUSER COMMAND BELOW
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")
TSUSER=$(echo $currentUser)

# SIMPLIFIES RUN AS USER COMMAND FOR STANDARD USER ACCOUNTS WITHOUT SUDO RIGHTS
runAsUser() {
  if [ "$currentUser" != "loginwindow" ]; then
	launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
  echo 
	echo "no user logged in"
	echo 
	exit 1
  fi
}
defaults write io.tailscale.ipn.macos ManagedByOrganizationName "Purple Computing"  
runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale logout
sleep 2
killall Tailscale
runAsUser rm -rf ~/Library/Containers/io.tailscale.ipn.macsys
runAsUser rm -rf ~/Library/Containers/io.tailscale.ipn.macsys.login-item-helper
runAsUser rm -rf ~/Library/Containers/io.tailscale.ipn.macsys.share-extension
sleep 3
sudo rm -rf /Library/Tailscale/
