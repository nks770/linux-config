#!/bin/bash

# Functions for detecting and building rsnapshot
echo 'Loading rsnapshot...'

#function rsnapshotInstalled() {
#
#rsnapshot_vvv=${1}
#
#if [ -z "${rsnapshot_vvv}" ] ; then
#rsnapshot_vvv=1.4.5
#fi
#
#if [ ! -f ${opt}/rsnapshot-${rsnapshot_vvv}/bin/rsnapshot ] ; then
#  return 1
#fi
#
#return 0
#}

function rsnapshotInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check yasm
if [ ! -f ${MODULEPATH}/rsnapshot/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_rsnapshot() {
if rsnapshotInstalled ${1} ; then
  echo "rsnapshot-${1} is installed."
else
  build_rsnapshot ${1}
fi
}

function build_rsnapshot() {

# Get desired version number to install
rsnapshot_v=${1}
if [ -z "${rsnapshot_v}" ] ; then
  rsnapshot_v=1.4.5
fi
rsnapshot_srcdir=rsnapshot-${rsnapshot_v}

echo "Installing rsnapshot version ${rsnapshot_v}..."

check_modules

downloadPackage rsnapshot-${rsnapshot_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${rsnapshot_srcdir} ] ; then
  rm -rf ${tmp}/${rsnapshot_srcdir}
fi

tar xvfz ${pkg}/rsnapshot-${rsnapshot_v}.tar.gz
cd ${tmp}/${rsnapshot_srcdir}

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  echo ./configure --prefix=${opt}/rsnapshot-${rsnapshot_v}
  read k
fi

./configure --prefix=${opt}/rsnapshot-${rsnapshot_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make

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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
mkdir -pv ${MODULEPATH}/rsnapshot
cat << eof > ${MODULEPATH}/rsnapshot/${rsnapshot_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts rsnapshot-${rsnapshot_v} into your environment"
}

set VER ${rsnapshot_v}
set PKG ${opt}/rsnapshot-\$VER

module-whatis   "Loads rsnapshot-${rsnapshot_v}"
conflict rsnapshot

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

cd ${root}
rm -rf ${tmp}/${rsnapshot_srcdir}
}
