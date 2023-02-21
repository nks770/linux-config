#!/bin/bash

# Functions for detecting and building DejaGnu
echo 'Loading DejaGnu...'

function dejagnuInstalled() {

dejagnu_vvv=${1}

if [ -z "${dejagnu_vvv}" ] ; then
dejagnu_vvv=1.6.3
fi

if [ ! -f ${opt}/dejagnu-${dejagnu_vvv}/bin/runtest ] ; then
  return 1
fi

return 0
}

function check_dejagnu() {
if dejagnuInstalled ${1} ; then
  echo "dejagnu-${1} is installed."
else
  build_dejagnu ${1}
fi
}

function build_dejagnu() {

# Get desired version number to install
dejagnu_v=${1}
if [ -z "${dejagnu_v}" ] ; then
  dejagnu_v=1.6.3
fi
dejagnu_srcdir=dejagnu-${dejagnu_v}

case ${dejagnu_v} in
1.6.3)
   expect_ver=5.45.4
   ;;
*)
   expect_ver=5.45.4
   ;;
esac


echo "Installing DejaGnu version ${dejagnu_v}..."

check_expect ${expect_ver}

downloadPackage dejagnu-${dejagnu_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${dejagnu_srcdir} ] ; then
  rm -rf ${tmp}/${dejagnu_srcdir}
fi

tar xvfz ${pkg}/dejagnu-${dejagnu_v}.tar.gz
cd ${tmp}/${dejagnu_srcdir}

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  echo ./configure --prefix=${opt}/dejagnu-${dejagnu_v}
  read k
fi

./configure --prefix=${opt}/dejagnu-${dejagnu_v}

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

# There is no test suite for DejaGnu
#if [ ${run_tests} -gt 0 ] ; then
#  make test
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

cd ${root}
rm -rf ${tmp}/${dejagnu_srcdir}
}
