#!/bin/bash

# Functions for detecting and building openjpeg
echo 'Loading openjpeg...'

function get_openjpeg_library() {
case ${1} in
  1.5.2)
    echo libopenjpeg.so.1.5.2
  ;;
  2.1.2)
    echo libopenjp2.so.2.1.2
  ;;
  2.2.0)
    echo libopenjp2.so.2.2.0
  ;;
  2.3.1)
    echo libopenjp2.so.2.3.1
  ;;
  *)
    echo ''
  ;;
esac
}

function openjpegDepInstalled() {
if [ ! -f "${2}/lib/$(get_openjpeg_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_openjpeg() {
echo -n "Checking for presence of openjpeg-${1} in ${2}..."
if openjpegDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_openjpeg ${1} ${2} ${3}
fi
}

function ff_build_openjpeg() {

# Get desired version number to install
openjpeg_v=${1}
if [ -z "${openjpeg_v}" ] ; then
  echo "ERROR: No OpenJPEG version specified!"
  exit 2
fi

case ${openjpeg_v} in
  1.5.2) # 2014-03-28
   openjpeg_cmake_ver=2.8.12.2 # 2014-01-16
   openjpeg_doxygen_ver=1.8.6  # 2013-12-24
   openjpeg_srcdir=openjpeg-version.${openjpeg_v}
  ;;
  2.1.2) # 2016-09-28
   openjpeg_cmake_ver=3.6.2    # 2016-09-07
   openjpeg_doxygen_ver=1.8.12 # 2016-09-05
   openjpeg_srcdir=openjpeg-${openjpeg_v}
  ;;
  2.2.0) # 2017-08-09
   openjpeg_cmake_ver=3.9.0    # 2017-07-18
   openjpeg_doxygen_ver=1.8.13 # 2016-12-29
   openjpeg_srcdir=openjpeg-${openjpeg_v}
  ;;
  2.3.1) # Apr 2, 2019
   openjpeg_cmake_ver=3.13.4   # 2019-02-01 13:20
   openjpeg_doxygen_ver=1.8.15 # 2018-12-27
   openjpeg_srcdir=openjpeg-${openjpeg_v}
  ;;
  2.5.0) # May 13, 2022
   openjpeg_cmake_ver=3.23.1  # 2022-04-12 10:55
   openjpeg_doxygen_ver=1.9.4 # 2022-05-05
   openjpeg_srcdir=openjpeg-${openjpeg_v}
  ;;
  *)
   echo "ERROR: Review needed for openjpeg ${openjpeg_v}"
   exit 4 # Please review
  ;;
esac

openjpeg_ffmpeg_ver=${3}

openjpeg_zlib_ver=${ffmpeg_zlib_ver}
openjpeg_libpng_ver=${ffmpeg_libpng_ver}
openjpeg_tiff_ver=${ffmpeg_tiff_ver}
openjpeg_lcms2_ver=${ffmpeg_lcms2_ver}

openjpeg_zlib_lib=$(get_zlib_library ${openjpeg_zlib_ver})
openjpeg_libpng_lib=$(get_libpng_library ${openjpeg_libpng_ver})
openjpeg_tiff_lib=$(get_tiff_library ${openjpeg_tiff_ver})
openjpeg_lcms2_lib=$(get_lcms2_library ${openjpeg_lcms2_ver})

openjpeg_prefix=${2}

echo "Installing openjpeg-${openjpeg_v} in ${openjpeg_prefix}..."

check_modules
check_cmake ${openjpeg_cmake_ver}
check_zlib ${openjpeg_zlib_ver}
check_libpng ${openjpeg_libpng_ver}
check_doxygen ${openjpeg_doxygen_ver}
ff_check_tiff ${openjpeg_tiff_ver} ${2} ${3}
ff_check_lcms2 ${openjpeg_lcms2_ver} ${2} ${3}

downloadPackage openjpeg-${openjpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openjpeg_srcdir} ] ; then
  rm -rf ${tmp}/${openjpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openjpeg-${openjpeg_v}.tar.gz
mkdir -pv ${tmp}/${openjpeg_srcdir}/build
cd ${tmp}/${openjpeg_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Fix build issue of JPWL by adding opj_image_data_alloc() and opj_image_data_free() to src/lib/openmj2
# https://github.com/uclouvain/openjpeg/commit/1e387de74273c4dac618df94475556541c1caf3e
if [ "${openjpeg_v}" == "2.2.0" ] ; then
cat << eof > openmj2.patch
--- src/lib/openmj2/openjpeg.c
+++ src/lib/openmj2/openjpeg.c
@@ -372,3 +372,18 @@
         opj_free(cstr_info->numdecompos);
     }
 }
