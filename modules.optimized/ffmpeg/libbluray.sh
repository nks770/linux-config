#!/bin/bash

# Functions for detecting and building libbluray
echo 'Loading libbluray...'

function libblurayInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libbluray
if [ ! -f ${MODULEPATH}/libbluray/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libbluray() {
if libblurayInstalled ${1}; then
  echo "libbluray ${1} is installed."
else
  build_libbluray ${1}
fi
}

function build_libbluray() {

# Get desired version number to install
libbluray_v=${1}
if [ -z "${libbluray_v}" ] ; then
  libbluray_v=1.0.2
fi
libbluray_srcdir=libbluray-${libbluray_v}

echo "Installing libbluray ${libbluray_v}..."

case ${1} in
  1.1.2) # 2019-06-07
   libxml2_ver=2.9.9     # 2019-01-03
   freetype_ver=2.9.1    # 2018-05-02
   fontconfig_ver=2.13.1 # 2018-08-30
   doxygen_ver=1.8.15    # 2018-12-27
#   apacheant_ver=1.9.14  # 2019-03-17
  ;;
  *)
   echo "ERROR: Need review for libbluray ${1}"
   exit 4
   ;;
esac

check_modules
check_libxml2 ${libxml2_ver}
check_freetype_harfbuzz ${freetype_ver}
check_fontconfig ${fontconfig_ver}
check_doxygen ${doxygen_ver}
#check_apacheant ${apacheant_ver}

downloadPackage libbluray-${libbluray_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${libbluray_srcdir} ] ; then
  rm -rf ${tmp}/${libbluray_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/libbluray-${libbluray_v}.tar.bz2
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

config="./configure --prefix=${opt}/libbluray-${libbluray_v}"

module purge
module load libxml2/${libxml2_ver}
module load freetype/${freetype_ver}
module load fontconfig/${fontconfig_ver}
module load doxygen/${doxygen_ver}
#module load apache-ant/${apacheant_ver}

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
mkdir -pv ${MODULEPATH}/libbluray
cat << eof > ${MODULEPATH}/libbluray/${libbluray_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libbluray-${libbluray_v} into your environment"
}

set VER ${libbluray_v}
set PKG ${opt}/libbluray-\$VER

module-whatis   "Loads libbluray-${libbluray_v}"
conflict libbluray
module load libxml2/${libxml2_ver}
module load freetype/${freetype_ver}
module load fontconfig/${fontconfig_ver}
prereq libxml2/${libxml2_ver}
prereq freetype/${freetype_ver}
prereq fontconfig/${fontconfig_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libbluray_srcdir}

}
