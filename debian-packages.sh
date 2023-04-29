#!/bin/bash

apt-get update
apt-get install g++ gdb gfortran git libx11-dev net-tools make parted rsync samba smbclient smartmontools sysstat vim xfsprogs zip
apt-get install ant openjdk-11-jdk


# Server specific items
apt-get install firmware-qlogic ipmitool
