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
TARGET="/opt/PurpleComputing/tstools.sh"
mkdir -p /opt/PurpleComputing/
DA=$(date +%s)
curl -fsSL -o /tmp/tailscale-$DA.sh https://prpl.uk/tailscalesh
curl -fsSL -o $TARGET https://prpl.uk/tailscaletools
source /tmp/tailscale-$DA.sh



# Check if the symlink exists and is valid
# if [ -L "$SYMLINK" ] && [ "$(readlink "$SYMLINK")" == "$TARGET" ]; then
# 	echo " "
# else
# 	# Remove any existing file or incorrect symlink
# 	if [ -e "$SYMLINK" ] || [ -L "$SYMLINK" ]; then
# 		rm -f "$SYMLINK"
# 	fi
#
 	ln -s "$TARGET" "$SYMLINK"
#
# 	# Verify the creation
	if [ -L "$SYMLINK" ]; then
		echo ""
	else
		ln -s "$TARGET" "$SYMLINK"
	fi
# fi
####################################################################################################
echo ""
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
