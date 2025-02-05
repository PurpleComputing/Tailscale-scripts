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
# check-tailscale-settings-present.sh SCMv
# Last Updated by Michael Tanner, 05/02/2025
####################################################################################################
## Attribute Name: Tailscale Automatic Configuration
## Attribute Unique ID: ts_auto_config
## For Execute command: Immediately when saving the profile, upon assignment, or based on schedule or events
## For Event Tick: Every start up of the Mac, Every user sign-in, Every "Device Info" update
#####################################################################################################
# Check if the profile with the specific Payload Identifier exists
if profiles list | grep -q "com.purplecomputing.mdm.tailscale"; then
	echo "Config Profile Present"
else
	echo "Config Profile Not Found"
fi
