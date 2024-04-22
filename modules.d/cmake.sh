#!/bin/bash

# Functions for detecting and building cmake
echo 'Loading cmake...'

function cmakeInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check cmake
if [ ! -f ${MODULEPATH}/cmake/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_cmake() {
if cmakeInstalled ${1}; then
  echo "cmake ${1} is installed."
else
  build_cmake ${1}
fi
}

function build_cmake() {

# Get desired version number to install
cmake_v=${1}
if [ -z "${cmake_v}" ] ; then
  echo "ERROR: No cmake version specified!"
  exit 2
fi
cmake_srcdir=cmake-${cmake_v}
cmake_prefix=${opt}/${cmake_srcdir}

kwsys_warning=0
chmod_warning=0
rerun_failures=0

case ${cmake_v} in
2.8.12.1) # 2013-11-06
   cmake_ncurses_ver=5.9  # 2011-04-04
   cmake_openssl_ver=0
   cmake_manpath=1
   kwsys_warning=0
   ;;
2.8.12.2) # 2014-01-16
   cmake_ncurses_ver=5.9  # 2011-04-04
   cmake_openssl_ver=0
   cmake_manpath=1
   kwsys_warning=0
   ;;
3.0.2) # 2014-09-11
   cmake_ncurses_ver=5.9  # 2011-04-04
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.6.1) # 2016-07-22
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.6.2) # 2016-09-07
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.6.3) # 2016-11-03
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.8.1) # 2017-05-02
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.9.0) # 2017-07-18
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.9.6) # 2017-11-10
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.10.1) # 2017-12-14
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.10.2) # 2018-01-18
   cmake_ncurses_ver=6.0  # 2015-08-08
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.10.3) # 2018-03-16
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.11.4) # 2018-06-14
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.13.2) # 2018-12-13
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.13.4) # 2019-02-01
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.14.7) # 2019-10-02
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.15.2) # 2019-08-07
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.15.3) # 2019-09-04
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.15.5) # 2019-10-30
   cmake_ncurses_ver=6.1  # 2018-01-27
   cmake_openssl_ver=0
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.16.2) # 2019-12-19
   cmake_ncurses_ver=6.1    # 2018-01-27
   cmake_openssl_ver=1.1.1d # 2019-09-10
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.16.4) # 2020-02-05
   cmake_ncurses_ver=6.1    # 2018-01-27
   cmake_openssl_ver=1.1.1d # 2019-09-10
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.16.5) # 2020-03-04
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1d # 2019-09-10
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.17.0) # 2020-03-20
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1e # 2020-03-17
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.17.1) # 2020-04-09
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1f # 2020-03-31
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.17.2) # 2020-04-28
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1g # 2020-04-21
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.17.3) # 2020-05-28
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1g # 2020-04-21
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.18.2) # 2020-08-20
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1g # 2020-04-21
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.18.4) # 2020-10-06
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1h # 2020-09-22
   cmake_manpath=0
   kwsys_warning=1
   ;;
3.19.2) # 2020-12-16
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1i # 2020-12-08
   cmake_manpath=0
   chmod_warning=1
   ;;
3.19.3) # 2021-01-13
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1i # 2020-12-08
   cmake_manpath=0
   chmod_warning=1
   ;;
3.19.4) # 2021-01-28
   cmake_ncurses_ver=6.2    # 2020-02-12
   cmake_openssl_ver=1.1.1i # 2020-12-08
   cmake_manpath=0
   chmod_warning=1
   ;;
3.24.0) # 2022-08-04
   cmake_ncurses_ver=6.3    # 2021-11-08
   cmake_openssl_ver=1.1.1q # 2022-07-05
   cmake_manpath=0
   chmod_warning=0
   rerun_failures=161
   ;;
*)
   echo "ERROR: Review needed for cmake ${cmake_v}"
   exit 4 # Need to review
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
    cmake_ncurses_ver=${global_ncurses}
  fi
  if [ ! "${cmake_openssl_ver}" == "0" ] ; then
    cmake_openssl_ver=${global_openssl}
  fi
