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
# check-tailscale-auth-present.sh SCMv
# Last Updated by Michael Tanner, 05/02/2025
####################################################################################################
## Attribute Name: Tailscale Automatic Authentication
## Attribute Unique ID: ts_auto_auth
## For Execute command: Immediately when saving the profile, upon assignment, or based on schedule or events
## For Event Tick: Every start up of the Mac, Every user sign-in, Every "Device Info" update
#####################################################################################################
# Check if the profile with the specific Payload Identifier exists
# FUNCTIONS
DA=$(date +%s)
curl -fsSL -o /tmp/tailscale-$DA.sh https://prpl.uk/tailscalesh
source /tmp/tailscale-$DA.sh
tsbundle=io.tailscale.ipn.macos # VPP
#tsbundle=io.tailscale.ipn.macsys # STNDALONE

create_tstools_sym
#check_config_profile
check_auth_profile

####################################################################################################
# TIDY
rm /tmp/tailscale-$DA.sh
echo ""
