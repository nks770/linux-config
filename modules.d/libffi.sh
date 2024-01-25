#!/bin/bash

# Functions for detecting and building libffi
echo 'Loading libffi...'

function libffiInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libffi
if [ ! -f ${MODULEPATH}/libffi/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libffi() {
if libffiInstalled ${1}; then
  echo "libffi ${1} is installed."
else
  build_libffi ${1}
fi
}

function build_libffi() {

# Get desired version number to install
libffi_v=${1}
if [ -z "${libffi_v}" ] ; then
  echo "ERROR: No libffi version specified!"
  exit 2
fi

case ${libffi_v} in
3.0.13)
   libffi_dejagnu_ver=1.6.3
   libffi_include_dir=${opt}/libffi-${libffi_v}/lib/libffi-${libffi_v}/include
   ;;
3.2.1)
   libffi_dejagnu_ver=1.6.3
   libffi_include_dir=${opt}/libffi-${libffi_v}/lib/libffi-${libffi_v}/include
   ;;
3.3)
   libffi_dejagnu_ver=1.6.3
   libffi_include_dir=${opt}/libffi-${libffi_v}/include
   ;;
3.4.4)
   libffi_dejagnu_ver=1.6.3
   libffi_include_dir=${opt}/libffi-${libffi_v}/include
   ;;
*)
   echo "ERROR: Need review for libffi ${libffi_v}"
   exit 4
   ;;
esac

echo "Installing libffi ${libffi_v}..."
libffi_srcdir=libffi-${libffi_v}

check_modules
check_dejagnu ${libffi_dejagnu_ver}

downloadPackage libffi-${libffi_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libffi_srcdir} ] ; then
  rm -rf ${tmp}/${libffi_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libffi-${libffi_v}.tar.gz
cd ${tmp}/${libffi_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to fix a testsuite error in libffi 3.0.13
if [ "${libffi_v}" == "3.0.13" ] ; then
cat << eof > ffitest.patch
--- testsuite/libffi.call/ffitest.h
+++ testsuite/libffi.call/ffitest.h
@@ -15,7 +15,7 @@
 
 #define MAX_ARGS 256
 
-#define CHECK(x) !(x) ? (abort(), 1) : 0
+#define CHECK(x) (void)(!(x) ? (abort(), 1) : 0)
 
 /* Define __UNUSED__ that also other compilers than gcc can run the tests.  */
 #undef __UNUSED__
eof
patch -Z -b -p0 < ffitest.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

module purge
module load dejagnu/${libffi_dejagnu_ver}

config="./configure --prefix=${opt}/libffi-${libffi_v}"

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
  # Requires DejaGnu to work
  echo runtest: $(which runtest)
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
mkdir -pv ${MODULEPATH}/libffi
cat << eof > ${MODULEPATH}/libffi/${libffi_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libffi-${libffi_v} into your environment"
}

set VER ${libffi_v}
set PKG ${opt}/libffi-\$VER

module-whatis   "Loads libffi-${libffi_v}"
conflict libffi

prepend-path CPATH ${libffi_include_dir}
prepend-path C_INCLUDE_PATH ${libffi_include_dir}
prepend-path CPLUS_INCLUDE_PATH ${libffi_include_dir}

setenv LIBFFI_INCLUDE ${libffi_include_dir}

prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libffi_srcdir}

}
