#!/bin/bash

# Functions for detecting and building libffi
echo 'Loading libffi...'

function libffiInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libffi
if [ ! -f ${MODULEPATH}/libffi/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libffi() {
if libffiInstalled ${1}; then
  echo "libffi ${1} is installed."
else
  build_libffi ${1}
fi
}

function build_libffi() {

# Get desired version number to install
libffi_v=${1}
if [ -z "${libffi_v}" ] ; then
  libffi_v=3.4.4
fi

case ${libffi_v} in
3.4.4)
   dejagnu_ver=1.6.3
   ;;
*)
   dejagnu_ver=1.6.3
   ;;
esac
echo "Installing libffi ${libffi_v}..."

check_modules
check_dejagnu ${dejagnu_ver}

module purge
module load dejagnu/${dejagnu_ver}

downloadPackage libffi-${libffi_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/libffi-${libffi_v} ] ; then
  rm -rf ${tmp}/libffi-${libffi_v}
fi

tar xvfz ${pkg}/libffi-${libffi_v}.tar.gz
cd ${tmp}/libffi-${libffi_v}

config="./configure --prefix=${opt}/libffi-${libffi_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

#make -j ${ncpu}
make

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  # Requires DejaGnu to work
  echo runtest: $(which runtest)
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
mkdir -pv ${MODULEPATH}/libffi
cat << eof > ${MODULEPATH}/libffi/${libffi_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libffi-${libffi_v} into your environment"
}

set VER ${libffi_v}
set PKG ${opt}/libffi-\$VER

module-whatis   "Loads libffi-${libffi_v}"
conflict libffi

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/libffi-${libffi_v}

}
