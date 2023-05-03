#!/bin/bash

root=$(pwd)
opt=/opt
pkg=${root}/packages
tmp=${root}/temp

debug=1
run_tests=1
dependency_strategy=optimized

# Global dependency versions (for optimized strategy)
global_bison=3.8.2      # 2021-09-25
global_bzip2=1.0.8      # 2019-07-13
#global_cmake=3.26.3    # 2023-04-04
global_flex=2.6.4       # 2017-05-06
#global_gdbm=1.23        # 2022-02-04
global_help2man=1.49.3  # 2022-12-15
global_m4=1.4.19        # 2021-05-28
global_ncurses=6.4      # 2022-12-31
global_openssl=1.1.1t   # 2023-02-07
global_readline=8.2     # 2022-09-26
#global_sqlite=3.41.2    # 2023-03-22
global_texinfo=7.0      # 2022-11-07
global_utillinux=2.38.1 # 2022-08-04
global_xz=5.4.2         # 2023-03-18
global_zlib=1.2.13      # 2022-10-12

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
  echo ">> Modules (${dependency_strategy}) loaded, press enter to begin."
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
    check_p3wheel ${pv} demjson 2.2.4
    install_p3wheel ${pv} setuptools 67.6.0
    install_p3wheel ${pv} pip 23.0.1
    check_p3wheel ${pv} soupsieve 2.4
    check_p3wheel ${pv} beautifulsoup4 4.11.2
    check_p3wheel ${pv} mutagen 1.46.0
    check_p3wheel ${pv} demjson3 3.0.6
  done

#elif [ "${1}" == "screen" ] ; then
#  check_screen 4.8.0

elif [ "${1}" == "ffmpeg" ] ; then
  check_ffmpeg 4.2.2

#elif [ "${1}" == "all" ] ; then
#  check_screen 4.8.0
#  check_vim 8.2
#  check_python 3.9.4
#  check_ffmpeg 4.2.2

elif [ "${1}" == "download" ] ; then
  downloadAllPackages

else
  check_modules
fi

