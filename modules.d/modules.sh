#!/bin/bash

# Functions for detecting and building Environment Modules

function modulesInstalled() {
test=$(module avail 2>&1 | grep use.own | wc -l)

if [ ${test} -lt 1 ] ; then
  source /etc/profile.d/modules.sh
fi

test=$(module avail 2>&1 | grep use.own | wc -l)

if [ ${test} -lt 1 ] ; then
  return 1
elif [ -z "${MODULEPATH}" ] ; then
  return 1
elif [ ! -d "${MODULEPATH}" ] ; then
  return 1
else
  return 0
fi

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
modules_v=${1}
if [ -z "${modules_v}" ] ; then
  modules_v=4.7.0
fi

case ${modules_v} in
4.7.0)
   tcl_tk_ver=8.6.11
   ;;
*)
   tcl_tk_ver=8.6.11
   ;;
esac


echo "Installing Environment Modules version ${modules_v}..."

check_tcl ${tcl_tk_ver}
#check_tk ${tcl_tk_ver}

downloadPackage modules-${modules_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/modules-${modules_v} ] ; then
  rm -rf ${tmp}/modules-${modules_v}
fi

tar xvfz ${pkg}/modules-${modules_v}.tar.gz
cd ${tmp}/modules-${modules_v}
./configure --prefix=${opt}/Modules/${modules_v} \
            --with-tclsh=${opt}/tcl-${tcl_tk_ver}/bin/tclsh${tcl_tk_ver%.*} \
            --with-tcl=${opt}/tcl-${tcl_tk_ver}/lib \
            --with-tcl-ver=${tcl_tk_ver%.*} \
#            --without-tclx \
#            --with-tclx=/opt/tcl-${2}/lib \
#            --with-tclx-ver=${tcl_tk_ver%.*}
#            CPPFLAGS="-DUSE_INTERP_ERRORLINE"

# DUSE_INTERP_ERRORLINE is for modules 3.x when compilation against tcl 8.6 fails

make && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

cp -av ${tmp}/modules-${modules_v}/init/profile.sh /etc/profile.d/modules.sh
ln -sv ${opt}/Modules/${modules_v} ${opt}/Modules/default

cd ${root}
rm -rf ${tmp}/modules-${modules_v}

}
