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
# VARS
tsserverip="100.100.1.10"
export tsserverip
####################################################################################################
# FUNCTIONS
DA=$(date +%s)
curl -fsSL -o /tmp/tailscale-$DA.sh https://prpl.uk/tailscalesh
source /tmp/tailscale-$DA.sh

# CREATES / UPDATES TS
create_tstools_sym
####################################################################################################
# COMMANDS
check_tailscale_installed
check_tailscale_channel
check_tailscale_update
#
check_config_profile
check_auth_profile
check_tailscale_vpn_added
#
check_connectivity
launch_tailscale
tailscale_up
check_connectivity

# set_exit_node
# switch_tailscale_network
# set_tailscale_hostname

####################################################################################################
# TIDY
rm /tmp/tailscale-$DA.sh
echo ""
