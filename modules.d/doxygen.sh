#!/bin/bash

# Functions for detecting and building the Vim text editor

function doxygenInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check doxygen
if [ ! -f ${MODULEPATH}/doxygen/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_doxygen() {
if doxygenInstalled ${1}; then
  echo "doxygen ${1} is installed."
else
  build_doxygen ${1}
fi
}

function build_doxygen() {

# Get desired version number to install
doxygen_v=${1}
if [ -z "${doxygen_v}" ] ; then
  doxygen_v=1.8.14
fi
doxygen_srcdir=doxygen-${doxygen_v}

echo "Installing doxygen ${doxygen_v}..."

case ${1} in
  1.8.14)
   doxygen_cmake_ver=3.9.6
  ;;
esac

check_modules
check_cmake ${doxygen_cmake_ver}
module purge
module load cmake/${doxygen_cmake_ver}
module list

downloadPackage doxygen-${doxygen_v}.src.tar.gz

cd ${tmp}

if [ -d ${tmp}/${doxygen_srcdir} ] ; then
  rm -rf ${tmp}/${doxygen_srcdir}
fi

tar xvfz ${pkg}/doxygen-${doxygen_v}.src.tar.gz
cd ${tmp}/${doxygen_srcdir}

cmake -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${opt}/doxygen-${doxygen_v}

exit 4
#make -j ${ncpu} && make install
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#
## Create the environment module
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi
#mkdir -pv ${MODULEPATH}/doxygen
#cat << eof > ${MODULEPATH}/doxygen/${doxygen_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts doxygen-${doxygen_v} into your environment"
#}
#
#set VER ${doxygen_v}
#set PKG /opt/doxygen-\$VER
#
#module-whatis   "Loads doxygen-${doxygen_v}"
#conflict doxygen
#
#prepend-path CPATH \$PKG/include
#prepend-path C_INCLUDE_PATH \$PKG/include
#prepend-path CPLUS_INCLUDE_PATH \$PKG/include
#prepend-path LD_LIBRARY_PATH \$PKG/lib
#prepend-path PATH \$PKG/bin
#prepend-path MANPATH \$PKG/share/man
#
#eof
#
#cd ${root}
#rm -rf ${tmp}/${doxygen_srcdir}

}
