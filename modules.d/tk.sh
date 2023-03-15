#!/bin/bash

# Functions for detecting and building Tk
echo 'Loading tk...'

function tkInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
# If modules is OK, then check zlib
if [ ! -f ${MODULEPATH}/tk/${1} ] ; then
  return 1
else
  return 0
fi
}

#function tkInstalled() {
#
#tk_vvv=${1}
#
#if [ -z "${tk_vvv}" ] ; then
#tk_vvv=8.6.13
#fi
#tk_vv=${tk_vvv%.*}
#
#if [ ! -f ${opt}/tk-${tk_vvv}/lib/libtk${tk_vv}.so ] ; then
#  return 1
#fi
#
#return 0
#}

function check_tk() {
if tkInstalled ${1} ; then
  echo "tk-${1} is installed."
else
  build_tk ${1}
fi
}

function build_tk() {

# Get desired version number to install
tk_v=${1}
if [ -z "${tk_v}" ] ; then
  tk_v=8.6.13
fi

#if [ "${tk_v}" == "8.6.11" ] ; then
#  tk_vv=8.6.11.1
#else
#  tk_vv=${v}
#fi

case ${tk_v} in
8.6.13)
   tcl_ver=8.6.13
   ;;
*)
   tcl_ver=8.6.13
   ;;
esac

echo "Installing Tk version ${tk_v}..."

check_modules
check_tcl ${tcl_ver}

module purge
module load tcl/${tcl_ver}

downloadPackage tk${tk_v}-src.tar.gz

mkdir -pv ${opt}/tk-${tk_v}

cd ${opt}/tk-${tk_v}
tar xvfz ${pkg}/tk${tk_v}-src.tar.gz
mv -fv tk${tk_v} build
cd ${opt}/tk-${tk_v}/build/unix

config="./configure --prefix=${opt}/tk-${tk_v} --with-tcl=${opt}/tcl-${tcl_ver}/lib"

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

make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make test
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
mkdir -pv ${MODULEPATH}/tk
cat << eof > ${MODULEPATH}/tk/${tk_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts tk-${tk_v} into your environment"
}

set VER ${tk_v}
set PKG ${opt}/tk-\$VER

module-whatis   "Loads tk-${tk_v}"
conflict tk
module load tcl/${tcl_ver}
prereq tcl/${tcl_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}

}
