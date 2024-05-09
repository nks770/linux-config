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
  echo "ERROR: No FFmpeg version specified!"
  exit 2
fi

ffmpeg_libdeflate_ver=0

case ${ffmpeg_v} in
  2.8.16) # 2020-04-28
    # Compression libraries
    ffmpeg_zstd_ver=1.4.4                 # 2019-11-05 - next May 22, 2020
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 11/14/2023
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 11/14/2023
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16
    ffmpeg_libjpegturbo_ver=2.0.4         # 2019-12-31 - next Jun 18, 2020
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-Dec-19
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next Sat Jan 30 03:08:45 2021
    ffmpeg_lcms2_ver=2.9                  # 2017-11-25 - next May 26, 2020
    ffmpeg_openjpeg_ver=1.5.2             # 2014-03-28 - maximum version; ffmpeg 2.8 requires openjpeg < 2.0
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.35.1           # 2020-01-31 - next 2020-05-20
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next Oct 3, 2020
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 11/23/2023
    ffmpeg_freetype_ver=2.10.1            # 2019-07-01 - next 2020-05-09
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27
    ffmpeg_harfbuzz_ver=2.6.5             # 2020-04-17 - next 2020-05-11
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18
    ffmpeg_fribidi_ver=1.0.9              # 2020-03-02 - next 2020-07-05
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next Oct 26, 2020
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26 - next 2020-06-27
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16 - next 2020-07-04
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 11/15/2023
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next June 16, 2022
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next Apr 20, 2023
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next Dec 17, 2020
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 11/15/2023
    ffmpeg_fdkaac_ver=0.1.6               # 2018-03-06 - maximum version; ffmpeg 2.8 requires fdk-aac < 2.0.0
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 20 Feb 2022
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next Aug 15, 2020
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 11/15/2023
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 11/15/2023
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 11/15/2023
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 11/15/2023
    # Video codecs
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 11/15/2023
    ffmpeg_x264_ver=20200425              # 2020-04-25 - next 2020-05-24
    ffmpeg_x265_ver=3.3                   # 2020-02-17 - next 2020-05-29
    ffmpeg_kvazaar_ver=0.6.1              # 2015-09-16 - maximum version; ffmpeg 2.8 requires kvazaar < 0.7.0
    ffmpeg_openh264_ver=1.5.0             # 2015-10-26 - maximum version; ffmpeg 2.8 requires openh264 < 1.6.0
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next Jul 30, 2020
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next May 30, 2022
  ;;
  2.8.17) # 2020-07-07
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 11/14/2023
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 11/14/2023
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16 (2.0.6)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-Dec-19
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next Sat Jan 30 03:08:45 2021
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06 (2.12)
    ffmpeg_openjpeg_ver=1.5.2             # 2014-03-28 - maximum version; ffmpeg 2.8 requires openjpeg < 2.0
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next Oct 3, 2020
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 11/23/2023
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25 (2.7.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18
    ffmpeg_fribidi_ver=1.0.10             # 2020-07-05 - next 2021-09-23 (1.0.11)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next Oct 26, 2020
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26 - maximum version; this version of ffmpeg generates x86inc.asm errors when compiled with nasm 2.15.x
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 11/15/2023
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next June 16, 2022
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next Apr 20, 2023
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next Dec 17, 2020
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 11/15/2023
    ffmpeg_fdkaac_ver=0.1.6               # 2018-03-06 - maximum version; ffmpeg 2.8 requires fdk-aac < 2.0.0
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 20 Feb 2022
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next Aug 15, 2020
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 11/15/2023
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 11/15/2023
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 11/15/2023
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 11/15/2023
    # Video codecs
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 11/15/2023
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=0.6.1              # 2015-09-16 - maximum version; ffmpeg 2.8 requires kvazaar < 0.7.0
    ffmpeg_openh264_ver=1.5.0             # 2015-10-26 - maximum version; ffmpeg 2.8 requires openh264 < 1.6.0
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next Jul 30, 2020
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next May 30, 2022
  ;;
  3.2.15) # 2020-07-02 20:22
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16 (2.0.6)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-12-19 (4.2.0)
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next 2021-01-30 (1.2.0)
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06 (2.12)
    ffmpeg_openjpeg_ver=2.1.2             # 2016-09-28 - maximum version; ffmpeg 3.2 requires openjpeg < 2.2.0
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next 2020-10-03 (2.2.10)
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27 (2.13.93)
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25 (2.7.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.9              # 2020-03-02 - next 2020-07-05 (1.0.10)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next 2020-10-26 (0.15.0)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26 - maximum version; this version of ffmpeg generates x86inc.asm errors when compiled with nasm 2.15.x
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16 - next 2020-07-04 (1.3.7)
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next 2020-12-17 (3.0.0)
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=0.1.6               # 2018-03-06 - maximum version; ffmpeg 3.2 requires fdk-aac < 2.0.0
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next 2020-08-15 (1.0.29)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next 2020-07-30 (1.9.0)
    ffmpeg_vidstab_ver=1.1.1              # 2020-05-30 - latest as of 2024-02-11
  ;;
  3.4.8) # 2020-07-04
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16 (2.0.6)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-12-19 (4.2.0)
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next 2021-01-30 (1.2.0)
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06 (2.12)
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next 2020-12-28 (2.4.0)
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next 2020-10-03 (2.2.10)
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27 (2.13.93)
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25 (2.7.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.9              # 2020-03-02 - next 2020-07-05 (1.0.10)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next 2020-10-26 (0.15.0)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.15.02               # 2020-07-01 - next 2020-07-17 (2.15.03)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next 2020-12-17 (3.0.0)
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=0.1.6               # 2018-03-06 - maximum version; ffmpeg 3.4 requires fdk-aac < 2.0.0
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next 2020-08-15 (1.0.29)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next 2020-07-30 (1.9.0)
    ffmpeg_vidstab_ver=1.1.1              # 2020-05-30 - latest as of 2024-02-11
  ;;
  4.0.6) # 2020-07-03
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-06-22 - next 2020-12-16
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 11/14/2023
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 11/14/2023
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-Dec-19
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next Sat Jan 30 03:08:45 2021
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next Dec 28, 2020
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next Oct 3, 2020
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-04-10
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-10
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18
    ffmpeg_fribidi_ver=1.0.9              # 2020-03-02 - next 2020-07-05
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next Oct 26, 2020
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24
    ffmpeg_nasm_ver=2.15.02               # 2020-07-01 - next 2020-07-17
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16 - next 2020-07-04
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 11/15/2023
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next June 16, 2022
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next Apr 20, 2023
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next Dec 17, 2020
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 11/15/2023
    ffmpeg_fdkaac_ver=0.1.6               # 2018-03-06 - maximum version; ffmpeg 4.0 requires fdk-aac < 2.0.0
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 20 Feb 2022
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next Aug 15, 2020
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 11/15/2023
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 11/15/2023
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 11/15/2023
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 11/15/2023
    # Video codecs
    ffmpeg_libaom_ver=2.0.0               # 2020-05-18 - next 2020-11-25
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 11/15/2023
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - latest as of 2024-04-10
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next Jul 30, 2020
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next May 30, 2022
  ;;
  4.1.5) # 2020-01-07
    # Compression libraries
    ffmpeg_zstd_ver=1.4.4                 # 2019-11-05 - next May 22, 2020
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 11/14/2023
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 11/14/2023
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16
    ffmpeg_libjpegturbo_ver=2.0.4         # 2019-12-31 - next Jun 18, 2020
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-Dec-19
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next Sat Jan 30 03:08:45 2021
    ffmpeg_lcms2_ver=2.9                  # 2017-11-25 - next May 26, 2020
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next Dec 28, 2020
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.34             # 2019-06-14 - next Jan 21, 2020
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next Oct 3, 2020
    ffmpeg_icu_ver=65.1                   # 2019-10-03 - next 2020-03-11
    ffmpeg_graphite2_ver=1.3.13           # 2018-12-20 - next Mar 31, 2020
    ffmpeg_freetype_ver=2.10.1            # 2019-07-01 - next 2020-05-09
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27
    ffmpeg_harfbuzz_ver=2.6.4             # 2019-10-29 - next Apr 17, 2020
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23
    ffmpeg_pixman_ver=0.38.4              # 2019-04-10 - next 2020-04-19
    ffmpeg_fribidi_ver=1.0.8              # 2019-12-13 - next Mar 2, 2020
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next Oct 26, 2020
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13
    ffmpeg_libbluray_ver=1.1.2            # 2019-06-07 - next 2020-03-22
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26 - next 2020-06-27
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16 - next 2020-07-04
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 11/15/2023
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next June 16, 2022
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next Apr 20, 2023
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next Dec 17, 2020
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 11/15/2023
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next Apr 28, 2021
    ffmpeg_wavpack_ver=5.2.0              # 2019-12-15 - next April 14, 2020
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 20 Feb 2022
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next Aug 15, 2020
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 11/15/2023
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 11/15/2023 
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 11/15/2023
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 11/15/2023
    # Video codecs
    ffmpeg_libaom_ver=1.0.0-errata1-avif  # 2019-12-12 - next May 18 17:03:09 2020
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 11/15/2023
    ffmpeg_x264_ver=20191125              # 2019-11-25 - next 2020-02-29
    ffmpeg_x265_ver=3.2.1                 # 2019-10-22 - next Feb 17, 2020
    ffmpeg_kvazaar_ver=1.3.0              # 2019-07-09 - next Apr 21, 2020
    ffmpeg_openh264_ver=2.0.0             # 2019-05-08 - next Mar 3, 2020
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next Jul 30, 2020
    ffmpeg_davs2_ver=1.6                  # 2018-11-15 - next Apr 19, 2020
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 04/08/2024
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next May 30, 2022
  ;;
  4.1.6) # 2020-07-05
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 11/14/2023
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 11/14/2023
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16 (2.0.6)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-Dec-19
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next Sat Jan 30 03:08:45 2021
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06 (2.12)
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next Dec 28, 2020
    # Font rendering libraries and dependencies
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next Oct 3, 2020
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25 (2.7.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.10             # 2020-07-05 - next 2021-09-23 (1.0.11)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next Oct 26, 2020
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.15.02               # 2020-07-01 - next 2020-07-17 (2.15.03)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 11/15/2023
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next June 16, 2022
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next Apr 20, 2023
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next Dec 17, 2020
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 11/15/2023
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next Apr 28, 2021
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 20 Feb 2022
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next Aug 15, 2020
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 11/15/2023
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 11/15/2023
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 11/15/2023
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 11/15/2023
    # Video codecs
    ffmpeg_libaom_ver=2.0.0               # 2020-05-18 - next 2020-11-25 (2.0.1)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 11/15/2023
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next Jul 30, 2020
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-04-11
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 2024-04-08
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next May 30, 2022
  ;;
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
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18
    ffmpeg_utillinux_ver=2.34             # 2019-06-14
    ffmpeg_expat_ver=2.2.9                # 2019-09-25
    ffmpeg_icu_ver=65.1                   # 2019-10-03
    ffmpeg_graphite2_ver=1.3.13           # 2018-12-20
    ffmpeg_freetype_ver=2.10.1            # 2019-07-01
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09
    ffmpeg_harfbuzz_ver=2.6.4             # 2019-10-29
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19
    ffmpeg_pixman_ver=0.38.4              # 2019-04-10
    ffmpeg_fribidi_ver=1.0.8              # 2019-12-13
    ffmpeg_libass_ver=0.14.0              # 2017-10-31
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30
    ffmpeg_libbluray_ver=1.1.2            # 2019-06-07
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01
    ffmpeg_speex_ver=1.2.0                # 2016-12-07
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14
    ffmpeg_lame_ver=3.100                 # 2017-10-13
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08
    ffmpeg_wavpack_ver=5.2.0              # 2019-12-15
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24
    # Video codecs
    ffmpeg_libaom_ver=1.0.0-errata1-avif  # 2019-12-12
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29
    ffmpeg_x264_ver=20191125              # 2019-11-25
    ffmpeg_x265_ver=3.2.1                 # 2019-10-22
    ffmpeg_kvazaar_ver=1.3.0              # 2019-07-09
    ffmpeg_openh264_ver=2.0.0             # 2019-05-08
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19
    ffmpeg_dav1d_ver=0.5.2                # 2019-12-04
    ffmpeg_davs2_ver=1.6                  # 2018-11-15
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 04/08/2024
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30
  ;;
  4.2.3) # 2020-05-21 20:14
    # Compression libraries
    ffmpeg_zstd_ver=1.4.4                 # 2019-11-05 - next 2020-05-22 (1.4.5)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.4         # 2019-12-31 - next 2020-06-23 (2.0.5)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-12-19 (4.2.0)
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next 2021-01-30 (1.2.0)
    ffmpeg_lcms2_ver=2.9                  # 2017-11-25 - next 2020-05-26 (2.10)
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next 2020-12-28 (2.4.0)
    # Font rendering libraries and dependencies
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18 - latest as of 2024-02-09
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next 2020-10-03 (2.2.10)
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27 (2.13.93)
    ffmpeg_harfbuzz_ver=2.6.6             # 2020-05-11 - next 2020-06-03 (2.6.7)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.9              # 2020-03-02 - next 2020-07-05 (1.0.10)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next 2020-10-26 (0.15.0)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26 - next 2020-06-27 (2.15)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16 - next 2020-07-04 (1.3.7)
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next 2020-12-17 (3.0.0)
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next 2021-04-28 (2.0.2)
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next 2020-08-15 (1.0.29)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_libaom_ver=2.0.0               # 2020-05-18 - next 2020-11-25 (2.0.1)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20200425              # 2020-04-25 - next 2020-05-24
    ffmpeg_x265_ver=3.3                   # 2020-02-17 - next 2020-05-29 (3.4)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next 2020-07-30 (1.9.0)
    ffmpeg_dav1d_ver=0.7.0                # 2020-05-20 - next 2020-06-21 (0.7.1)
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-02-09
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 04/08/2024
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next 2022-05-30 (1.1.1)
  ;;
  4.2.4) # 2020-07-09
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16 (2.0.6)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-12-19 (4.2.0)
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next 2021-01-30 (1.2.0)
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06 (2.12)
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next 2020-12-28 (2.4.0)
    # Font rendering libraries and dependencies
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18 - latest as of 2024-02-09
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next 2020-10-03 (2.2.10)
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27 (2.13.93)
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25 (2.7.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.10             # 2020-07-05 - next 2021-09-23 (1.0.11)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next 2020-10-26 (0.15.0)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.15.02               # 2020-07-01 - next 2020-07-17 (2.15.03)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next 2020-12-17 (3.0.0)
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next 2021-04-28 (2.0.2)
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next 2020-08-15 (1.0.29)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_libaom_ver=2.0.0               # 2020-05-18 - next 2020-11-25 (2.0.1)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next 2020-07-30 (1.9.0)
    ffmpeg_dav1d_ver=0.7.1                # 2020-06-20 - next 2020-11-23 (0.8.0)
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-02-09
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 04/08/2024
    ffmpeg_vidstab_ver=1.1.0              # 2017-05-30 - next 2022-05-30 (1.1.1)
  ;;
  4.3) # 2020-06-15 21:54
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.4         # 2019-12-31 - next 2020-06-23 (2.0.5)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-12-19 (4.2.0)
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next 2021-01-30 (1.2.0)
    ffmpeg_lcms2_ver=2.10                 # 2020-05-26 - next 2020-06-16 (2.11)
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next 2020-12-28 (2.4.0)
    # Font rendering libraries and dependencies
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18 - latest as of 2024-02-09
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next 2020-10-03 (2.2.10)
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27 (2.13.93)
    ffmpeg_harfbuzz_ver=2.6.7             # 2020-06-03 - next 2020-06-22 (2.6.8)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.9              # 2020-03-02 - next 2020-07-05 (1.0.10)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next 2020-10-26 (0.15.0)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.14.02               # 2018-12-26 - next 2020-06-27 (2.15)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.6            # 2018-03-16 - next 2020-07-04 (1.3.7)
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next 2020-12-17 (3.0.0)
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next 2021-04-28 (2.0.2)
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next 2020-08-15 (1.0.29)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_libaom_ver=2.0.0               # 2020-05-18 - next 2020-11-25 (2.0.1)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20200615              # 2020-06-15 - next 2020-07-01
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next 2020-07-30 (1.9.0)
    ffmpeg_dav1d_ver=0.7.0                # 2020-05-20 - next 2020-06-21 (0.7.1)
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-02-09
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 04/08/2024
    ffmpeg_vidstab_ver=1.1.1              # 2020-05-30 - latest as of 2024-02-11
  ;;
  4.3.1) # 2020-07-11
    # Compression libraries
    ffmpeg_zstd_ver=1.4.5                 # 2020-05-22 - next 2020-12-16 (1.4.7)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.5         # 2020-06-23 - next 2020-11-16 (2.0.6)
    ffmpeg_tiff_ver=4.1.0                 # 2019-11-03 - next 2020-12-19 (4.2.0)
    ffmpeg_libwebp_ver=1.1.0              # 2020-01-06 - next 2021-01-30 (1.2.0)
    ffmpeg_lcms2_ver=2.11                 # 2020-06-16 - next 2021-02-06 (2.12)
    ffmpeg_openjpeg_ver=2.3.1             # 2019-04-02 - next 2020-12-28 (2.4.0)
    # Font rendering libraries and dependencies
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18 - latest as of 2024-02-09
    ffmpeg_utillinux_ver=2.35.2           # 2020-05-20 - next 2020-07-23 (2.36)
    ffmpeg_expat_ver=2.2.9                # 2019-09-25 - next 2020-10-03 (2.2.10)
    ffmpeg_icu_ver=67.1                   # 2020-04-22 - next 2020-10-27 (68.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.2            # 2020-05-09 - next 2020-10-01 (2.10.3)
    ffmpeg_fontconfig_ver=2.13.92         # 2019-08-09 - next 2020-11-27 (2.13.93)
    ffmpeg_harfbuzz_ver=2.6.8             # 2020-06-22 - next 2020-07-25 (2.7.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.10             # 2020-07-05 - next 2021-09-23 (1.0.11)
    ffmpeg_libass_ver=0.14.0              # 2017-10-31 - next 2020-10-26 (0.15.0)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.0            # 2020-03-22 - next 2020-10-24 (1.2.1)
    ffmpeg_nasm_ver=2.15.02               # 2020-07-01 - next 2020-07-17 (2.15.03)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=2.0.2              # 2014-12-14 - next 2020-12-17 (3.0.0)
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next 2021-04-28 (2.0.2)
    ffmpeg_wavpack_ver=5.3.0              # 2020-04-14 - next 2021-01-10 (5.4.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.28          # 2017-04-02 - next 2020-08-15 (1.0.29)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_libaom_ver=2.0.0               # 2020-05-18 - next 2020-11-25 (2.0.1)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20200702              # 2020-07-02 - next 2020-07-14
    ffmpeg_x265_ver=3.4                   # 2020-05-29 - next 2021-01-22 (3.4.1)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.8.2               # 2019-12-19 - next 2020-07-30 (1.9.0)
    ffmpeg_dav1d_ver=0.7.1                # 2020-06-20 - next 2020-11-23 (0.8.0)
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-02-09
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 04/08/2024
    ffmpeg_vidstab_ver=1.1.1              # 2020-05-30 - latest as of 2024-02-11
  ;;
  4.3.2) # 2021-02-20
    # Compression libraries
    ffmpeg_zstd_ver=1.4.8                 # 2020-12-18 - next 2021-03-03 (1.4.9)
    ffmpeg_libdeflate_ver=1.7             # 2020-11-09 - next 2021-07-15 (1.8)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.6         # 2020-11-16 - next 2021-04-23 (2.1.0)
    ffmpeg_tiff_ver=4.2.0                 # 2020-12-19 - next 2021-04-16 (4.3.0)
    ffmpeg_libwebp_ver=1.2.0              # 2021-01-30 - next 2021-08-13 (1.2.1)
    ffmpeg_lcms2_ver=2.12                 # 2021-02-06 - next 2022-01-29 (2.13)
    ffmpeg_openjpeg_ver=2.4.0             # 2020-12-28 - next 2022-05-13 (2.5.0)
    # Font rendering libraries and dependencies
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18 - latest as of 2024-02-09
    ffmpeg_utillinux_ver=2.36.2           # 2021-02-12 - next 2021-06-01 (2.37)
    ffmpeg_expat_ver=2.2.10               # 2020-10-03 - next 2021-03-24 (2.3.0)
    ffmpeg_icu_ver=68.2                   # 2020-12-16 - next 2021-04-07 (69.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.4            # 2020-10-20 - next 2021-07-19 (2.11.0)
    ffmpeg_fontconfig_ver=2.13.93         # 2020-11-27 - next 2021-06-28 (2.13.94)
    ffmpeg_harfbuzz_ver=2.7.4             # 2020-12-26 - next 2021-03-16 (2.8.0)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.10             # 2020-07-05 - next 2021-09-23 (1.0.11)
    ffmpeg_libass_ver=0.15.0              # 2020-10-26 - next 2021-05-01 (0.15.1)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.2.1            # 2020-10-24 - next 2021-04-05 (1.3.0)
    ffmpeg_nasm_ver=2.15.05               # 2020-08-28 - next 2022-12-20 (2.16)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=3.0.4              # 2020-12-31 - latest as of 2024-04-11
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next 2021-04-28 (2.0.2)
    ffmpeg_wavpack_ver=5.4.0              # 2021-01-10 - next 2022-07-07 (5.5.0)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.31          # 2021-01-24 - next 2022-03-27 (1.1.0)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_libaom_ver=2.0.2               # 2021-02-09 - next 2021-03-23 (3.0.0)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20210211              # 2021-02-11 - next 2021-04-12
    ffmpeg_x265_ver=3.4.1                 # 2021-01-22 - next 2021-03-16 (3.5)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.9.0               # 2020-07-30 - next 2021-03-24 (1.10.0)
    ffmpeg_dav1d_ver=0.8.1                # 2021-01-02 - next 2021-02-21 (0.8.2)
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-02-09
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 2024-04-08
    ffmpeg_vidstab_ver=1.1.1              # 2020-05-30 - latest as of 2024-02-11
  ;;
  4.4) # 2021-04-09
    # Compression libraries
    ffmpeg_zstd_ver=1.4.9                 # 2021-03-03 - next 2021-05-14 (1.5.0)
    ffmpeg_libdeflate_ver=1.7             # 2020-11-09 - next 2021-07-15 (1.8)
    # Image processing libraries
    ffmpeg_jbigkit_ver=2.1                # 2014-04-08 - latest as of 2024-02-09
    ffmpeg_giflib_ver=5.2.1               # 2019-06-24 - latest as of 2024-02-09
    ffmpeg_libpng_ver=1.6.37              # 2019-04-15 - next 2022-09-16 (1.6.38)
    ffmpeg_libjpegturbo_ver=2.0.6         # 2020-11-16 - next 2021-04-23 (2.1.0)
    ffmpeg_tiff_ver=4.2.0                 # 2020-12-19 - next 2021-04-16 (4.3.0)
    ffmpeg_libwebp_ver=1.2.0              # 2021-01-30 - next 2021-08-13 (1.2.1)
    ffmpeg_lcms2_ver=2.12                 # 2021-02-06 - next 2022-01-29 (2.13)
    ffmpeg_openjpeg_ver=2.4.0             # 2020-12-28 - next 2022-05-13 (2.5.0)
    # Font rendering libraries and dependencies
    ffmpeg_aribb24_ver=1.0.3              # 2014-08-18 - latest as of 2024-02-09
    ffmpeg_utillinux_ver=2.36.2           # 2021-02-12 - next 2021-06-01 (2.37)
    ffmpeg_expat_ver=2.3.0                # 2021-03-24 - next 2021-05-22 (2.4.0)
    ffmpeg_icu_ver=69.1                   # 2021-04-07 - next 2021-10-27 (70.1)
    ffmpeg_graphite2_ver=1.3.14           # 2020-03-31 - latest as of 2024-02-09
    ffmpeg_freetype_ver=2.10.4            # 2020-10-20 - next 2021-07-19 (2.11.0)
    ffmpeg_fontconfig_ver=2.13.93         # 2020-11-27 - next 2021-06-28 (2.13.94)
    ffmpeg_harfbuzz_ver=2.8.0             # 2021-03-16 - next 2021-05-03 (2.8.1)
    ffmpeg_cairo_ver=1.16.0               # 2018-10-19 - next 2023-09-23 (1.18.0)
    ffmpeg_pixman_ver=0.40.0              # 2020-04-19 - next 2022-10-18 (0.42.0)
    ffmpeg_fribidi_ver=1.0.10             # 2020-07-05 - next 2021-09-23 (1.0.11)
    ffmpeg_libass_ver=0.15.0              # 2020-10-26 - next 2021-05-01 (0.15.1)
    # Miscellaneous extras
    ffmpeg_libxml2_ver=2.9.10             # 2019-10-30 - next 2021-05-13 (2.9.11)
    ffmpeg_libbluray_ver=1.3.0            # 2021-04-05 - next 2022-03-03 (1.3.1)
    ffmpeg_nasm_ver=2.15.05               # 2020-08-28 - next 2022-12-20 (2.16)
    ffmpeg_librist_ver=0.2.0-RC6          # 2021-03-28 - next 2021-05-12 (0.2.0)
    # Xiph.org libraries
    ffmpeg_libogg_ver=1.3.4               # 2019-08-30 - next 2021-06-03 (1.3.5)
    ffmpeg_libvorbis_ver=1.3.7            # 2020-07-04 - latest as of 2024-04-10
    ffmpeg_libtheora_ver=1.1.1            # 2009-10-01 - latest as of 2024-02-09
    ffmpeg_speex_ver=1.2.0                # 2016-12-07 - next 2022-06-16 (1.2.1)
    ffmpeg_opus_ver=1.3.1                 # 2019-04-12 - next 2023-04-18 (1.4)
    # Audio codecs
    ffmpeg_libilbc_ver=3.0.4              # 2020-12-31 - latest as of 2024-04-11
    ffmpeg_lame_ver=3.100                 # 2017-10-13 - latest as of 2024-02-09
    ffmpeg_fdkaac_ver=2.0.1               # 2019-10-08 - next 2021-04-28 (2.0.2)
    ffmpeg_flac_ver=1.3.3                 # 2019-08-04 - next 2022-02-20 (1.3.4)
    ffmpeg_libsndfile_ver=1.0.31          # 2021-01-24 - next 2022-03-27 (1.1.0)
    ffmpeg_twolame_ver=0.4.0              # 2019-10-11 - latest as of 2024-02-09
    ffmpeg_libbs2b_ver=3.1.0              # 2009-06-04 - latest as of 2024-02-09
    ffmpeg_opencoreamr_ver=0.1.5          # 2017-03-16 - next 2022-08-01 (0.1.6)
    ffmpeg_voamrwbenc_ver=0.1.3           # 2013-07-27 - latest as of 2024-02-09
    ffmpeg_soxr_ver=0.1.3                 # 2018-02-24 - latest as of 2024-02-09
    # Video codecs
    ffmpeg_libaom_ver=3.0.0               # 2021-03-23 - next 2021-05-03 (3.1.0)
    ffmpeg_xvidcore_ver=1.3.7             # 2019-12-29 - latest as of 2024-02-09
    ffmpeg_x264_ver=20210211              # 2021-02-11 - next 2021-04-12
    ffmpeg_x265_ver=3.5                   # 2021-03-16 - next 2024-04-04 (3.6)
    ffmpeg_kvazaar_ver=2.0.0              # 2020-04-21 - next 2021-10-13 (2.1.0)
    ffmpeg_openh264_ver=2.1.1             # 2020-05-21 - next 2022-01-27 (2.2.0)
    ffmpeg_libvpx_ver=1.10.0              # 2021-03-24 - next 2021-10-07 (1.11.0)
    ffmpeg_dav1d_ver=0.8.2                # 2021-02-21 - next 2021-05-16 (0.9.0)
    ffmpeg_davs2_ver=1.7                  # 2020-04-19 - latest as of 2024-02-09
    ffmpeg_xavs2_ver=1.4                  # 2019-04-21 - latest as of 2024-04-08
    ffmpeg_vidstab_ver=1.1.1              # 2020-05-30 - latest as of 2024-02-11
    ffmpeg_libsvtav1_ver=0.8.6            # 2020-11-29 - next 2021-05-08 (0.8.7)
    ffmpeg_uavs3d_ver=1.1.63              # 2021-04-09 - next 2021-07-01 (1.1.64)
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
  *)
   echo "ERROR: Review needed for FFmpeg ${ffmpeg_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  ffmpeg_utillinux_ver=${global_utillinux}
