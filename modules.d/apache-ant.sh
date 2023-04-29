#!/bin/bash

## Functions for detecting and building apache-ant
#echo 'Loading apache-ant...'
#
#function apacheantInstalled() {
## Cannot evaulate if we dont have modules installed
#if [ ! -f /etc/profile.d/modules.sh ] ; then
#  return 1
#fi
## Load modules if not loaded already
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
## If modules is OK, then check apacheant
#if [ ! -f ${MODULEPATH}/apache-ant/${1} ] ; then
#  return 1
#else
#  return 0
#fi
#}
#
#function check_apacheant() {
#if apacheantInstalled ${1}; then
#  echo "apache-ant ${1} is installed."
#else
#  build_apacheant ${1}
#fi
#}
#
#function build_apacheant() {
#
## Get desired version number to install
#apacheant_v=${1}
#if [ -z "${apacheant_v}" ] ; then
#  apacheant_v=1.9.16
#fi
#
#echo "Installing apache-ant ${apacheant_v}..."
#
#case ${1} in
#  1.9.14) # 2019-03-17
#   openjdk_ver=jdk8u202-ga # 2018-12-14
#  ;;
#  *)
#   echo "ERROR: Need review for libbluray ${1}"
#   exit 4
#   ;;
#esac
#
#check_modules
#check_openjdk ${openjdk_ver}
#
#downloadPackage apache-ant-${apacheant_v}-src.tar.gz
#
#cd ${tmp}
#
#if [ -d ${tmp}/apache-ant-${apacheant_v} ] ; then
#  rm -rf ${tmp}/apache-ant-${apacheant_v}
#fi
#
#tar xvfz ${pkg}/apache-ant-${apacheant_v}-src.tar.gz
#cd ${tmp}/apache-ant-${apacheant_v}
#
#module purge
#module load openjdk/${openjdk_ver}
#
#config="./configure --prefix=${opt}/apache-ant-${apacheant_v}"
#
#if [ ${debug} -gt 0 ] ; then
#  ./configure --help
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
#mkdir -pv ${MODULEPATH}/apacheant
#cat << eof > ${MODULEPATH}/apache-ant/${apacheant_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts apache-ant-${apacheant_v} into your environment"
#}
#
#set VER ${apacheant_v}
#set PKG ${opt}/apache-ant-\$VER
#
#module-whatis   "Loads apache-ant-${apacheant_v}"
#conflict apache-ant
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
#rm -rf ${tmp}/apache-ant-${apacheant_v}
#
#}
