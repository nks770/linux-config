#!/bin/bash

root=$(pwd)
opt=/opt
pkg=${root}/packages
tmp=${root}/temp

ncpu=$(cat /proc/cpuinfo | grep name | wc -l)

if [ ! -d ${pkg} ] ; then
  mkdir -pv ${pkg}
fi

if [ ! -d ${tmp} ] ; then
  mkdir -pv ${tmp}
fi

# Load script resources
source bin/resources.sh

# Load all modules in modules.d
for module in $(ls modules.d/*.sh) ; do
  source ${module}
done
for module in $(ls modules.d/*/*.sh) ; do
  source ${module}
done

# Install python libraries
check_demjson 3.9.4 2.2.4
check_bs4 3.9.4 4.9.3
