#!/bin/bash

# Functions for detecting and building libtool
echo 'Loading libtool...'

function libtoolInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libtool
if [ ! -f ${MODULEPATH}/libtool/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libtool() {
if libtoolInstalled ${1}; then
  echo "libtool ${1} is installed."
else
  build_libtool ${1}
fi
}

function build_libtool() {

# Get desired version number to install
libtool_v=${1}
if [ -z "${libtool_v}" ] ; then
  echo "ERROR: No version of libtool specified!"
  exit 2
fi

#case ${libtool_v} in
#2.69) # 2012-04-24
#   libtool_m4_ver=1.4.16   # 2011-03-01
#   ;;
#*)
#   echo "ERROR: Need review for libtool ${libtool_v}"
#   exit 4
#   ;;
#esac
#
## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  libtool_m4_ver=${global_m4}
#fi

echo "Installing libtool ${libtool_v}..."

check_modules
#check_m4 ${libtool_m4_ver}

downloadPackage libtool-${libtool_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/libtool-${libtool_v} ] ; then
  rm -rf ${tmp}/libtool-${libtool_v}
fi

tar xvfz ${pkg}/libtool-${libtool_v}.tar.gz
cd ${tmp}/libtool-${libtool_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
#module load m4/${libtool_m4_ver}

config="./configure --prefix=${opt}/libtool-${libtool_v}"

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
mkdir -pv ${MODULEPATH}/libtool
cat << eof > ${MODULEPATH}/libtool/${libtool_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libtool-${libtool_v} into your environment"
}

set VER ${libtool_v}
set PKG ${opt}/libtool-\$VER

module-whatis   "Loads libtool-${libtool_v}"
conflict libtool

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
setenv LIBTOOL_MACRO \$PKG/share/aclocal

eof

cd ${root}
rm -rf ${tmp}/libtool-${libtool_v}

}
