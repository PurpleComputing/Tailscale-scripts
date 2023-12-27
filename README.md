# Tailscale-scripts

## Linux / deploy-vpr.sh

### Deploy Tailscale Virtual Private Router 

This script is designed to be run on a fresh Linode instance to deploy a Virtual Private Router, a virtual private router is an exit node running on a VPS to route all traffic securely through an encrypted VPN tunnel. Clients who use Tailscale can get NordVPN / ExpressVPN style protection whilst maintaining their P2P connections.

#### Options

* None

You will be prompted for a Tailscale Auth Key, see here for more information: [https://tailscale.com/kb/1085/auth-keys/](https://tailscale.com/kb/1085/auth-keys/)

Remember to disable key expiry and to enable as an exit node in Tailscale admin.

##### Command to execute

```
curl -L https://prpl.it/vprdeploy | bash
```

## Mac / launch-connect-vpr.sh

### Launch Tailscale VPR on login

This script is designed to be run on login on an MDM asset to ensure Tailscale launch and connection to VPR.

#### Options

* None
##### Command to execute

```
curl -s https://raw.githubusercontent.com/PurpleComputing/Tailscale-scripts/main/Mac/launch-connect-vpr.sh | bash
```

## Mac / silent-auth.sh

### Launch Tailscale with Silent Authentication (Designed to be one script to 

This script is designed to be run on login on an MDM asset to ensure Tailscale launches and authenticates Tailscale and sets the hostname relative to the User or User and Device. We use this where a client has a requirement that all external server access has to be encrypted over a tunnel.

The script pings the exit node or a server that is online and verifies a connection. If it cannot find a connection after a short delay, it forces the authentication using an AUTH key, sets the hostname and or selects an exit node.

#### Options

* TAILSCALENET="purplecomputing.com"
* TAILSCALEAUTHKEY="tskey-auth-UERI564CNTRL-94949ur49hfkhkdfnknff"
* TAILSCALEAPIKEY="tskey-api-UERI564CNTRL-94949ur49hfkhkdfnknff" # USED FOR REMOVING DUPLICATE DEVICES ON NEW AUTH
* HOOKHELPER="" # USED FOR REMOVING DUPLICATE DEVICES ON NEW AUTH
* TSSERVERIP="100.100.100.100" # USED FOR PING CHECK TO CHECK IF DEVICE IS ON THE TAILSCALE NETWORK
* TSUNAME="%FullName%" # USED IF MDM SETTING ASSIGNEE NAME OPPOSED TO CONSOLE NAME IF NOT USED FALLS BACK TO CONSOLE NAME
* USEMODELANDSERIAL="N" # IF N THE HOSTNAME WILL BE CONSOLE NAME OR ASSIGNEE NAME (joebloggs) IF Y THE HOSTNAME NAME WILL BE (joe-bloggs-macbook-pro-vhk228jhfx) name-model-serial
* TSEXITNODE="100.100.100.100" # EITHER TAILSCALE LAN IP OF EXIT NODE or "N"

##### Command to execute

```
curl -s https://raw.githubusercontent.com/PurpleComputing/Tailscale-scripts/main/Mac/silent-auth.sh | bash
```
