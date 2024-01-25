#!/bin/bash

# Functions for detecting and building fribidi
echo 'Loading fribidi...'

function fribidiInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check fribidi
if [ ! -f ${MODULEPATH}/fribidi/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_fribidi() {
if fribidiInstalled ${1}; then
  echo "fribidi ${1} is installed."
else
  build_fribidi ${1}
fi
}

function build_fribidi() {

# Get desired version number to install
fribidi_v=${1}
if [ -z "${fribidi_v}" ] ; then
  echo "ERROR: No FriBidi version specified!"
  exit 2
fi

case ${fribidi_v} in
0.19.7) #2015-08-06
   fribidi_arc=bz2
   fribidi_tar=xvfj
   ;;
1.0.8) #2019-12-13
   fribidi_arc=bz2
   fribidi_tar=xvfj
   ;;
1.0.9) #2020-03-02
   fribidi_arc=xz
   fribidi_tar=xvfJ
   ;;
*)
   echo "ERROR: Need review for FriBidi ${fribidi_v}"
   exit 4
   ;;
esac

echo "Installing fribidi ${fribidi_v}..."

check_modules
module purge

downloadPackage fribidi-${fribidi_v}.tar.${fribidi_arc}

cd ${tmp}

if [ -d ${tmp}/fribidi-${fribidi_v} ] ; then
  rm -rf ${tmp}/fribidi-${fribidi_v}
fi

tar ${fribidi_tar} ${pkg}/fribidi-${fribidi_v}.tar.${fribidi_arc}
cd ${tmp}/fribidi-${fribidi_v}

config="./configure --prefix=${opt}/fribidi-${fribidi_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
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
mkdir -pv ${MODULEPATH}/fribidi
cat << eof > ${MODULEPATH}/fribidi/${fribidi_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts fribidi-${fribidi_v} into your environment"
}

set VER ${fribidi_v}
set PKG ${opt}/fribidi-\$VER

module-whatis   "Loads fribidi-${fribidi_v}"
conflict fribidi

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/fribidi-${fribidi_v}

}
