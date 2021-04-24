#!/bin/bash

# Functions for detecting and building the Vim text editor

function libaomInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libaom
if [ ! -f ${MODULEPATH}/libaom/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libaom() {
if libaomInstalled ${1}; then
  echo "libaom ${1} is installed."
else
  build_libaom ${1}
fi
}

function build_libaom() {

# Get desired version number to install
libaom_v=${1}
if [ -z "${libaom_v}" ] ; then
  libaom_v=1.0.0
fi
libaom_srcdir=libaom-${libaom_v}

echo "Installing libaom ${libaom_v}..."

case ${1} in
  1.0.0)
   libaom_yasm_ver=1.3.0
   libaom_cmake_ver=3.11.4
   libaom_doxygen_ver=1.8.14
  ;;
esac

check_modules
check_yasm ${libaom_yasm_ver}
check_cmake ${libaom_cmake_ver}
check_doxygen ${libaom_doxygen_ver}

module purge
module load yasm/${libaom_yasm_ver} \
            cmake/${libaom_cmake_ver} \
            doxygen/${libaom_doxygen_ver}
module list

downloadPackage libaom-${libaom_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libaom_srcdir} ] ; then
  rm -rf ${tmp}/${libaom_srcdir}
fi

mkdir -pv ${tmp}/${libaom_srcdir}
cd ${tmp}/${libaom_srcdir}
tar xvfz ${pkg}/libaom-${libaom_v}.tar.gz
#cd ${tmp}/${libaom_srcdir}
#./configure --prefix=${opt}/libaom-${libaom_v}
#
#make -j ${ncpu} && make install
#
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#
## Create the environment module
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
#mkdir -pv ${MODULEPATH}/libaom
#cat << eof > ${MODULEPATH}/libaom/${libaom_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts libaom-${libaom_v} into your environment"
#}
#
#set VER ${libaom_v}
#set PKG /opt/libaom-\$VER
#
#module-whatis   "Loads libaom-${libaom_v}"
#conflict libaom
#
#prepend-path PATH \$PKG/bin
#prepend-path MANPATH \$PKG/share/man
#
#eof

exit 4

cd ${root}
#rm -rf ${tmp}/${libaom_srcdir}

}