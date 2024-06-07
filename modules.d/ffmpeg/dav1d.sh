#!/bin/bash

# Functions for detecting and building dav1d
echo 'Loading dav1d...'

function dav1dInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check dav1d
if [ ! -f ${MODULEPATH}/dav1d/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_dav1d() {
if dav1dInstalled ${1}; then
  echo "dav1d ${1} is installed."
else
  build_dav1d ${1}
fi
}

function build_dav1d() {

# Get desired version number to install
dav1d_v=${1}
if [ -z "${dav1d_v}" ] ; then
  echo "ERROR: No dav1d version specified!"
  exit 2
fi

dav1d_srcdir=dav1d-${dav1d_v}
dav1d_prefix=${opt}/${dav1d_srcdir}

echo "Installing dav1d ${dav1d_v}..."

case ${dav1d_v} in
  0.5.2) # 2019-12-04
   dav1d_meson_ver=0.52.0 # 2019-10-06
   dav1d_ninja_ver=1.9.0  # 2019-01-30
   dav1d_python_ver=3.8.0 # 2019-10-14
   dav1d_nasm_ver=2.14.02 # 2018-12-26
   dav1d_doxygen_ver=1.8.16 # 2019-08-08
  ;;
  0.7.0) # 2020-05-20
   dav1d_meson_ver=0.54.2 # 2020-05-15
   dav1d_ninja_ver=1.10.0 # 2020-01-27
   dav1d_python_ver=3.8.3 # 2020-05-13
   dav1d_nasm_ver=2.14.02 # 2018-12-26
   dav1d_doxygen_ver=1.8.18 # 2020-04-12
  ;;
  0.7.1) # 2020-06-21
   dav1d_meson_ver=0.54.2 # 2020-05-15 (or 0.54.3 2020-06-15)
   dav1d_ninja_ver=1.10.0 # 2020-01-27
   dav1d_python_ver=3.8.3 # 2020-05-13
   dav1d_nasm_ver=2.14.02 # 2018-12-26
   dav1d_doxygen_ver=1.8.18 # 2020-04-12
  ;;
  0.8.1) # 2021-01-02
   dav1d_meson_ver=0.56.0 # 2020-10-30
   dav1d_ninja_ver=1.10.2 # 2020-11-28
   dav1d_python_ver=3.9.1 # 2020-12-07
   dav1d_nasm_ver=2.15.05 # 2020-08-28
   dav1d_doxygen_ver=1.9.0 # 2020-12-27
  ;;
  0.8.2) # 2021-02-21
   dav1d_meson_ver=0.57.1 # 2021-02-20
   dav1d_ninja_ver=1.10.2 # 2020-11-28
   dav1d_python_ver=3.9.2 # 2021-02-19
   dav1d_nasm_ver=2.15.05 # 2020-08-28
   dav1d_doxygen_ver=1.9.1 # 2021-01-08
  ;;
  0.9.2) # 2021-09-03
   dav1d_meson_ver=0.59.1 # 2021-08-18
   dav1d_ninja_ver=1.10.2 # 2020-11-28
   dav1d_python_ver=3.9.7 # 2021-08-30
   dav1d_nasm_ver=2.15.05 # 2020-08-28
   dav1d_doxygen_ver=1.9.2 # 2021-08-18
  ;;
  *)
   echo "ERROR: Need review for dav1d ${dav1d_v}"
   exit 4
   ;;
esac

check_modules
check_nasm ${dav1d_nasm_ver}
check_doxygen ${dav1d_doxygen_ver}
check_ninja ${dav1d_ninja_ver}
check_python ${dav1d_python_ver}
#check_p3wheel ${dav1d_python_ver} setuptools 68.0.0
if [ "${dav1d_meson_ver}" == "0.54.2" ] && [ "${dav1d_python_ver}" == "3.8.3" ] ; then
  check_p3wheel ${dav1d_python_ver} wheel 0.34.2
fi
if [ "${dav1d_meson_ver}" == "0.56.0" ] && [ "${dav1d_python_ver}" == "3.9.1" ] ; then
  check_p3wheel ${dav1d_python_ver} wheel 0.36.1
fi
if [ "${dav1d_meson_ver}" == "0.57.1" ] && [ "${dav1d_python_ver}" == "3.9.2" ] ; then
  check_p3wheel ${dav1d_python_ver} wheel 0.36.2
fi
if [ "${dav1d_meson_ver}" == "0.59.1" ] && [ "${dav1d_python_ver}" == "3.9.7" ] ; then
  check_p3wheel ${dav1d_python_ver} wheel 0.37.0
fi
check_p3wheel ${dav1d_python_ver} meson ${dav1d_meson_ver}

downloadPackage ${dav1d_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${dav1d_srcdir} ] ; then
  rm -rf ${tmp}/${dav1d_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/dav1d-${dav1d_v}.tar.gz
mkdir -pv ${tmp}/${dav1d_srcdir}/build
cd ${tmp}/${dav1d_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load Python/${dav1d_python_ver}
module load ninja/${dav1d_ninja_ver}
module load nasm/${dav1d_nasm_ver}
module load doxygen/${dav1d_doxygen_ver}

config="meson setup --prefix=${dav1d_prefix} .."

if [ ${debug} -gt 0 ] ; then
  meson --help
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
ninja

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

## dav1d testsuite requires downloading external test data
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

ninja install
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
mkdir -pv ${MODULEPATH}/dav1d
cat << eof > ${MODULEPATH}/dav1d/${dav1d_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts dav1d-${dav1d_v} into your environment"
}

set VER ${dav1d_v}
set PKG ${opt}/dav1d-\$VER

module-whatis   "Loads dav1d-${dav1d_v}"
conflict dav1d

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib64
prepend-path PKG_CONFIG_PATH \$PKG/lib64/pkgconfig
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${dav1d_srcdir}

}
