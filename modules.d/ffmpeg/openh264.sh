#!/bin/bash

# Functions for detecting and building openh264

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
  openh264_v=2.0.0
fi
openh264_srcdir=openh264-${openh264_v}

echo "Installing openh264 ${openh264_v}..."

case ${1} in
  2.0.0) # May 8, 2019
   openh264_nasm_ver=2.14.02
  ;;
esac

check_modules
check_nasm ${openh264_nasm_ver}

module purge
module load nasm/${openh264_nasm_ver}
module list

downloadPackage openh264-${openh264_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openh264_srcdir} ] ; then
  rm -rf ${tmp}/${openh264_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openh264-${openh264_v}.tar.gz
cd ${tmp}/${openh264_srcdir}

# Patch to change installation prefix
cat << eof > prefix.patch
Index: Makefile
===================================================================
--- Makefile    2019-05-08 07:07:17.000000000 +0000
+++ Makefile    2021-04-25 06:20:24.866535202 +0000
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

make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
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
