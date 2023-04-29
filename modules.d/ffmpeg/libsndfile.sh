#!/bin/bash

# Functions for detecting and building libsndfile

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
libsndfile_srcdir=libsndfile-${libsndfile_v}

echo "Installing libsndfile ${libsndfile_v}..."

case ${1} in
  1.0.28)
   libsndfile_libogg_ver=1.3.4
   libsndfile_libvorbis_ver=1.3.7
   libsndfile_flac_ver=1.3.3
  ;;
esac

check_modules
check_libogg ${libsndfile_libogg_ver}
check_libvorbis ${libsndfile_libvorbis_ver}
check_flac ${libsndfile_flac_ver}

module purge
module load libogg/${libsndfile_libogg_ver} \
            libvorbis/${libsndfile_libvorbis_ver} \
            flac/${libsndfile_flac_ver}
module list

downloadPackage libsndfile-${libsndfile_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libsndfile_srcdir} ] ; then
  rm -rf ${tmp}/${libsndfile_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libsndfile-${libsndfile_v}.tar.gz
cd ${tmp}/${libsndfile_srcdir}

./configure --prefix=${opt}/libsndfile-${libsndfile_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
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
module load libogg/${libsndfile_libogg_ver}
module load libvorbis/${libsndfile_libvorbis_ver}
module load flac/${libsndfile_flac_ver}
prereq libogg/${libsndfile_libogg_ver}
prereq libvorbis/${libsndfile_libvorbis_ver}
prereq flac/${libsndfile_flac_ver}

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
