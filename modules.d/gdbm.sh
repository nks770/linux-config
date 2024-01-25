#!/bin/bash

# Functions for detecting and building gdbm
echo 'Loading gdbm...'

function gdbmInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check gdbm
if [ ! -f ${MODULEPATH}/gdbm/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_gdbm() {
if gdbmInstalled ${1}; then
  echo "gdbm ${1} is installed."
else
  build_gdbm ${1}
fi
}

function build_gdbm() {

# Get desired version number to install
gdbm_v=${1}
if [ -z "${gdbm_v}" ] ; then
  echo "ERROR: No gdbm version specified!"
  exit 2
fi

case ${gdbm_v} in
1.10) #2011-11-13
   gdbm_readline_ver=6.2 #2011-02-13
   gdbm_ncurses_ver=5.9  #2011-04-04
   gdbm_dejagnu_ver=1.6.3
   ;;
1.13) #2017-03-11
   gdbm_readline_ver=7.0 #2016-09-15
   gdbm_ncurses_ver=6.0  #2015-08-08
   gdbm_dejagnu_ver=1.6.3
   ;;
1.14.1) #2018-01-03
   gdbm_readline_ver=7.0 #2016-09-15
   gdbm_ncurses_ver=6.0  #2015-08-08
   gdbm_dejagnu_ver=1.6.3
   ;;
1.18) #2018-08-21
   gdbm_readline_ver=7.0 #2016-09-15
   gdbm_ncurses_ver=6.0  #2015-08-08
   gdbm_dejagnu_ver=1.6.3
   ;;
1.18.1) #2018-10-27
   gdbm_readline_ver=7.0 #2016-09-15
   gdbm_ncurses_ver=6.0  #2015-08-08
   gdbm_dejagnu_ver=1.6.3
   ;;
1.19) #2020-12-23
   gdbm_readline_ver=8.1 #2020-12-06
   gdbm_ncurses_ver=6.2  #2020-02-12
   gdbm_dejagnu_ver=1.6.3
   ;;
1.23) #2022-02-04
   gdbm_readline_ver=8.1.2 #2022-01-05
   gdbm_ncurses_ver=6.3    #2021-11-08
   gdbm_dejagnu_ver=1.6.3
   ;;
*)
   echo "ERROR: Need review for gdbm ${gdbm_v}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  gdbm_readline_ver=${global_readline}
  gdbm_ncurses_ver=${global_ncurses}
fi

echo "Installing gdbm ${gdbm_v}..."
gdbm_srcdir=gdbm-${gdbm_v}

check_modules
check_readline ${gdbm_readline_ver}
check_ncurses ${gdbm_ncurses_ver}
check_dejagnu ${gdbm_dejagnu_ver}

downloadPackage gdbm-${gdbm_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${gdbm_srcdir} ] ; then
  rm -rf ${tmp}/${gdbm_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/gdbm-${gdbm_v}.tar.gz
cd ${tmp}/${gdbm_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to enable compilation with GCC 8
# https://bugs.gentoo.org/705898
if [ "${gdbm_v}" == "1.13" ] || [ "${gdbm_v}" == "1.18" ] || [ "${gdbm_v}" == "1.18.1" ] ; then

if [ "${gdbm_v}" == "1.13" ] ; then
cat << eof > parseopt.patch
--- src/parseopt.c
+++ src/parseopt.c
@@ -252,8 +252,6 @@
 }
eof
echo -e ' \f' >> parseopt.patch
cat << eof >> parseopt.patch
 char *parseopt_program_name;
-char *parseopt_program_doc;
-char *parseopt_program_args;
 const char *program_bug_address = "<" PACKAGE_BUGREPORT ">";
 void (*parseopt_help_hook) (FILE *stream);
eof
echo -e ' \f' >> parseopt.patch
fi

if [ "${gdbm_v}" == "1.18" ] || [ "${gdbm_v}" == "1.18.1" ] ; then
cat << eof > parseopt.patch
--- src/parseopt.c
+++ src/parseopt.c
@@ -255,8 +255,6 @@
 }
eof
echo -e ' \f' >> parseopt.patch
cat << eof >> parseopt.patch
 char *parseopt_program_name;
-char *parseopt_program_doc;
-char *parseopt_program_args;
 const char *program_bug_address = "<" PACKAGE_BUGREPORT ">";
 void (*parseopt_help_hook) (FILE *stream);
eof
echo -e ' \f' >> parseopt.patch
fi

patch -Z -b -p0 < parseopt.patch

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
module load readline/${gdbm_readline_ver}
module load ncurses/${gdbm_ncurses_ver}
module load dejagnu/${gdbm_dejagnu_ver}

if [ "${gdbm_v}" == "1.13" ] ; then
  config="./configure --prefix=${opt}/gdbm-${gdbm_v} --enable-libgdbm-compat --enable-gdbm-export CPPFLAGS=-I/opt/readline-${gdbm_readline_ver}/include"
  export LDFLAGS="-L${opt}/readline-${gdbm_readline_ver}/lib -L${opt}/ncurses-${gdbm_ncurses_ver}/lib -L${tmp}/${gdbm_srcdir}/src/.libs"
else
  config="./configure --prefix=${opt}/gdbm-${gdbm_v} --enable-libgdbm-compat CPPFLAGS=-I/opt/readline-${gdbm_readline_ver}/include"
  export LDFLAGS="-L${opt}/readline-${gdbm_readline_ver}/lib -L${opt}/ncurses-${gdbm_ncurses_ver}/lib"
fi

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo LDFLAGS="${LDFLAGS}"
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
  if [ "${gdbm_v}" == "1.18" ] || [ "${gdbm_v}" == "1.18.1" ] ; then
    module unload dejagnu
  fi
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
mkdir -pv ${MODULEPATH}/gdbm
cat << eof > ${MODULEPATH}/gdbm/${gdbm_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts gdbm-${gdbm_v} into your environment"
}

set VER ${gdbm_v}
set PKG ${opt}/gdbm-\$VER

module-whatis   "Loads gdbm-${gdbm_v}"
conflict gdbm
module load readline/${gdbm_readline_ver} ncurses/${gdbm_ncurses_ver}
prereq readline/${gdbm_readline_ver}
prereq ncurses/${gdbm_ncurses_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${gdbm_srcdir}

}
