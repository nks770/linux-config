#!/bin/bash

# Functions for detecting and building TwoLAME
echo 'Loading twolame...'

function twolameInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check twolame
if [ ! -f ${MODULEPATH}/twolame/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_twolame() {
if twolameInstalled ${1}; then
  echo "twolame ${1} is installed."
else
  build_twolame ${1}
fi
}

function build_twolame() {

# Get desired version number to install
twolame_v=${1}
if [ -z "${twolame_v}" ] ; then
  twolame_v=0.4.0
fi

case ${twolame_v} in
  0.4.0) # 2019-10-11
   twolame_libsndfile_ver=1.0.28-flac1.3.3 # 2017-04-02 / 2019-08-04
  ;;
  *)
   echo "ERROR: Review needed for twolame ${twolame_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing twolame ${twolame_v}..."
twolame_srcdir=twolame-${twolame_v}

check_modules
check_libsndfile ${twolame_libsndfile_ver}

downloadPackage twolame-${twolame_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${twolame_srcdir} ] ; then
  rm -rf ${tmp}/${twolame_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/twolame-${twolame_v}.tar.gz
cd ${tmp}/${twolame_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load libsndfile/${twolame_libsndfile_ver}

config="./configure --prefix=${opt}/twolame-${twolame_v}"
if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
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
mkdir -pv ${MODULEPATH}/twolame
cat << eof > ${MODULEPATH}/twolame/${twolame_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts twolame-${twolame_v} into your environment"
}

set VER ${twolame_v}
set PKG ${opt}/twolame-\$VER

module-whatis   "Loads twolame-${twolame_v}"
conflict twolame
module load libsndfile/${twolame_libsndfile_ver}
prereq libsndfile/${twolame_libsndfile_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${twolame_srcdir}

}
