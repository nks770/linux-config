#!/bin/bash

# Functions for detecting and building m4
echo 'Loading m4...'

function m4Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check m4
if [ ! -f ${MODULEPATH}/m4/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_m4() {
if m4Installed ${1}; then
  echo "m4 ${1} is installed."
else
  build_m4 ${1}
fi
}

function build_m4() {

# Get desired version number to install
m4_v=${1}
if [ -z "${m4_v}" ] ; then
  m4_v=1.4.18
fi

echo "Installing m4 ${m4_v}..."

check_modules
module purge

downloadPackage m4-${m4_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/m4-${m4_v} ] ; then
  rm -rf ${tmp}/m4-${m4_v}
fi

tar xvfz ${pkg}/m4-${m4_v}.tar.gz
cd ${tmp}/m4-${m4_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to enable compilation with glibc >= 2.28
# The problem is that the authors of m4 made some code that depended
# on glibc internal symbols, which they shouldn't have done. In
# version 2.28, glibc took those symbols internally and broke m4.
# This patch is a workaround.
# Sourced fix from https://sources.debian.org/patches/m4/1.4.18-5/
if [ "${m4_v}" == "1.4.17" ] ; then

cat << eof > gnulib.patch
--- lib/fflush.c	2013-09-22 01:15:20.000000000 -0500
+++ lib/fflush.c	2023-04-01 18:31:19.220533268 -0500
@@ -33,7 +33,7 @@
 #undef fflush
 
 
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
 
 /* Clear the stream's ungetc buffer, preserving the value of ftello (fp).  */
 static void
@@ -71,7 +71,7 @@
 
 #endif
 
-#if ! (defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */)
+#if ! (defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */)
 
 # if (defined __sferror || defined __DragonFly__) && defined __SNPT /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin */
 
@@ -145,7 +145,7 @@
   if (stream == NULL || ! freading (stream))
     return fflush (stream);
 
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
 
   clear_ungetc_buffer_preserving_position (stream);
 
--- lib/fpurge.c	2013-09-22 01:15:20.000000000 -0500
+++ lib/fpurge.c	2023-04-01 18:33:06.681998128 -0500
@@ -61,7 +61,7 @@
   /* Most systems provide FILE as a struct and the necessary bitmask in
      <stdio.h>, because they need it for implementing getc() and putc() as
      fast macros.  */
-# if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+# if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   fp->_IO_read_end = fp->_IO_read_ptr;
   fp->_IO_write_ptr = fp->_IO_write_base;
   /* Avoid memory leak when there is an active ungetc buffer.  */
--- lib/freadahead.c	2013-09-22 01:15:20.000000000 -0500
+++ lib/freadahead.c	2023-04-01 18:34:12.982879137 -0500
@@ -25,7 +25,7 @@
 size_t
 freadahead (FILE *fp)
 {
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   if (fp->_IO_write_ptr > fp->_IO_write_base)
     return 0;
   return (fp->_IO_read_end - fp->_IO_read_ptr)
--- lib/freading.c	2013-09-22 01:15:20.000000000 -0500
+++ lib/freading.c	2023-04-01 18:34:32.519135827 -0500
@@ -31,7 +31,7 @@
   /* Most systems provide FILE as a struct and the necessary bitmask in
      <stdio.h>, because they need it for implementing getc() and putc() as
      fast macros.  */
-# if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+# if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   return ((fp->_flags & _IO_NO_WRITES) != 0
           || ((fp->_flags & (_IO_NO_READS | _IO_CURRENTLY_PUTTING)) == 0
               && fp->_IO_read_base != NULL));
--- lib/fseeko.c	2013-09-22 01:15:55.000000000 -0500
+++ lib/fseeko.c	2023-04-01 18:35:00.459500778 -0500
@@ -47,7 +47,7 @@
 #endif
 
   /* These tests are based on fpurge.c.  */
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   if (fp->_IO_read_end == fp->_IO_read_ptr
       && fp->_IO_write_ptr == fp->_IO_write_base
       && fp->_IO_save_base == NULL)
@@ -121,7 +121,7 @@
           return -1;
         }
 
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
       fp->_flags &= ~_IO_EOF_SEEN;
       fp->_offset = pos;
 #elif defined __sferror || defined __DragonFly__ /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin */
--- lib/stdio-impl.h	2013-09-22 01:20:02.000000000 -0500
+++ lib/stdio-impl.h	2023-04-01 18:36:02.732305761 -0500
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
if [ "${m4_v}" == "1.4.18" ] ; then

cat << eof > gnulib.patch
--- lib/fflush.c	2016-12-31 07:54:41.000000000 -0600
+++ lib/fflush.c	2023-03-31 10:11:25.647866549 -0500
@@ -33,7 +33,7 @@
 #undef fflush
 
 
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
 
 /* Clear the stream's ungetc buffer, preserving the value of ftello (fp).  */
 static void
@@ -72,7 +72,7 @@
 
 #endif
 
-#if ! (defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */)
+#if ! (defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */)
 
 # if (defined __sferror || defined __DragonFly__ || defined __ANDROID__) && defined __SNPT
 /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin, Android */
@@ -148,7 +148,7 @@
   if (stream == NULL || ! freading (stream))
     return fflush (stream);
 
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
 
   clear_ungetc_buffer_preserving_position (stream);
 
--- lib/fpending.c	2016-12-31 07:54:41.000000000 -0600
+++ lib/fpending.c	2023-03-31 10:11:25.647866549 -0500
@@ -32,7 +32,7 @@
   /* Most systems provide FILE as a struct and the necessary bitmask in
      <stdio.h>, because they need it for implementing getc() and putc() as
      fast macros.  */
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   return fp->_IO_write_ptr - fp->_IO_write_base;
 #elif defined __sferror || defined __DragonFly__ || defined __ANDROID__
   /* FreeBSD, NetBSD, OpenBSD, DragonFly, Mac OS X, Cygwin, Android */
--- lib/fpurge.c	2016-12-31 07:54:41.000000000 -0600
+++ lib/fpurge.c	2023-03-31 10:11:25.647866549 -0500
@@ -62,7 +62,7 @@
   /* Most systems provide FILE as a struct and the necessary bitmask in
      <stdio.h>, because they need it for implementing getc() and putc() as
      fast macros.  */
-# if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+# if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   fp->_IO_read_end = fp->_IO_read_ptr;
   fp->_IO_write_ptr = fp->_IO_write_base;
   /* Avoid memory leak when there is an active ungetc buffer.  */
--- lib/freadahead.c	2016-12-31 07:54:41.000000000 -0600
+++ lib/freadahead.c	2023-03-31 10:11:25.647866549 -0500
@@ -25,7 +25,7 @@
 size_t
 freadahead (FILE *fp)
 {
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   if (fp->_IO_write_ptr > fp->_IO_write_base)
     return 0;
   return (fp->_IO_read_end - fp->_IO_read_ptr)
--- lib/freading.c	2016-12-31 07:54:41.000000000 -0600
+++ lib/freading.c	2023-03-31 10:11:25.647866549 -0500
@@ -31,7 +31,7 @@
   /* Most systems provide FILE as a struct and the necessary bitmask in
      <stdio.h>, because they need it for implementing getc() and putc() as
      fast macros.  */
-# if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+# if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   return ((fp->_flags & _IO_NO_WRITES) != 0
           || ((fp->_flags & (_IO_NO_READS | _IO_CURRENTLY_PUTTING)) == 0
               && fp->_IO_read_base != NULL));
--- lib/fseeko.c	2016-12-31 07:54:41.000000000 -0600
+++ lib/fseeko.c	2023-03-31 10:11:25.647866549 -0500
@@ -47,7 +47,7 @@
 #endif
 
   /* These tests are based on fpurge.c.  */
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
   if (fp->_IO_read_end == fp->_IO_read_ptr
       && fp->_IO_write_ptr == fp->_IO_write_base
       && fp->_IO_save_base == NULL)
@@ -123,7 +123,7 @@
           return -1;
         }
 
-#if defined _IO_ftrylockfile || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
+#if defined _IO_EOF_SEEN || __GNU_LIBRARY__ == 1 /* GNU libc, BeOS, Haiku, Linux libc5 */
       fp->_flags &= ~_IO_EOF_SEEN;
       fp->_offset = pos;
 #elif defined __sferror || defined __DragonFly__ || defined __ANDROID__
--- lib/stdio-impl.h	2016-12-31 07:54:42.000000000 -0600
+++ lib/stdio-impl.h	2023-03-31 10:11:25.647866549 -0500
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

config="./configure --prefix=${opt}/m4-${m4_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
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
mkdir -pv ${MODULEPATH}/m4
cat << eof > ${MODULEPATH}/m4/${m4_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts m4-${m4_v} into your environment"
}

set VER ${m4_v}
set PKG ${opt}/m4-\$VER

module-whatis   "Loads m4-${m4_v}"
conflict m4

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/m4-${m4_v}

}
