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

## Mac / force-auth.sh

### Launch Tailscale VPR on login

This script is designed to be run on login on an MDM asset to ensure Tailscale launches and authenticates Tailscale, we use this where a client has a requirement for all external server access has to be encrypted over a tunnel.

The script pings the exit node or a server which is online and verifies a connection, if it cannot find a connection after a short delay to force the authentication using an AUTH key.

#### Options

* TAILSCALEAUTHKEY="tskey-auth-hdhhj8hjdhj-dwwdgewghEHWEH90238909"
* TSSERVERIP="100.100.100.100"
##### Command to execute

```
curl -s https://raw.githubusercontent.com/PurpleComputing/Tailscale-scripts/main/Mac/launch-connect-vpr.sh | bash
```
