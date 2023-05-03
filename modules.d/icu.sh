#!/bin/bash

# Functions for detecting and building ICU
echo 'Loading ICU...'

function icuInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check icu
if [ ! -f ${MODULEPATH}/icu/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_icu() {
if icuInstalled ${1}; then
  echo "ICU ${1} is installed."
else
  build_icu ${1}
fi
}

function build_icu() {

# Get desired version number to install
icu_v=${1}
if [ -z "${icu_v}" ] ; then
  icu_v=72.1
fi

case ${icu_v} in
63.1) #2018-10-15
   icuarc=icu4c-63_1-src
   ;;
69.1) #2021-04-07
   icuarc=icu4c-69_1-src
   ;;
*)
   echo "ERROR: Need review for ICU ${1}"
   exit 4
   ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  m4_ver=${global_m4}
#  help2man_ver=${global_help2man}
#  texinfo_ver=${global_texinfo}
#fi

echo "Installing ICU ${icu_v}..."

check_modules
module purge

downloadPackage ${icuarc}.tgz

cd ${tmp}

if [ -d ${tmp}/icu ] ; then
  rm -rf ${tmp}/icu
fi

tar xvfz ${pkg}/${icuarc}.tgz
cd ${tmp}/icu/source

config="./configure --prefix=${opt}/icu-${icu_v} --enable-shared"

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
mkdir -pv ${MODULEPATH}/icu
cat << eof > ${MODULEPATH}/icu/${icu_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts icu-${icu_v} into your environment"
}

set VER ${icu_v}
set PKG ${opt}/icu-\$VER

module-whatis   "Loads icu-${icu_v}"
conflict icu

prepend-path PATH \$PKG/bin
prepend-path PATH \$PKG/sbin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${icuarc}

}
