#!/bin/bash

# Functions for detecting and building SDL2
echo 'Loading Simple DirectMedia Layer (SDL)...'

function get_sdl_library() {
case ${1} in
  2.0.10)
    echo unknown.so
  ;;
  *)
    echo ''
  ;;
esac
}

function sdlDepInstalled() {
if [ ! -f "${2}/lib/$(get_sdl_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_sdl() {
echo -n "Checking for presence of sdl-${1} in ${2}..."
if sdlDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_sdl ${1} ${2} ${3}
fi
}

function ff_build_sdl() {

# Get desired version number to install
sdl_v=${1}
if [ -z "${sdl_v}" ] ; then
  sdl_v=2.0.10
fi

#case ${sdl_v} in
#  1.0.3) # Sat Jul 13 07:23:45 2019
#   sdl_tiff_ver=4.1.0 # 2019-Nov-03
#   sdl_giflib_ver=5.2.1 # 2019-06-24
#  ;;
#  1.2.4) # Sat Aug 06 02:19:15 2022
#   sdl_tiff_ver=4.4.0 # 2022-May-27 14:52
#   sdl_giflib_ver=5.2.1 # 2019-06-24
#  ;;
#  *)
#   echo "ERROR: Need review for sdl ${sdl_v}"
#   exit 4
#   ;;
#esac

sdl_ffmpeg_ver=${3}

sdl_srcdir=SDL2-${sdl_v}
sdl_prefix=${2}

echo "Installing sdl-${sdl_v} in ${sdl_prefix}..."

check_modules

downloadPackage ${sdl_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${sdl_srcdir} ] ; then
  rm -rf ${tmp}/${sdl_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${sdl_srcdir}.tar.gz
cd ${tmp}/${sdl_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${sdl_prefix}"
if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make check
  echo '>> Tests complete'
  read k
fi

make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

cd ${root}
rm -rf ${tmp}/${sdl_srcdir}

}
