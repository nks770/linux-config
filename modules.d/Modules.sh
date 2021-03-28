#!/bin/bash

# Functions for detecting and building Environment Modules

function modulesInstalled() {
test=$(modufe avail 2>&1 | grep use.own | wc -l)

if [ ${test} -lt 1 ] || [ ! -d ${modpath} ]; then
  return 1
fi

return 0
}

function check_modules() {
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

case ${1} in
4.7.0)
   tcl_tk_ver=8.6.11
   ;;
*)
   tcl_tk_ver=8.6.11
   ;;
esac


echo "Installing Environment Modules version ${v}..."

#check_tcl ${tcl_tk_ver}
check_tk ${tcl_tk_ver}

downloadPackage modules-${v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/modules-${v} ] ; then
  rm -rf ${tmp}/modules-${v}
fi

tar xvfz ${pkg}/modules-${v}.tar.gz
cd ${tmp}/modules-${v}
./configure --prefix=${opt} \
            --with-tcl=${opt}tcl-${tcl_tk_ver}/lib \
            --with-tcl-ver=${tcl_tk_ver%.*} \
#            --with-tclx=/opt/tcl-${2}/lib \
#            --with-tclx-ver=${3%.*} \
            CPPFLAGS="-DUSE_INTERP_ERRORLINE"

}
