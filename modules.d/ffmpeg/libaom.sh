#!/bin/bash

# Functions for detecting and building libaom

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
  1.0.0) #Mon Jun 25 07:54:59 2018 -0700
   libaom_yasm_ver=1.3.0
   libaom_cmake_ver=3.11.4
   libaom_doxygen_ver=1.8.14
   libaom_python_ver=3.9.4
  ;;
  3.5.0) #Wed Sep 21 12:36:24 2022 -0400
   libaom_yasm_ver=1.3.0
   libaom_cmake_ver=3.24.2   # 2022-09-13
   libaom_doxygen_ver=1.9.5  # 2022-08-26
   libaom_python_ver=3.10.7  # 2022-09-06
  ;;
esac

check_modules
check_yasm ${libaom_yasm_ver}
check_cmake ${libaom_cmake_ver}
check_doxygen ${libaom_doxygen_ver}
check_python ${libaom_python_ver}

module purge
module load yasm/${libaom_yasm_ver} \
            cmake/${libaom_cmake_ver} \
            doxygen/${libaom_doxygen_ver} \
            Python/${libaom_python_ver}
module list

downloadPackage libaom-${libaom_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libaom_srcdir} ] ; then
  rm -rf ${tmp}/${libaom_srcdir}
fi
if [ -d ${tmp}/${libaom_srcdir}_build ] ; then
  rm -rf ${tmp}/${libaom_srcdir}_build
fi

mkdir -pv ${tmp}/${libaom_srcdir} ${tmp}/${libaom_srcdir}_build
cd ${tmp}/${libaom_srcdir}
tar xvfz ${pkg}/libaom-${libaom_v}.tar.gz
cd ${tmp}/${libaom_srcdir}_build

cmake -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=${opt}/libaom-${libaom_v} -DBUILD_SHARED_LIBS=on ../${libaom_srcdir}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libaom
cat << eof > ${MODULEPATH}/libaom/${libaom_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libaom-${libaom_v} into your environment"
}

set VER ${libaom_v}
set PKG ${opt}/libaom-\$VER

module-whatis   "Loads libaom-${libaom_v}"
conflict libaom

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib64
prepend-path PKG_CONFIG_PATH \$PKG/lib64/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libaom_srcdir}
rm -rf ${tmp}/${libaom_srcdir}_build

}
