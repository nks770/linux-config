#!/bin/bash

apt-get update
apt-get install g++ git net-tools make parted rsync samba smbclient smartmontools sysstat vim xfsprogs


# Server specific items
apt-get install firmware-qlogic ipmitool
