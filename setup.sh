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
source bin/system.sh

# Load all modules in modules.d
for module in $(ls modules.d/*.sh) ; do
  source ${module}
done


installSystemPackages

check_vim 8.2
check_python 3.9.4
