#!/bin/bash

# Functions for detecting and building Environment Modules

function modulesInstalled() {
test=$(modufe avail 2>&1 | grep use.own | wc -l)

if [ ${test} -lt 1 ] || [ ! -d ${modpath} ]; then
  return 1
fi

return 0
}

function setup_modules() {
if modulesInstalled ; then
  echo "Environment Modules is installed."
else
  build_modules
fi
}

function build_modules() {

# Get desired version number to install
v=${1}
if [ -z "${v}" ] ; then
  v=4.7.0
fi

echo "Installing Environment Modules version ${v}..."

downloadPackage tcl8.6.11-src.tar.gz
downloadPackage modules-${v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/modules-${v} ] ; then
  rm -rf ${tmp}/modules-${v}
fi

if [ -d ${tmp}/modules-${v} ] ; then
  rm -rf ${tmp}/modules-${v}
fi

tar xvfz ${pkg}/modules-${v}.tar.gz
cd ${tmp}/modules-${v}
./configure --prefix=/opt --with-tcl=/opt/tcl-${2}/lib --with-tcl-ver=${2%.*} --with-tclx=/opt/tcl-${2}/lib --with-tclx-ver=${3%.*} CPPFLAGS="-DUSE_INTERP_ERRORLINE"

}
