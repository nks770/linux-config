#!/bin/bash

# Functions for detecting and building FLAC
echo 'Loading flac...'

function flacInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check flac
if [ ! -f ${MODULEPATH}/flac/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_flac() {
if flacInstalled ${1}; then
  echo "flac ${1} is installed."
else
  build_flac ${1}
fi
}

function build_flac() {

# Get desired version number to install
flac_v=${1}
if [ -z "${flac_v}" ] ; then
  flac_v=1.3.3
fi

case ${flac_v} in
  1.3.3) # 4 Aug 2019
   nasm_ver=2.14.02
   libogg_ver=1.3.4
  ;;
  *)
   echo "ERROR: Review needed for flac ${flac_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  libogg_ver=${global_libogg}
fi

echo "Installing flac ${flac_v}..."
flac_srcdir=flac-${flac_v}

check_modules
check_nasm ${nasm_ver}
check_libogg ${libogg_ver}

downloadPackage flac-${flac_v}.tar.xz

cd ${tmp}

if [ -d ${tmp}/${flac_srcdir} ] ; then
  rm -rf ${tmp}/${flac_srcdir}
fi

cd ${tmp}
tar xvfJ ${pkg}/flac-${flac_v}.tar.xz
cd ${tmp}/${flac_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load nasm/${nasm_ver} \
            libogg/${libogg_ver}

config="./configure --prefix=${opt}/flac-${flac_v} \
            --with-ogg=${opt}/libogg-${libogg_ver} \
            --disable-xmms-plugin"
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
mkdir -pv ${MODULEPATH}/flac
cat << eof > ${MODULEPATH}/flac/${flac_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts flac-${flac_v} into your environment"
}

set VER ${flac_v}
set PKG ${opt}/flac-\$VER

module-whatis   "Loads flac-${flac_v}"
conflict flac
module load libogg/${libogg_ver}
prereq libogg/${libogg_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${flac_srcdir}

}
