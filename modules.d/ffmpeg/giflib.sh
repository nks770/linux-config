#!/bin/bash

# Functions for detecting and building giflib
echo 'Loading giflib...'

function giflibInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check giflib
if [ ! -f ${MODULEPATH}/giflib/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_giflib() {
if giflibInstalled ${1}; then
  echo "giflib ${1} is installed."
else
  build_giflib ${1}
fi
}

function build_giflib() {

# Get desired version number to install
giflib_v=${1}
if [ -z "${giflib_v}" ] ; then
  giflib_v=5.2.1
fi

#case ${1} in
#  9c)
#   giflib_libogg_ver=1.3.4
#   giflib_libvorbis_ver=1.3.7
#   giflib_flac_ver=1.3.3
#  ;;
#esac

echo "Installing giflib ${giflib_v}..."
giflib_srcdir=giflib-${giflib_v}

check_modules

downloadPackage giflib-${giflib_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${giflib_srcdir} ] ; then
  rm -rf ${tmp}/${giflib_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/giflib-${giflib_v}.tar.gz
cd ${tmp}/${giflib_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to change installation prefix
cat << eof > prefix.patch
--- Makefile
+++ Makefile
@@ -14,7 +14,7 @@
 TAR = tar
 INSTALL = install

-PREFIX = /usr/local
+PREFIX = ${opt}/giflib-${giflib_v}
 BINDIR = \$(PREFIX)/bin
 INCDIR = \$(PREFIX)/include
 LIBDIR = \$(PREFIX)/lib
eof
patch -N -Z -b -p0 < prefix.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

module purge

make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make test
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
mkdir -pv ${MODULEPATH}/giflib
cat << eof > ${MODULEPATH}/giflib/${giflib_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts giflib-${giflib_v} into your environment"
}

set VER ${giflib_v}
set PKG ${opt}/giflib-\$VER

module-whatis   "Loads giflib-${giflib_v}"
conflict giflib

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${giflib_srcdir}

}
