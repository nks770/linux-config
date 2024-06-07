#!/bin/bash

# Functions for detecting and building uavs3d
echo 'Loading uavs3d...'

function get_uavs3d_library() {
case ${1} in
  1.1.63)
    echo libuavs3d.so
  ;;
  1.1.67)
    echo libuavs3d.so
  ;;
  *)
    echo ''
  ;;
esac
}

function uavs3dInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check uavs3d
if [ ! -f ${MODULEPATH}/uavs3d/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_uavs3d() {
if uavs3dInstalled ${1}; then
  echo "uavs3d ${1} is installed."
else
  build_uavs3d ${1}
fi
}

function build_uavs3d() {

# Get desired version number to install
uavs3d_v=${1}
if [ -z "${uavs3d_v}" ] ; then
  echo "ERROR: No uavs3d version specified!"
  exit 2
fi

case ${uavs3d_v} in
1.1.63) # 2021-04-09
   uavs3d_cmake_ver=3.20.1    # 2021-04-08
   uavs3d_gawk_ver=5.1.0      # 2020-04-14
   uavs3d_commit=26b088ed51a8c3f7ed73e2a70321777c8aff5a8a
   uavs3d_build_num=63
   ;;
1.1.67) # 2021-08-03
   uavs3d_cmake_ver=3.21.1    # 2021-07-27
   uavs3d_gawk_ver=5.1.0      # 2020-04-14
   uavs3d_commit=57d20183301d4197d1c938f62f8a5911e33465d7
   uavs3d_build_num=67
   ;;
*)
   echo "ERROR: Need review for uavs3d ${uavs3d_v}"
   exit 4
   ;;
esac

echo "Installing uavs3d ${uavs3d_v}..."

uavs3d_srcdir=uavs3d-${uavs3d_commit}
uavs3d_zipfil=uavs3d-${uavs3d_v}
uavs3d_prefix=${opt}/uavs3d-${uavs3d_v}

check_modules
check_cmake ${uavs3d_cmake_ver}
check_gawk ${uavs3d_gawk_ver}

downloadPackage ${uavs3d_zipfil}.zip

cd ${tmp}

if [ -d ${tmp}/${uavs3d_srcdir} ] ; then
  rm -rf ${tmp}/${uavs3d_srcdir}
fi

cd ${tmp}
unzip ${pkg}/${uavs3d_zipfil}.zip
mkdir -pv ${tmp}/${uavs3d_srcdir}/build
cd ${tmp}/${uavs3d_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch
cat << eof > version.patch
--- version.sh
+++ version.sh
@@ -15,8 +15,8 @@
     shell_dir=\$1
 fi
 
-VER_R=\`git rev-list origin/master | sort | wc -l | gawk '{print \$1}'\`
-VER_L=\`git rev-list HEAD | sort | wc -l | gawk '{print \$1}'\`
+VER_R=${uavs3d_build_num}
+VER_L=${uavs3d_build_num}
 VER_SHA1=\`git log -n 1 | head -n 1 | cut -d ' ' -f 2\`
 
 major_version="1"
eof
patch -Z -b -p0 < version.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

cd ${tmp}/${uavs3d_srcdir}/build

module purge
module load cmake/${uavs3d_cmake_ver}
module load gawk/${uavs3d_gawk_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DBUILD_SHARED_LIBS=true \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=${uavs3d_prefix} ..
  echo ''
  read k
fi

cmake -L -G "Unix Makefiles" \
       -DBUILD_SHARED_LIBS=true \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=${uavs3d_prefix} ..

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make
#make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

mkdir -pv ${uavs3d_prefix}/bin
cp -av uavs3dec ${uavs3d_prefix}/bin

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
mkdir -pv ${MODULEPATH}/uavs3d
cat << eof > ${MODULEPATH}/uavs3d/${uavs3d_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts uavs3d-${uavs3d_v} into your environment"
}

set VER ${uavs3d_v}
set PKG ${opt}/uavs3d-\$VER

module-whatis   "Loads uavs3d-${uavs3d_v}"
conflict uavs3d

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${uavs3d_srcdir}

}
