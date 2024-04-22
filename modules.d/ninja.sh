#!/bin/bash

# Functions for detecting and building ninja
echo 'Loading ninja...'

function ninjaInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check ninja
if [ ! -f ${MODULEPATH}/ninja/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_ninja() {
if ninjaInstalled ${1}; then
  echo "ninja ${1} is installed."
else
  build_ninja ${1}
fi
}

function build_ninja() {

# Get desired version number to install
ninja_v=${1}
if [ -z "${ninja_v}" ] ; then
  echo "ERROR: No ninja version specified!"
  exit 2
fi

case ${ninja_v} in
1.9.0) # 2019-01-30
   ninja_python_ver=3.7.2 # 2018-12-24
   ;;
1.10.0) # 2020-01-27
   ninja_python_ver=3.8.1 # 2019-12-18
   ;;
1.10.2) # 2020-11-28
   ninja_python_ver=3.9.0 # 2020-10-05
   ;;
*)
   echo "ERROR: Review needed for ninja ${ninja_v}"
   exit 4
   ;;
esac

echo "Installing ninja ${ninja_v}..."
ninja_srcdir=ninja-${ninja_v}
ninja_prefix=${opt}/${ninja_srcdir}

check_modules
check_python ${ninja_python_ver}

downloadPackage ninja-${ninja_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${ninja_srcdir} ] ; then
  rm -rf ${tmp}/${ninja_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/ninja-${ninja_v}.tar.gz
cd ${tmp}/${ninja_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to use Python 3
if [ "${ninja_v}" == "1.9.0" ] || [ "${ninja_v}" == "1.10.0" ] || [ "${ninja_v}" == "1.10.2" ] ; then

cat << eof > configure.patch
--- configure.py
+++ configure.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python
+#!/usr/bin/env python3
 #
 # Copyright 2001 Google Inc. All Rights Reserved.
 #
eof

patch -Z -b -p0 < configure.patch

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
module load Python/${ninja_python_ver}

config="./configure.py --bootstrap --verbose --with-python=$(which python3)"

if [ ${debug} -gt 0 ] ; then
  ./configure.py --help
  echo ''
  module list
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ! $? -eq 0 ] ; then
  exit 4
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Bootstrap complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  ./ninja ninja_test
  ./ninja_test
  echo '>> Tests complete'
  read k
fi

mkdir -pv ${ninja_prefix}/bin && cp -av ninja ${ninja_prefix}/bin/

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
mkdir -pv ${MODULEPATH}/ninja
cat << eof > ${MODULEPATH}/ninja/${ninja_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts ninja-${ninja_v} into your environment"
}

set VER ${ninja_v}
set PKG ${opt}/ninja-\$VER

module-whatis   "Loads ninja-${ninja_v}"
conflict ninja

prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${ninja_srcdir}

}
