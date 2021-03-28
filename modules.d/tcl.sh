#!/bin/bash

# Functions for detecting and building Environment Modules

function tclInstalled() {

tcl_vvv=${1}

if [ -z "${tcl_vvv}" ] ; then
tcl_vvv=8.6.11
fi
tcl_vv=${tcl_vvv%.*}

if [ ! -f ${opt}/tcl-${tcl_vvv}/lib/libtcl${tcl_vv}.so ] ; then
  return 1
fi

return 0
}

function check_tcl() {
if tclInstalled ${1} ; then
  echo "tcl-${1} is installed."
else
  build_tcl ${1}
fi
}

function build_tcl() {

# Get desired version number to install
tcl_v=${1}
if [ -z "${tcl_v}" ] ; then
  tcl_v=8.6.11
fi

echo "Installing Tcl version ${tcl_v}..."

downloadPackage tcl${tcl_v}-src.tar.gz

mkdir -pv ${opt}/tcl-${tcl_v}

cd ${opt}/tcl-${tcl_v}
tar xvfz ${pkg}/tcl${tcl_v}-src.tar.gz
mv -fv tcl${tcl_v} build
cd ${opt}/tcl-${tcl_v}/build/unix
./configure --prefix=${opt}/tcl-${tcl_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

cd ${root}

}
