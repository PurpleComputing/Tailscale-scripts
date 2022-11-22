#!/bin/sh
echo "*** PURPLE LINODE VPR DEPLOYMENT SCRIPT ***"
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
# NOTICE: LINUX SPECIFIC SCRIPT
###############################################################################################

DIR01="/opt/PurpleComputing/Tailscale"

if [ -d "$DIR01" ]; then
  echo "PURPLE LINODE VPR DEPLOYMENT SCRIPT has been run before"
  echo "Script Quit"
else
  echo "PURPLE LINODE VPR DEPLOYMENT SCRIPT has not been run before"
  hostname secure-vpr
  echo INSTALLING TAILSCALE
  curl -fsSL https://tailscale.com/install.sh | sh
  echo TAILSCALE INSTALLER COMPLETED
  sleep 2
  echo Continuing...
  echo ADDING IP ROUTING RULES
  echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
  echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p /etc/sysctl.conf
  echo IP RULES ADDED
  echo
  echo Please enter Tailscale AUTH key":"
  echo For more info visit "https://tailscale.com/kb/1085/auth-keys/"
  read TSAUTHKEY
  tailscale up --authkey $TSAUTHKEY --advertise-exit-node
  mkdir -p "/opt/PurpleComputing/"
  mkdir -p "/opt/PurpleComputing/Tailscale"
  echo "Tailscale deployed successfully!"
  echo Please disable Key expiry and enable as an Exit Node in Tailscale admin under machines
fi

