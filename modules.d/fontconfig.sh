#!/bin/bash

# Functions for detecting and building fontconfig
echo 'Loading fontconfig...'

function fontconfigInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check fontconfig
if [ ! -f ${MODULEPATH}/fontconfig/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_fontconfig() {
if fontconfigInstalled ${1}; then
  echo "fontconfig ${1} is installed."
else
  build_fontconfig ${1}
fi
}

function build_fontconfig() {

# Get desired version number to install
fontconfig_v=${1}
if [ -z "${fontconfig_v}" ] ; then
  fontconfig_v=2.12.6
fi

case ${1} in
  2.12.6) # 2017-09-21
   freetype_ver=2.8.1 # 2017-09-16
   expat_ver=2.2.4    # 2017-08-19
   gperf_ver=3.1      # 2017-01-05
  ;;
  2.13.1) # 2018-08-30
   freetype_ver=2.9.1   # 2018-05-02
   expat_ver=2.2.6      # 2018-08-15
   gperf_ver=3.1        # 2017-01-05
   utillinux_ver=2.32.1 # 2018-07-16
  ;;
  2.13.91) # 2019-06-10
   freetype_ver=2.10.0  # 2019-03-15
   expat_ver=2.2.6      # 2018-08-15
   gperf_ver=3.1        # 2017-01-05
   utillinux_ver=2.33.2 # 2019-04-09
  ;;
  *)
   echo "ERROR: Need review for fontconfig ${1}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  if [ ! -z "${utillinux_ver}" ] ; then
    utillinux_ver=${global_utillinux}
  fi
fi

echo "Installing fontconfig ${fontconfig_v}..."

check_modules
check_freetype_harfbuzz ${freetype_ver}
check_expat ${expat_ver}
check_gperf ${gperf_ver}
if [ ! -z "${utillinux_ver}" ] ; then
  check_utillinux ${utillinux_ver}
fi

downloadPackage fontconfig-${fontconfig_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/fontconfig-${fontconfig_v} ] ; then
  rm -rf ${tmp}/fontconfig-${fontconfig_v}
fi

tar xvfz ${pkg}/fontconfig-${fontconfig_v}.tar.gz
cd ${tmp}/fontconfig-${fontconfig_v}

config="./configure --prefix=${opt}/fontconfig-${fontconfig_v}"

module purge
module load freetype/${freetype_ver}
module load expat/${expat_ver}
module load gperf/${gperf_ver}
if [ ! -z "${utillinux_ver}" ] ; then
  module load util-linux/${utillinux_ver}
fi

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
mkdir -pv ${MODULEPATH}/fontconfig
cat << eof > ${MODULEPATH}/fontconfig/${fontconfig_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts fontconfig-${fontconfig_v} into your environment"
}

set VER ${fontconfig_v}
set PKG ${opt}/fontconfig-\$VER

module-whatis   "Loads fontconfig-${fontconfig_v}"
conflict fontconfig
module load freetype/${freetype_ver}
module load expat/${expat_ver}
prereq freetype/${freetype_ver}
prereq expat/${expat_ver}
eof
if [ ! -z "${utillinux_ver}" ] ; then
  echo "module load util-linux/${utillinux_ver}" >> ${MODULEPATH}/fontconfig/${fontconfig_v}
  echo "prereq util-linux/${utillinux_ver}" >> ${MODULEPATH}/fontconfig/${fontconfig_v}
fi

cat << eof >> ${MODULEPATH}/fontconfig/${fontconfig_v}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/fontconfig-${fontconfig_v}

}
