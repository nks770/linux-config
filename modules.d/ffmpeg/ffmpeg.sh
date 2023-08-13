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
# First check if environment module exists
if [ ! -f ${MODULEPATH}/ffmpeg/${1} ] ; then
  return 1
fi
# If it does, then also verify the binary is there as expected
if [ -f "${opt}/ffmpeg-${1}/bin/ffmpeg" ] ; then
  return 0
else
  return 1
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

echo "Installing ffmpeg ${ffmpeg_v}..."
ffmpeg_srcdir=ffmpeg-${ffmpeg_v}
ffmpeg_depdir=${opt}/ffmpeg-dep-${ffmpeg_v}

case ${1} in
  4.2.2) # 2019-12-31 23:58
    # Compression libraries
    ffmpeg_zstd_ver=1.4.4                 # 2019-11-05
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15
    ffmpeg_libjpegturbo_ver=2.0.4         # 2019-12-31
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03
    ffmpeg_libwebp_ver=1.0.3              # 2019-07-13
    ffmpeg_lcms2_ver=2.9                  # 2017-11-25
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.34             # 2019-06-14
    ffmpeg_expat_ver=2.2.9                # 2019-09-25
    ffmpeg_icu_ver=65.1                   # 2019-10-03
    ffmpeg_graphite2_ver=1.3.13           # 2018-12-20
    ffmpeg_freetype_ver=2.10.1            # 2019-07-01
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09
    ffmpeg_harfbuzz_ver=2.6.4             # 2019-10-29
#   ffmpeg_nasm_ver=2.14.02               # 2018-12-26
#   ffmpeg_libaom_ver=1.0.0-errata1-avif  # 2019-12-12
#   ffmpeg_libass_ver=0.14.0              # 2017-10-31
#   ffmpeg_lame_ver=3.100                 # 2017-10-13
#   ffmpeg_xvidcore_ver=1.3.6             # 2019-12-08
#   ffmpeg_libbluray_ver=1.1.2            # 2019-06-07
#   ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08
#   ffmpeg_x264_ver=20191125              # 2019-11-25
#   ffmpeg_x265_ver=3.2.1                 # 2019-10-22
#   ffmpeg_libogg_ver=1.3.5               # 2021-06-03
#   ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04
#   ffmpeg_libtheora_ver=1.1.1            # 2009-10-01
#   ffmpeg_libbs2b_ver=3.1.0-flac1.3.3    # 2009-06-04 / 2019-08-04
#   ffmpeg_kvazaar_ver=1.3.0              # 2019-07-09
#   ffmpeg_libilbc_ver=2.0.2              # 2014-12-14
#   ffmpeg_openh264_ver=2.0.0             # 2019-05-08
#   ffmpeg_wavpack_ver=5.2.0              # 2019-12-15
#   ffmpeg_twolame_ver=0.4.0              # 2019-10-11
#   ffmpeg_opus_ver=1.3.1                 # 2019-04-12
#   ffmpeg_speex_ver=1.2.0    # December 7, 2016
#   ffmpeg_opencoreamr_ver=0.1.5 # 2017-03-16
#   ffmpeg_voamrwbenc_ver=0.1.3  # 2013-07-27
#   ffmpeg_libvpx_ver=1.8.2   # Dec 19, 2019
  ;;
#  5.1.2) # 2022-09-25
#   ffmpeg_nasm_ver=2.15.05   # 2020-08-28
#   ffmpeg_libaom_ver=3.5.0   # 2022-09-21
#   ffmpeg_libass_ver=0.16.0  # 2022-05-12
#   ffmpeg_lame_ver=3.100     # 2017-10-13
#   ffmpeg_xvidcore_ver=1.3.7 # 2019-12-28
#   ffmpeg_libbluray_ver=1.3.2 # 2022-07-30
#   ffmpeg_fdkaac_ver=2.0.2   # 2021-04-28
#   ffmpeg_x264_ver=20220601  # Latest stable, 2022-06-01 baee400fa9ced6f5481a728138fed6e867b0ff7f
#   ffmpeg_x265_ver=3.4       # 2020-05-29
#   ffmpeg_libogg_ver=1.3.4
#   ffmpeg_libvorbis_ver=1.3.7
#   ffmpeg_libtheora_ver=1.1.1 # 2009-10-01
#   ffmpeg_libbs2b_ver=3.1.0   # 2009-06-05
#   ffmpeg_kvazaar_ver=2.1.0   # 2021-10-13
#   ffmpeg_libilbc_ver=3.0.4   # 2020-12-31
#   ffmpeg_openh264_ver=2.3.1  # 2022-09-20
#   ffmpeg_openjpeg_ver=2.5.0  # 2022-05-13
#   ffmpeg_wavpack_ver=5.5.0   # 2022-07-08
#   ffmpeg_twolame_ver=0.4.0   # 2019-10-11
#   ffmpeg_opus_ver=1.3.1      # Apr 12, 2019
#   ffmpeg_speex_ver=1.2.1     # 2022-06-16
#   ffmpeg_opencoreamr_ver=0.1.6 # 2022-08-01
#   ffmpeg_voamrwbenc_ver=0.1.3  # 2013-07-27
#   ffmpeg_libwebp_ver=1.2.4   # 2022-08-06
#   ffmpeg_libvpx_ver=1.12.0   # 2022-06-28
#  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  ffmpeg_utillinux_ver=${global_utillinux}
fi

