#!/bin/bash

# Functions for detecting and building kvazaar
echo 'Loading kvazaar...'

function kvazaarInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check kvazaar
if [ ! -f ${MODULEPATH}/kvazaar/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_kvazaar() {
if kvazaarInstalled ${1}; then
  echo "kvazaar ${1} is installed."
else
  build_kvazaar ${1}
fi
}

function build_kvazaar() {

# Get desired version number to install
kvazaar_v=${1}
if [ -z "${kvazaar_v}" ] ; then
  echo "ERROR: No kvazaar version specified!"
  exit 2
fi

case ${kvazaar_v} in
  0.6.1) # 2015-09-16
   kvazaar_yasm_ver=1.3.0 # 2014-08-10
   kvazaar_simple_build=1
   kvazaar_share_man=0
  ;;
  0.7.0) # 2015-09-30
   kvazaar_yasm_ver=1.3.0 # 2014-08-10
   kvazaar_simple_build=1
   kvazaar_share_man=0
  ;;
  1.3.0) # Jul 9, 2019
   kvazaar_yasm_ver=1.3.0 # 2014-08-10
   kvazaar_simple_build=0
   kvazaar_share_man=1
  ;;
  2.0.0) # 2020-04-21
   kvazaar_yasm_ver=1.3.0 # 2014-08-10
   kvazaar_simple_build=0
   kvazaar_share_man=1
  ;;
  *)
   echo "ERROR: Review needed for kvazaar ${kvazaar_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing kvazaar ${kvazaar_v}..."
kvazaar_srcdir=kvazaar-${kvazaar_v}
kvazaar_prefix=${opt}/${kvazaar_srcdir}

check_modules
# Yasm is optional, but some of the optimization will not be compiled in if it's missing.
check_yasm ${kvazaar_yasm_ver}

downloadPackage kvazaar-${kvazaar_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${kvazaar_srcdir} ] ; then
  rm -rf ${tmp}/${kvazaar_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/kvazaar-${kvazaar_v}.tar.gz
cd ${tmp}/${kvazaar_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load yasm/${kvazaar_yasm_ver}

if [ ${kvazaar_simple_build} -gt 0 ] ; then

# Patch to change installation prefix
cat << eof > prefix.patch
--- src/Makefile
+++ src/Makefile
@@ -5,7 +5,7 @@
 
 # Installation locations
 DESTDIR =
-PREFIX  = /usr/local
+PREFIX  = ${kvazaar_prefix}
 BINDIR  = \$(PREFIX)/bin
 INCDIR  = \$(PREFIX)/include
 LIBDIR  = \$(PREFIX)/lib
eof
patch -N -Z -b -p0 < prefix.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
cd ${tmp}/${kvazaar_srcdir}/src

else
config="./configure --prefix=${kvazaar_prefix}"
if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo ${config}
  read k
fi

${config}
fi

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

## There is a testsuite for kvazaar, but it depends on ffmpeg
## Without ffmpeg, it is useless
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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/kvazaar
cat << eof > ${MODULEPATH}/kvazaar/${kvazaar_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts kvazaar-${kvazaar_v} into your environment"
}

set VER ${kvazaar_v}
set PKG ${opt}/kvazaar-\$VER

module-whatis   "Loads kvazaar-${kvazaar_v}"
conflict kvazaar

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
eof
if [ ${kvazaar_share_man} -gt 0 ] ; then
  echo 'prepend-path MANPATH $PKG/share/man' >> ${MODULEPATH}/kvazaar/${kvazaar_v}
fi
echo '' >> ${MODULEPATH}/kvazaar/${kvazaar_v}

cd ${root}
rm -rf ${tmp}/${kvazaar_srcdir}

}
