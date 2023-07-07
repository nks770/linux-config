#!/bin/bash

# Functions for detecting and building zstd
echo 'Loading zstd...'

function get_zstd_library() {
case ${1} in
  1.4.4)
    echo libzstd.so.1.4.4
  ;;
  *)
    echo ''
  ;;
esac
}

function zstdInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check zstd
if [ ! -f ${MODULEPATH}/zstd/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_zstd() {
if zstdInstalled ${1}; then
  echo "zstd ${1} is installed."
else
  build_zstd ${1}
fi
}

function build_zstd() {

zstd_use_cmake=0

# Get desired version number to install
zstd_v=${1}
if [ -z "${zstd_v}" ] ; then
  zstd_v=1.4.4
fi

case ${zstd_v} in
  1.4.4) # 2019-11-05
    zstd_cmake_ver=3.15.5 # 2019-10-30
  ;;
  *)
   echo "ERROR: Review needed for zstd ${zstd_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing zstd ${zstd_v}..."
zstd_srcdir=zstd-${zstd_v}

check_modules
if [ ${zstd_use_cmake} -gt 0 ] ; then
  check_cmake ${zstd_cmake_ver}
fi

downloadPackage zstd-${zstd_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${zstd_srcdir} ] ; then
  rm -rf ${tmp}/${zstd_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/zstd-${zstd_v}.tar.gz
cd ${tmp}/${zstd_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
if [ ${zstd_use_cmake} -gt 0 ] ; then
  module load cmake/${zstd_cmake_ver}
fi

if [ ${zstd_use_cmake} -gt 0 ] ; then

cd ${tmp}/${zstd_srcdir}/build/cmake

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DCMAKE_INSTALL_PREFIX=${opt}/zstd-${zstd_v}
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
       -DCMAKE_INSTALL_PREFIX=${opt}/zstd-${zstd_v}

else

echo 'No configuration is necessary.'

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

if [ ${run_tests} -gt 0 ] ; then
  make check
  echo '>> Tests complete'
  read k
fi

if [ ${zstd_use_cmake} -gt 0 ] ; then
  make install
else
  make prefix=${opt}/zstd-${zstd_v} install
fi

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
mkdir -pv ${MODULEPATH}/zstd
cat << eof > ${MODULEPATH}/zstd/${zstd_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts zstd-${zstd_v} into your environment"
}

set VER ${zstd_v}
set PKG ${opt}/zstd-\$VER

module-whatis   "Loads zstd-${zstd_v}"
conflict zstd

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${zstd_srcdir}

}
