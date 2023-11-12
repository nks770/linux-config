#!/bin/bash

# Functions for detecting and building davs2
echo 'Loading davs2...'

function davs2Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check davs2
if [ ! -f ${MODULEPATH}/davs2/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_davs2() {
if davs2Installed ${1}; then
  echo "davs2 ${1} is installed."
else
  build_davs2 ${1}
fi
}

function build_davs2() {

# Get desired version number to install
davs2_v=${1}
if [ -z "${davs2_v}" ] ; then
  echo "ERROR: No davs2 version specified!"
  exit 2
fi

case ${davs2_v} in
  1.6 ) # 2019-10-11
   davs2_yasm_ver=1.3.0 # 2014-08-10
  ;;
  *)
   echo "ERROR: Review needed for davs2 ${davs2_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing davs2 ${davs2_v}..."
davs2_srcdir=davs2-${davs2_v}
davs2_prefix=${opt}/${davs2_srcdir}

check_modules
check_yasm ${davs2_yasm_ver}

downloadPackage davs2-${davs2_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${davs2_srcdir} ] ; then
  rm -rf ${tmp}/${davs2_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/davs2-${davs2_v}.tar.gz
cd ${tmp}/${davs2_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patches based on Debian patches
#
# This fixes some architecture optimization flags in the configure script
#
# This also fixes some compile errors with GCC 8 (and above) - notes:
#  _mm256_insertf128_si256 and _mm256_castsi128_si256 are undeclared
#  in the scope of source/common/vec/intrinsic.h,
#  which seems to be strictly not permitted by gcc8.
#
if [ "${davs2_v}" == "1.6" ] ; then
cat << eof > multiple.patch
--- build/linux/configure
+++ build/linux/configure
@@ -664,7 +664,7 @@
                 CFLAGS="\$CFLAGS -march=i686"
             fi
             if [[ "\$asm" == auto && "\$CFLAGS" != *-mfpmath* ]]; then
-                CFLAGS="\$CFLAGS -mfpmath=sse -msse -msse2"
+                CFLAGS="\$CFLAGS -mfpmath=sse -msse"
             fi
             CFLAGS="-m32 \$CFLAGS"
             LDFLAGS="-m32 \$LDFLAGS"
@@ -712,15 +712,8 @@
     powerpc*)
         ARCH="PPC"
         if [ \$asm = auto ] ; then
-            define HAVE_ALTIVEC
             AS="\${AS-\${CC}}"
             AS_EXT=".c"
-            if [ \$SYS = MACOSX ] ; then
-                CFLAGS="\$CFLAGS -faltivec -fastf -mcpu=G4"
-            else
-                CFLAGS="\$CFLAGS -maltivec -mabi=altivec"
-                define HAVE_ALTIVEC_H
-            fi
             if [ "\$vsx" != "no" ] ; then
                 vsx="no"
                 if cc_check "" "-mvsx" ; then
--- source/common/vec/intrinsic_deblock_avx2.cc
+++ source/common/vec/intrinsic_deblock_avx2.cc
@@ -30,15 +30,14 @@
eof

echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e ' #if !HIGH_BIT_DEPTH\r' >> multiple.patch
echo -e ' __m128i c_0_128;\r' >> multiple.patch
echo -e '--- source/common/vec/intrinsic_idct_avx2.cc' >> multiple.patch
echo -e '+++ source/common/vec/intrinsic_idct_avx2.cc' >> multiple.patch
echo -e '@@ -30,15 +30,15 @@' >> multiple.patch
echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e ' /* disable warnings */\r' >> multiple.patch
echo -e ' #pragma warning(disable:4127)  // warning C4127: \xcc\xf5\xbc\xfe\xb1\xed\xb4\xef\xca\xbd\xca\xc7\xb3\xa3\xc1\xbf\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '--- source/common/vec/intrinsic_inter_pred.cc' >> multiple.patch
echo -e '+++ source/common/vec/intrinsic_inter_pred.cc' >> multiple.patch
echo -e '@@ -30,15 +30,15 @@' >> multiple.patch
echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e ' #if !HIGH_BIT_DEPTH\r' >> multiple.patch
echo -e ' /* ---------------------------------------------------------------------------\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e '--- source/common/vec/intrinsic_inter_pred_avx2.cc' >> multiple.patch
echo -e '+++ source/common/vec/intrinsic_inter_pred_avx2.cc' >> multiple.patch
echo -e '@@ -30,14 +30,15 @@' >> multiple.patch
echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e ' #pragma warning(disable:4127)  // warning C4127: \xcc\xf5\xbc\xfe\xb1\xed\xb4\xef\xca\xbd\xca\xc7\xb3\xa3\xc1\xbf\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e ' #if !HIGH_BIT_DEPTH\r' >> multiple.patch
echo -e '--- source/common/vec/intrinsic_intra-pred_avx2.cc' >> multiple.patch
echo -e '+++ source/common/vec/intrinsic_intra-pred_avx2.cc' >> multiple.patch
echo -e '@@ -30,15 +30,15 @@' >> multiple.patch
echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e ' #if !HIGH_BIT_DEPTH\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e ' void intra_pred_ver_avx(pel_t *src, pel_t *dst, int i_dst, int dir_mode, int bsx, int bsy)\r' >> multiple.patch
echo -e '--- source/common/vec/intrinsic_pixel_avx.cc' >> multiple.patch
echo -e '+++ source/common/vec/intrinsic_pixel_avx.cc' >> multiple.patch
echo -e '@@ -30,15 +30,15 @@' >> multiple.patch
echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e ' /* ---------------------------------------------------------------------------\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' void *davs2_memzero_aligned_c_avx(void *dst, size_t n)\r' >> multiple.patch
echo -e '--- source/common/vec/intrinsic_sao_avx2.cc' >> multiple.patch
echo -e '+++ source/common/vec/intrinsic_sao_avx2.cc' >> multiple.patch
echo -e '@@ -30,15 +30,15 @@' >> multiple.patch
echo -e '  *    For more information, contact us at sswang @ pku.edu.cn.\r' >> multiple.patch
echo -e '  */\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '-#include "../common.h"\r' >> multiple.patch
echo -e '-#include "intrinsic.h"\r' >> multiple.patch
echo -e '-\r' >> multiple.patch
echo -e ' #include <mmintrin.h>\r' >> multiple.patch
echo -e ' #include <emmintrin.h>\r' >> multiple.patch
echo -e ' #include <tmmintrin.h>\r' >> multiple.patch
echo -e ' #include <smmintrin.h>\r' >> multiple.patch
echo -e ' #include <immintrin.h>\r' >> multiple.patch
echo -e ' \r' >> multiple.patch
echo -e '+#include "../common.h"\r' >> multiple.patch
echo -e '+#include "intrinsic.h"\r' >> multiple.patch
echo -e '+\r' >> multiple.patch
echo -e ' #if !HIGH_BIT_DEPTH\r' >> multiple.patch
echo -e ' #ifdef _MSC_VER\r' >> multiple.patch
echo -e ' #pragma warning(disable:4244)  // TODO: \xd0\xde\xd5\xfd\xb1\xe0\xd2\xebwarning\r' >> multiple.patch

patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

cd ${tmp}/${davs2_srcdir}/build/linux

module purge
module load yasm/${davs2_yasm_ver}

config="./configure --prefix=${davs2_prefix} --enable-shared"

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

#make
make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

# There is no testsuite for davs2
#
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

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
mkdir -pv ${MODULEPATH}/davs2
cat << eof > ${MODULEPATH}/davs2/${davs2_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts davs2-${davs2_v} into your environment"
}

set VER ${davs2_v}
set PKG ${opt}/davs2-\$VER

module-whatis   "Loads davs2-${davs2_v}"
conflict davs2

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${davs2_srcdir}

}