fi

echo "Installing ffmpeg ${ffmpeg_v}..."

ffmpeg_srcdir=ffmpeg-${ffmpeg_v}
ffmpeg_depdir=${opt}/ffmpeg-dep-${ffmpeg_v}
ffmpeg_prefix=${opt}/ffmpeg-${ffmpeg_v}

ffmpeg_zlib_ver=${global_zlib}
ffmpeg_xz_ver=${global_xz}
ffmpeg_bzip2_ver=${global_bzip2}
ffmpeg_openssl_ver=${global_openssl}

if [ "${ffmpeg_v:0:3}" == "2.8" ] ; then
  ffmpeg_openssl_ver=1.0.2u # 2019-12-20
fi

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
eof
if [ ! "${ffmpeg_libdeflate_ver}" == "0" ] ; then
  echo "module load libdeflate/${ffmpeg_libdeflate_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
module load jbigkit/${ffmpeg_jbigkit_ver}
module load zstd/${ffmpeg_zstd_ver}
module load bzip2/${ffmpeg_bzip2_ver}
module load expat/${ffmpeg_expat_ver}
module load util-linux/${ffmpeg_utillinux_ver}
module load icu/${ffmpeg_icu_ver}
module load fribidi/${ffmpeg_fribidi_ver}
module load libilbc/${ffmpeg_libilbc_ver}
module load lame/${ffmpeg_lame_ver}
module load fdk-aac/${ffmpeg_fdkaac_ver}
eof
if [ "${ffmpeg_v:0:1}" == "2" ] || [ "${ffmpeg_v:0:1}" == "3" ] || [ "${ffmpeg_v:0:3}" == "4.0" ] || [ "${ffmpeg_v:0:3}" == "4.1" ] || [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] ; then
  echo "module load wavpack/${ffmpeg_wavpack_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
