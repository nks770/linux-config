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
  modules_v=5.3.1
fi

case ${modules_v} in
4.7.0)
   modules_tcl_ver=8.6.11
   modules_expect_ver=5.45.4
   modules_dejagnu_ver=1.6.3
   ;;
5.2.0)
   modules_tcl_ver=8.6.13
   modules_expect_ver=5.45.4
   modules_dejagnu_ver=1.6.3
   ;;
5.3.1)
   modules_tcl_ver=8.6.13
   modules_expect_ver=5.45.4
   modules_dejagnu_ver=1.6.3
   ;;
*)
   echo "ERROR: Need review for modules ${modules_v}"
   exit 4
   ;;
esac

echo "Installing Environment Modules version ${modules_v}..."
modules_srcdir=modules-${modules_v}

check_tcl ${modules_tcl_ver}
check_expect ${modules_expect_ver}
check_dejagnu ${modules_dejagnu_ver} # DejaGnu is needed for the test suite, specifically the 'runtest' executable

downloadPackage modules-${modules_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${modules_srcdir} ] ; then
  rm -rf ${tmp}/${modules_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/modules-${modules_v}.tar.gz
cd ${tmp}/${modules_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

config="./configure --prefix=${opt}/Modules/${modules_v} \
            --with-tclsh=${opt}/tcl-${modules_tcl_ver}/bin/tclsh${modules_tcl_ver%.*} \
            --with-tcl=${opt}/tcl-${modules_tcl_ver}/lib \
            --with-tcl-ver=${modules_tcl_ver%.*} \
	    --with-tclinclude=${opt}/tcl-${modules_tcl_ver}/include"
#            --without-tclx \
#            --with-tclx=/opt/tcl-${2}/lib \
#            --with-tclx-ver=${modules_tcl_ver%.*}
#            CPPFLAGS="-DUSE_INTERP_ERRORLINE"

# DUSE_INTERP_ERRORLINE is for modules 3.x when compilation against tcl 8.6 fails

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
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
  # Requires DejaGnu to work
  echo export PATH=${PATH}:${opt}/dejagnu-${modules_dejagnu_ver}/bin
  export PATH=${PATH}:${opt}/tcl-${modules_tcl_ver}/bin:${opt}/dejagnu-${modules_dejagnu_ver}/bin
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

profile_needed=1

while [ ${profile_needed} -gt 0 ] ; do
  if [ -f /etc/profile.d/modules.sh ] ; then
    cmp -s ${tmp}/${modules_srcdir}/init/profile.sh /etc/profile.d/modules.sh
    if [ $? -eq 0 ] ; then
      profile_needed=0
      echo 'The correct modules.sh is already installed in profile.d.'
      echo 'No further action is needed.'
    else
      profile_needed=1
    fi
  else
    profile_needed=1
  fi
  if [ ${profile_needed} -gt 0 ] ; then
    cp -av ${tmp}/${modules_srcdir}/init/profile.sh /etc/profile.d/modules.sh
    if [ $? -eq 0 ] ; then
      profile_needed=0
    fi
  fi
  if [ ${profile_needed} -gt 0 ] ; then
    echo ''
    echo 'PLEASE EXECUTE THE FOLLOWING COMMAND AS SUPER USER:'
    echo "cp -av ${tmp}/${modules_srcdir}/init/profile.sh /etc/profile.d/modules.sh"
    echo ''
    echo 'Press enter when complete.'
    echo ''
    read k
  fi
done

ln -sv ${opt}/Modules/${modules_v} ${opt}/Modules/default

# Create the environment module for tcl
mkdir -pv ${opt}/Modules/${modules_v}/modulefiles/tcl
cat << eof > ${opt}/Modules/${modules_v}/modulefiles/tcl/${modules_tcl_ver}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts tcl-${modules_tcl_ver} into your environment"
}

set VER ${modules_tcl_ver}
set PKG ${opt}/tcl-\$VER

module-whatis   "Loads tcl-${tcl_v}"
conflict tcl

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path MANPATH \$PKG/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

# Create the environment module for expect
mkdir -pv ${opt}/Modules/${modules_v}/modulefiles/expect
cat << eof > ${opt}/Modules/${modules_v}/modulefiles/expect/${modules_expect_ver}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts expect-${modules_expect_ver} into your environment"
}

set VER ${modules_expect_ver}
set PKG ${opt}/expect-\$VER

module-whatis   "Loads expect-${modules_expect_ver}"
conflict expect
module load tcl/${modules_tcl_ver}
prereq tcl/${modules_tcl_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path MANPATH \$PKG/share/man

eof

# Create the environment module for DejaGnu
mkdir -pv ${opt}/Modules/${modules_v}/modulefiles/dejagnu
cat << eof > ${opt}/Modules/${modules_v}/modulefiles/dejagnu/${modules_dejagnu_ver}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts DejaGnu-${modules_dejagnu_ver} into your environment"
}

set VER ${modules_dejagnu_ver}
set PKG ${opt}/dejagnu-\$VER

module-whatis   "Loads dejagnu-${modules_dejagnu_ver}"
conflict dejagnu
module load expect/${modules_expect_ver}
prereq expect/${modules_expect_ver}

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
rm -rf ${tmp}/${modules_srcdir}

}
