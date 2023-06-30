#!/bin/bash

# Functions for detecting and building libopus
echo 'Loading opus...'

function opusInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check opus
if [ ! -f ${MODULEPATH}/opus/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_opus() {
if opusInstalled ${1}; then
  echo "opus ${1} is installed."
else
  build_opus ${1}
fi
}

function build_opus() {

# Get desired version number to install
opus_v=${1}
if [ -z "${opus_v}" ] ; then
  opus_v=1.3.1
fi

case ${opus_v} in
  1.3.1) # Apr 12, 2019
   opus_doxygen_ver=1.8.14
  ;;
  *)
   echo "ERROR: Review needed for opus ${opus_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing opus ${opus_v}..."
opus_srcdir=opus-${opus_v}

check_modules
check_doxygen ${opus_doxygen_ver}

downloadPackage opus-${opus_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${opus_srcdir} ] ; then
  rm -rf ${tmp}/${opus_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/opus-${opus_v}.tar.gz
cd ${tmp}/${opus_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load doxygen/${opus_doxygen_ver}

# NOTE
# The 'No inline ASM for your platform' message is normal for x86 hosts. It's a bit
# misleading since we added intrinsic optimization. You should be ok on that count 
# as long as you have something like
#
#    Intrinsics Optimizations.......: x86 SSE SSE2 SSE4.1 AVX
#    Run-time CPU detection: ........ x86 AVX
#
# a few lines down.

config="./configure --prefix=${opt}/opus-${opus_v}"
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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/opus
cat << eof > ${MODULEPATH}/opus/${opus_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts opus-${opus_v} into your environment"
}

set VER ${opus_v}
set PKG ${opt}/opus-\$VER

module-whatis   "Loads opus-${opus_v}"
conflict opus

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${opus_srcdir}

}
