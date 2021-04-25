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
   ffmpeg_fdkaac_ver=2.0.1
   ffmpeg_x264_ver=20191125
   ffmpeg_x265_ver=3.2.1      # Oct 22, 2019
   ffmpeg_libogg_ver=1.3.4
   ffmpeg_libvorbis_ver=1.3.7
   ffmpeg_libtheora_ver=1.1.1 # 2009 October 1
   ffmpeg_libbs2b_ver=3.1.0
   ffmpeg_kvazaar_ver=1.3.0 # Jul 9, 2019
   ffmpeg_libilbc_ver=2.0.2
   ffmpeg_openh264_ver=2.0.0 # May 8, 2019
   ffmpeg_openjpeg_ver=2.3.1 # Apr 2, 2019
   ffmpeg_wavpack_ver=5.2.0  # December 15, 2019
   ffmpeg_twolame_ver=0.4.0  # 2019-10-11
   ffmpeg_opus_ver=1.3.1     # Apr 12, 2019
   ffmpeg_speex_ver=1.2.0    # December 7, 2016
   ffmpeg_opencoreamr_ver=0.1.5 # 2017-03-16
   ffmpeg_voamrwbenc_ver=0.1.3  # 2013-07-27
   ffmpeg_libwebp_ver=1.0.3      # Sat Jul 13 07:23:45 2019
   ffmpeg_libvpx_ver=1.8.2   # Dec 19, 2019
  ;;
esac

check_modules
check_nasm ${ffmpeg_nasm_ver}
check_libaom ${ffmpeg_libaom_ver}
check_libass ${ffmpeg_libass_ver}
check_lame ${ffmpeg_lame_ver}
check_xvidcore ${ffmpeg_xvidcore_ver}
check_libbluray ${ffmpeg_libbluray_ver}
check_fdkaac ${ffmpeg_fdkaac_ver}
check_x264 ${ffmpeg_x264_ver}
check_x265 ${ffmpeg_x265_ver}
check_libogg ${ffmpeg_libogg_ver}
check_libvorbis ${ffmpeg_libvorbis_ver}
check_libtheora ${ffmpeg_libtheora_ver}
check_libbs2b ${ffmpeg_libbs2b_ver}
check_kvazaar ${ffmpeg_kvazaar_ver}
check_libilbc ${ffmpeg_libilbc_ver}
check_openh264 ${ffmpeg_openh264_ver}
check_openjpeg ${ffmpeg_openjpeg_ver}
check_wavpack ${ffmpeg_wavpack_ver}
check_twolame ${ffmpeg_twolame_ver}
check_opus ${ffmpeg_opus_ver}
check_speex ${ffmpeg_speex_ver}
check_opencoreamr ${ffmpeg_opencoreamr_ver}
check_voamrwbenc ${ffmpeg_voamrwbenc_ver}
check_libwebp ${ffmpeg_libwebp_ver}
check_libvpx ${ffmpeg_libvpx_ver}

module purge
module load nasm/${ffmpeg_nasm_ver} \
            libaom/${ffmpeg_libaom_ver} \
            libass/${ffmpeg_libass_ver} \
            lame/${ffmpeg_lame_ver} \
            xvidcore/${ffmpeg_xvidcore_ver} \
            libbluray/${ffmpeg_libbluray_ver} \
            fdk-aac/${ffmpeg_fdkaac_ver} \
            x264/${ffmpeg_x264_ver} \
            x265/${ffmpeg_x265_ver} \
            libogg/${ffmpeg_libogg_ver} \
            libvorbis/${ffmpeg_libvorbis_ver} \
            libtheora/${ffmpeg_libtheora_ver} \
            libbs2b/${ffmpeg_libbs2b_ver} \
            kvazaar/${ffmpeg_kvazaar_ver} \
            libilbc/${ffmpeg_libilbc_ver} \
            openh264/${ffmpeg_openh264_ver} \
            openjpeg/${ffmpeg_openjpeg_ver} \
            wavpack/${ffmpeg_wavpack_ver} \
            twolame/${ffmpeg_twolame_ver} \
            opus/${ffmpeg_opus_ver} \
            speex/${ffmpeg_speex_ver} \
            opencore-amr/${ffmpeg_opencoreamr_ver} \
            vo-amrwbenc/${ffmpeg_voamrwbenc_ver} \
            libwebp/${ffmpeg_libwebp_ver} \
            libvpx/${ffmpeg_libvpx_ver}
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
