#!/bin/bash

# Functions for detecting and building flex
echo 'Loading flex...'

function flexInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check flex
if [ ! -f ${MODULEPATH}/flex/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_flex() {
if flexInstalled ${1}; then
  echo "flex ${1} is installed."
else
  build_flex ${1}
fi
}

function build_flex() {

# Get desired version number to install
flex_v=${1}
if [ -z "${flex_v}" ] ; then
  flex_v=2.6.4
fi

case ${flex_v} in
2.6.4) #2017-05-06
   m4_ver=1.4.18       # 2016-12-31
   help2man_ver=1.47.4 # 2016-05-09
#   bison_ver=3.0.4     # 2015-01-23 bison testsuite requires flex, but bison is not a strict prerequisite for flex
   texinfo_ver=6.3     # 2016-09-10
   ;;
*)
   echo "ERROR: Need review for flex ${1}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  m4_ver=${global_m4}
  help2man_ver=${global_help2man}
  texinfo_ver=${global_texinfo}
fi

echo "Installing flex ${flex_v}..."

check_modules
check_m4 ${m4_ver}
check_help2man ${help2man_ver}
#check_bison ${bison_ver}
check_texinfo ${texinfo_ver}
module purge
module load m4/${m4_ver}
module load help2man/${help2man_ver}
#module load bison/${bison_ver}
module load texinfo/${texinfo_ver}

downloadPackage flex-${flex_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/flex-${flex_v} ] ; then
  rm -rf ${tmp}/flex-${flex_v}
fi

tar xvfz ${pkg}/flex-${flex_v}.tar.gz
cd ${tmp}/flex-${flex_v}

config="./configure --prefix=${opt}/flex-${flex_v}"

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
mkdir -pv ${MODULEPATH}/flex
cat << eof > ${MODULEPATH}/flex/${flex_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts flex-${flex_v} into your environment"
}

set VER ${flex_v}
set PKG ${opt}/flex-\$VER

module-whatis   "Loads flex-${flex_v}"
conflict flex

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/flex-${flex_v}

}
