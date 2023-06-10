#!/bin/bash

# Functions for detecting and building libsndfile
echo 'Loading libsndfile...'

function libsndfileInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libsndfile
if [ ! -f ${MODULEPATH}/libsndfile/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libsndfile() {
if libsndfileInstalled ${1}; then
  echo "libsndfile ${1} is installed."
else
  build_libsndfile ${1}
fi
}

function build_libsndfile() {

# Get desired version number to install
libsndfile_v=${1}
if [ -z "${libsndfile_v}" ] ; then
  libsndfile_v=1.0.28
fi

case ${libsndfile_v} in
  1.0.28-flac1.3.3) # 2017-04-02
   libsndfile_vv=1.0.28
   libogg_ver=1.3.2 # 2014-05-27
#   libvorbis_ver=1.3.5 # 2015-03-03
   libvorbis_ver=1.3.7 # 2020-07-04
   flac_ver=1.3.3 # 2019-08-04
  ;;
  *)
   echo "ERROR: Review needed for libsndfile ${libsndfile_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  libogg_ver=${global_libogg}
fi

echo "Installing libsndfile ${libsndfile_v}..."
libsndfile_srcdir=libsndfile-${libsndfile_vv}

check_modules
check_libogg ${libogg_ver}
check_libvorbis ${libvorbis_ver}
check_flac ${flac_ver}

downloadPackage libsndfile-${libsndfile_vv}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libsndfile_srcdir} ] ; then
  rm -rf ${tmp}/${libsndfile_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libsndfile-${libsndfile_vv}.tar.gz
cd ${tmp}/${libsndfile_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load libogg/${libogg_ver} \
            libvorbis/${libvorbis_ver} \
            flac/${flac_ver}

config="./configure --prefix=${opt}/libsndfile-${libsndfile_v}"
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
mkdir -pv ${MODULEPATH}/libsndfile
cat << eof > ${MODULEPATH}/libsndfile/${libsndfile_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libsndfile-${libsndfile_v} into your environment"
}

set VER ${libsndfile_v}
set PKG ${opt}/libsndfile-\$VER

module-whatis   "Loads libsndfile-${libsndfile_v}"
conflict libsndfile
module load libogg/${libogg_ver}
module load libvorbis/${libvorbis_ver}
module load flac/${flac_ver}
prereq libogg/${libogg_ver}
prereq libvorbis/${libvorbis_ver}
prereq flac/${flac_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${libsndfile_srcdir}

}
