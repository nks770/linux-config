#!/bin/bash

# Functions for detecting and building pkg-config
echo 'Loading pkg-config...'

function pkgconfigInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check pkg-config
if [ ! -f ${MODULEPATH}/pkg-config/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_pkgconfig() {
if pkgconfigInstalled ${1}; then
  echo "pkg-config ${1} is installed."
else
  build_pkgconfig ${1}
fi
}

function build_pkgconfig() {

# Get desired version number to install
pkgconfig_v=${1}
if [ -z "${pkgconfig_v}" ] ; then
  echo "ERROR: No version of pkg-config specified!"
  exit 2
fi

#case ${pkgconfig_v} in
#2.69) # 2012-04-24
#   pkgconfig_m4_ver=1.4.16   # 2011-03-01
#   ;;
#*)
#   echo "ERROR: Need review for pkg-config ${pkgconfig_v}"
#   exit 4
#   ;;
#esac
#
## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  pkgconfig_m4_ver=${global_m4}
#fi

echo "Installing pkg-config ${pkgconfig_v}..."

check_modules

downloadPackage pkg-config-${pkgconfig_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/pkg-config-${pkgconfig_v} ] ; then
  rm -rf ${tmp}/pkg-config-${pkgconfig_v}
fi

tar xvfz ${pkg}/pkg-config-${pkgconfig_v}.tar.gz
cd ${tmp}/pkg-config-${pkgconfig_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${opt}/pkg-config-${pkgconfig_v}"

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
mkdir -pv ${MODULEPATH}/pkg-config
cat << eof > ${MODULEPATH}/pkg-config/${pkgconfig_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts pkg-config-${pkgconfig_v} into your environment"
}

set VER ${pkgconfig_v}
set PKG ${opt}/pkg-config-\$VER

module-whatis   "Loads pkg-config-${pkgconfig_v}"
conflict pkg-config

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man
setenv PKG_CONFIG_MACRO \$PKG/share/aclocal

eof

cd ${root}
rm -rf ${tmp}/pkg-config-${pkgconfig_v}

}
