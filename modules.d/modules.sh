#!/bin/bash

# Functions for detecting and building Environment Modules
echo 'Loading modules...'

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
  modules_v=5.2.0
fi

case ${modules_v} in
4.7.0)
   tcl_tk_ver=8.6.11
   expect_ver=5.45.4
   dejagnu_ver=1.6.3
   ;;
5.2.0)
   tcl_tk_ver=8.6.13
   expect_ver=5.45.4
   dejagnu_ver=1.6.3
   ;;
*)
   tcl_tk_ver=8.6.13
   expect_ver=5.45.4
   dejagnu_ver=1.6.3
   ;;
esac

echo "Installing Environment Modules version ${modules_v}..."

check_tcl ${tcl_tk_ver}
check_expect ${expect_ver}
check_dejagnu ${dejagnu_ver} # DejaGnu is needed for the test suite, specifically the 'runtest' executable
#check_tk ${tcl_tk_ver}

downloadPackage modules-${modules_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/modules-${modules_v} ] ; then
  rm -rf ${tmp}/modules-${modules_v}
fi

tar xvfz ${pkg}/modules-${modules_v}.tar.gz
cd ${tmp}/modules-${modules_v}

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  echo ./configure --prefix=${opt}/Modules/${modules_v} \
            --with-tclsh=${opt}/tcl-${tcl_tk_ver}/bin/tclsh${tcl_tk_ver%.*} \
            --with-tcl=${opt}/tcl-${tcl_tk_ver}/lib \
            --with-tcl-ver=${tcl_tk_ver%.*} \
	    --with-tclinclude=${opt}/tcl-${tcl_tk_ver}/include
  read k
fi

./configure --prefix=${opt}/Modules/${modules_v} \
            --with-tclsh=${opt}/tcl-${tcl_tk_ver}/bin/tclsh${tcl_tk_ver%.*} \
            --with-tcl=${opt}/tcl-${tcl_tk_ver}/lib \
            --with-tcl-ver=${tcl_tk_ver%.*} \
	    --with-tclinclude=${opt}/tcl-${tcl_tk_ver}/include
#            --without-tclx \
#            --with-tclx=/opt/tcl-${2}/lib \
#            --with-tclx-ver=${tcl_tk_ver%.*}
#            CPPFLAGS="-DUSE_INTERP_ERRORLINE"

# DUSE_INTERP_ERRORLINE is for modules 3.x when compilation against tcl 8.6 fails

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
  # Requires DejaGnu to work
  echo export PATH=${PATH}:${opt}/dejagnu-${dejagnu_ver}/bin
  export PATH=${PATH}:${opt}/tcl-${tcl_tk_ver}/bin:${opt}/dejagnu-${dejagnu_ver}/bin
  echo runtest: $(which runtest)
  echo expect: $(which expect)
  make test
  echo '>> Tests complete'
  read k
fi

make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

cp -av ${tmp}/modules-${modules_v}/init/profile.sh /etc/profile.d/modules.sh
ln -sv ${opt}/Modules/${modules_v} ${opt}/Modules/default

# Create the environment module for expect
mkdir -pv ${opt}/Modules/${modules_v}/modulefiles/expect
cat << eof > ${opt}/Modules/${modules_v}/modulefiles/expect/${expect_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts expect-${expect_v} into your environment"
}

set VER ${expect_v}
set PKG ${opt}/expect-\$VER
set TCL ${opt}/tcl-${tcl_tk_ver}

module-whatis   "Loads expect-${expect_v}"
conflict expect

prepend-path CPATH \$PKG/include
prepend-path CPATH \$TCL/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path C_INCLUDE_PATH \$TCL/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$TCL/include
prepend-path LD_LIBRARY_PATH \$TCL/lib
prepend-path PATH \$PKG/bin
prepend-path PATH \$TCL/bin
prepend-path MANPATH \$PKG/share/man
prepend-path MANPATH \$TCL/share/man
prepend-path MANPATH \$TCL/man

eof

# Create the environment module for DejaGnu
mkdir -pv ${opt}/Modules/${modules_v}/modulefiles/dejagnu
cat << eof > ${opt}/Modules/${modules_v}/modulefiles/dejagnu/${dejagnu_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts DejaGnu-${dejagnu_v} into your environment"
}

set VER ${dejagnu_v}
set PKG ${opt}/dejagnu-\$VER

module-whatis   "Loads dejagnu-${dejagnu_v}"
conflict dejagnu
module load expect/${expect_v}
prereq expect/${expect_v}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

cd ${root}
rm -rf ${tmp}/modules-${modules_v}

}
