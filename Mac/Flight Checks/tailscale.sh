#!/bin/bash
####################################################################################################
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
# ATTENTION - DISCLAIMER
# YOU USE THIS SCRIPT AT YOUR OWN RISK. THE SCRIPT IS PROVIDED FOR USE “AS IS” WITHOUT WARRANTY OF
# ANY KIND. TO THE MAXIMUM EXTENT PERMITTED BY LAW PURPLE COMPUTING DISCLAIMS ALL WARRANTIES OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, IMPLIED WARRANTIES OR CONDITIONS
# OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. PURPLE COMPUTING CANNOT
# BE HELD LIABLE FOR DAMAGES CAUSED BY THE EXECUTION OF THIS CODE.
#
####################################################################################################
# tailscale.sh SCMv2.0-aaaaa1
# Last Updated by Purple, 05/02/2025
####################################################################################################
echo " "

####################################################################################################
## Variables
####################################################################################################
# tschannel=""
# tsversion=""
# tsbundle=""
# tailnet=""
#tsserverip=""
loggedInUser=$(stat -f "%Su" /dev/console)
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser")

####################################################################################################
## Functions
####################################################################################################
runAsUser() {
  if [ "$currentUser" != "loginwindow" ]; then
	launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
	  echo
	echo "No user is logged in"
	echo
	#echo "*** END tailscale-intial-launch.sh ***"
	echo " "
	exit 1
  fi
}

check_auth_profile() {
	if profiles list | grep -q "com.purplecomputing.mdm.tailscale.authkey"; then
		echo "Auth Profile Present"
	else
		echo "Error: Auth Profile Not Found. Script Failed."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi
}

check_config_profile() {
	if profiles list | grep -q "com.purplecomputing.mdm.tailscale"; then
		echo "Config Profile Present"
	else
		echo "Error: Config Profile Not Found. Script Failed."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi
}

check_tailscale_channel() {
	local plist="/Applications/Tailscale.app/Contents/Info.plist"

	# Ensure the plist file exists
	if [[ ! -f "$plist" ]]; then
		echo "Error: Info.plist not found at $plist"
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi

	# Extract the bundle identifier
	local bundle_id
	bundle_id=$(defaults read "$plist" CFBundleIdentifier 2>/dev/null)

	# Determine the channel type
	case "$bundle_id" in
		"io.tailscale.ipn.macsys")
			tschannel="STNDALONE"
			tsbundle=io.tailscale.ipn.macsys
			;;
		"io.tailscale.ipn.macos")
			tschannel="VPP"
			tsbundle=io.tailscale.ipn.macos
			;;
		*)
			echo "Error: Unknown bundle identifier '$bundle_id'"
			#echo "*** END tailscale-intial-launch.sh ***"
			echo " "
			exit 1
			;;
	esac

	echo "Tailscale channel: $tschannel"
}

check_tailscale_installed() {
	local app_path="/Applications/Tailscale.app"

	if [[ ! -d "$app_path" ]]; then
		echo "Error: Tailscale is not installed."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi
}

