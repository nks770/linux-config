#!/bin/bash

# Functions for detecting and building aribb24
echo 'Loading aribb24...'

function get_aribb24_library() {
case ${1} in
  1.0.3)
    echo libaribb24.so.0.0.0
  ;;
  *)
    echo ''
  ;;
esac
}

function aribb24DepInstalled() {
if [ ! -f "${2}/lib/$(get_aribb24_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_aribb24() {
echo -n "Checking for presence of aribb24-${1} in ${2}..."
if aribb24DepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_aribb24 ${1} ${2} ${3}
fi
}


function ff_build_aribb24() {

# Get desired version number to install
aribb24_v=${1}
if [ -z "${aribb24_v}" ] ; then
  echo "ERROR: No aribb24 version specified!"
  exit 2
fi

case ${aribb24_v} in
  1.0.3) # 2014-08-18
    aribb24_autoconf_ver=2.69   # 2012-04-24
    aribb24_automake_ver=1.14.1 # 2013-12-24
    aribb24_pkgconfig_ver=0.28  # 2013-01-24
    aribb24_libtool_ver=2.4.2   # 2011-10-18
  ;;
  *)
   echo "ERROR: Review needed for aribb24 ${aribb24_v}"
   exit 4 # Please review
  ;;
esac

aribb24_ffmpeg_ver=${3}
aribb24_libpng_ver=${ffmpeg_libpng_ver}

aribb24_srcdir=aribb24-${aribb24_v}
aribb24_prefix=${2}

echo "Installing ${aribb24_srcdir} in ${aribb24_prefix}..."

check_modules
check_autoconf ${aribb24_autoconf_ver}
check_automake ${aribb24_automake_ver}
check_pkgconfig ${aribb24_pkgconfig_ver}
check_libtool ${aribb24_libtool_ver}
check_libpng ${aribb24_libpng_ver}

downloadPackage ${aribb24_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${aribb24_srcdir} ] ; then
  rm -rf ${tmp}/${aribb24_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${aribb24_srcdir}.tar.gz
cd ${tmp}/${aribb24_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${aribb24_ffmpeg_ver}
module load autoconf/${aribb24_autoconf_ver}
module load automake/${aribb24_automake_ver}
module load pkg-config/${aribb24_pkgconfig_ver}
module load libtool/${aribb24_libtool_ver}

echo 'Running autoconf...'
mkdir -pv ${tmp}/${aribb24_srcdir}/m4
autoreconf -fi -I ${PKG_CONFIG_MACRO} -I ${LIBTOOL_MACRO}

if [ ${debug} -gt 0 ] ; then
  echo '>> Autoconf complete'
  read k
fi

config="./configure --prefix=${aribb24_prefix}"

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

# aribb24 does not have any test suite
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

cd ${root}
rm -rf ${tmp}/${aribb24_srcdir}

}
