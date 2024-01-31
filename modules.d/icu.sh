#!/bin/bash

# Functions for detecting and building ICU
echo 'Loading ICU...'

function icuInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check icu
if [ ! -f ${MODULEPATH}/icu/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_icu() {
if icuInstalled ${1}; then
  echo "ICU ${1} is installed."
else
  build_icu ${1}
fi
}

function build_icu() {

# Get desired version number to install
icu_v=${1}
if [ -z "${icu_v}" ] ; then
  echo "ERROR: No ICU version specified!"
  exit 2
fi

case ${icu_v} in
51.1) #2013-03-22
   icuarc=icu4c-51_1-src
   ;;
59.1) #2017-04-14
   icuarc=icu4c-59_1-src
   ;;
60.1) #2017-11-01
   icuarc=icu4c-60_1-src
   ;;
60.2) #2017-12-13
   icuarc=icu4c-60_2-src
   ;;
61.1) #2018-03-26
   icuarc=icu4c-61_1-src
   ;;
63.1) #2018-10-15
   icuarc=icu4c-63_1-src
   ;;
65.1) #2019-10-03
   icuarc=icu4c-65_1-src
   ;;
67.1) #2020-04-22
   icuarc=icu4c-67_1-src
   ;;
69.1) #2021-04-07
   icuarc=icu4c-69_1-src
   ;;
*)
   echo "ERROR: Need review for ICU ${1}"
   exit 4
   ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  m4_ver=${global_m4}
#  help2man_ver=${global_help2man}
#  texinfo_ver=${global_texinfo}
#fi

echo "Installing ICU ${icu_v}..."

check_modules

downloadPackage ${icuarc}.tgz

cd ${tmp}

if [ -d ${tmp}/icu ] ; then
  rm -rf ${tmp}/icu
fi

tar xvfz ${pkg}/${icuarc}.tgz
cd ${tmp}/icu

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# The format/DateFormatTest/TestTwoDigitYear test is now failing, as it has
# an implicit dependency on the current date. This test is part of the
# standard make check tests.
#
# Issue : This test in test/intltest/dtfmttst.cpp expects the year to be
# parsed as 1934, but as it is now less than 20 years to 2034/6/4 so this is
# parsed as 2034.
if [ "${icu_v}" == "51.1" ] ; then
cat << eof > TestTwoDigitYear.patch
--- source/test/intltest/dtfmttst.cpp
+++ source/test/intltest/dtfmttst.cpp
@@ -1127,8 +1127,8 @@
         dataerrln("FAIL: SimpleDateFormat constructor - %s", u_errorName(ec));
         return;
     }
-    parse2DigitYear(fmt, "5/6/17", date(117, UCAL_JUNE, 5));
-    parse2DigitYear(fmt, "4/6/34", date(34, UCAL_JUNE, 4));
+    parse2DigitYear(fmt, "5/6/30", date(130, UCAL_JUNE, 5));
+    parse2DigitYear(fmt, "4/6/50", date(50, UCAL_JUNE, 4));
 }
 
 // -------------------------------------
eof

patch -Z -b -p0 < TestTwoDigitYear.patch

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

# With the release of GLIBC 2.26 in August 2017, the nonstandard header
# <xlocale.h> has been removed.  Most programs should use <locale.h> instead.
# https://sourceware.org/legacy-ml/libc-alpha/2017-08/msg00010.html
if [ "${icu_v}" == "59.1" ] ; then
cat << eof > glibc.patch
--- source/i18n/digitlst.cpp	2017-01-19 18:20:31.000000000 -0600
+++ source/i18n/digitlst.cpp	2023-05-06 22:02:48.768451716 -0500
@@ -61,11 +61,7 @@
 #endif
 
 #if U_USE_STRTOD_L
-# if U_PLATFORM_USES_ONLY_WIN32_API || U_PLATFORM == U_PF_CYGWIN
 #   include <locale.h>
-# else
-#   include <xlocale.h>
-# endif
 #endif
 
 // ***************************************************************************
eof

patch -Z -b -p0 < glibc.patch

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

cd ${tmp}/icu/source
module purge

config="./configure --prefix=${opt}/icu-${icu_v} --enable-shared"

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
mkdir -pv ${MODULEPATH}/icu
cat << eof > ${MODULEPATH}/icu/${icu_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts icu-${icu_v} into your environment"
}

set VER ${icu_v}
set PKG ${opt}/icu-\$VER

module-whatis   "Loads icu-${icu_v}"
conflict icu

prepend-path PATH \$PKG/bin
prepend-path PATH \$PKG/sbin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/icu

}
