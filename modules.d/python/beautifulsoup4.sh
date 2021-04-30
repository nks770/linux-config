#!/bin/bash

# Functions for detecting and building NASM

function bs4Installed() {
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
pytest=$(find "${py_lib}" -name 'bs4')
# If modules is OK, then check bs4
if [ -z "${pytest}" ] ; then
  return 1
else
  return 0
fi
}

function check_bs4() {
if bs4Installed ${1}; then
  echo "bs4 is installed for Python/${1}."
else
  build_bs4 ${1} ${2}
fi
}

function build_bs4() {

# Get desired version number to install
python_v=${1}
bs4_v=${2}
if [ -z "${python_v}" ] ; then
  python_v=3.9.4
fi
if [ -z "${bs4_v}" ] ; then
  bs4_v=4.9.3
fi
bs4_srcdir=beautifulsoup4-${bs4_v}

echo "Installing bs4 ${bs4_v} for Python/${python_v}..."

check_modules
module load Python/${python_v}

downloadPackage beautifulsoup4-${bs4_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${bs4_srcdir} ] ; then
  rm -rf ${tmp}/${bs4_srcdir}
fi

tar xvfz ${pkg}/beautifulsoup4-${bs4_v}.tar.gz
cd ${tmp}/${bs4_srcdir}

python3 setup.py install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

cd ${root}
rm -rf ${tmp}/${bs4_srcdir}

}
