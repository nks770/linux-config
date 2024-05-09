#!/bin/bash

# Functions for detecting and building gawk
echo 'Loading gawk...'

function gawkInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check gawk
if [ ! -f ${MODULEPATH}/gawk/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_gawk() {
if gawkInstalled ${1}; then
  echo "gawk ${1} is installed."
else
  build_gawk ${1}
fi
}

function build_gawk() {

# Get desired version number to install
gawk_v=${1}
if [ -z "${gawk_v}" ] ; then
  echo "ERROR: No gawk version specified!"
  exit 2
fi

echo "Installing gawk ${gawk_v}..."

check_modules
module purge

downloadPackage gawk-${gawk_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/gawk-${gawk_v} ] ; then
  rm -rf ${tmp}/gawk-${gawk_v}
fi

tar xvfz ${pkg}/gawk-${gawk_v}.tar.gz
cd ${tmp}/gawk-${gawk_v}

config="./configure --prefix=${opt}/gawk-${gawk_v}"

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
mkdir -pv ${MODULEPATH}/gawk
cat << eof > ${MODULEPATH}/gawk/${gawk_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts gawk-${gawk_v} into your environment"
}

set VER ${gawk_v}
set PKG ${opt}/gawk-\$VER

module-whatis   "Loads gawk-${gawk_v}"
conflict gawk

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/gawk-${gawk_v}

}
