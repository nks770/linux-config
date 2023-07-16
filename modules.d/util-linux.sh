#!/bin/bash

# Functions for detecting and building util-linux
echo 'Loading util-linux...'

function utillinuxInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check util-linux
if [ ! -f ${MODULEPATH}/util-linux/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_utillinux() {
if utillinuxInstalled ${1}; then
  echo "util-linux ${1} is installed."
else
  build_utillinux ${1}
fi
}

function build_utillinux() {

# Get desired version number to install
utillinux_v=${1}
if [ -z "${utillinux_v}" ] ; then
  utillinux_v=2.38.1
fi

echo "Installing util-linux ${utillinux_v}..."
utillinux_srcdir=util-linux-${utillinux_v}

check_modules

downloadPackage util-linux-${utillinux_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${utillinux_srcdir} ] ; then
  rm -rf ${tmp}/${utillinux_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/util-linux-${utillinux_v}.tar.gz
cd ${tmp}/${utillinux_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

#config="./configure --prefix=${opt}/util-linux-${utillinux_v} \
#	    ADJTIME_PATH=${opt}/util-linux-${utillinux_v}/etc/adjtime \
#            --disable-chfn-chsh  \
#            --disable-login      \
#            --disable-nologin    \
#            --disable-su         \
#            --disable-setpriv    \
#            --disable-runuser    \
#            --disable-pylibmount \
#            --disable-static     \
#	    --disable-wall       \
#            --without-python     \
#            runstatedir=/run"

# At this point, we're really just interested in uuid components
# Several other components like 'mount' and 'wall' cannot be built
# as non-root user because the 'make install' phase depends on being
# able to run arbitrary 'chgrp' and 'chmod' commands.

# --disable-bash-completion \
config="./configure --prefix=${opt}/util-linux-${utillinux_v} \
	--disable-all-programs \
	--with-bashcompletiondir=${opt}/util-linux-${utillinux_v}/share/bash-completion/completions \
	--enable-libuuid \
	--enable-uuidd \
	--enable-uuidgen"

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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/util-linux
cat << eof > ${MODULEPATH}/util-linux/${utillinux_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts util-linux-${utillinux_v} into your environment"
}

set VER ${utillinux_v}
set PKG ${opt}/util-linux-\$VER

module-whatis   "Loads util-linux-${utillinux_v}"
conflict util-linux

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${utillinux_srcdir}

}