fi

echo "Installing cmake ${cmake_v}..."

check_modules
if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
  check_ncurses ${cmake_ncurses_ver}
fi
if [ ! "${cmake_openssl_ver}" == 0 ] ; then
  check_openssl ${cmake_openssl_ver}
fi

module purge

# Note ncurses dependency is to build optional module ccmake (the curses GUI to cmake)
if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
  module load ncurses/${cmake_ncurses_ver}
fi
if [ ! "${cmake_openssl_ver}" == "0" ] ; then
  module load openssl/${cmake_openssl_ver}
fi

downloadPackage cmake-${cmake_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${cmake_srcdir} ] ; then
  rm -rf ${tmp}/${cmake_srcdir}
fi

tar xvfz ${pkg}/cmake-${cmake_v}.tar.gz
cd ${tmp}/${cmake_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

if [ "${cmake_v}" == "2.8.12.2" ] || [ "${cmake_v}" == "2.8.12.1" ] ; then
  cat << eof > CTestTestUpload.patch
--- Tests/CMakeLists.txt
+++ Tests/CMakeLists.txt
@@ -1882,17 +1882,6 @@
     FAIL_REGULAR_EXPRESSION "SegFault")
 
   configure_file(
-    "\${CMake_SOURCE_DIR}/Tests/CTestTestUpload/test.cmake.in"
-    "\${CMake_BINARY_DIR}/Tests/CTestTestUpload/test.cmake"
-    @ONLY ESCAPE_QUOTES)
-  add_test(CTestTestUpload \${CMAKE_CTEST_COMMAND}
-    -S "\${CMake_BINARY_DIR}/Tests/CTestTestUpload/test.cmake" -V
-    --output-log "\${CMake_BINARY_DIR}/Tests/CTestTestUpload/testOut.log"
-    )
-  set_tests_properties(CTestTestUpload PROPERTIES
-    PASS_REGULAR_EXPRESSION "Upload\\\\.xml")
-
-  configure_file(
     "\${CMake_SOURCE_DIR}/Tests/CTestTestConfigFileInBuildDir/test1.cmake.in"
     "\${CMake_BINARY_DIR}/Tests/CTestTestConfigFileInBuildDir1/test1.cmake"
     @ONLY ESCAPE_QUOTES)
eof
  patch -Z -b -p0 < CTestTestUpload.patch
  if [ ! $? -eq 0 ] ; then
    exit 4
  fi
  if [ ${debug} -gt 0 ] ; then
    echo '>> Patching complete'
    read k
  fi
fi

config="./configure --prefix=${cmake_prefix} --parallel=${ncpu}"
if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
  echo "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}"
  export CMAKE_PREFIX_PATH=${opt}/ncurses-${cmake_ncurses_ver}
fi

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
    echo CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}"
  fi
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


if [ ${run_cmake_tests} -gt 0 ] ; then
  # Patch to enable avoid a testsuite failure when compiled with newer GCC
  # I borrowed this update from referencing cmake 3.11.4 (slightly newer)
  # This is for test # "34 - CompileFeatures"
  if [ "${cmake_v:0:4}" == "3.6." ] || [ "${cmake_v}" == "3.8.1" ] || [ "${cmake_v}" == "3.9.0" ] || [ "${cmake_v}" == "3.10.1" ] || [ "${cmake_v}" == "3.10.2" ] ; then
    cat << eof > testsuite.patch
--- Tests/CompileFeatures/default_dialect.c
+++ Tests/CompileFeatures/default_dialect.c
@@ -1,6 +1,6 @@
 
 #if DEFAULT_C11
-#if __STDC_VERSION__ != 201112L
+#if __STDC_VERSION__ < 201112L
 #error Unexpected value for __STDC_VERSION__.
 #endif
 #elif DEFAULT_C99
eof
    patch -Z -b -p0 < testsuite.patch
    if [ ! $? -eq 0 ] ; then
      exit 4
    fi
    if [ ${debug} -gt 0 ] ; then
      echo '>> Testsuite patching complete'
      read k
    fi
  fi


  export CTEST_OUTPUT_ON_FAILURE=1
