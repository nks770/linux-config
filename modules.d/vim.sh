#!/bin/bash

# Functions for detecting and building the Vim text editor

function vimInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check vim
if [ ! -f ${MODULEPATH}/vim/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_vim() {
if vimInstalled ${1}; then
  echo "vim ${1} is installed."
else
  build_vim ${1}
fi
}

function build_vim() {

# Get desired version number to install
vim_v=${1}
if [ -z "${vim_v}" ] ; then
  vim_v=8.2
fi

case ${vim_v} in
8.2)
   vim_srcdir=vim82
   ;;
*)
   vim_srcdir=vim-${vim_v}
   ;;
esac

echo "Installing vim ${vim_v}..."

check_modules

downloadPackage vim-${vim_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${vim_srcdir} ] ; then
  rm -rf ${tmp}/${vim_srcdir}
fi

tar xvfj ${pkg}/vim-${vim_v}.tar.bz2
cd ${tmp}/${vim_srcdir}
./configure --prefix=${opt}/vim-${vim_v} \
            --with-features=huge \
            --with-tlib=ncursesw \
            --enable-gui=no
#           --enable-gui=gtk3

make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/vim
cat << eof > ${MODULEPATH}/vim/${vim_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts vim-${vim_v} into your environment"
}

set VER ${vim_v}
set PKG ${opt}/vim-\$VER

module-whatis   "Loads vim-${vim_v}"
conflict vim

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${vim_srcdir}

}
