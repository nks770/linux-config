#!/bin/bash

# Functions for detecting and building autoconf
echo 'Loading autoconf...'

function autoconfInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check autoconf
if [ ! -f ${MODULEPATH}/autoconf/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_autoconf() {
if autoconfInstalled ${1}; then
  echo "autoconf ${1} is installed."
else
  build_autoconf ${1}
fi
}

function build_autoconf() {

# Get desired version number to install
autoconf_v=${1}
if [ -z "${autoconf_v}" ] ; then
  echo "ERROR: No version of autoconf specified!"
  exit 2
fi

case ${autoconf_v} in
2.69) # 2012-04-24
   autoconf_m4_ver=1.4.16   # 2011-03-01
   ;;
*)
   echo "ERROR: Need review for autoconf ${autoconf_v}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  autoconf_m4_ver=${global_m4}
fi

echo "Installing autoconf ${autoconf_v}..."

check_modules
check_m4 ${autoconf_m4_ver}

downloadPackage autoconf-${autoconf_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/autoconf-${autoconf_v} ] ; then
  rm -rf ${tmp}/autoconf-${autoconf_v}
fi

tar xvfz ${pkg}/autoconf-${autoconf_v}.tar.gz
cd ${tmp}/autoconf-${autoconf_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# 151 testsuite failures (listed at the bottom) get fixed by the attached patch
# with bash-5 (tested bash-5.0.7-3.fc31.x86_64).
# 
# Tested with GIT trunk: 4677fc349ce759069c9dc8f099a72e77651f1f7b
# 
# I think it is due to (from bash-5 release notes):
# ------------------------------------------------------------------------------
# There are a few incompatible changes between bash-4.4 and bash-5.0. The
# changes to how nameref variables are resolved means that some uses of
# namerefs will behave differently, though I have tried to minimize the
# compatibility issues. By default, the shell only sets BASH_ARGC and
# BASH_ARGV at startup if extended debugging mode is enabled; it was an
# oversight that it was set unconditionally and caused performance issues
# when scripts were passed large numbers of arguments.
# ------------------------------------------------------------------------------
#
# https://mail.gnu.org/archive/html/autoconf-patches/2019-08/msg00000.html
#
if [ "${autoconf_v}" == "2.69" ] ; then
cat << eof > local.patch
--- tests/local.at
+++ tests/local.at
@@ -381,6 +381,8 @@
 	/'\\'\\\\\\\$\\''=/ d
 	/^argv=/ d
 	/^ARGC=/ d
+	/^BASH_ARGC=/ d
+	/^BASH_ARGV=/ d
 	' \$act_file >at_config_vars-\$act_file
 done
 AT_CMP([at_config_vars-\$1], [at_config_vars-\$2])[]dnl
eof
fi
patch -p0 -b < local.patch

if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

module purge
module load m4/${autoconf_m4_ver}

config="./configure --prefix=${opt}/autoconf-${autoconf_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo ${config}
  read k
fi

${config}

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
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/autoconf
cat << eof > ${MODULEPATH}/autoconf/${autoconf_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts autoconf-${autoconf_v} into your environment"
}

set VER ${autoconf_v}
set PKG ${opt}/autoconf-\$VER

module-whatis   "Loads autoconf-${autoconf_v}"
conflict autoconf
module load m4/${autoconf_m4_ver}
prereq m4/${autoconf_m4_ver}

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/autoconf-${autoconf_v}

}
