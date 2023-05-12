#!/bin/bash

# Functions for detecting and building Graphite2
echo 'Loading Graphite2...'

function graphite2Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check graphite2
if [ ! -f ${MODULEPATH}/graphite2/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_graphite2() {
if graphite2Installed ${1}; then
  echo "Graphite2 ${1} is installed."
else
  build_graphite2 ${1}
fi
}

function build_graphite2() {

# Get desired version number to install
graphite2_v=${1}
if [ -z "${graphite2_v}" ] ; then
  graphite2_v=1.3.14
fi

case ${graphite2_v} in
  1.3.10) # 2017-05-05
   cmake_ver=3.8.1  # 2017-05-02
  ;;
  1.3.11) # 2018-03-04
   cmake_ver=3.10.2 # 2018-01-18
  ;;
  *)
   echo "ERROR: Review needed for Graphite2 ${graphite2_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing Graphite2 ${graphite2_v}..."

check_modules
check_cmake ${cmake_ver}

downloadPackage graphite2-${graphite2_v}.tgz

cd ${tmp}

if [ -d ${tmp}/graphite2-${graphite2_v} ] ; then
  rm -rf ${tmp}/graphite2-${graphite2_v}
fi

tar xvfz ${pkg}/graphite2-${graphite2_v}.tgz
mkdir -v ${tmp}/graphite2-${graphite2_v}/build
cd ${tmp}/graphite2-${graphite2_v}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load cmake/${cmake_ver}

if [ ${debug} -gt 0 ] ; then
  #cmake -L -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) ..
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DCMAKE_INSTALL_PREFIX=${opt}/graphite2-${graphite2_v} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=${opt}/graphite2-${graphite2_v} ..

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
  echo ''
  echo 'NOTE: Several tests fail if python cannot be found.'
  echo ''
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
mkdir -pv ${MODULEPATH}/graphite2
cat << eof > ${MODULEPATH}/graphite2/${graphite2_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts Graphite2-${graphite2_v} into your environment"
}

set VER ${graphite2_v}
set PKG ${opt}/graphite2-\$VER

module-whatis   "Loads Graphite2-${graphite2_v}"
conflict graphite2

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/graphite2-${graphite2_v}

}
