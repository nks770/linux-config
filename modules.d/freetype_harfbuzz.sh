#!/bin/bash

# Functions for detecting and building freetype
echo 'Loading freetype/harfbuzz...'

function freetype_harfbuzzInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check freetype
if [ ! -f ${MODULEPATH}/freetype/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_freetype_harfbuzz() {
if freetype_harfbuzzInstalled ${1}; then
  echo "freetype ${1} is installed."
else
  build_freetype_harfbuzz ${1}
fi
}

function build_freetype_harfbuzz() {

# Get desired version number to install
freetype_v=${1}
if [ -z "${freetype_v}" ] ; then
  freetype_v=2.12.1
fi

case ${freetype_v} in
2.8.1) # 2017-09-16
   zlib_ver=1.2.11    #2017-01-15
   bzip2_ver=1.0.6    #2010-09-20
#   libpng_ver=1.2.58 #2017-08-24
#   libpng_ver=1.4.21 #2017-08-24
   libpng_ver=1.5.29  #2017-08-24
   harfbuzz_v=1.5.1   #2017-09-05
   ;;
*)
   echo "ERROR: Need review for freetype ${1}"
   exit 4
   ;;
esac

############
# freetype #
############

echo "Installing freetype ${freetype_v}..."

check_modules
check_zlib ${zlib_ver}
check_bzip2 ${bzip2_ver}
check_libpng ${libpng_ver}
#check_harfbuzz ${harfbuzz_ver}

downloadPackage freetype-${freetype_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/freetype-${freetype_v} ] ; then
  rm -rf ${tmp}/freetype-${freetype_v}
fi

tar xvfz ${pkg}/freetype-${freetype_v}.tar.gz
cd ${tmp}/freetype-${freetype_v}

config="./configure --prefix=${opt}/freetype-${freetype_v} CFLAGS=-I${opt}/bzip2-${bzip2_ver}/include LDFLAGS=-L${opt}/bzip2-${bzip2_ver}/lib"

module purge
module load zlib/${zlib_ver}
module load bzip2/${bzip2_ver}
module load libpng/${libpng_ver}
#module load harfbuzz/${harfbuzz_ver}

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
  echo '>> (Phase 1) Install complete'
  read k
fi

############
# harfbuzz #
############

echo "Installing harfbuzz ${harfbuzz_v}..."

downloadPackage harfbuzz-${harfbuzz_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/harfbuzz-${harfbuzz_v} ] ; then
  rm -rf ${tmp}/harfbuzz-${harfbuzz_v}
fi

tar xvfj ${pkg}/harfbuzz-${harfbuzz_v}.tar.bz2
cd ${tmp}/harfbuzz-${harfbuzz_v}

config="./configure --prefix=${opt}/harfbuzz-${harfbuzz_v} PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${opt}/freetype-${freetype_v}/lib/pkgconfig"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
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
  echo '>> harfbuzz install complete'
  read k
fi

############
# freetype #
############

echo "Installing freetype ${freetype_v}..."

#downloadPackage freetype-${freetype_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/freetype-${freetype_v} ] ; then
  rm -rf ${tmp}/freetype-${freetype_v}
fi

tar xvfz ${pkg}/freetype-${freetype_v}.tar.gz
cd ${tmp}/freetype-${freetype_v}

config="./configure --prefix=${opt}/freetype-${freetype_v} CFLAGS=-I${opt}/bzip2-${bzip2_ver}/include LDFLAGS=-L${opt}/bzip2-${bzip2_ver}/lib PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${opt}/harfbuzz-${harfbuzz_v}/lib/pkgconfig"

module purge
module load zlib/${zlib_ver}
module load bzip2/${bzip2_ver}
module load libpng/${libpng_ver}
#module load harfbuzz/${harfbuzz_ver}

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
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

# Create the environment modules
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/freetype
mkdir -pv ${MODULEPATH}/harfbuzz
cat << eof > ${MODULEPATH}/freetype/${freetype_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts freetype-${freetype_v} into your environment"
}

set VER ${freetype_v}
set PKG ${opt}/freetype-\$VER

module-whatis   "Loads freetype-${freetype_v}"
conflict freetype
module load zlib/${zlib_ver}
module load bzip2/${bzip2_ver}
module load libpng/${libpng_ver}
module load harfbuzz/${harfbuzz_v}
prereq zlib/${zlib_ver}
prereq bzip2/${bzip2_ver}
prereq libpng/${libpng_ver}
prereq harfbuzz/${harfbuzz_v}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof
cat << eof > ${MODULEPATH}/harfbuzz/${harfbuzz_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts harfbuzz-${harfbuzz_v} into your environment"
}

set VER ${harfbuzz_v}
set PKG ${opt}/harfbuzz-\$VER

module-whatis   "Loads harfbuzz-${harfbuzz_v}"
conflict harfbuzz
module load freetype/${freetype_v}
prereq freetype/${freetype_v}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
#prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/freetype-${freetype_v}
rm -rf ${tmp}/harfbuzz-${harfbuzz_v}
}
