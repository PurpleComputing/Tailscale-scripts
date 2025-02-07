#!/bin/zsh
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
# tstools.sh - Must be run with Sudo or MDM
# Last Updated by Purple, 05/02/2025
####################################################################################################
SYMLINK="/usr/local/bin/tstools"
TARGET="/Library/Application Support/Purple/tstools.sh"
mkdir -p "/Library/Application Support/Purple/"
DA=$(date +%s)
sudo curl -fsSL -o /tmp/tailscale-$DA.sh https://prpl.uk/tailscalesh
# sudo curl -fsSL -o $TARGET https://prpl.uk/tailscaletools
source /tmp/tailscale-$DA.sh


	if [ -L "$SYMLINK" ]; then
		echo ""
	else
		rm -f "$SYMLINK"
		sleep 0.5
		ln -s "$TARGET" "$SYMLINK"
	fi

####################################################################################################
echo ...............................................
echo ....... Purple Tailscale Toolkit ..............
echo ...............................................
echo ""
echo "Command Selected: $@"
echo ""
$@

####################################################################################################

rm /tmp/tailscale-$DA.sh
chmod +x $SYMLINK
echo ""
