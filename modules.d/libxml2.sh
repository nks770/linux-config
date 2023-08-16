#!/bin/bash

# Functions for detecting and building libxml2
echo 'Loading libxml2...'

function libxml2Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libxml2
if [ ! -f ${MODULEPATH}/libxml2/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libxml2() {
if libxml2Installed ${1}; then
  echo "libxml2 ${1} is installed."
else
  build_libxml2 ${1}
fi
}

function get_libxml2_library() {
case ${1} in
  2.9.10)
    echo libxml2.so.2.9.10
  ;;
  *)
    echo ''
  ;;
esac
}

function libxml2DepInstalled() {
if [ ! -f "${2}/lib/$(get_libxml2_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libxml2() {
echo -n "Checking for presence of libxml2-${1} in ${2}..."
if libxml2DepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libxml2 ${1} ${2} ${3}
fi
}


function build_libxml2() {

# Get desired version number to install
libxml2_v=${1}
if [ -z "${libxml2_v}" ] ; then
  libxml2_v=2.9.9
fi

case ${libxml2_v} in
2.9.7) # 2017-11-02
   xz_ver=5.2.3    # 2016-12-30
   zlib_ver=1.2.11 # 2017-01-15
   icu_ver=60.1    # 2017-11-01
   ;;
2.9.8) # 2018-03-05
   xz_ver=5.2.3    # 2016-12-30
   zlib_ver=1.2.11 # 2017-01-15
#   icu_ver=60.2    # 2017-12-13
   icu_ver=61.1    # 2018-03-26 -- for compatibility with freetype 2.9.1
   ;;
2.9.9) # 2019-01-03
   xz_ver=5.2.4    # 2018-04-29
   zlib_ver=1.2.11 # 2017-01-15
   icu_ver=63.1    # 2018-10-15
   ;;
2.9.10) # 2019-10-30
   xz_ver=5.2.4    # 2018-04-29
   zlib_ver=1.2.11 # 2017-01-15
   icu_ver=65.1    # 2019-10-03
   ;;
2.9.11) # 2021-05-13
   xz_ver=5.2.5    # 2020-03-17
   zlib_ver=1.2.11 # 2017-01-15
   icu_ver=69.1    # 2021-04-07
   ;;
*)
   echo "ERROR: Need review for libxml2 ${1}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  xz_ver=${global_xz}
  zlib_ver=${global_zlib}
fi

echo "Installing libxml2 ${libxml2_v}..."

check_modules
check_xz ${xz_ver}
check_zlib ${zlib_ver}
check_icu ${icu_ver}

downloadPackage libxml2-${libxml2_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/libxml2-${libxml2_v} ] ; then
  rm -rf ${tmp}/libxml2-${libxml2_v}
fi

tar xvfz ${pkg}/libxml2-${libxml2_v}.tar.gz
cd ${tmp}/libxml2-${libxml2_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

if [ "${libxml2_v}" == "2.9.11" ] ; then

if [ -f fuzz/fuzz.h ] ; then
  echo 'ERROR: fuzz/fuzz.h unexpectedly exists.'
  exit 4
fi

cat << eof > fuzz/fuzz.h
/*
 * fuzz.h: Common functions and macros for fuzzing.
 *
 * See Copyright for the status of this software.
 */

#ifndef __XML_FUZZERCOMMON_H__
#define __XML_FUZZERCOMMON_H__

#include <stddef.h>
#include <stdio.h>
#include <libxml/parser.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(LIBXML_HTML_ENABLED) && defined(LIBXML_OUTPUT_ENABLED)
  #define HAVE_HTML_FUZZER
#endif
#if defined(LIBXML_REGEXP_ENABLED)
  #define HAVE_REGEXP_FUZZER
#endif
#if defined(LIBXML_SCHEMAS_ENABLED)
  #define HAVE_SCHEMA_FUZZER
#endif
#if 1
  #define HAVE_URI_FUZZER
#endif
#if defined(LIBXML_OUTPUT_ENABLED) && \\
    defined(LIBXML_READER_ENABLED) && \\
    defined(LIBXML_XINCLUDE_ENABLED)
  #define HAVE_XML_FUZZER
#endif
#if defined(LIBXML_XPATH_ENABLED)
  #define HAVE_XPATH_FUZZER
#endif

int
LLVMFuzzerInitialize(int *argc, char ***argv);

int
LLVMFuzzerTestOneInput(const char *data, size_t size);

void
xmlFuzzErrorFunc(void *ctx ATTRIBUTE_UNUSED, const char *msg ATTRIBUTE_UNUSED,
                 ...);

void
xmlFuzzDataInit(const char *data, size_t size);

void
xmlFuzzDataCleanup(void);

int
xmlFuzzReadInt(void);

const char *
xmlFuzzReadRemaining(size_t *size);

void
xmlFuzzWriteString(FILE *out, const char *str);

const char *
xmlFuzzReadString(size_t *size);

void
xmlFuzzReadEntities(void);

const char *
xmlFuzzMainUrl(void);

const char *
xmlFuzzMainEntity(size_t *size);

xmlParserInputPtr
xmlFuzzEntityLoader(const char *URL, const char *ID, xmlParserCtxtPtr ctxt);

size_t
xmlFuzzExtractStrings(const char *data, size_t size, char **strings,
                      size_t numStrings);

char *
xmlSlurpFile(const char *path, size_t *size);

#ifdef __cplusplus
}
#endif

#endif /* __XML_FUZZERCOMMON_H__ */

eof
echo 'Created fuzz/fuzz.h'
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
module load xz/${xz_ver}
module load zlib/${zlib_ver}
module load icu/${icu_ver}

