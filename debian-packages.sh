#!/bin/bash

apt-get update
apt-get install g++ gdb git libx11-dev net-tools make parted rsync samba smbclient smartmontools sysstat vim xfsprogs


# Server specific items
apt-get install firmware-qlogic ipmitool
