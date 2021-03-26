#!/bin/bash

root=$(pwd)
pkg=${root}/packages

if [ ! -d ${pkg} ] ; then
  mkdir -pv ${pkg}
fi

