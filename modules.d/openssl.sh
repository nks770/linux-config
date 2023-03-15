#!/bin/bash

# Functions for detecting and building OpenSSL
echo 'Loading OpenSSL...'

function opensslInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check openssl
if [ ! -f ${MODULEPATH}/openssl/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_openssl() {
if opensslInstalled ${1}; then
  echo "OpenSSL ${1} is installed."
else
  build_openssl ${1}
fi
}

function build_openssl() {

# Get desired version number to install
openssl_v=${1}
if [ -z "${openssl_v}" ] ; then
  openssl_v=3.0.8
fi

case ${openssl_v} in
1.1.1k) # 2021-03-25
   zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   ;;
1.1.1n) # 2022-03-15
   zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   ;;
1.1.1s) # 2022-11-01
   zlib_ver=1.2.13 # 2022-10-12
   cert_error_warn=0
   ;;
1.1.1t) # 2023-02-07
   zlib_ver=1.2.13 # 2022-10-12
   cert_error_warn=0
   ;;
*)
   zlib_ver=1.2.13
   cert_error_warn=0
   ;;
esac

echo "Installing OpenSSL ${openssl_v}..."

check_modules
check_zlib ${zlib_ver}

module purge
module load zlib/${zlib_ver}

downloadPackage openssl-${openssl_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/openssl-${openssl_v} ] ; then
  rm -rf ${tmp}/openssl-${openssl_v}
fi

tar xvfz ${pkg}/openssl-${openssl_v}.tar.gz
cd ${tmp}/openssl-${openssl_v}

config="./config -v --prefix=${opt}/openssl-${openssl_v} \
	    --openssldir=${opt}/openssl-${openssl_v}/etc/ssl \
	    shared zlib-dynamic enable-md2 enable-rc5"

if [ ${debug} -gt 0 ] ; then
  ./config -h
  echo ''
  echo ${config}
  read k
  module list
  echo zlib: $(pkg-config --libs zlib)
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  echo ''
  echo 'Press enter for additional info...'
  read k
  perl configdata.pm --dump
  echo ''
  echo '>> Press enter to proceed with build'
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
  if [ ${cert_error_warn} -gt 0 ]; then
    echo ''
    echo 'NOTE: Test 80_teset_ssl_new.t fails due to a known expired certificate.'
    # make test TESTS='test_ssl_new' V=1
  fi
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
mkdir -pv ${MODULEPATH}/openssl
cat << eof > ${MODULEPATH}/openssl/${openssl_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts openssl-${openssl_v} into your environment"
}

set VER ${openssl_v}
set PKG ${opt}/openssl-\$VER

module-whatis   "Loads openssl-${openssl_v}"
conflict openssl
module load zlib/${zlib_ver}
prereq zlib/${zlib_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/openssl-${openssl_v}

}
