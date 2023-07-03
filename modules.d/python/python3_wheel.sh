#!/bin/bash

# Functions for installing generic wheel modules for python 3
echo 'Loading generic wheel installer for Python 3...'

function p3wheelInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
module purge
module load Python/${1}
if [ ! $? -eq 0 ] ; then
  return 1
fi

case ${2} in
mutagen)
  mname=mutagen
  vquery="print('.'.join([str(x) for x in mutagen.version]))"
  ;;
beautifulsoup4)
  mname=bs4
  vquery="print(bs4.__version__)"
  ;;
*)
  mname=${2}
  vquery="print(${2}.__version__)"
  ;;
esac

echo -n "Searching for ${2} ${3}... "

if [ "${2}" == "demjson3" ] ; then
  # demjson3 3.0.6 reports internally as 3.0.5
  pytest=$(pip3 list | grep demjson3 | awk '{print $2}' 2>/dev/null)
  if [ -z "${pytest}" ] ; then
    pytest="<not found>"
  fi
else
  pytest=$(echo -e "import ${mname}\n${vquery}" | python3 2>/dev/null)
  if [ -z "${pytest}" ] ; then
    pytest="<not found>"
  fi
fi

echo -n "${pytest} "
if [ "${pytest}" == "${3}" ] ; then
  echo "(success)"
  return 0
else
  echo "(fail)"
  return 1
fi
}

function check_p3wheel() {
if p3wheelInstalled ${1} ${2} ${3}; then
  echo "${2} is installed for Python/${1}."
else
  if [ "${2}" == "demjson" ] ; then
    install_p3wheel ${1} setuptools 57.5.0
    install_p3wheel ${1} pip 23.0.1
    install_p3wheel ${1} ${2} ${3}
  elif [ "${2}" == "demjson3" ] ; then
    install_p3wheel ${1} pip 23.0.1
    install_p3wheel ${1} ${2} ${3}
  else
    install_p3wheel ${1} ${2} ${3}
  fi
fi
}

function install_p3wheel() {

# Get desired version number to install
python_v=${1}
wheel_name=${2}
wheel_v=${3}
if [ -z "${python_v}" ] ; then
  exit 4
fi
if [ -z "${wheel_v}" ] ; then
  exit 4
fi
if [ "${wheel_name}" == "beautifulsoup4" ] ; then
  module_name=bs4
else
  module_name=${wheel_name}
fi

mode=whl
if [ "${wheel_name}" == "demjson" ] || [ "${wheel_name}" == "demjson3" ] ; then
  wfile=${wheel_name}-${wheel_v}.tar.gz
  mode=tgz
else
  wfile=${wheel_name}-${wheel_v}-py3-none-any.whl
fi

echo "Installing ${wheel_name} (${module_name}) ${wheel_v} for Python/${python_v}..."

check_modules
module load Python/${python_v}

downloadPackage ${wfile}

if [ ! -f ${pkg}/${wfile} ] ; then
  exit 4
fi

if [ ${debug} -gt 0 ] ; then
  echo ">> Ready to install ${module_name}"
  read k
fi

pip3 install --no-index ${pkg}/${wfile}
if [ ! $? -eq 0 ] ; then
  exit 4
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  if [ "${module_name}" == "soupsieve" ] ; then
    echo 'Skipping test because soupsieve requires bs4'
  else
    echo -e "import ${module_name}\n\nprint(\"Import of ${module_name} succeeded.\")" | python3
  fi
  echo ''
  echo '>> Tests complete'
  read k
fi
cd ${root}

}
