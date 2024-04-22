#!/bin/bash

# Functions for detecting and building fontconfig
echo 'Loading fontconfig...'

function get_fontconfig_library() {
case ${1} in
  2.13.92)
    echo libfontconfig.so.1.12.0
  ;;
  2.13.93)
    echo libfontconfig.so.1.12.0
  ;;
  *)
    echo ''
  ;;
esac
}

function fontconfigDepInstalled() {
if [ ! -f "${2}/lib/$(get_fontconfig_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_fontconfig() {
echo -n "Checking for presence of fontconfig-${1} in ${2}..."
if fontconfigDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_fontconfig ${1} ${2} ${3}
fi
}

function ff_build_fontconfig() {

# Get desired version number to install
fontconfig_v=${1}
if [ -z "${fontconfig_v}" ] ; then
  echo "ERROR: No fontconfig version specified!"
  exit 2
fi

case ${fontconfig_v} in
  2.12.6) # 2017-09-21
#   freetype_ver=2.8.1 # 2017-09-16
#   fontconfig_expat_ver=2.2.4    # 2017-08-19
   fontconfig_gperf_ver=3.1      # 2017-01-05
  ;;
  2.13.1) # 2018-08-30
#   freetype_ver=2.9.1   # 2018-05-02
#   fontconfig_expat_ver=2.2.6      # 2018-08-15
   fontconfig_gperf_ver=3.1        # 2017-01-05
#   fontconfig_utillinux_ver=2.32.1 # 2018-07-16
  ;;
  2.13.91) # 2019-06-10
#   freetype_ver=2.10.0  # 2019-03-15
#   fontconfig_expat_ver=2.2.6      # 2018-08-15
   fontconfig_gperf_ver=3.1        # 2017-01-05
#   fontconfig_utillinux_ver=2.33.2 # 2019-04-09
  ;;
  2.13.92) # 2019-08-09
#   freetype_ver=2.10.0  # 2019-03-15
#   fontconfig_expat_ver=2.2.7      # 2019-06-19
   fontconfig_gperf_ver=3.1        # 2017-01-05
#   fontconfig_utillinux_ver=2.34   # 2019-06-14
  ;;
  2.13.93) # 2020-11-28
#   freetype_ver=2.10.0  # 2019-03-15
#   fontconfig_expat_ver=2.2.7      # 2019-06-19
   fontconfig_gperf_ver=3.1        # 2017-01-05 - latest as of 2024-04-20
#   fontconfig_utillinux_ver=2.34   # 2019-06-14
  ;;
  *)
   echo "ERROR: Need review for fontconfig ${fontconfig_v}"
   exit 4
   ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  if [ ! -z "${fontconfig_utillinux_ver}" ] ; then
#    fontconfig_utillinux_ver=${global_utillinux}
#  fi
#fi

fontconfig_ffmpeg_ver=${3}
fontconfig_freetype_ver=${ffmpeg_freetype_ver}
fontconfig_expat_ver=${ffmpeg_expat_ver}
fontconfig_utillinux_ver=${ffmpeg_utillinux_ver}

fontconfig_srcdir=fontconfig-${fontconfig_v}
fontconfig_prefix=${2}

echo "Installing fontconfig-${fontconfig_v} in ${fontconfig_prefix}..."

check_modules
ff_check_freetype ${fontconfig_freetype_ver} ${2} ${3}
check_expat ${fontconfig_expat_ver}
check_gperf ${fontconfig_gperf_ver}
if [ ! -z "${fontconfig_utillinux_ver}" ] ; then
  check_utillinux ${fontconfig_utillinux_ver}
fi

downloadPackage fontconfig-${fontconfig_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${fontconfig_srcdir} ] ; then
  rm -rf ${tmp}/${fontconfig_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/fontconfig-${fontconfig_v}.tar.gz
cd ${tmp}/${fontconfig_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

if [ "${fontconfig_v}" == "2.13.93" ] ; then
  # Known issue where sgml files are not generated
  # https://gitlab.freedesktop.org/fontconfig/fontconfig/-/issues/272
  for i in doc/*.fncs; do
    touch -r $i ${i//.fncs/.sgml}
  done
  if [ ${debug} -gt 0 ] ; then
    echo '>> Patching complete'
    read k
  fi
fi

module purge
module load ffmpeg-dep/${fontconfig_ffmpeg_ver}
module load expat/${fontconfig_expat_ver}
module load gperf/${fontconfig_gperf_ver}

if [ ! -z "${fontconfig_utillinux_ver}" ] ; then
  module load util-linux/${fontconfig_utillinux_ver}
fi

config="./configure --prefix=${fontconfig_prefix}"
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
rm -rf ${tmp}/${fontconfig_srcdir}

}
