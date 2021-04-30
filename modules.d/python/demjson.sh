#!/bin/bash

# Functions for detecting and building NASM

function demjsonInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
module load Python/${1}
if [ ! $? -eq 0 ] ; then
  return 1
fi
py_exe=$(which python3)
if [ ! -f "${py_exe}" ] ; then
  return 1
fi
py_lib=$(echo ${py_exe%/*}/../lib/python*/site-packages)
pytest=$(find "${py_lib}" -name 'demjson.py')
# If modules is OK, then check demjson
if [ -z "${pytest}" ] ; then
  return 1
else
  return 0
fi
}

function check_demjson() {
if demjsonInstalled ${1}; then
  echo "demjson is installed for Python/${1}."
else
  build_demjson ${1} ${2}
fi
}

function build_demjson() {

# Get desired version number to install
python_v=${1}
demjson_v=${2}
if [ -z "${python_v}" ] ; then
  python_v=3.9.4
fi
if [ -z "${demjson_v}" ] ; then
  demjson_v=2.2.4
fi
demjson_srcdir=demjson-${demjson_v}

echo "Installing demjson ${demjson_v} for Python/${python_v}..."

check_modules
module load Python/${python_v}

downloadPackage demjson-${demjson_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${demjson_srcdir} ] ; then
  rm -rf ${tmp}/${demjson_srcdir}
fi

tar xvfz ${pkg}/demjson-${demjson_v}.tar.gz
cd ${tmp}/${demjson_srcdir}

python3 setup.py install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

cd ${root}
rm -rf ${tmp}/${demjson_srcdir}

}
