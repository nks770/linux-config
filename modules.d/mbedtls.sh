#!/bin/bash

# Functions for detecting and building mbedtls
echo 'Loading mbedtls...'

function mbedtlsInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check mbedtls
if [ ! -f ${MODULEPATH}/mbedtls/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_mbedtls() {
if mbedtlsInstalled ${1}; then
  echo "mbedtls ${1} is installed."
else
  build_mbedtls ${1}
fi
}

function build_mbedtls() {

# Get desired version number to install
mbedtls_v=${1}
if [ -z "${mbedtls_v}" ] ; then
  echo "ERROR: No mbedtls version specified!"
  exit 2
fi
mbedtls_srcdir=mbedtls-${mbedtls_v}
mbedtls_prefix=${opt}/${mbedtls_srcdir}

mbedtls_create_pkgconfig=0
case ${mbedtls_v} in
  2.26.0) # 2021-03-12
   mbedtls_cmake_ver=3.19.6  # 2021-02-24
   mbedtls_python_ver=3.9.2  # 2021-02-19
   mbedtls_zlib_ver=1.2.11   # 2017-01-15
   mbedtls_create_pkgconfig=1
  ;;
  3.0.0) # 2021-07-07
   mbedtls_cmake_ver=3.20.5  # 2021-06-21
   mbedtls_python_ver=3.9.6  # 2021-06-28
   mbedtls_zlib_ver=1.2.11   # 2017-01-15
   mbedtls_create_pkgconfig=1
  ;;
  *)
   echo "ERROR: Review needed for mbedtls ${mbedtls_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  mbedtls_zlib_ver=${global_zlib}
fi

echo "Installing mbed-TLS ${mbedtls_v}..."

check_modules
check_zlib ${mbedtls_zlib_ver}
check_cmake ${mbedtls_cmake_ver}
check_python ${mbedtls_python_ver}

downloadPackage ${mbedtls_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${mbedtls_srcdir} ] ; then
  rm -rf ${tmp}/${mbedtls_srcdir}
fi

tar xvfz ${pkg}/${mbedtls_srcdir}.tar.gz
mkdir -v ${tmp}/${mbedtls_srcdir}/build
cd ${tmp}/${mbedtls_srcdir}/build


if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load zlib/${mbedtls_zlib_ver}
module load cmake/${mbedtls_cmake_ver}
module load Python/${mbedtls_python_ver}

case ${mbedtls_v} in
  2.26.0)
     build_options="-DENABLE_ZLIB_SUPPORT=ON
                    -DLINK_WITH_PTHREAD=ON"
  ;;
  3.0.0)
     build_options="-DCMAKE_BUILD_TYPE=Release
                    -DLINK_WITH_PTHREAD=ON"
  ;;
  *)
   echo "ERROR: Review needed for mbedtls ${mbedtls_v}"
   exit 4 # Please review
  ;;
esac
if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      ${build_options} \
      -DUSE_SHARED_MBEDTLS_LIBRARY=ON \
      -DCMAKE_INSTALL_PREFIX=${mbedtls_prefix} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      ${build_options} \
      -DUSE_SHARED_MBEDTLS_LIBRARY=ON \
      -DCMAKE_INSTALL_PREFIX=${mbedtls_prefix} ..

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

#make
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

# If the pkg-config files are missing, then create some
if [ ${mbedtls_create_pkgconfig} -gt 0 ] ; then
mkdir -pv ${mbedtls_prefix}/lib/pkgconfig
cat << eof > ${mbedtls_prefix}/lib/pkgconfig/mbedcrypto.pc
prefix=${mbedtls_prefix}
includedir=\${prefix}/include
libdir=\${prefix}/lib

Name: Mbed TLS
Description: Mbed TLS is a C library that implements cryptographic primitives, X.509 certificate manipulation and the SSL/TLS and DTLS protocols. Its small code footprint makes it suitable for embedded systems.
URL: https://www.trustedfirmware.org/projects/mbed-tls/
Version: ${mbedtls_v}
Cflags: -I"\${includedir}"
Libs: -L"\${libdir}" -lmbedcrypto
eof
cat << eof > ${mbedtls_prefix}/lib/pkgconfig/mbedtls.pc
prefix=${mbedtls_prefix}
includedir=\${prefix}/include
libdir=\${prefix}/lib

Name: Mbed TLS
Description: Mbed TLS is a C library that implements cryptographic primitives, X.509 certificate manipulation and the SSL/TLS and DTLS protocols. Its small code footprint makes it suitable for embedded systems.
URL: https://www.trustedfirmware.org/projects/mbed-tls/
Version: ${mbedtls_v}
Requires.private: mbedcrypto mbedx509
Cflags: -I"\${includedir}"
Libs: -L"\${libdir}" -lmbedtls
eof
cat << eof > ${mbedtls_prefix}/lib/pkgconfig/mbedx509.pc
prefix=${mbedtls_prefix}
includedir=\${prefix}/include
libdir=\${prefix}/lib

Name: Mbed TLS
Description: Mbed TLS is a C library that implements cryptographic primitives, X.509 certificate manipulation and the SSL/TLS and DTLS protocols. Its small code footprint makes it suitable for embedded systems.
URL: https://www.trustedfirmware.org/projects/mbed-tls/
Version: ${mbedtls_v}
Requires.private: mbedcrypto
Cflags: -I"\${includedir}"
Libs: -L"\${libdir}" -lmbedx509
eof
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
mkdir -pv ${MODULEPATH}/mbedtls
cat << eof > ${MODULEPATH}/mbedtls/${mbedtls_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts mbedtls-${mbedtls_v} into your environment"
}

set VER ${mbedtls_v}
set PKG ${opt}/mbedtls-\$VER

module-whatis   "Loads mbedtls-${mbedtls_v}"
conflict mbedtls
module load zlib/${mbedtls_zlib_ver}
prereq zlib/${mbedtls_zlib_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof


cd ${root}
rm -rf ${tmp}/${mbedtls_srcdir}

}
