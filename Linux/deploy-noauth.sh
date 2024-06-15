#!/bin/sh
echo "*** PURPLE VPR DEPLOYMENT SCRIPT ***"
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
#
############################################################################################### 
# NOTICE: LINUX SPECIFIC SCRIPT
###############################################################################################

DIR01="/opt/PurpleComputing/Tailscale"

if [ -d "$DIR01" ]; then
  echo "PURPLE VPR DEPLOYMENT SCRIPT has been run before"
  echo "Script Quit"
else
  echo "PURPLE VPR DEPLOYMENT SCRIPT has not been run before"
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
  echo AUTH SKIPPED
  mkdir -p "/opt/PurpleComputing/Tailscale"
  echo "Tailscale deployed successfully!"
fi
echo
echo "Enabling Auto Update:"
crontab <<EOF
0 5 * * * /usr/bin/tailscale update --yes
EOF
echo DONE
echo
echo "Enabling Firewall:"
ufw allow in on tailscale0
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo ufw status
echo DONE
