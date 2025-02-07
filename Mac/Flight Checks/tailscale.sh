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

####################################################################################################
## Variables
####################################################################################################
# tschannel=""
# tsversion=""
# tsbundle=""
# tailnet=""
# tsserverip=""
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

test() {
	# Define log file
	LOGFILE="/Users/$currentUser/.tailscale_diagnostics_$(date +%Y%m%d%H%M%S).log"

	# Path to Tailscale binary
	TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

	# Function to log output
	echo_and_log() {
		echo "$1"
		echo "$1" >> "$LOGFILE"
	}

	# Start diagnostic script
	echo_and_log "Purple Tailscale Diagnostics Report - $(date)"
	echo_and_log "============================================================="

	echo_and_log "Checking if Tailscale is installed..."
	if [ ! -f "$TAILSCALE_BIN" ]; then
		echo_and_log "Tailscale is not installed at $TAILSCALE_BIN. Please install Tailscale and retry."
		exit 1
	fi

	echo_and_log "Tailscale is installed. Proceeding with diagnostics."

	echo_and_log "\nChecking Tailscale service status..."
	TS_STATUS=$(runAsUser $TAILSCALE_BIN status 2>&1)
	echo_and_log "$TS_STATUS"

	echo_and_log "\nChecking Tailscale IP and connectivity..."
	TS_IP=$(runAsUser $TAILSCALE_BIN ip -4 2>&1)
	echo_and_log "Tailscale IPv4: $TS_IP"
	TS_IP6=$(runAsUser $TAILSCALE_BIN ip -6 2>&1)
	echo_and_log "Tailscale IPv6: $TS_IP6"

	echo_and_log "\nPinging Tailscale's coordination server (control plane)..."
	TS_PING=$(runAsUser $TAILSCALE_BIN ping $($TAILSCALE_BIN status --active=true | awk '$5 != "offline" && NR>1 {print $1; exit}'))
	echo_and_log "$TS_PING"

	echo_and_log "\nChecking for active connections..."
	TS_PEERS=$(runAsUser $TAILSCALE_BIN status --json | jq '.Peer' 2>/dev/null)
	if [[ -z "$TS_PEERS" ]]; then
		echo_and_log "No active peers found."
	else
		echo_and_log "Active peers:"
		echo_and_log "$TS_PEERS"
	fi

	echo_and_log "\n Running Tailscale Netcheck..."
	TS_NETCHECK=$(runAsUser $TAILSCALE_BIN netcheck)
	echo_and_log "$TS_NETCHECK"


	echo_and_log "\nTesting connection to a public IP outside of Tailscale (Google DNS)..."
	PING_TEST=$(ping -c 4 8.8.8.8 2>&1)
	echo_and_log "$PING_TEST"

	echo_and_log "\nTesting connection to a public IP outside of Tailscale (London VM01)..."
	PING_TEST=$(ping -c 4 a.ping.prpl.it 2>&1)
	echo_and_log "$PING_TEST"


	echo_and_log "\nTesting connection to a public IP outside of Tailscale (London VM02)..."
	PING_TEST=$(ping -c 4 b.ping.prpl.it 2>&1)
	echo_and_log "$PING_TEST"

	echo_and_log "\nTesting connection to a public IP outside of Tailscale (Germany VM03)..."
	PING_TEST=$(ping -c 4 c.ping.prpl.it 2>&1)
	echo_and_log "$PING_TEST"

	echo_and_log "\nTesting connection to a public IP outside of Tailscale (Toronto)..."
	PING_TEST=$(ping -c 4 d.ping.prpl.it 2>&1)
	echo_and_log "$PING_TEST"

	echo_and_log "\nTesting connection to a public IP outside of Tailscale (Amsterdam)..."
	PING_TEST=$(ping -c 4 e.ping.prpl.it 2>&1)
	echo_and_log "$PING_TEST"



	echo_and_log "\nDiagnostics complete. Log file: $LOGFILE"
	runAsUser open $LOGFILE

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
