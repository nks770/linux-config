#!/bin/bash

# Functions for detecting and building FFmpeg
echo 'Loading ffmpeg...'

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
   nasm_ver=2.14.02               # 2018-12-26
   libaom_ver=1.0.0-errata1-avif  # 2019-12-12
   libass_ver=0.14.0              # 2017-10-31
   ffmpeg_lame_ver=3.100          # 2017-10-13
   ffmpeg_xvidcore_ver=1.3.6      # 2019-12-08
   ffmpeg_libbluray_ver=1.1.2     # 2019-06-07
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
  5.1.2) # 2022-09-25
   nasm_ver=2.15.05   # 2020-08-28
   libaom_ver=3.5.0   # 2022-09-21
   libass_ver=0.16.0  # 2022-05-12
   ffmpeg_lame_ver=3.100     # 2017-10-13
   ffmpeg_xvidcore_ver=1.3.7 # 2019-12-28
   ffmpeg_libbluray_ver=1.3.2 # 2022-07-30
   ffmpeg_fdkaac_ver=2.0.2   # 2021-04-28
   ffmpeg_x264_ver=20220601  # Latest stable, 2022-06-01 baee400fa9ced6f5481a728138fed6e867b0ff7f
   ffmpeg_x265_ver=3.4       # 2020-05-29
   ffmpeg_libogg_ver=1.3.4
   ffmpeg_libvorbis_ver=1.3.7
   ffmpeg_libtheora_ver=1.1.1 # 2009-10-01
   ffmpeg_libbs2b_ver=3.1.0   # 2009-06-05
   ffmpeg_kvazaar_ver=2.1.0   # 2021-10-13
   ffmpeg_libilbc_ver=3.0.4   # 2020-12-31
   ffmpeg_openh264_ver=2.3.1  # 2022-09-20
   ffmpeg_openjpeg_ver=2.5.0  # 2022-05-13
   ffmpeg_wavpack_ver=5.5.0   # 2022-07-08
   ffmpeg_twolame_ver=0.4.0   # 2019-10-11
   ffmpeg_opus_ver=1.3.1      # Apr 12, 2019
   ffmpeg_speex_ver=1.2.1     # 2022-06-16
   ffmpeg_opencoreamr_ver=0.1.6 # 2022-08-01
   ffmpeg_voamrwbenc_ver=0.1.3  # 2013-07-27
   ffmpeg_libwebp_ver=1.2.4   # 2022-08-06
   ffmpeg_libvpx_ver=1.12.0   # 2022-06-28
  ;;
esac

check_modules
check_nasm ${nasm_ver}
check_libaom ${libaom_ver}
check_libass ${libass_ver}
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
module load nasm/${nasm_ver} \
            libaom/${libaom_ver} \
            libass/${libass_ver} \
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

downloadPackage ffmpeg-${ffmpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${ffmpeg_srcdir} ] ; then
  rm -rf ${tmp}/${ffmpeg_srcdir}
fi

tar xvfz ${pkg}/ffmpeg-${ffmpeg_v}.tar.gz
cd ${tmp}/${ffmpeg_srcdir}

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo '>> Press enter to run configure command...'
  echo ''
  read k
fi

