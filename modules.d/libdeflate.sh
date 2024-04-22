#!/bin/bash

# Functions for detecting and building libdeflate
echo 'Loading libdeflate...'

function get_libdeflate_library() {
case ${1} in
  1.7)
    echo libdeflate.so.0
  ;;
  *)
    echo ''
  ;;
esac
}

function libdeflateInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libdeflate
if [ ! -f ${MODULEPATH}/libdeflate/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libdeflate() {
if libdeflateInstalled ${1}; then
  echo "libdeflate ${1} is installed."
else
  build_libdeflate ${1}
fi
}

function build_libdeflate() {

# Get desired version number to install
libdeflate_v=${1}
if [ -z "${libdeflate_v}" ] ; then
  echo "ERROR: No aribb24 version specified!"
  exit 2
fi

echo "Installing libdeflate ${libdeflate_v}..."
libdeflate_srcdir=libdeflate-${libdeflate_v}
libdeflate_prefix=${opt}/${libdeflate_srcdir}

check_modules

downloadPackage libdeflate-${libdeflate_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libdeflate_srcdir} ] ; then
  rm -rf ${tmp}/${libdeflate_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libdeflate-${libdeflate_v}.tar.gz
cd ${tmp}/${libdeflate_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

if [ ${debug} -gt 0 ] ; then
  echo
  echo '(Configure not necessary)'
  echo
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

export PREFIX=${libdeflate_prefix}
make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi
unset PREFIX

if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libdeflate
cat << eof > ${MODULEPATH}/libdeflate/${libdeflate_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libdeflate-${libdeflate_v} into your environment"
}

set VER ${libdeflate_v}
set PKG ${opt}/libdeflate-\$VER

module-whatis   "Loads libdeflate-${libdeflate_v}"
conflict libdeflate

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib

eof

cd ${root}
rm -rf ${tmp}/${libdeflate_srcdir}

}
