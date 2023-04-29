#!/bin/bash

# Functions for detecting and building bison
echo 'Loading bison...'

function bisonInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check bison
if [ ! -f ${MODULEPATH}/bison/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_bison() {
if bisonInstalled ${1}; then
  echo "bison ${1} is installed."
else
  build_bison ${1}
fi
}

function build_bison() {

# Get desired version number to install
bison_v=${1}
if [ -z "${bison_v}" ] ; then
  bison_v=3.0.4
fi

case ${bison_v} in
3.0.4) #2015-01-23
#   m4_ver=1.4.17 # 2013-09-22
   m4_ver=1.4.18  # Using m4 1.4.18 because 1.4.17 has some testsuite failures
   flex_ver=2.5.39 # 2014-03-26
   ;;
3.2.4) #2018-12-24
   m4_ver=1.4.18  # 2016-12-31
   flex_ver=2.6.4 # 2017-05-06
   ;;
3.4.1) #2019-05-22
   m4_ver=1.4.18  # 2016-12-31
   flex_ver=2.6.4 # 2017-05-06
   ;;
*)
   echo "ERROR: Need review for bison ${1}"
   exit 4
   ;;
esac
echo "Installing bison ${bison_v}..."

check_modules
check_m4 ${m4_ver}
check_flex ${flex_ver}
module purge
module load m4/${m4_ver}
module load flex/${flex_ver}

downloadPackage bison-${bison_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/bison-${bison_v} ] ; then
  rm -rf ${tmp}/bison-${bison_v}
fi

tar xvfz ${pkg}/bison-${bison_v}.tar.gz
cd ${tmp}/bison-${bison_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to enable compilation with glibc >= 2.28
# The problem is that the authors of m4 made some code that depended
# on glibc internal symbols, which they shouldn't have done. In
# version 2.28, glibc took those symbols internally and broke m4.
# This patch is a workaround.
# Based fix around the same thing we did for m4
if [ "${bison_v}" == "3.0.4" ] ; then

cat << eof > gnulib.patch
--- lib/fseterr.c	2015-01-04 10:43:50.000000000 -0600
+++ lib/fseterr.c	2023-04-01 22:55:51.861039604 -0500
@@ -29,7 +29,7 @@
   /* Most systems provide FILE as a struct and the necessary bitmask in
      <stdio.h>, because they need it for implementing getc() and putc() as
      fast macros.  */
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   fp->_flags |= _IO_ERR_SEEN;
 #elif defined __sferror || defined __DragonFly__ /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin */
   fp_->_flags |= __SERR;
--- lib/stdio-impl.h	2015-01-04 10:43:51.000000000 -0600
+++ lib/stdio-impl.h	2023-04-01 22:54:12.728020265 -0500
@@ -18,6 +18,12 @@
    the same implementation of stdio extension API, except that some fields
    have different naming conventions, or their access requires some casts.  */
 
+/* Glibc 2.28 made _IO_IN_BACKUP private.  For now, work around this
+   problem by defining it ourselves.  FIXME: Do not rely on glibc
+   internals.  */
+#if !defined _IO_IN_BACKUP && defined _IO_EOF_SEEN
+# define _IO_IN_BACKUP 0x100
+#endif
 
 /* BSD stdio derived implementations.  */

eof

patch -Z -b -p0 < gnulib.patch

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

config="./configure --prefix=${opt}/bison-${bison_v}"

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
mkdir -pv ${MODULEPATH}/bison
cat << eof > ${MODULEPATH}/bison/${bison_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts bison-${bison_v} into your environment"
}

set VER ${bison_v}
set PKG ${opt}/bison-\$VER

module-whatis   "Loads bison-${bison_v}"
conflict bison

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/bison-${bison_v}

}