+
+void* OPJ_CALLCONV opj_image_data_alloc(size_t size)
+{
+    /* NOTE: this defers from libopenjp2 where we use opj_aligned_malloc */
+    void* ret = opj_malloc(size);
+    /* printf("opj_image_data_alloc %p\\n", ret); */
+    return ret;
+}
+
+void OPJ_CALLCONV opj_image_data_free(void* ptr)
+{
+    /* NOTE: this defers from libopenjp2 where we use opj_aligned_free */
+    /* printf("opj_image_data_free %p\\n", ptr); */
+    opj_free(ptr);
+}
--- src/lib/openmj2/openjpeg.h
+++ src/lib/openmj2/openjpeg.h
@@ -763,6 +763,27 @@
 */
 OPJ_API void OPJ_CALLCONV opj_image_destroy(opj_image_t *image);
 
+/**
+ * Allocator for opj_image_t->comps[].data
+ * To be paired with opj_image_data_free.
+ *
+ * @param   size    number of bytes to allocate
+ *
+ * @return  a new pointer if successful, NULL otherwise.
+ * @since 2.2.0
+*/
+OPJ_API void* OPJ_CALLCONV opj_image_data_alloc(size_t size);
+
+/**
+ * Destructor for opj_image_t->comps[].data
+ * To be paired with opj_image_data_alloc.
+ *
+ * @param   ptr    Pointer to free
+ *
+ * @since 2.2.0
+*/
+OPJ_API void OPJ_CALLCONV opj_image_data_free(void* ptr);
+
 /*
 ==========================================================
    stream functions definitions
eof
patch -Z -b -p0 < openmj2.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

cd ${tmp}/${openjpeg_srcdir}/build

module purge
module load ffmpeg-dep/${openjpeg_ffmpeg_ver}
module load cmake/${openjpeg_cmake_ver}
module load zlib/${openjpeg_zlib_ver}
module load libpng/${openjpeg_libpng_ver}
module load doxygen/${openjpeg_doxygen_ver}

case ${openjpeg_v} in
  1.5.2)
     build_options="-DBUILD_DOC=ON \
       -DBUILD_JPIP=ON \
       -DBUILD_JPWL=ON \
       -DBUILD_MJ2=ON \
       -DJAVA_SOURCE_VERSION=6 \
       -DJAVA_TARGET_VERSION=1.6" 
  ;;
  2.1.2)
     build_options="-DBUILD_DOC=ON \
       -DBUILD_JPIP=ON \
       -DBUILD_JPWL=ON \
       -DBUILD_MJ2=ON \
       -DBUILD_LUTS_GENERATOR=ON"
  ;;
  2.2.0)
     build_options="-DBUILD_DOC=ON \
       -DBUILD_JPIP=ON \
       -DBUILD_JPWL=ON \
       -DBUILD_MJ2=ON \
       -DBUILD_LUTS_GENERATOR=ON"
  ;;
  2.3.1)
     build_options="-DBUILD_DOC=ON \
       -DBUILD_JPIP=ON \
       -DBUILD_JPWL=ON \
       -DBUILD_MJ2=ON \
       -DBUILD_LUTS_GENERATOR=ON \
       -DJAVA_SOURCE_VERSION=6 \
       -DJAVA_TARGET_VERSION=1.6" 
  ;;
  *)
   echo "ERROR: Review needed for openjpeg ${openjpeg_v}"
   exit 4 # Please review
  ;;
esac

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DZLIB_LIBRARY=${opt}/zlib-${openjpeg_zlib_ver}/lib/${openjpeg_zlib_lib} \
       -DZLIB_INCLUDE_DIR=${opt}/zlib-${openjpeg_zlib_ver}/include \
       -DPNG_LIBRARY=${opt}/libpng-${openjpeg_libpng_ver}/lib/${openjpeg_libpng_lib} \
       -DPNG_PNG_INCLUDE_DIR=${opt}/libpng-${openjpeg_libpng_ver}/include \
       -DTIFF_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_tiff_lib} \
       -DTIFF_INCLUDE_DIR=${openjpeg_prefix}/include \
       -DLCMS2_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_lcms2_lib} \
       -DLCMS2_INCLUDE_DIR=${openjpeg_prefix}/include \
       ${build_options} \
       -DCMAKE_INSTALL_PREFIX=${openjpeg_prefix} ..
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
       -DZLIB_LIBRARY=${opt}/zlib-${openjpeg_zlib_ver}/lib/${openjpeg_zlib_lib} \
       -DZLIB_INCLUDE_DIR=${opt}/zlib-${openjpeg_zlib_ver}/include \
       -DPNG_LIBRARY=${opt}/libpng-${openjpeg_libpng_ver}/lib/${openjpeg_libpng_lib} \
       -DPNG_PNG_INCLUDE_DIR=${opt}/libpng-${openjpeg_libpng_ver}/include \
       -DTIFF_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_tiff_lib} \
       -DTIFF_INCLUDE_DIR=${openjpeg_prefix}/include \
       -DLCMS2_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_lcms2_lib} \
       -DLCMS2_INCLUDE_DIR=${openjpeg_prefix}/include \
       ${build_options} \
       -DCMAKE_INSTALL_PREFIX=${openjpeg_prefix} ..

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

#make -j ${ncpu}
make

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

## openjpeg does not appear to have a test suite
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

cd ${root}
rm -rf ${tmp}/${openjpeg_srcdir}

}
