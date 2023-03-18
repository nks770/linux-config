#!/bin/bash

root=$(pwd)
opt=/opt
pkg=${root}/packages
tmp=${root}/temp

debug=1
run_tests=1

ncpu=$(cat /proc/cpuinfo | grep name | wc -l)

if [ ! -d ${pkg} ] ; then
  mkdir -pv ${pkg}
fi

if [ ! -d ${tmp} ] ; then
  mkdir -pv ${tmp}
fi

# Load script resources
source bin/resources.sh
#source bin/system.sh

# Load all modules in modules.d
for module in $(ls modules.d/*.sh) ; do
  source ${module}
done
for module in $(ls modules.d/*/*.sh) ; do
  source ${module}
done

if [ ${debug} -gt 0 ] ; then
  echo '>> Modules loaded, press enter to begin.'
  read k
fi

#installSystemPackages

if [ "${1}" == "vim" ] ; then
  check_vim 8.2

elif [ "${1}" == "rsnapshot" ] ; then
  check_rsnapshot 1.4.4
  check_rsnapshot 1.4.5

elif [ "${1}" == "rar" ] ; then
  check_rarlinux 6.12
  check_rarlinux 6.20
  check_rarlinux 6.21

elif [ "${1}" == "python" ] ; then
  for pv in 3.9.4 3.9.16 3.10.{9..10} 3.11.2 ; do
    check_python ${pv}
    check_p3wheel ${pv} soupsieve 2.4
    check_p3wheel ${pv} beautifulsoup4 4.11.2
    check_p3wheel ${pv} mutagen 1.46.0
    check_p3wheel ${pv} demjson 2.2.4
  done

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