config="./configure --prefix=${opt}/libxml2-${libxml2_v} --with-icu"

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
  if [ "${libxml2_v}" == "2.9.11" ] ; then
    echo ''
    echo 'NOTE: There is a failure with testFuzzer because of some testsuite files that are'
    echo '      missing from the 2.9.11 tarball distribution.  Specifically, the missing'
    echo '      subdirectory is libxml2-2.9.11/fuzz/seed/regex/'
  fi
  echo ''
  echo '>> Tests complete'
  echo ''
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
mkdir -pv ${MODULEPATH}/libxml2
cat << eof > ${MODULEPATH}/libxml2/${libxml2_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libxml2-${libxml2_v} into your environment"
}

set VER ${libxml2_v}
set PKG ${opt}/libxml2-\$VER

module-whatis   "Loads libxml2-${libxml2_v}"
conflict libxml2
module load zlib/${zlib_ver} xz/${xz_ver} icu/${icu_ver}
prereq zlib/${zlib_ver}
prereq xz/${xz_ver}
prereq icu/${icu_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/libxml2-${libxml2_v}

}

function ff_build_libxml2() {

# Get desired version number to install
libxml2_v=${1}
if [ -z "${libxml2_v}" ] ; then
  libxml2_v=2.9.9
fi

libxml2_ffmpeg_ver=${3}
libxml2_xz_ver=${ffmpeg_xz_ver}
libxml2_zlib_ver=${ffmpeg_zlib_ver}
libxml2_icu_ver=${ffmpeg_icu_ver}

libxml2_srcdir=libxml2-${libxml2_v}
libxml2_prefix=${2}

echo "Installing libxml2 ${libxml2_v} in ${libxml2_prefix}..."

check_modules
check_xz ${libxml2_xz_ver}
check_zlib ${libxml2_zlib_ver}
check_icu ${libxml2_icu_ver}

downloadPackage ${libxml2_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libxml2_srcdir} ] ; then
  rm -rf ${tmp}/${libxml2_srcdir}
fi

tar xvfz ${pkg}/${libxml2_srcdir}.tar.gz
cd ${tmp}/${libxml2_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

if [ "${libxml2_v}" == "2.9.11" ] ; then

if [ -f fuzz/fuzz.h ] ; then
  echo 'ERROR: fuzz/fuzz.h unexpectedly exists.'
  exit 4
fi

cat << eof > fuzz/fuzz.h
/*
 * fuzz.h: Common functions and macros for fuzzing.
 *
 * See Copyright for the status of this software.
 */

#ifndef __XML_FUZZERCOMMON_H__
#define __XML_FUZZERCOMMON_H__

#include <stddef.h>
#include <stdio.h>
#include <libxml/parser.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(LIBXML_HTML_ENABLED) && defined(LIBXML_OUTPUT_ENABLED)
  #define HAVE_HTML_FUZZER
#endif
#if defined(LIBXML_REGEXP_ENABLED)
  #define HAVE_REGEXP_FUZZER
#endif
#if defined(LIBXML_SCHEMAS_ENABLED)
  #define HAVE_SCHEMA_FUZZER
#endif
#if 1
  #define HAVE_URI_FUZZER
#endif
#if defined(LIBXML_OUTPUT_ENABLED) && \\
    defined(LIBXML_READER_ENABLED) && \\
    defined(LIBXML_XINCLUDE_ENABLED)
  #define HAVE_XML_FUZZER
#endif
#if defined(LIBXML_XPATH_ENABLED)
  #define HAVE_XPATH_FUZZER
#endif

int
LLVMFuzzerInitialize(int *argc, char ***argv);

int
LLVMFuzzerTestOneInput(const char *data, size_t size);

void
xmlFuzzErrorFunc(void *ctx ATTRIBUTE_UNUSED, const char *msg ATTRIBUTE_UNUSED,
                 ...);

void
xmlFuzzDataInit(const char *data, size_t size);

void
xmlFuzzDataCleanup(void);

int
xmlFuzzReadInt(void);

const char *
xmlFuzzReadRemaining(size_t *size);

void
xmlFuzzWriteString(FILE *out, const char *str);

const char *
xmlFuzzReadString(size_t *size);

void
xmlFuzzReadEntities(void);

const char *
xmlFuzzMainUrl(void);

const char *
xmlFuzzMainEntity(size_t *size);

xmlParserInputPtr
xmlFuzzEntityLoader(const char *URL, const char *ID, xmlParserCtxtPtr ctxt);

size_t
xmlFuzzExtractStrings(const char *data, size_t size, char **strings,
                      size_t numStrings);

char *
xmlSlurpFile(const char *path, size_t *size);

#ifdef __cplusplus
}
#endif

#endif /* __XML_FUZZERCOMMON_H__ */

eof
echo 'Created fuzz/fuzz.h'
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
module load ffmpeg-dep/${libxml2_ffmpeg_ver}
module load xz/${libxml2_xz_ver}
module load zlib/${libxml2_zlib_ver}
module load icu/${libxml2_icu_ver}

config="./configure --prefix=${libxml2_prefix} --with-icu"

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
  if [ "${libxml2_v}" == "2.9.11" ] ; then
    echo ''
    echo 'NOTE: There is a failure with testFuzzer because of some testsuite files that are'
    echo '      missing from the 2.9.11 tarball distribution.  Specifically, the missing'
    echo '      subdirectory is libxml2-2.9.11/fuzz/seed/regex/'
  fi
  echo ''
  echo '>> Tests complete'
  echo ''
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

cd ${root}
rm -rf ${tmp}/${libxml2_srcdir}

}