ffmpeg_zlib_ver=${global_zlib}
ffmpeg_xz_ver=${global_xz}
ffmpeg_bzip2_ver=${global_bzip2}

check_modules
# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/ffmpeg-dep
cat << eof > ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Loads ffmpeg-${ffmpeg_v} dependencies into your environment"
}

set VER ${ffmpeg_v}
set PKG ${opt}/ffmpeg-dep-\$VER

module-whatis   "Loads ffmpeg-dep-${ffmpeg_v}"
conflict ffmpeg-dep
module load libpng/${ffmpeg_libpng_ver}
module load libjpeg-turbo/${ffmpeg_libjpegturbo_ver}
module load zlib/${ffmpeg_zlib_ver}
module load xz/${ffmpeg_xz_ver}
module load jbigkit/${ffmpeg_jbigkit_ver}
module load zstd/${ffmpeg_zstd_ver}
module load bzip2/${ffmpeg_bzip2_ver}
module load expat/${ffmpeg_expat_ver}
module load util-linux/${ffmpeg_utillinux_ver}
module load icu/${ffmpeg_icu_ver}
prereq libpng/${ffmpeg_libpng_ver}
prereq libjpeg-turbo/${ffmpeg_libjpegturbo_ver}
prereq zlib/${ffmpeg_zlib_ver}
prereq xz/${ffmpeg_xz_ver}
prereq jbigkit/${ffmpeg_jbigkit_ver}
prereq zstd/${ffmpeg_zstd_ver}
prereq bzip2/${ffmpeg_bzip2_ver}
prereq expat/${ffmpeg_expat_ver}
prereq util-linux/${ffmpeg_utillinux_ver}
prereq icu/${ffmpeg_icu_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

# Image processing libraries
check_zstd    ${ffmpeg_zstd_ver}
check_jbigkit ${ffmpeg_jbigkit_ver}
check_giflib  ${ffmpeg_giflib_ver}
check_libpng  ${ffmpeg_libpng_ver}
check_libjpegturbo ${ffmpeg_libjpegturbo_ver}
check_expat ${ffmpeg_expat_ver}
check_utillinux ${ffmpeg_utillinux_ver}
check_icu ${ffmpeg_icu_ver}
ff_check_tiff ${ffmpeg_tiff_ver} ${ffmpeg_depdir} ${ffmpeg_v} ${ffmpeg_libwebp_ver}
ff_check_libwebp ${ffmpeg_libwebp_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_lcms2 ${ffmpeg_lcms2_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_openjpeg ${ffmpeg_openjpeg_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_freetype ${ffmpeg_freetype_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_fontconfig ${ffmpeg_fontconfig_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_graphite2 ${ffmpeg_graphite2_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_harfbuzz ${ffmpeg_harfbuzz_ver} ${ffmpeg_depdir} ${ffmpeg_v}
#check_nasm ${ffmpeg_nasm_ver}
#check_libaom ${ffmpeg_libaom_ver}
#check_libass ${ffmpeg_libass_ver}
#check_lame ${ffmpeg_lame_ver}
#check_xvidcore ${ffmpeg_xvidcore_ver}
#check_libbluray ${ffmpeg_libbluray_ver}
#check_fdkaac ${ffmpeg_fdkaac_ver}
#check_x264 ${ffmpeg_x264_ver}
#check_x265 ${ffmpeg_x265_ver}
#check_libogg ${ffmpeg_libogg_ver}
#check_libvorbis ${ffmpeg_libvorbis_ver}
#check_libtheora ${ffmpeg_libtheora_ver}
#check_libbs2b ${ffmpeg_libbs2b_ver}
#check_kvazaar ${ffmpeg_kvazaar_ver}
#check_libilbc ${ffmpeg_libilbc_ver}
#check_openh264 ${ffmpeg_openh264_ver}
#check_openjpeg ${ffmpeg_openjpeg_ver}
#check_wavpack ${ffmpeg_wavpack_ver}
#check_twolame ${ffmpeg_twolame_ver}
#check_opus ${ffmpeg_opus_ver}
#check_speex ${ffmpeg_speex_ver}
#check_opencoreamr ${ffmpeg_opencoreamr_ver}
#check_voamrwbenc ${ffmpeg_voamrwbenc_ver}
#check_libwebp ${ffmpeg_libwebp_ver}
#check_libvpx ${ffmpeg_libvpx_ver}

exit 0

downloadPackage ffmpeg-${ffmpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${ffmpeg_srcdir} ] ; then
  rm -rf ${tmp}/${ffmpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/ffmpeg-${ffmpeg_v}.tar.gz
cd ${tmp}/${ffmpeg_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load jbigkit/${ffmpeg_jbigkit_ver}
module load giflib/${ffmpeg_giflib_ver}
module load libpng/${ffmpeg_libpng_ver}
module load libjpeg-turbo/${ffmpeg_libjpegturbo_ver}
#module load nasm/${ffmpeg_nasm_ver} \
#            libaom/${ffmpeg_libaom_ver} \
#            libass/${ffmpeg_libass_ver} \
#            lame/${ffmpeg_lame_ver} \
#            xvidcore/${ffmpeg_xvidcore_ver} \
#            libbluray/${ffmpeg_libbluray_ver} \
#            fdk-aac/${ffmpeg_fdkaac_ver} \
#            x264/${ffmpeg_x264_ver} \
#            x265/${ffmpeg_x265_ver} \
#            libogg/${ffmpeg_libogg_ver} \
#            libvorbis/${ffmpeg_libvorbis_ver} \
#            libtheora/${ffmpeg_libtheora_ver} \
#            libbs2b/${ffmpeg_libbs2b_ver} \
#            kvazaar/${ffmpeg_kvazaar_ver} \
#            libilbc/${ffmpeg_libilbc_ver} \
#            openh264/${ffmpeg_openh264_ver} \
#            openjpeg/${ffmpeg_openjpeg_ver} \
#            wavpack/${ffmpeg_wavpack_ver} \
#            twolame/${ffmpeg_twolame_ver} \
#            opus/${ffmpeg_opus_ver} \
#            speex/${ffmpeg_speex_ver} \
#            opencore-amr/${ffmpeg_opencoreamr_ver} \
#            vo-amrwbenc/${ffmpeg_voamrwbenc_ver} \
#            libwebp/${ffmpeg_libwebp_ver} \
#            libvpx/${ffmpeg_libvpx_ver}
#
if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo '>> Press enter to run configure command...'
  echo ''
  read k
fi
#
#./configure --prefix=${opt}/ffmpeg-${ffmpeg_v} \
#            --enable-gpl \
#            --enable-version3 \
#            --enable-nonfree \
#            --enable-shared \
#            --enable-openssl \
#            --enable-libaom \
#            --enable-libfontconfig \
#            --enable-libfreetype \
#            --enable-libfribidi \
#            --enable-libxml2 \
#            --enable-libfdk-aac \
#            --enable-libbluray \
#            --enable-libass \
#            --enable-libmp3lame \
#            --enable-libxvid \
#            --enable-libvorbis \
#            --enable-libtheora \
#            --enable-libx264 \
#            --enable-libx265 \
#            --enable-libbs2b \
#            --enable-libkvazaar \
#            --enable-libilbc \
#            --enable-libopencore-amrnb \
#            --enable-libopencore-amrwb \
#            --enable-libopenh264 \
#            --enable-libopus \
#            --enable-libopenjpeg \
#            --enable-libspeex \
#            --enable-libvo-amrwbenc \
#            --enable-libwavpack \
#            --enable-libwebp \
#            --enable-libvpx \
#            --enable-libtwolame \
#            --extra-cflags="-I${opt}/lame-${ffmpeg_lame_ver}/include -I${opt}/libtheora-${ffmpeg_libtheora_ver}/include -I${opt}/libogg-${ffmpeg_libogg_ver}/include -I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include -I${opt}/libilbc-${ffmpeg_libilbc_ver}/include -I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include -I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include -I${opt}/wavpack-${ffmpeg_wavpack_ver}/include -I${opt}/twolame-${ffmpeg_twolame_ver}/include" \
#            --extra-ldflags="-L${opt}/lame-${ffmpeg_lame_ver}/lib -L${opt}/libtheora-${ffmpeg_libtheora_ver}/lib -L${opt}/libogg-${ffmpeg_libogg_ver}/lib -L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib -L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib64 -L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib -L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib -L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib -L${opt}/twolame-${ffmpeg_twolame_ver}/lib"
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Configure complete'
#  read k
#fi
#
#make -j ${ncpu}
#
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Build complete'
#  read k
#fi
#
#if [ ${run_tests} -gt 0 ] ; then
#  make test
#  echo ''
#  echo '>> Tests complete'
#  read k
#fi
#
#make install
#
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Install complete'
#  read k
#fi
#
## Create the environment module
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
#mkdir -pv ${MODULEPATH}/ffmpeg
#cat << eof > ${MODULEPATH}/ffmpeg/${ffmpeg_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts ffmpeg-${ffmpeg_v} into your environment"
#}
#
#set VER ${ffmpeg_v}
#set PKG ${opt}/ffmpeg-\$VER
#
#module-whatis   "Loads ffmpeg-${ffmpeg_v}"
#conflict ffmpeg
#module load libaom/${ffmpeg_libaom_ver}
#module load libass/${ffmpeg_libass_ver}
#module load lame/${ffmpeg_lame_ver}
#module load xvidcore/${ffmpeg_xvidcore_ver}
#module load libbluray/${ffmpeg_libbluray_ver}
#module load fdk-aac/${ffmpeg_fdkaac_ver}
#module load x264/${ffmpeg_x264_ver}
#module load x265/${ffmpeg_x265_ver}
#module load libogg/${ffmpeg_libogg_ver}
#module load libvorbis/${ffmpeg_libvorbis_ver}
#module load libtheora/${ffmpeg_libtheora_ver}
#module load libbs2b/${ffmpeg_libbs2b_ver}
#module load kvazaar/${ffmpeg_kvazaar_ver}
#module load libilbc/${ffmpeg_libilbc_ver}
#module load openh264/${ffmpeg_openh264_ver}
#module load openjpeg/${ffmpeg_openjpeg_ver}
#module load wavpack/${ffmpeg_wavpack_ver}
#module load twolame/${ffmpeg_twolame_ver}
#module load opus/${ffmpeg_opus_ver}
#module load speex/${ffmpeg_speex_ver}
#module load opencore-amr/${ffmpeg_opencoreamr_ver}
#module load vo-amrwbenc/${ffmpeg_voamrwbenc_ver}
#module load libwebp/${ffmpeg_libwebp_ver}
#module load libvpx/${ffmpeg_libvpx_ver}
#prereq libaom/${ffmpeg_libaom_ver}
#prereq libass/${ffmpeg_libass_ver}
#prereq lame/${ffmpeg_lame_ver}
#prereq xvidcore/${ffmpeg_xvidcore_ver}
#prereq libbluray/${ffmpeg_libbluray_ver}
#prereq fdk-aac/${ffmpeg_fdkaac_ver}
#prereq x264/${ffmpeg_x264_ver}
#prereq x265/${ffmpeg_x265_ver}
#prereq libogg/${ffmpeg_libogg_ver}
#prereq libvorbis/${ffmpeg_libvorbis_ver}
#prereq libtheora/${ffmpeg_libtheora_ver}
#prereq libbs2b/${ffmpeg_libbs2b_ver}
#prereq kvazaar/${ffmpeg_kvazaar_ver}
#prereq libilbc/${ffmpeg_libilbc_ver}
#prereq openh264/${ffmpeg_openh264_ver}
#prereq openjpeg/${ffmpeg_openjpeg_ver}
#prereq wavpack/${ffmpeg_wavpack_ver}
#prereq twolame/${ffmpeg_twolame_ver}
#prereq opus/${ffmpeg_opus_ver}
#prereq speex/${ffmpeg_speex_ver}
#prereq opencore-amr/${ffmpeg_opencoreamr_ver}
#prereq vo-amrwbenc/${ffmpeg_voamrwbenc_ver}
#prereq libwebp/${ffmpeg_libwebp_ver}
#prereq libvpx/${ffmpeg_libvpx_ver}
#
#prepend-path CPATH \$PKG/include
#prepend-path C_INCLUDE_PATH \$PKG/include
#prepend-path CPLUS_INCLUDE_PATH \$PKG/include
#prepend-path LD_LIBRARY_PATH \$PKG/lib
#prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
#prepend-path PATH \$PKG/bin
#prepend-path MANPATH \$PKG/share/man
#
#eof
#
#cd ${root}
#rm -rf ${tmp}/${ffmpeg_srcdir}
#
}
