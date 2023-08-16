#!/bin/bash

# Functions for detecting and building libbluray
echo 'Loading libbluray...'

function get_libbluray_library() {
case ${1} in
  1.1.2)
    echo libbluray.so.2.1.2
  ;;
  *)
    echo ''
  ;;
esac
}

function libblurayDepInstalled() {
if [ ! -f "${2}/lib/$(get_libbluray_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libbluray() {
echo -n "Checking for presence of libbluray-${1} in ${2}..."
if libblurayDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libbluray ${1} ${2} ${3}
fi
}


function ff_build_libbluray() {

# Get desired version number to install
libbluray_v=${1}
if [ -z "${libbluray_v}" ] ; then
  libbluray_v=1.1.2
fi

case ${libbluray_v} in
  1.1.2) # 2019-06-07
   libbluray_doxygen_ver=1.8.15    # 2018-12-27
#   apacheant_ver=1.9.14  # 2019-03-17
  ;;
  *)
   echo "ERROR: Need review for libbluray ${libbluray_v}"
   exit 4
   ;;
esac

libbluray_ffmpeg_ver=${3}
libbluray_libxml2_ver=${ffmpeg_libxml2_ver}
libbluray_freetype_ver=${ffmpeg_freetype_ver}
libbluray_fontconfig_ver=${ffmpeg_fontconfig_ver}

libbluray_srcdir=libbluray-${libbluray_v}
libbluray_prefix=${2}

echo "Installing libbluray-${libbluray_v} in ${libbluray_prefix}..."

check_modules
ff_check_libxml2 ${libbluray_libxml2_ver} ${2} ${3}
ff_check_freetype ${libbluray_freetype_ver} ${2} ${3}
ff_check_fontconfig ${libbluray_fontconfig_ver} ${2} ${3}
check_doxygen ${libbluray_doxygen_ver}
#check_apacheant ${apacheant_ver}

downloadPackage ${libbluray_srcdir}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${libbluray_srcdir} ] ; then
  rm -rf ${tmp}/${libbluray_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/${libbluray_srcdir}.tar.bz2
cd ${tmp}/${libbluray_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to fix issue compiling with recent Java
# >> Explanation:
#
# `java.io.FileSystem` was extended with an protected abstract method `isInvalid()` by
# jdk commit 395bb5b7f97f ("8278356: Improve file creation"). libbluray places a
# BDFileSystem class in the java.io package, which extends java.io.FileSystem but only
# recently implemented `isInvalid()` in commit 8f26777b1ce1 ("Fix build failure after
# Oracle Java CPU for April 2022").
#
if [ "${libbluray_v}" == "1.1.2" ] ; then
cat << eof > BDFileSystem.patch
--- src/libbluray/bdj/java/java/io/BDFileSystem.java	2019-06-07 13:00:28.000000000 -0500
+++ src/libbluray/bdj/java/java/io/BDFileSystem.java	2023-04-23 22:07:27.866670710 -0500
@@ -207,6 +207,17 @@
         return fs.isAbsolute(f);
     }
 
+    public boolean isInvalid(File f) {
+        try {
+            Method m = fs.getClass().getDeclaredMethod("isInvalid", new Class[] { File.class });
+            Object[] args = new Object[] {(Object)f};
+            Boolean result = (Boolean)m.invoke(fs, args);
+            return result.booleanValue();
+        } finally {
+            return false;
+        }
+    }
+
     public String resolve(File f) {
         if (!booted)
             return fs.resolve(f);
eof
patch -Z -b -p0 < BDFileSystem.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

module purge
module load ffmpeg-dep/${libbluray_ffmpeg_ver}
module load doxygen/${libbluray_doxygen_ver}
#module load apache-ant/${apacheant_ver}

config="./configure --prefix=${libbluray_prefix}"

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

cd ${root}
rm -rf ${tmp}/${libbluray_srcdir}

}
