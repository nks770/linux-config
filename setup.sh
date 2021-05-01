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
for module in $(ls modules.d/*/*.sh) ; do
  source ${module}
done


installSystemPackages

if [ "${1}" == "vim" ] ; then
  check_vim 8.2

elif [ "${1}" == "python" ] ; then
  check_python 3.9.4
  check_demjson 3.9.4 2.2.4
  check_bs4 3.9.4 4.9.3

elif [ "${1}" == "screen" ] ; then
  check_screen 4.8.0

elif [ "${1}" == "ffmpeg" ] ; then
  check_ffmpeg 4.2.2

elif [ "${1}" == "all" ] ; then
  check_screen 4.8.0
  check_vim 8.2
  check_python 3.9.4
  check_demjson 3.9.4 2.2.4
  check_bs4 3.9.4 4.9.3
  check_ffmpeg 4.2.2

elif [ "${1}" == "download" ] ; then
  downloadAllPackages

else
  check_modules
fi

