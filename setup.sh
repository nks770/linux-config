#!/bin/bash

root=$(pwd)
pkg=${root}/packages

if [ ! -d ${pkg} ] ; then
  mkdir -pv ${pkg}
fi

source bin/resources.sh

downloadPackage modules-4.7.0.tar.gz
