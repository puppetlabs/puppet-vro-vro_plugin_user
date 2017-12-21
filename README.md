# plugin_user

#### Table of Contents

1. [Description](#description)
2. [Usage - Configuration options and additional functionality](#usage)


## Description

Manages the sudoers commands for the vro-plugin-user.  This allows VMware VRO/VRA to purge a Puppet node, with limited elevated privilege commands.

## Usage
This module is part of the larger VMware VRO/VRA Plugin. When the VRO Plugin is setup this module creates both a Linux user and a PE RBAC user called `vro-plugin-user` by default on the Puppet Master with a default password of `puppetlabs`.

Note: In order for the sudoers rules in the sudoers.d directory to be picked up, ensure that you have something similar to this in your main `/etc/sudoers` file:

```
## Read drop-in files from /etc/sudoers.d (the # here does not mean a comment)
#includedir /etc/sudoers.d
```