module load opencore-amr/${ffmpeg_opencoreamr_ver}
module load vo-amrwbenc/${ffmpeg_voamrwbenc_ver}
eof
if [ "${ffmpeg_v:0:1}" == "4" ] ; then
  echo "module load libaom/${ffmpeg_libaom_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
if [ "${ffmpeg_v:0:3}" == "4.1" ] || [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  echo "module load davs2/${ffmpeg_davs2_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
  echo "module load xavs2/${ffmpeg_xavs2_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
if [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  echo "module load librist/${ffmpeg_librist_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
  echo "module load libsvtav1/${ffmpeg_libsvtav1_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
  echo "module load uavs3d/${ffmpeg_uavs3d_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
module load xvidcore/${ffmpeg_xvidcore_ver}
module load x264/${ffmpeg_x264_ver}
module load x265/${ffmpeg_x265_ver}
module load kvazaar/${ffmpeg_kvazaar_ver}
module load openh264/${ffmpeg_openh264_ver}
module load libvpx/${ffmpeg_libvpx_ver}
eof
if [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  echo "module load dav1d/${ffmpeg_dav1d_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
module load soxr/${ffmpeg_soxr_ver}
module load vidstab/${ffmpeg_vidstab_ver}

prereq libpng/${ffmpeg_libpng_ver}
prereq libjpeg-turbo/${ffmpeg_libjpegturbo_ver}
prereq zlib/${ffmpeg_zlib_ver}
prereq xz/${ffmpeg_xz_ver}
eof
if [ ! "${ffmpeg_libdeflate_ver}" == "0" ] ; then
  echo "prereq libdeflate/${ffmpeg_libdeflate_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
prereq jbigkit/${ffmpeg_jbigkit_ver}
prereq zstd/${ffmpeg_zstd_ver}
prereq bzip2/${ffmpeg_bzip2_ver}
prereq expat/${ffmpeg_expat_ver}
prereq util-linux/${ffmpeg_utillinux_ver}
prereq icu/${ffmpeg_icu_ver}
prereq fribidi/${ffmpeg_fribidi_ver}
prereq libilbc/${ffmpeg_libilbc_ver}
prereq lame/${ffmpeg_lame_ver}
prereq fdk-aac/${ffmpeg_fdkaac_ver}
eof
if [ "${ffmpeg_v:0:1}" == "2" ] || [ "${ffmpeg_v:0:1}" == "3" ] || [ "${ffmpeg_v:0:3}" == "4.0" ] || [ "${ffmpeg_v:0:3}" == "4.1" ] || [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] ; then
  echo "prereq wavpack/${ffmpeg_wavpack_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
prereq opencore-amr/${ffmpeg_opencoreamr_ver}
prereq vo-amrwbenc/${ffmpeg_voamrwbenc_ver}
eof
if [ "${ffmpeg_v:0:1}" == "4" ] ; then
  echo "prereq libaom/${ffmpeg_libaom_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
if [ "${ffmpeg_v:0:3}" == "4.1" ] || [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  echo "prereq davs2/${ffmpeg_davs2_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
  echo "prereq xavs2/${ffmpeg_xavs2_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
if [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  echo "prereq librist/${ffmpeg_librist_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
  echo "prereq libsvtav1/${ffmpeg_libsvtav1_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
  echo "prereq uavs3d/${ffmpeg_uavs3d_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
prereq xvidcore/${ffmpeg_xvidcore_ver}
prereq x264/${ffmpeg_x264_ver}
prereq x265/${ffmpeg_x265_ver}
prereq kvazaar/${ffmpeg_kvazaar_ver}
prereq openh264/${ffmpeg_openh264_ver}
prereq libvpx/${ffmpeg_libvpx_ver}
eof
if [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  echo "prereq dav1d/${ffmpeg_dav1d_ver}" >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
fi
cat << eof >> ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}
prereq soxr/${ffmpeg_soxr_ver}
prereq vidstab/${ffmpeg_vidstab_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof


check_nasm ${ffmpeg_nasm_ver}
check_openssl ${ffmpeg_openssl_ver}
check_zstd ${ffmpeg_zstd_ver}
if [ ! "${ffmpeg_libdeflate_ver}" == "0" ] ; then
  check_libdeflate ${ffmpeg_libdeflate_ver}
fi
check_jbigkit ${ffmpeg_jbigkit_ver}
check_giflib ${ffmpeg_giflib_ver}
check_libpng ${ffmpeg_libpng_ver}
check_libjpegturbo ${ffmpeg_libjpegturbo_ver}
check_expat ${ffmpeg_expat_ver}
check_utillinux ${ffmpeg_utillinux_ver}
check_icu ${ffmpeg_icu_ver}
check_fribidi ${ffmpeg_fribidi_ver}
check_libilbc ${ffmpeg_libilbc_ver}
check_lame ${ffmpeg_lame_ver}
check_fdkaac ${ffmpeg_fdkaac_ver}
if [ "${ffmpeg_v:0:1}" == "2" ] || [ "${ffmpeg_v:0:1}" == "3" ] || [ "${ffmpeg_v:0:3}" == "4.0" ] || [ "${ffmpeg_v:0:3}" == "4.1" ] || [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] ; then
  check_wavpack ${ffmpeg_wavpack_ver}
fi
check_opencoreamr ${ffmpeg_opencoreamr_ver}
check_voamrwbenc ${ffmpeg_voamrwbenc_ver}
if [ "${ffmpeg_v:0:1}" == "4" ] ; then
  check_libaom ${ffmpeg_libaom_ver}
fi
if [ "${ffmpeg_v:0:3}" == "4.1" ] || [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  check_davs2 ${ffmpeg_davs2_ver}
  check_xavs2 ${ffmpeg_xavs2_ver}
fi
if [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  check_librist ${ffmpeg_librist_ver}
  check_libsvtav1 ${ffmpeg_libsvtav1_ver}
  check_uavs3d ${ffmpeg_uavs3d_ver}
fi
check_xvidcore ${ffmpeg_xvidcore_ver}
check_x264 ${ffmpeg_x264_ver}
check_x265 ${ffmpeg_x265_ver}
check_kvazaar ${ffmpeg_kvazaar_ver}
check_openh264 ${ffmpeg_openh264_ver}
check_libvpx ${ffmpeg_libvpx_ver}
if [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  check_dav1d ${ffmpeg_dav1d_ver}
fi
check_soxr ${ffmpeg_soxr_ver}
check_vidstab ${ffmpeg_vidstab_ver}

if [ "${ffmpeg_v:0:3}" == "4.2" ] || [ "${ffmpeg_v:0:3}" == "4.3" ] || [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
  ff_check_aribb24 ${ffmpeg_aribb24_ver} ${ffmpeg_depdir} ${ffmpeg_v}
fi
ff_check_tiff ${ffmpeg_tiff_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libwebp ${ffmpeg_libwebp_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_lcms2 ${ffmpeg_lcms2_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_openjpeg ${ffmpeg_openjpeg_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_freetype ${ffmpeg_freetype_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_fontconfig ${ffmpeg_fontconfig_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_graphite2 ${ffmpeg_graphite2_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_harfbuzz ${ffmpeg_harfbuzz_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_pixman ${ffmpeg_pixman_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_cairo ${ffmpeg_cairo_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libass ${ffmpeg_libass_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libxml2 ${ffmpeg_libxml2_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libbluray ${ffmpeg_libbluray_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libogg ${ffmpeg_libogg_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libvorbis ${ffmpeg_libvorbis_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libtheora ${ffmpeg_libtheora_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_speex ${ffmpeg_speex_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_opus ${ffmpeg_opus_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_flac ${ffmpeg_flac_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libsndfile ${ffmpeg_libsndfile_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_twolame ${ffmpeg_twolame_ver} ${ffmpeg_depdir} ${ffmpeg_v}
ff_check_libbs2b ${ffmpeg_libbs2b_ver} ${ffmpeg_depdir} ${ffmpeg_v}


downloadPackage ${ffmpeg_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${ffmpeg_srcdir} ] ; then
  rm -rf ${tmp}/${ffmpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${ffmpeg_srcdir}.tar.gz
cd ${tmp}/${ffmpeg_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${ffmpeg_v}
module load nasm/${ffmpeg_nasm_ver}
module load openssl/${ffmpeg_openssl_ver}

if [ "${ffmpeg_v:0:3}" == "2.8" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-fontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
#ffconf_extra_libs="-ldl -pthread"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include \
-I${opt}/openssl-${ffmpeg_openssl_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib \
-L${opt}/openssl-${ffmpeg_openssl_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "3.2" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "3.4" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "4.0" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "4.1" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-libdavs2 \
            --enable-libxavs2 \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "4.2" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-libdav1d \
            --enable-libdavs2 \
            --enable-libxavs2 \
            --enable-libaom \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libxml2 \
            --enable-libfdk-aac \
            --enable-libbluray \
            --enable-libaribb24 \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "4.3" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-libdav1d \
            --enable-libdavs2 \
            --enable-libxavs2 \
            --enable-libaom \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libxml2 \
            --enable-libfdk-aac \
            --enable-libbluray \
            --enable-libaribb24 \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwavpack \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/wavpack-${ffmpeg_wavpack_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/wavpack-${ffmpeg_wavpack_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi

if [ "${ffmpeg_v:0:3}" == "4.4" ] ; then
ffconf_opt="--prefix=${ffmpeg_prefix} \
            --enable-gpl \
            --enable-version3 \
            --enable-nonfree \
            --enable-shared \
            --enable-openssl \
            --enable-librist \
            --enable-libdav1d \
            --enable-libdavs2 \
            --enable-libxavs2 \
            --enable-libaom \
            --enable-libsvtav1 \
            --enable-libuavs3d \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libxml2 \
            --enable-libfdk-aac \
            --enable-libbluray \
            --enable-libaribb24 \
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
            --enable-libsoxr \
            --enable-libspeex \
            --enable-libvo-amrwbenc \
            --enable-libwebp \
            --enable-libvpx \
            --enable-libtwolame \
            --enable-libvidstab"
ffconf_extra_libs=""
ffconf_cflags="-I${ffmpeg_depdir}/include \
-I${opt}/xvidcore-${ffmpeg_xvidcore_ver}/include \
-I${opt}/libilbc-${ffmpeg_libilbc_ver}/include \
-I${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/include \
-I${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/include \
-I${opt}/lame-${ffmpeg_lame_ver}/include \
-I${opt}/soxr-${ffmpeg_soxr_ver}/include"
ffconf_ldflgs="-L${ffmpeg_depdir}/lib \
-L${opt}/xvidcore-${ffmpeg_xvidcore_ver}/lib \
-L${opt}/libilbc-${ffmpeg_libilbc_ver}/lib \
-L${opt}/opencore-amr-${ffmpeg_opencoreamr_ver}/lib \
-L${opt}/vo-amrwbenc-${ffmpeg_voamrwbenc_ver}/lib \
-L${opt}/lame-${ffmpeg_lame_ver}/lib \
-L${opt}/soxr-${ffmpeg_soxr_ver}/lib"
fi


if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  if [ -z "${ffconf_extra_libs}" ] ; then
    echo ./configure ${ffconf_opt} --extra-cflags=\"${ffconf_cflags}\" --extra-ldflags=\"${ffconf_ldflgs}\"
  else
    echo ./configure ${ffconf_opt} --extra-libs=\"${ffconf_extra_libs}\" --extra-cflags=\"${ffconf_cflags}\" --extra-ldflags=\"${ffconf_ldflgs}\"
  fi
  echo ''
  echo '>> Press enter to run configure command...'
  echo ''
  read k
fi


if [ -z "${ffconf_extra_libs}" ] ; then
  ./configure ${ffconf_opt} --extra-cflags="${ffconf_cflags}" --extra-ldflags="${ffconf_ldflgs}"
else
  ./configure ${ffconf_opt} --extra-libs="${ffconf_extra_libs}" --extra-cflags="${ffconf_cflags}" --extra-ldflags="${ffconf_ldflgs}"
fi


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
module purge

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
module load ffmpeg-dep/${ffmpeg_v}
prereq ffmpeg-dep/${ffmpeg_v}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

grep -v 'prepend-path' ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v} > ${MODULEPATH}/ffmpeg-dep/temp
cat << eof >> ${MODULEPATH}/ffmpeg-dep/temp
module load openssl/${ffmpeg_openssl_ver}
prereq openssl/${ffmpeg_openssl_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof
mv -fv ${MODULEPATH}/ffmpeg-dep/temp ${MODULEPATH}/ffmpeg-dep/${ffmpeg_v}

cd ${root}
rm -rf ${tmp}/${ffmpeg_srcdir}

}
