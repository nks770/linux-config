#!/bin/bash

# Functions for detecting and building expect
echo 'Loading expect...'

function expectInstalled() {

expect_vvv=${1}

if [ -z "${expect_vvv}" ] ; then
expect_vvv=5.45.4
fi

if [ ! -f ${opt}/expect-${expect_vvv}/bin/autoexpect ] ; then
  return 1
fi

return 0
}

function check_expect() {
if expectInstalled ${1} ; then
  echo "expect-${1} is installed."
else
  build_expect ${1}
fi
}

function build_expect() {

# Get desired version number to install
expect_v=${1}
if [ -z "${expect_v}" ] ; then
  expect_v=5.45.4
fi

case ${expect_v} in
5.45.4)
   expect_tcl_ver=8.6.13
   ;;
*)
   echo "ERROR: Need review for expect ${expect_v}"
   exit 4
   ;;
esac

echo "Installing expect version ${expect_v}..."
expect_srcdir=expect${expect_v}

check_tcl ${expect_tcl_ver}

downloadPackage expect${expect_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${expect_srcdir} ] ; then
  rm -rf ${tmp}/${expect_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/expect${expect_v}.tar.gz
cd ${tmp}/${expect_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

config="./configure --prefix=${opt}/expect-${expect_v} \
	    --with-tcl=${opt}/tcl-${expect_tcl_ver}/lib \
	    --with-tclinclude=${opt}/tcl-${expect_tcl_ver}/include"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make test
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
rm -rf ${tmp}/${expect_srcdir}
}