./configure --prefix=${opt}/ffmpeg-${ffmpeg_v} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-libaom \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libxml2 \
            --enable-libfdk-aac \
            --enable-libbluray \
            --enable-libass \
            --enable-libmp3lame \
            --enable-libxvid \
            --enable-libvorbis \
            --enable-libtheora \
            --enable-libx264 \
            --enable-libx265 \
            --enable-libbs2b \
            --enable-libkvazaar \
            --enable-libilbc \
            --enable-libopencore-amrnb \
            --enable-libopencore-amrwb \
            --enable-libopenh264 \
            --enable-libopus \
            --enable-libopenjpeg \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --extra-cflags="-I${opt}/lame-${ffmpeg_lame_ver}/include -I${opt}/libtheora-${ffmpeg_libtheora_ver}/include -I${opt}/libogg-${ffmpeg_libogg_ver}/include -I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include -I${opt}/libilbc-${ffmpeg_libilbc_ver}/include -I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include -I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include -I${opt}/wavpack-${ffmpeg_wavpack_ver}/include -I${opt}/twolame-${ffmpeg_twolame_ver}/include" \
            --extra-ldflags="-L${opt}/lame-${ffmpeg_lame_ver}/lib -L${opt}/libtheora-${ffmpeg_libtheora_ver}/lib -L${opt}/libogg-${ffmpeg_libogg_ver}/lib -L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib -L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib64 -L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib -L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib -L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib -L${opt}/twolame-${ffmpeg_twolame_ver}/lib"

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
  make test
  echo ''
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
mkdir -pv ${MODULEPATH}/ffmpeg
cat << eof > ${MODULEPATH}/ffmpeg/${ffmpeg_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts ffmpeg-${ffmpeg_v} into your environment"
}

set VER ${ffmpeg_v}
set PKG ${opt}/ffmpeg-\$VER

module-whatis   "Loads ffmpeg-${ffmpeg_v}"
conflict ffmpeg
module load libaom/${libaom_ver}
module load libass/${libass_ver}
module load lame/${ffmpeg_lame_ver}
module load xvidcore/${ffmpeg_xvidcore_ver}
module load libbluray/${ffmpeg_libbluray_ver}
module load fdk-aac/${ffmpeg_fdkaac_ver}
module load x264/${ffmpeg_x264_ver}
module load x265/${ffmpeg_x265_ver}
module load libogg/${ffmpeg_libogg_ver}
module load libvorbis/${ffmpeg_libvorbis_ver}
module load libtheora/${ffmpeg_libtheora_ver}
module load libbs2b/${ffmpeg_libbs2b_ver}
module load kvazaar/${ffmpeg_kvazaar_ver}
module load libilbc/${ffmpeg_libilbc_ver}
module load openh264/${ffmpeg_openh264_ver}
module load openjpeg/${ffmpeg_openjpeg_ver}
module load wavpack/${ffmpeg_wavpack_ver}
module load twolame/${ffmpeg_twolame_ver}
module load opus/${ffmpeg_opus_ver}
module load speex/${ffmpeg_speex_ver}
module load opencore-amr/${ffmpeg_opencoreamr_ver}
module load vo-amrwbenc/${ffmpeg_voamrwbenc_ver}
module load libwebp/${ffmpeg_libwebp_ver}
module load libvpx/${ffmpeg_libvpx_ver}
prereq libaom/${libaom_ver}
prereq libass/${libass_ver}
prereq lame/${ffmpeg_lame_ver}
prereq xvidcore/${ffmpeg_xvidcore_ver}
prereq libbluray/${ffmpeg_libbluray_ver}
prereq fdk-aac/${ffmpeg_fdkaac_ver}
prereq x264/${ffmpeg_x264_ver}
prereq x265/${ffmpeg_x265_ver}
prereq libogg/${ffmpeg_libogg_ver}
prereq libvorbis/${ffmpeg_libvorbis_ver}
prereq libtheora/${ffmpeg_libtheora_ver}
prereq libbs2b/${ffmpeg_libbs2b_ver}
prereq kvazaar/${ffmpeg_kvazaar_ver}
prereq libilbc/${ffmpeg_libilbc_ver}
prereq openh264/${ffmpeg_openh264_ver}
prereq openjpeg/${ffmpeg_openjpeg_ver}
prereq wavpack/${ffmpeg_wavpack_ver}
prereq twolame/${ffmpeg_twolame_ver}
prereq opus/${ffmpeg_opus_ver}
prereq speex/${ffmpeg_speex_ver}
prereq opencore-amr/${ffmpeg_opencoreamr_ver}
prereq vo-amrwbenc/${ffmpeg_voamrwbenc_ver}
prereq libwebp/${ffmpeg_libwebp_ver}
prereq libvpx/${ffmpeg_libvpx_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${ffmpeg_srcdir}

}
