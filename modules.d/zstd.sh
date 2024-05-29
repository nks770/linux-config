#!/bin/bash

# Functions for detecting and building zstd
echo 'Loading zstd...'

function get_zstd_library() {
case ${1} in
  1.4.4)
    echo libzstd.so.1.4.4
  ;;
  1.4.5)
    echo libzstd.so.1.4.5
  ;;
  1.4.8)
    echo libzstd.so.1.4.8
  ;;
  1.4.9)
    echo libzstd.so.1.4.9
  ;;
  1.5.0)
    echo libzstd.so.1.5.0
  ;;
  *)
    echo ''
  ;;
esac
}

function zstdInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check zstd
if [ ! -f ${MODULEPATH}/zstd/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_zstd() {
if zstdInstalled ${1}; then
  echo "zstd ${1} is installed."
else
  build_zstd ${1}
fi
}

function build_zstd() {

zstd_use_cmake=0

# Get desired version number to install
zstd_v=${1}
if [ -z "${zstd_v}" ] ; then
  echo "ERROR: No zstd version specified!"
  exit 2
fi

case ${zstd_v} in
  1.4.4) # 2019-11-05
    zstd_cmake_ver=3.15.5 # 2019-10-30
    zstd_zlib_ver=1.2.11      #2017-01-15
    zstd_xz_ver=5.2.4         #2018-04-29
    zstd_lz4_ver=1.9.2        #2019-08-15
  ;;
  1.4.5) # 2020-05-22
    zstd_cmake_ver=3.17.2 # 2020-04-28
    zstd_zlib_ver=1.2.11      #2017-01-15
    zstd_xz_ver=5.2.5         #2020-03-17
    zstd_lz4_ver=1.9.2        #2019-08-15 - next 2020-11-15 (1.9.3)
  ;;
  1.4.8) # 2020-12-18
    zstd_cmake_ver=3.19.0 # 2020-11-18
    zstd_zlib_ver=1.2.11      #2017-01-15
    zstd_xz_ver=5.2.5         #2020-03-17
    zstd_lz4_ver=1.9.3        #2020-11-15 - next 2022-08-15 (1.9.4)
  ;;
  1.4.9) # 2021-03-03
    zstd_cmake_ver=3.19.6 # 2021-02-24
    zstd_zlib_ver=1.2.11      #2017-01-15
    zstd_xz_ver=5.2.5         #2020-03-17
    zstd_lz4_ver=1.9.3        #2020-11-15 - next 2022-08-15 (1.9.4)
  ;;
  1.5.0) # 2021-05-14
    zstd_cmake_ver=3.20.2 # 2021-04-29
    zstd_zlib_ver=1.2.11      #2017-01-15
    zstd_xz_ver=5.2.5         #2020-03-17
    zstd_lz4_ver=1.9.3        #2020-11-15 - next 2022-08-15 (1.9.4)
  ;;
  *)
   echo "ERROR: Review needed for zstd ${zstd_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  zstd_zlib_ver=${global_zlib}
  zstd_xz_ver=${global_xz}
#  zstd_lz4_ver=${global_lz4}
fi

echo "Installing zstd ${zstd_v}..."
zstd_srcdir=zstd-${zstd_v}

check_modules
if [ ${zstd_use_cmake} -gt 0 ] ; then
  check_cmake ${zstd_cmake_ver}
fi
check_xz ${zstd_xz_ver}
check_zlib ${zstd_zlib_ver}
check_lz4 ${zstd_lz4_ver}

