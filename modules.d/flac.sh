#!/bin/bash

# Functions for detecting and building FLAC

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
flac_srcdir=flac-${flac_v}

echo "Installing flac ${flac_v}..."

case ${1} in
  1.3.3) # 4 Aug 2019
   flac_nasm_ver=2.14.02
   flac_libogg_ver=1.3.4
  ;;
esac

check_modules
check_nasm ${flac_nasm_ver}
check_libogg ${flac_libogg_ver}

module purge
module load nasm/${flac_nasm_ver} \
            libogg/${flac_libogg_ver}
module list

downloadPackage flac-${flac_v}.tar.xz

cd ${tmp}

if [ -d ${tmp}/${flac_srcdir} ] ; then
  rm -rf ${tmp}/${flac_srcdir}
fi

cd ${tmp}
tar xvfJ ${pkg}/flac-${flac_v}.tar.xz
cd ${tmp}/${flac_srcdir}

./configure --prefix=${opt}/flac-${flac_v} \
            --with-ogg=${opt}/libogg-${flac_libogg_ver} \
            --disable-xmms-plugin
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
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
module load libogg/${flac_libogg_ver}
prereq libogg/${flac_libogg_ver}

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
