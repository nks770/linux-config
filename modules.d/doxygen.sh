#!/bin/bash

# Functions for detecting and building doxygen
echo 'Loading doxygen...'

function doxygenInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check doxygen
if [ ! -f ${MODULEPATH}/doxygen/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_doxygen() {
if doxygenInstalled ${1}; then
  echo "doxygen ${1} is installed."
else
  build_doxygen ${1}
fi
}

function build_doxygen() {

# Get desired version number to install
doxygen_v=${1}
if [ -z "${doxygen_v}" ] ; then
  doxygen_v=1.8.14
fi
doxygen_srcdir=doxygen-${doxygen_v}

echo "Installing doxygen ${doxygen_v}..."

case ${1} in
  1.8.14) # 2017-12-25
   cmake_ver=3.10.1 # 2017-12-14
   python_ver=3.6.4 # 2017-12-19
  ;;
  1.8.16) # 2019-08-08
   cmake_ver=3.19.2  # 2020-03-04 - earliest cmake that uses ncurses 6.2 and openssl 1.1.1i
   python_ver=3.7.10 # 2021-02-15 - earliest python 3.7 that uses ncurses 6.2 and openssl 1.1.1i
   flex_ver=2.6.4    # 2017-05-06
  ;;
  *) # 2017-12-25
   echo "ERROR: Review needed for doxygen ${1}"
   exit 4 # Please review
  ;;
esac

check_modules
check_flex ${flex_ver}
check_cmake ${cmake_ver}
check_python ${python_ver}
module purge
module load flex/${flex_ver} \
            cmake/${cmake_ver} \
            Python/${python_ver}
module list

downloadPackage doxygen-${doxygen_v}.src.tar.gz

cd ${tmp}

if [ -d ${tmp}/${doxygen_srcdir} ] ; then
  rm -rf ${tmp}/${doxygen_srcdir}
fi

tar xvfz ${pkg}/doxygen-${doxygen_v}.src.tar.gz
mkdir -v ${tmp}/${doxygen_srcdir}/build
cd ${tmp}/${doxygen_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  cmake -L -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) ..
  echo ''
  echo cmake -G \"Unix Makefiles\" \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
      -DCMAKE_BUILD_TYPE=Release \
      -Dbuild_doc=OFF \
      -DCMAKE_INSTALL_PREFIX=${opt}/doxygen-${doxygen_v}
  read k
fi

cmake -G "Unix Makefiles" \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
      -DCMAKE_BUILD_TYPE=Release \
      -Dbuild_doc=OFF \
      -DCMAKE_INSTALL_PREFIX=${opt}/doxygen-${doxygen_v}

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
mkdir -pv ${MODULEPATH}/doxygen
cat << eof > ${MODULEPATH}/doxygen/${doxygen_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts doxygen-${doxygen_v} into your environment"
}

set VER ${doxygen_v}
set PKG ${opt}/doxygen-\$VER

module-whatis   "Loads doxygen-${doxygen_v}"
conflict doxygen

prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${doxygen_srcdir}

}