downloadPackage zstd-${zstd_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${zstd_srcdir} ] ; then
  rm -rf ${tmp}/${zstd_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/zstd-${zstd_v}.tar.gz
cd ${tmp}/${zstd_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi


# Fix some issues with escape characters in the Makefile
if [ "${zstd_v}" == "1.4.4" ] ; then
cat << eof > zstd.patch
--- programs/Makefile
+++ programs/Makefile
@@ -96,7 +96,7 @@
 
 # thread detection
 NO_THREAD_MSG := ==> no threads, building without multithreading support
-HAVE_PTHREAD := \$(shell printf '\\#include <pthread.h>\\nint main(void) { return 0; }' > have_pthread.c && \$(CC) \$(FLAGS) -o have_pthread\$(EXT) have_pthread.c -pthread 2> \$(VOID) && rm have_pthread\$(EXT) && echo 1 || echo 0; rm have_pthread.c)
+HAVE_PTHREAD := \$(shell printf '#include <pthread.h>\\nint main(void) { return 0; }' > have_pthread.c && \$(CC) \$(FLAGS) -o have_pthread\$(EXT) have_pthread.c -pthread 2> \$(VOID) && rm have_pthread\$(EXT) && echo 1 || echo 0; rm have_pthread.c)
 HAVE_THREAD := \$(shell [ "\$(HAVE_PTHREAD)" -eq "1" -o -n "\$(filter Windows%,\$(OS))" ] && echo 1 || echo 0)
 ifeq (\$(HAVE_THREAD), 1)
 THREAD_MSG := ==> building with threading support
@@ -108,7 +108,7 @@
 
 # zlib detection
 NO_ZLIB_MSG := ==> no zlib, building zstd without .gz support
-HAVE_ZLIB := \$(shell printf '\\#include <zlib.h>\\nint main(void) { return 0; }' > have_zlib.c && \$(CC) \$(FLAGS) -o have_zlib\$(EXT) have_zlib.c -lz 2> \$(VOID) && rm have_zlib\$(EXT) && echo 1 || echo 0; rm have_zlib.c)
+HAVE_ZLIB := \$(shell printf '#include <zlib.h>\\nint main(void) { return 0; }' > have_zlib.c && \$(CC) \$(FLAGS) -o have_zlib\$(EXT) have_zlib.c -lz 2> \$(VOID) && rm have_zlib\$(EXT) && echo 1 || echo 0; rm have_zlib.c)
 ifeq (\$(HAVE_ZLIB), 1)
 ZLIB_MSG := ==> building zstd with .gz compression support
 ZLIBCPP = -DZSTD_GZCOMPRESS -DZSTD_GZDECOMPRESS
@@ -119,7 +119,7 @@
 
 # lzma detection
 NO_LZMA_MSG := ==> no liblzma, building zstd without .xz/.lzma support
-HAVE_LZMA := \$(shell printf '\\#include <lzma.h>\\nint main(void) { return 0; }' > have_lzma.c && \$(CC) \$(FLAGS) -o have_lzma\$(EXT) have_lzma.c -llzma 2> \$(VOID) && rm have_lzma\$(EXT) && echo 1 || echo 0; rm have_lzma.c)
+HAVE_LZMA := \$(shell printf '#include <lzma.h>\\nint main(void) { return 0; }' > have_lzma.c && \$(CC) \$(FLAGS) -o have_lzma\$(EXT) have_lzma.c -llzma 2> \$(VOID) && rm have_lzma\$(EXT) && echo 1 || echo 0; rm have_lzma.c)
 ifeq (\$(HAVE_LZMA), 1)
 LZMA_MSG := ==> building zstd with .xz/.lzma compression support
 LZMACPP = -DZSTD_LZMACOMPRESS -DZSTD_LZMADECOMPRESS
@@ -130,7 +130,7 @@
 
 # lz4 detection
 NO_LZ4_MSG := ==> no liblz4, building zstd without .lz4 support
-HAVE_LZ4 := \$(shell printf '\\#include <lz4frame.h>\\n\\#include <lz4.h>\\nint main(void) { return 0; }' > have_lz4.c && \$(CC) \$(FLAGS) -o have_lz4\$(EXT) have_lz4.c -llz4 2> \$(VOID) && rm have_lz4\$(EXT) && echo 1 || echo 0; rm have_lz4.c)
+HAVE_LZ4 := \$(shell printf '#include <lz4frame.h>\\n#include <lz4.h>\\nint main(void) { return 0; }' > have_lz4.c && \$(CC) \$(FLAGS) -o have_lz4\$(EXT) have_lz4.c -llz4 2> \$(VOID) && rm have_lz4\$(EXT) && echo 1 || echo 0; rm have_lz4.c)
 ifeq (\$(HAVE_LZ4), 1)
 LZ4_MSG := ==> building zstd with .lz4 compression support
 LZ4CPP = -DZSTD_LZ4COMPRESS -DZSTD_LZ4DECOMPRESS
eof
patch -Z -b -p0 < zstd.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
if [ ${zstd_use_cmake} -gt 0 ] ; then
  module load cmake/${zstd_cmake_ver}
fi
module load xz/${zstd_xz_ver}
module load zlib/${zstd_zlib_ver}
module load lz4/${zstd_lz4_ver}

if [ ${zstd_use_cmake} -gt 0 ] ; then

cd ${tmp}/${zstd_srcdir}/build/cmake

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DCMAKE_INSTALL_PREFIX=${opt}/zstd-${zstd_v}
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
       -DCMAKE_INSTALL_PREFIX=${opt}/zstd-${zstd_v}

else
  export CFLAGS="-I${opt}/xz-${zstd_xz_ver}/include -I${opt}/zlib-${zstd_zlib_ver}/include -I${opt}/lz4-${zstd_lz4_ver}/include"
  export LDFLAGS="-L${opt}/xz-${zstd_xz_ver}/lib -L${opt}/zlib-${zstd_zlib_ver}/lib -L${opt}/lz4-${zstd_lz4_ver}/lib"
  if [ ${debug} -gt 0 ] ; then
    echo ''
    module list
    echo ''
    echo CFLAGS=${CFLAGS}
    echo LDFLAGS=${LDFLAGS}
    echo ''
    echo 'No configuration is necessary.'
    echo ''
  fi
fi

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

# The zstd testsuite is not safe to run as root!
# It sets the chmod of "/dev/null" to 600, and breaks a lot of stuff!
if [ ${run_tests} -gt 0 ] ; then
  make check
  echo '>> Tests complete'
  read k
fi

if [ ${zstd_use_cmake} -gt 0 ] ; then
  make install
else
  make prefix=${opt}/zstd-${zstd_v} install
fi

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
mkdir -pv ${MODULEPATH}/zstd
cat << eof > ${MODULEPATH}/zstd/${zstd_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts zstd-${zstd_v} into your environment"
}

set VER ${zstd_v}
set PKG ${opt}/zstd-\$VER

module-whatis   "Loads zstd-${zstd_v}"
conflict zstd
module load xz/${zstd_xz_ver}
module load zlib/${zstd_zlib_ver}
module load lz4/${zstd_lz4_ver}
prereq xz/${zstd_xz_ver}
prereq zlib/${zstd_zlib_ver}
prereq lz4/${zstd_lz4_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${zstd_srcdir}

unset CFLAGS
unset LDFLAGS

}
