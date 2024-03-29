#!/bin/bash

# Functions for detecting and building xz
echo 'Loading xz...'

function get_xz_library() {
case ${1} in
  5.4.2)
    echo liblzma.so.5.4.2
  ;;
  *)
    echo ''
  ;;
esac
}

function xzInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check xz
if [ ! -f ${MODULEPATH}/xz/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_xz() {
if xzInstalled ${1}; then
  echo "xz ${1} is installed."
else
  build_xz ${1}
fi
}

function build_xz() {

# Get desired version number to install
xz_v=${1}
if [ -z "${xz_v}" ] ; then
  xz_v=5.4.1
fi

echo "Installing xz ${xz_v}..."
xz_srcdir=xz-${xz_v}

check_modules

downloadPackage xz-${xz_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${xz_srcdir} ] ; then
  rm -rf ${tmp}/${xz_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/xz-${xz_v}.tar.gz
cd ${tmp}/${xz_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${opt}/xz-${xz_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
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
mkdir -pv ${MODULEPATH}/xz
cat << eof > ${MODULEPATH}/xz/${xz_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts xz-${xz_v} into your environment"
}

set VER ${xz_v}
set PKG ${opt}/xz-\$VER

module-whatis   "Loads xz-${xz_v}"
conflict xz

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${xz_srcdir}

}
