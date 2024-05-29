#!/bin/bash

# Functions for detecting and building libogg
echo 'Loading libogg...'

function get_libogg_library() {
case ${1} in
  1.3.4)
    echo libogg.so.0.8.4
  ;;
  1.3.5)
    echo libogg.so.0.8.5
  ;;
  *)
    echo ''
  ;;
esac
}

function liboggDepInstalled() {
if [ ! -f "${2}/lib/$(get_libogg_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libogg() {
echo -n "Checking for presence of libogg-${1} in ${2}..."
if liboggDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libogg ${1} ${2} ${3}
fi
}


function ff_build_libogg() {

# Get desired version number to install
libogg_v=${1}
if [ -z "${libogg_v}" ] ; then
  libogg_v=1.3.4
fi

libogg_ffmpeg_ver=${3}

libogg_srcdir=libogg-${libogg_v}
libogg_prefix=${2}

echo "Installing libogg-${libogg_v} in ${libogg_prefix}..."


check_modules

downloadPackage ${libogg_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libogg_srcdir} ] ; then
  rm -rf ${tmp}/${libogg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${libogg_srcdir}.tar.gz
cd ${tmp}/${libogg_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${libogg_prefix}"

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

cd ${root}
rm -rf ${tmp}/${libogg_srcdir}

}
