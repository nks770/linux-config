#!/bin/bash

# Functions for detecting and building Python
echo 'Loading Python...'

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

case ${python_v} in
3.9.4) #2021-04-04
   bzip2_ver=1.0.8
   zlib_ver=1.2.13
   openssl_ver=1.1.1n #2021-03-15
   ;;
*)
   bzip2_ver=1.0.8
   zlib_ver=1.2.13
   openssl_ver=3.0.8
   ;;
esac

echo "Installing Python ${python_v}..."

check_modules
check_bzip2 ${bzip2_ver}
check_zlib ${zlib_ver}
check_openssl ${openssl_ver}

module purge
module load bzip2/${bzip2_ver} zlib/${zlib_ver} openssl/${openssl_ver}

downloadPackage Python-${python_v}.tgz

cd ${tmp}

if [ -d ${tmp}/Python-${python_v} ] ; then
  rm -rf ${tmp}/Python-${python_v}
fi

tar xvfz ${pkg}/Python-${python_v}.tgz
cd ${tmp}/Python-${python_v}

config="./configure --prefix=${opt}/Python-${python_v} \
            --enable-shared \
	    --with-openssl=${opt}/openssl-${openssl_ver} \
	    --enable-optimizations \
	    CXX=$(command -v g++)"
#	    CPPFLAGS=-I/opt/zlib-${zlib_ver}/inblude \
#	    LDFLAGS=-L/opt/zlib-${zlib_ver}/lib"
#export CXX="$(command -v g++)"
export CPPFLAGS="-I/opt/zlib-${zlib_ver}/include -I/opt/bzip2-${bzip2_ver}/include"
export LDFLAGS="-L/opt/zlib-${zlib_ver}/lib -L/opt/bzip2-${bzip2_ver}/lib -lz -lbz2"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo CPPFLAGS="${CPPFLAGS}"
  echo LDFLAGS="${LDFLAGS}"
  echo ${config}
  echo ''
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

## Create a symlink to the executable
#cd ${opt}/Python-${python_v}/bin
#ln -sv python${python_v%.*} python

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
module load openssl/${openssl_ver} zlib/${zlib_ver} bzip2/${bzip2_ver}
prereq openssl/${openssl_ver}
prereq zlib/${zlib_ver}
prereq bzip2/${bzip2_ver}

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
