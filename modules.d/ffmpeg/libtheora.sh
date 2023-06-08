#!/bin/bash

# Functions for detecting and building libtheora
echo 'Loading libtheora...'

function libtheoraInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libtheora
if [ ! -f ${MODULEPATH}/libtheora/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libtheora() {
if libtheoraInstalled ${1}; then
  echo "libtheora ${1} is installed."
else
  build_libtheora ${1}
fi
}

function build_libtheora() {

# Get desired version number to install
libtheora_v=${1}
if [ -z "${libtheora_v}" ] ; then
  libtheora_v=1.1.1
fi
libtheora_srcdir=libtheora-${libtheora_v}

case ${1} in
  1.1.1) # 2009 October 1
   libogg_ver=1.3.4
   libvorbis_ver=1.3.7
   doxygen_ver=1.8.14
  ;;
  *)
   echo "ERROR: Review needed for libtheora ${1}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  libogg_ver=${global_libogg}
fi

echo "Installing libtheora ${libtheora_v}..."

check_modules
check_libogg ${libogg_ver}
check_libvorbis ${libvorbis_ver}
check_doxygen ${doxygen_ver}

downloadPackage libtheora-${libtheora_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${libtheora_srcdir} ] ; then
  rm -rf ${tmp}/${libtheora_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/libtheora-${libtheora_v}.tar.bz2
cd ${tmp}/${libtheora_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

## Patch needed because png_sizeof() function removed in libpng 1.6+
## Please use sizeof() insgtead of png_sizeof()
#if [ "${libtheora_v}" == "1.1.1" ] ; then
#cat << eof > png2theora.patch
#Index: examples/png2theora.c
#===================================================================
#--- examples/png2theora.c       2009-08-22 18:14:04.000000000 +0000
#+++ examples/png2theora.c       2021-04-25 04:47:25.666263747 +0000
#@@ -462,9 +462,9 @@
#   png_set_strip_alpha(png_ptr);
#
#   row_data = (png_bytep)png_malloc(png_ptr,
#-    3*height*width*png_sizeof(*row_data));
#+    3*height*width*sizeof(*row_data));
#   row_pointers = (png_bytep *)png_malloc(png_ptr,
#-    height*png_sizeof(*row_pointers));
#+    height*sizeof(*row_pointers));
#   for(y = 0; y < height; y++) {
#     row_pointers[y] = row_data + y*(3*width);
#   }
#eof
#patch -N -Z -b -p0 < png2theora.patch
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#fi
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Patching complete'
#  read k
#fi

module purge
module load libogg/${libogg_ver} \
            libvorbis/${libvorbis_ver} \
            doxygen/${doxygen_ver}

config="./configure --prefix=${opt}/libtheora-${libtheora_v} --disable-examples"
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
mkdir -pv ${MODULEPATH}/libtheora
cat << eof > ${MODULEPATH}/libtheora/${libtheora_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libtheora-${libtheora_v} into your environment"
}

set VER ${libtheora_v}
set PKG ${opt}/libtheora-\$VER

module-whatis   "Loads libtheora-${libtheora_v}"
conflict libtheora
module load libogg/${libogg_ver}
module load libvorbis/${libvorbis_ver}
prereq libogg/${libogg_ver}
prereq libvorbis/${libvorbis_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libtheora_srcdir}

}
