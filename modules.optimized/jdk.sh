#!/bin/bash

## Functions for detecting and building jdk
#echo 'Loading jdk...'
#
#function jdkInstalled() {
## Cannot evaulate if we dont have modules installed
#if [ ! -f /etc/profile.d/modules.sh ] ; then
#  return 1
#fi
## Load modules if not loaded already
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
## If modules is OK, then check yasm
#if [ ! -f ${MODULEPATH}/jdk/${1} ] ; then
#  return 1
#else
#  return 0
#fi
#}
#
#function check_jdk() {
#if jdkInstalled ${1} ; then
#  echo "jdk-${1} is installed."
#else
#  build_jdk ${1}
#fi
#}
#
#function build_jdk() {
#
## Get desired version number to install
#jdk_v=${1}
#if [ -z "${jdk_v}" ] ; then
#  jdk_v=7u80
#fi
#
#case ${jdk_v} in
#  7u80)
#   jdk_vv=jdk1.7.0_80
#  ;;
#  *)
#   echo "ERROR: Need review for jdk ${1}"
#   exit 4
#   ;;
#esac
#
#echo "Installing jdk version ${jdk_v}..."
#
#check_modules
#
#downloadPackage jdk-${jdk_v}-linux-x64.tar.gz
#
#mkdir -pv ${opt}/jdk-${jdk_v}
#
#cd ${opt}/jdk-${jdk_v}
#tar xvfz ${pkg}/jdk-${jdk_v}-linux-x64.tar.gz
#
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#if [ -z "${jdk_vv}" ] ; then
#  exit 4
#fi
#mv -fv ${jdk_vv}/* . && rmdir -v ${jdk_vv}
#
## Create the environment module
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi
#mkdir -pv ${MODULEPATH}/jdk
#cat << eof > ${MODULEPATH}/jdk/${jdk_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts jdk-${jdk_v} into your environment"
#}
#
#set VER ${jdk_v}
#set PKG ${opt}/jdk-\$VER
#
#module-whatis   "Loads jdk-${jdk_v}"
#conflict jdk
#
#prepend-path JAVA_HOME \$PKG
#prepend-path PATH \$PKG/bin
#
#eof
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Install complete'
#  read k
#fi
#
#cd ${root}
#
#}
