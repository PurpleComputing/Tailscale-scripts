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