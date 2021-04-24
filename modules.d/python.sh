#!/bin/bash

# Functions for detecting and building Python

function pythonInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check python
if [ ! -f ${MODULEPATH}/Python/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_python() {
if pythonInstalled ${1}; then
  echo "Python ${1} is installed."
else
  build_python ${1}
fi
}

function build_python() {

# Get desired version number to install
python_v=${1}
if [ -z "${python_v}" ] ; then
  python_v=3.9.4
fi

#case ${python_v} in
#3.9.4)
#   vim_srcdir=vim82
#   ;;
#*)
#   vim_srcdir=vim-${python_v}
#   ;;
#esac

echo "Installing Python ${python_v}..."

check_modules
module purge

downloadPackage Python-${python_v}.tgz

cd ${tmp}

if [ -d ${tmp}/Python-${python_v} ] ; then
  rm -rf ${tmp}/Python-${python_v}
fi

tar xvfz ${pkg}/Python-${python_v}.tgz
cd ${tmp}/Python-${python_v}
./configure --prefix=${opt}/Python-${python_v} \
            --enable-shared \
            --enable-optimizations

make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create a symlink to the executable
cd ${opt}/Python-${python_v}/bin
ln -sv python${python_v%.*} python

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/Python
cat << eof > ${MODULEPATH}/Python/${python_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts Python-${python_v} into your environment"
}

set VER ${python_v}
set PKG ${opt}/Python-\$VER

module-whatis   "Loads Python-${python_v}"
conflict Python

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof
#module load gcc/${python_gcc_ver}
#prereq gcc/${python_gcc_ver}

cd ${root}
rm -rf ${tmp}/Python-${python_v}

}
