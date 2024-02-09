#!/bin/bash

# Functions for detecting and building openh264
echo 'Loading openh264...'

function openh264Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check openh264
if [ ! -f ${MODULEPATH}/openh264/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_openh264() {
if openh264Installed ${1}; then
  echo "openh264 ${1} is installed."
else
  build_openh264 ${1}
fi
}

function build_openh264() {

# Get desired version number to install
openh264_v=${1}
if [ -z "${openh264_v}" ] ; then
  echo "ERROR: No openh264 version specified!"
  exit 2
fi

case ${openh264_v} in
  1.5.0) # Oct 26, 2015
   openh264_nasm_ver=2.11.08 # 2015-02-21
  ;;
  1.6.0) # Jul 12, 2016
   openh264_nasm_ver=2.12.02 # 2016-07-06
  ;;
  2.0.0) # May 8, 2019
   openh264_nasm_ver=2.14.02 # 2018-12-26
  ;;
  2.1.0) # 2020-03-23
   openh264_nasm_ver=2.14.02 # 2018-12-26
  ;;
  2.3.1) # Sep 20, 2022
   openh264_nasm_ver=2.15.05 # 2020-08-28 09:08
  ;;
  *)
   echo "ERROR: Review needed for openh264 ${openh264_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing openh264 ${openh264_v}..."
openh264_srcdir=openh264-${openh264_v}

check_modules
check_nasm ${openh264_nasm_ver}

downloadPackage openh264-${openh264_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openh264_srcdir} ] ; then
  rm -rf ${tmp}/${openh264_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openh264-${openh264_v}.tar.gz
cd ${tmp}/${openh264_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load nasm/${openh264_nasm_ver}

# Patch to change installation prefix
cat << eof > prefix.patch
--- Makefile
+++ Makefile
@@ -21,7 +21,7 @@
 CFLAGS_DEBUG=-g
 BUILDTYPE=Release
 V=Yes
-PREFIX=/usr/local
+PREFIX=${opt}/openh264-${openh264_v}
 SHARED=-shared
 OBJ=o
 DESTDIR=
eof
patch -N -Z -b -p0 < prefix.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/openh264
cat << eof > ${MODULEPATH}/openh264/${openh264_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts openh264-${openh264_v} into your environment"
}

set VER ${openh264_v}
set PKG ${opt}/openh264-\$VER

module-whatis   "Loads openh264-${openh264_v}"
conflict openh264

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${openh264_srcdir}

}
