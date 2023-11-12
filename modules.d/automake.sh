#!/bin/bash

# Functions for detecting and building automake
echo 'Loading automake...'

function automakeInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check automake
if [ ! -f ${MODULEPATH}/automake/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_automake() {
if automakeInstalled ${1}; then
  echo "automake ${1} is installed."
else
  build_automake ${1}
fi
}

function build_automake() {

# Get desired version number to install
automake_v=${1}
if [ -z "${automake_v}" ] ; then
  echo "ERROR: No version of automake specified!"
  exit 2
fi

case ${automake_v} in
1.14.1) # 2013-12-24
   automake_autoconf_ver=2.69 # 2012-04-24
   ;;
*)
   echo "ERROR: Need review for automake ${automake_v}"
   exit 4
   ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  automake_m4_ver=${global_m4}
#fi

echo "Installing automake ${automake_v}..."

check_modules
check_autoconf ${automake_autoconf_ver}
#check_m4 ${automake_m4_ver}

downloadPackage automake-${automake_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/automake-${automake_v} ] ; then
  rm -rf ${tmp}/automake-${automake_v}
fi

tar xvfz ${pkg}/automake-${automake_v}.tar.gz
cd ${tmp}/automake-${automake_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load autoconf/${automake_autoconf_ver}
#module load m4/${automake_m4_ver}

config="./configure --prefix=${opt}/automake-${automake_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
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
mkdir -pv ${MODULEPATH}/automake
cat << eof > ${MODULEPATH}/automake/${automake_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts automake-${automake_v} into your environment"
}

set VER ${automake_v}
set PKG ${opt}/automake-\$VER

module-whatis   "Loads automake-${automake_v}"
conflict automake
module load autoconf/${automake_autoconf_ver}
prereq autoconf/${automake_autoconf_ver}

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/automake-${automake_v}

}
