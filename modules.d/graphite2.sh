#!/bin/bash

# Functions for detecting and building Graphite2
echo 'Loading Graphite2...'

function get_graphite2_library() {
case ${1} in
  1.3.13)
    echo libgraphite2.so.3.2.1
  ;;
  *)
    echo ''
  ;;
esac
}

function graphite2DepInstalled() {
if [ ! -f "${2}/lib/$(get_graphite2_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_graphite2() {
echo -n "Checking for presence of graphite2-${1} in ${2}..."
if graphite2DepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_graphite2 ${1} ${2} ${3}
fi
}

function ff_build_graphite2() {

# Get desired version number to install
graphite2_v=${1}
if [ -z "${graphite2_v}" ] ; then
  graphite2_v=1.3.14
fi

case ${graphite2_v} in
  1.3.10) # 2017-05-05
   graphite2_cmake_ver=3.8.1  # 2017-05-02
   graphite2_doxygen_ver=1.8.14 # 2017-12-25
  ;;
  1.3.11) # 2018-03-04
   graphite2_cmake_ver=3.10.2 # 2018-01-18
   graphite2_doxygen_ver=1.8.14 # 2017-12-25
   graphite2_python_ver=3.6.4   # 2017-12-19
  ;;
  1.3.13) # 2018-12-20
   graphite2_cmake_ver=3.13.2   # 2018-12-13
   graphite2_doxygen_ver=1.8.14 # 2017-12-25
   graphite2_python_ver=3.7.1   # 2018-10-20
  ;;
  *)
   echo "ERROR: Review needed for Graphite2 ${graphite2_v}"
   exit 4 # Please review
  ;;
esac

graphite2_ffmpeg_ver=${3}
graphite2_freetype_ver=${ffmpeg_freetype_ver}

graphite2_srcdir=graphite2-${graphite2_v}
graphite2_prefix=${2}

echo "Installing graphite2-${graphite2_v} in ${graphite2_prefix}..."

check_modules
check_cmake ${graphite2_cmake_ver}
check_doxygen ${graphite2_doxygen_ver}
check_python ${graphite2_python_ver}

downloadPackage graphite2-${graphite2_v}.tgz

cd ${tmp}

if [ -d ${tmp}/${graphite2_srcdir} ] ; then
  rm -rf ${tmp}/${graphite2_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/graphite2-${graphite2_v}.tgz
mkdir -v ${tmp}/${graphite2_srcdir}/build
cd ${tmp}/${graphite2_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${graphite2_ffmpeg_ver}
module load cmake/${graphite2_cmake_ver}
module load doxygen/${graphite2_doxygen_ver}
module load Python/${graphite2_python_ver}

if [ ${debug} -gt 0 ] ; then
  #cmake -L -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) ..
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DCMAKE_INSTALL_PREFIX=${graphite2_prefix} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=${graphite2_prefix} ..

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
  echo ''
  echo 'NOTE: Several tests fail if python cannot be found.'
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

cd ${root}
rm -rf ${tmp}/${graphite2_srcdir}

}
