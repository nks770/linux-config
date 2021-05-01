#!/bin/bash

function downloadPackage() {

  file=""
  url=""

  while read u ; do
    if [ ! -z "${u}" ] && [ ! "${u:0:1}" == "#" ] ; then
      file=${u%%=*}
      location=${u#*=}

      if [ "${1}" == "${file}" ] ; then
        url="${location}"
      fi
    fi
  done < ${root}/bin/url.txt

  if [ ! -z "${url}" ] && [ ! -f ${pkg}/${1} ] ; then
    wget --no-check-certificate "${url}" -O ${pkg}/${1}
  fi

  if [ ! -f ${pkg}/${1} ] ; then
    echo "ERROR: Could not get ${1}!"
    exit 1
  fi

}

function downloadAllPackages() {

  while read u ; do
    if [ ! -z "${u}" ] && [ ! "${u:0:1}" == "#" ] ; then
      file=${u%%=*}
      url=${u#*=}

      if [ ! -z "${url}" ] && [ ! -f ${pkg}/${file} ] ; then
        wget --no-check-certificate "${url}" -O ${pkg}/${file}
      fi

      if [ ! -f ${pkg}/${file} ] ; then
        echo "ERROR: Could not get ${file}!"
        exit 1
      fi

    fi
  done < ${root}/bin/url.txt

}
