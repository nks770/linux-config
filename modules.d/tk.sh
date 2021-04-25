#!/bin/bash

# Functions for detecting and building Tk

function tkInstalled() {

tk_vvv=${1}

if [ -z "${tk_vvv}" ] ; then
tk_vvv=8.6.11
fi
tk_vv=${tk_vvv%.*}

if [ ! -f ${opt}/tk-${tk_vvv}/lib/libtk${tk_vv}.so ] ; then
  return 1
fi

return 0
}

function check_tk() {
if tkInstalled ${1} ; then
  echo "tk-${1} is installed."
else
  build_tk ${1}
fi
}

function build_tk() {

# Get desired version number to install
tk_v=${1}
if [ -z "${tk_v}" ] ; then
  tk_v=8.6.11
fi

if [ "${tk_v}" == "8.6.11" ] ; then
  tk_vv=8.6.11.1
else
  tk_vv=${v}
fi

echo "Installing Tk version ${tk_v}..."

check_tcl ${tk_v}
downloadPackage tk${tk_vv}-src.tar.gz

mkdir -pv ${opt}/tk-${tk_v}

cd ${opt}/tk-${tk_v}
tar xvfz ${pkg}/tk${tk_vv}-src.tar.gz
mv -fv tk${tk_v} build
cd ${opt}/tk-${tk_v}/build/unix
./configure --prefix=${opt}/tk-${tk_v} --with-tcl=${opt}/tcl-${tk_v}/lib
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

cd ${root}

}
