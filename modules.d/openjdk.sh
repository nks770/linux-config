#!/bin/bash

## Functions for detecting and building openjdk
#echo 'Loading openjdk...'
#
#function openjdkInstalled() {
## Cannot evaulate if we dont have modules installed
#if [ ! -f /etc/profile.d/modules.sh ] ; then
#  return 1
#fi
## Load modules if not loaded already
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
## If modules is OK, then check openjdk
#if [ ! -f ${MODULEPATH}/openjdk/${1} ] ; then
#  return 1
#else
#  return 0
#fi
#}
#
#function check_openjdk() {
#if openjdkInstalled ${1}; then
#  echo "openjdk ${1} is installed."
#else
#  build_openjdk ${1}
#fi
#}
#
#function build_openjdk() {
#
## Get desired version number to install
#openjdk_v=${1}
#if [ -z "${openjdk_v}" ] ; then
#  openjdk_v=jdk8u202-ga
#fi
#
#echo "Installing openjdk ${openjdk_v}..."
#
#case ${1} in
#  jdk8u202-ga) # 2018-12-14
#   jdk_ver=7u80
#  ;;
#  *)
#   echo "ERROR: Need review for openjdk ${1}"
#   exit 4
#   ;;
#esac
#srcdir=jdk8u-${openjdk_v}
#
#check_modules
#check_jdk ${jdk_ver}
#downloadPackage openjdk-${openjdk_v}.tar.gz
#
#cd ${tmp}
#
#if [ -d ${tmp}/${srcdir} ] ; then
#  rm -rf ${tmp}/${srcdir}
#fi
#
#tar xvfz ${pkg}/openjdk-${openjdk_v}.tar.gz
#cd ${tmp}/${srcdir}
#
#module purge
#module load jdk/${jdk_ver}
#
#config="bash ./configure --prefix=${opt}/openjdk-${openjdk_v}"
#
#if [ ${debug} -gt 0 ] ; then
#  bash ./configure --help
#  echo ''
#  echo ${config}
#  read k
#fi
#
#${config}
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
#  make check
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
#mkdir -pv ${MODULEPATH}/openjdk
#cat << eof > ${MODULEPATH}/openjdk/${openjdk_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts openjdk-${openjdk_v} into your environment"
#}
#
#set VER ${openjdk_v}
#set PKG ${opt}/openjdk-\$VER
#
#module-whatis   "Loads openjdk-${openjdk_v}"
#conflict openjdk
#
#prepend-path PATH \$PKG/bin
#prepend-path CPATH \$PKG/include
#prepend-path C_INCLUDE_PATH \$PKG/include
#prepend-path CPLUS_INCLUDE_PATH \$PKG/include
#prepend-path LD_LIBRARY_PATH \$PKG/lib
#prepend-path MANPATH \$PKG/share/man
#prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
#
#eof
#
#cd ${root}
#rm -rf ${tmp}/${srcdir}
#
#}
