#!/bin/bash

# Functions for detecting and building help2man
echo 'Loading help2man...'

function help2manInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check help2man
if [ ! -f ${MODULEPATH}/help2man/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_help2man() {
if help2manInstalled ${1}; then
  echo "help2man ${1} is installed."
else
  build_help2man ${1}
fi
}

function build_help2man() {

# Get desired version number to install
help2man_v=${1}
if [ -z "${help2man_v}" ] ; then
  help2man_v=1.47.4
fi

echo "Installing help2man ${help2man_v}..."

check_modules
module purge

downloadPackage help2man-${help2man_v}.tar.xz

cd ${tmp}

if [ -d ${tmp}/help2man-${help2man_v} ] ; then
  rm -rf ${tmp}/help2man-${help2man_v}
fi

tar xvfJ ${pkg}/help2man-${help2man_v}.tar.xz
cd ${tmp}/help2man-${help2man_v}

config="./configure --prefix=${opt}/help2man-${help2man_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
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

# help2man does not have any testsuite

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
mkdir -pv ${MODULEPATH}/help2man
cat << eof > ${MODULEPATH}/help2man/${help2man_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts help2man-${help2man_v} into your environment"
}

set VER ${help2man_v}
set PKG ${opt}/help2man-\$VER

module-whatis   "Loads help2man-${help2man_v}"
conflict help2man

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/help2man-${help2man_v}

}