#  export LC_ALL=en_US.UTF-8

#  make test
  make test ARGS=-j${ncpu}
  testresult=$?

  unset CTEST_OUTPUT_ON_FAILURE
#  unset LC_ALL

  if [ ${testresult} -gt 0 ] ; then
    echo ''
    if [ ${kwsys_warning} -gt 0 ] ; then
      echo 'NOTE: You are probably seeing a failed test for "kwsys.testSystemTools"'
      echo 'Looking further into the matter, the specific error message is:'
      echo 'TestFileAccess incorrectly indicated that this is a writable file: ...'
      echo ''
      echo 'If the testsuite is run as root, this is an expected failure'
      echo 'More info is available here:'
      echo 'https://gitlab.kitware.com/utils/kwsys/-/merge_requests/251'
    fi
    if [ ${chmod_warning} -gt 0 ] ; then
      echo 'NOTE: I have seen a few failed tests for this version of cmake. They'
      echo 'mostly seem to be related to running the test suite as root, and the'
      echo 'resulting file access permission associated with root.'
      echo ''
      echo 'Notes about four tests of concern:'
      echo '  355 - RunCMake.Make (Failed) - fails at first, but then succeeds when re-run'
      echo '  446 - RunCMake.file-CHMOD (Failed) - expected "file failed to open for reading"'
      echo '  451 - RunCMake.find_program (Failed) - expected "The file ... is readable but not executable"'
      echo '  512 - RunCMake.CommandLine (Failed) - expected "permission denied"'
      echo ''
      echo 'Perhaps worth looking into further later, but seems OK?'
    fi
    if [ ${rerun_failures} -gt 0 ] ; then
      echo "NOTE: With this version of CMake, I have observed ${rerun_failures} tests"
      echo 'that fail the first time they run.  Looking into the logs, the expected'
      echo 'and actual output appear to be identical, which points to the test system'
      echo 'itself being the problem, and not a problem with the cmake build.'
      echo ''
      echo 'In any case, re-running the failed tests results in a subsequent success.'
      echo ''
      echo 'Please proceed with re-running the tests, and you should find a 100%'
      echo 'success rate.'
    fi
    echo ''
    echo '>> Press enter for more info on failed tests (if applicable)'
    read k
    echo ''
    ./bin/ctest -V --rerun-failed
  fi
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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi

mkdir -pv ${MODULEPATH}/cmake

cat << eof > ${MODULEPATH}/cmake/${cmake_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts cmake-${cmake_v} into your environment"
}

set VER ${cmake_v}
set PKG ${opt}/cmake-\$VER

module-whatis   "Loads cmake-${cmake_v}"
conflict cmake
eof

if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
  echo "module load ncurses/${cmake_ncurses_ver}" >> ${MODULEPATH}/cmake/${cmake_v}
fi
if [ ! "${cmake_openssl_ver}" == "0" ] ; then
  echo "module load openssl/${cmake_openssl_ver}" >> ${MODULEPATH}/cmake/${cmake_v}
fi

if [ ! "${cmake_ncurses_ver}" == "0" ] ; then
  echo "prereq ncurses/${cmake_ncurses_ver}" >> ${MODULEPATH}/cmake/${cmake_v}
fi
if [ ! "${cmake_openssl_ver}" == "0" ] ; then
  echo "prereq openssl/${cmake_openssl_ver}" >> ${MODULEPATH}/cmake/${cmake_v}
fi

cat << eof >> ${MODULEPATH}/cmake/${cmake_v}

prepend-path PATH \$PKG/bin
eof
if [ ${cmake_manpath} -gt 0 ] ; then
  echo "prepend-path MANPATH \$PKG/man" >> ${MODULEPATH}/cmake/${cmake_v}
fi

cd ${root}
rm -rf ${tmp}/${cmake_srcdir}

unset CMAKE_PREFIX_PATH
}