check_tailscale_update() {
	local plist="/Applications/Tailscale.app/Contents/Info.plist"

	# Ensure the plist file exists
	if [[ ! -f "$plist" ]]; then
		echo "Error: Info.plist not found. Tailscale may not be installed."
		return 1
	fi

	# Read the installed version from the plist
	tsversion=$(defaults read "$plist" CFBundleShortVersionString 2>/dev/null)

	# Check if the version was successfully retrieved
	if [[ -z "$tsversion" ]]; then
		echo "Error: Unable to determine installed Tailscale version."
		return 1
	fi

	echo "Installed Tailscale version: $tsversion"

	# Fetch the latest available version from Tailscale's stable release page
	appNewVersion=$(curl -s https://pkgs.tailscale.com/stable/ | awk -F- '/Tailscale.*macos.zip/ {print $2}' | sort -V | tail -n 1)

	# Check if we successfully retrieved the latest version
	if [[ -z "$appNewVersion" ]]; then
		echo "Error: Unable to fetch the latest Tailscale version."
		return 1
	fi

	echo "Latest available Tailscale version: $appNewVersion"

	# Compare versions
	if [[ "$tsversion" == "$appNewVersion" ]]; then
		echo "Tailscale is up to date."
	else
		echo "Update available! Installed: $tsversion → Latest: $appNewVersion"
	fi
}

launch_tailscale() {

	# Ensure we have a valid user
	if [[ -z "$currentUser" || "$currentUser" == "root" ]]; then
		echo "No active user session found."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi

	echo "Launching Tailscale as $currentUser..."

	# Use runasuser to execute the command as the logged-in user
	runAsUser osascript -e 'tell application "Tailscale" to activate'
	sleep 1.5
}

check_connectivity() {
	local IP1="8.8.8.8"  # Google Public DNS
	local IP2="${tsserverip}"  # Tailscale server IP

	local PING1=$(ping -c 1 "$IP1" | grep -c "from")
	local PING2=0

	if [ -n "$IP2" ]; then
		PING2=$(ping -c 1 "$IP2" | grep -c "from")
	fi

	if [ "$PING1" -eq 1 ]; then
		echo "Internet is connected"
	else
		echo "Error: NO INTERNET..."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi

	if [ "$PING2" -eq 1 ]; then
		echo ""
		echo "Tailscale is connected"
		echo ""
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 0
	else
		echo ""
		echo "Tailscale not connected"
		echo ""
	fi
}

set_exit_node() {
	local TSEXITNODE="${TSEXITNODE}"

	if [ "$TSEXITNODE" == "N" ]; then
		echo "Exit Node NOT Enforced"
	else
		if [[ -z "$TSEXITNODE" ]]; then
			echo "Exit Node NOT Enforced"
		else
			echo "Exit Node Enforced"
			if [ -f "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
				runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --exit-node="$TSEXITNODE"
			else
				echo "Error: Tailscale is not installed or not found in /Applications."
				#echo "*** END tailscale-intial-launch.sh ***"
				echo " "
				exit 1
			fi
		fi
	fi
}

switch_tailscale_network() {
	local tailnet="${tailnet}"

	if [[ -z "$tailnet" ]]; then
		echo "Error: No Tailscale network specified. Set tailnet and try again."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi

	if [ -f "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
		echo "Switching to Tailscale network: $tailnet"
		runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale switch "$tailnet"
	else
		echo "Error: Tailscale is not installed or not found in /Applications."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi
}

set_tailscale_hostname() {
	local TSUSER="${TSUSER}"

	# If TSUSER is not set, use the current macOS account name in lowercase
	if [[ -z "$TSUSER" ]]; then
		TSUSER=$(whoami | tr '[:upper:]' '[:lower:]')
		echo "TSUSER variable not set. Using current account name: $TSUSER"
	fi

	if [ -f "/Applications/Tailscale.app/Contents/MacOS/Tailscale" ]; then
		echo "Setting Tailscale hostname to: $TSUSER"
		runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale set --hostname "$TSUSER"
	else
		echo "Error: Tailscale is not installed or not found in /Applications."
		#echo "*** END tailscale-intial-launch.sh ***"
		echo " "
		exit 1
	fi
}

tailscale_up() {
		runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale up
}

check_tailscale_vpn_added() {
	local TAILSCALE_VPN_COUNT

	# Check for VPNs with subtype tsbundle
	TAILSCALE_VPN_COUNT=$(scutil --nc list | grep -c "$tsbundle")

	if [[ "$TAILSCALE_VPN_COUNT" -gt 0 ]]; then
		echo "Tailscale VPN Extension is present."
	else
		echo "No active Tailscale VPN Extension found."
	fi
}

logout_all_tailnets() {
	list=$(runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale switch --list)

	# Loop over each line in the list
	while read -r line; do
		# Extract the ID using awk
		id=$(echo "$line" | awk '{print $1}')
		echo "$(date) Logging out of $id" >> /Users/$currentUser/.TSLogout.log
		# Echo the ID
		runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale switch $id
		sleep 2
		runAsUser /Applications/Tailscale.app/Contents/MacOS/Tailscale logout
	done <<< "$list"
}

####################################################################################################
####################################################################################################

# check_tailscale_installed
# check_tailscale_channel
# check_tailscale_update
#
# check_config_profile
# check_auth_profile
# check_tailscale_vpn_added
#
# check_connectivity
# launch_tailscale
# tailscale_up
# check_connectivity

# set_exit_node
# switch_tailscale_network
# set_tailscale_hostname

echo " "