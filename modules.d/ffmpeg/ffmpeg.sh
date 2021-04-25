#!/bin/bash

# Functions for detecting and building FFmpeg

function ffmpegInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check ffmpeg
if [ ! -f ${MODULEPATH}/ffmpeg/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_ffmpeg() {
if ffmpegInstalled ${1}; then
  echo "ffmpeg ${1} is installed."
else
  build_ffmpeg ${1}
fi
}

function build_ffmpeg() {

# Get desired version number to install
ffmpeg_v=${1}
if [ -z "${ffmpeg_v}" ] ; then
  ffmpeg_v=4.2.2
fi

ffmpeg_srcdir=ffmpeg-${ffmpeg_v}

echo "Installing ffmpeg ${ffmpeg_v}..."

case ${1} in
  4.2.2) # 2019-12-31 23:58
   ffmpeg_nasm_ver=2.13.03
   ffmpeg_libaom_ver=1.0.0
   ffmpeg_libass_ver=0.14.0
   ffmpeg_lame_ver=3.100
   ffmpeg_xvidcore_ver=1.3.6
   ffmpeg_libbluray_ver=1.1.2
  ;;
esac

check_modules
check_nasm ${ffmpeg_nasm_ver}
check_libaom ${ffmpeg_libaom_ver}
check_libass ${ffmpeg_libass_ver}
check_lame ${ffmpeg_lame_ver}
check_xvidcore ${ffmpeg_xvidcore_ver}
check_libbluray ${ffmpeg_libbluray_ver}

module purge
module load nasm/${ffmpeg_nasm_ver} \
            libaom/${ffmpeg_libaom_ver} \
            libass/${ffmpeg_libass_ver} \
            lame/${ffmpeg_lame_ver} \
            xvidcore/${ffmpeg_xvidcore_ver} \
            libbluray/${ffmpeg_libbluray_ver}
module list

exit 4

downloadPackage ffmpeg-${ffmpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${ffmpeg_srcdir} ] ; then
  rm -rf ${tmp}/${ffmpeg_srcdir}
fi

tar xvfz ${pkg}/ffmpeg-${ffmpeg_v}.tar.gz
cd ${tmp}/${ffmpeg_srcdir}

cd ${root}
#rm -rf ${tmp}/${ffmpeg_srcdir}

}
