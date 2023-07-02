#!/bin/bash

root=$(pwd)
opt=/opt
pkg=${root}/packages
tmp=${root}/temp

debug=1
run_tests=0
run_cmake_tests=0
dependency_strategy=optimized

#######################################################
# Global dependency versions (for optimized strategy) #
#######################################################
# Toolchain for bison/flex/m4/doxygen
global_bison=3.8.2      # 2021-09-25
global_help2man=1.49.3  # 2022-12-15
global_flex=2.6.4       # 2017-05-06
global_m4=1.4.19        # 2021-05-28
#global_texinfo=7.0      # 2022-11-07
global_texinfo=7.0.3    # 2023-03-26

# Other GNU utils and libraries, used by cmake+python
global_ncurses=6.4      # 2022-12-31
global_readline=8.2     # 2022-09-26
#global_utillinux=2.38.1 # 2022-08-04
global_utillinux=2.39.1 # 2023-06-27

# Commonly linked compression libraries
global_bzip2=1.0.8      # 2019-07-13
global_xz=5.4.2         # 2023-03-18
global_zlib=1.2.13      # 2022-10-12

# OpenSSL is used extensively by Python, FFmpeg, and their dependencies
#global_openssl=1.1.1t   # 2023-02-07
global_openssl=1.1.1u   # 2023-05-30


#####################
# Python extensions #
#####################
function python_extensions(){
    check_p3wheel ${1} demjson 2.2.4
    #install_p3wheel ${1} setuptools 67.6.0
    install_p3wheel ${1} setuptools 68.0.0
    #install_p3wheel ${1} pip 23.0.1
    install_p3wheel ${1} pip 23.1.2
    #check_p3wheel ${1} soupsieve 2.4
    check_p3wheel ${1} soupsieve 2.4.1
    #check_p3wheel ${1} beautifulsoup4 4.11.2
    check_p3wheel ${1} beautifulsoup4 4.12.2
    check_p3wheel ${1} mutagen 1.46.0
    check_p3wheel ${1} demjson3 3.0.6
}

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
  check_rarlinux 6.22

elif [ "${1}" == "python" ] ; then
  for pv in 3.9.4 3.9.16 3.10.{9..10} 3.11.2 ; do
    check_python ${pv}
    python_extensions ${pv}
  done

#elif [ "${1}" == "screen" ] ; then
#  check_screen 4.8.0

elif [ "${1}" == "libjpegturbo" ] ; then
  check_libjpegturbo 1.5.2

elif [ "${1}" == "ffmpeg" ] ; then
  check_ffmpeg 4.2.2

elif [ "${1}" == "base" ] ; then
  for rl in 6.12 6.20 6.21 6.22 ; do
    check_rarlinux ${rl}
  done
  for rs in 1.4.4 1.4.5 ; do
    check_rsnapshot ${rs}
  done
  check_python 3.11.4
  python_extensions 3.11.4

elif [ "${1}" == "download" ] ; then
  downloadAllPackages

else
  check_modules
fi

