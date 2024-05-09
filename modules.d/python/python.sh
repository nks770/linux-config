#!/bin/bash

# Functions for detecting and building Python
echo 'Loading Python...'

function pythonInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check python
if [ ! -f ${MODULEPATH}/Python/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_python() {
if pythonInstalled ${1}; then
  echo "Python ${1} is installed."
else
  build_python ${1}
fi
}

function build_python() {

# Get desired version number to install
python_v=${1}
if [ -z "${python_v}" ] ; then
  echo "ERROR: No Python version specified!"
  exit 2
fi

curses_failure=0
httlib_failure=0
sql_deterministic_chk=1

case ${python_v} in
2.7.6) # 2013-11-10
   python_gdbm_ver=1.10        #2011-11-13
   python_readline_ver=6.2     #2011-02-13
   python_ncurses_ver=5.7      #2008-11-02
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.0.5         #2013-06-30
   python_openssl_ver=1.0.1e   #2013-02-11
   python_sqlite_ver=3.8.1     #2013-10-17
   python_zlib_ver=1.2.8       #2013-04-28
   python_libffi_ver=3.0.13    #2013-03-17
   python_utillinux_ver=2.24   #2013-10-21
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.3.3) # 2013-11-17
   python_gdbm_ver=1.10        #2011-11-13
   python_readline_ver=6.2     #2011-02-13
   python_ncurses_ver=5.7      #2008-11-02
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.0.5         #2013-06-30
   python_openssl_ver=1.0.1e   #2013-02-11
   python_sqlite_ver=3.8.1     #2013-10-17
   python_zlib_ver=1.2.8       #2013-04-28
   python_libffi_ver=3.0.13    #2013-03-17
   python_utillinux_ver=2.24   #2013-10-21
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.5.2) # 2016-06-27
   python_gdbm_ver=1.12        #2016-05-16
   python_readline_ver=6.3     #2014-02-26
   python_ncurses_ver=5.9      #2011-04-04
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.2.2         #2015-09-29
   python_openssl_ver=1.0.2h   #2016-05-03
   python_sqlite_ver=3.13.0    #2016-05-18
   python_zlib_ver=1.2.8       #2013-04-28
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.28   #2016-04-12
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.6.0) # 2016-12-23
   python_gdbm_ver=1.12        #2016-05-16
   python_readline_ver=6.3     #2014-02-26
   python_ncurses_ver=5.9      #2011-04-04
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.2.2         #2015-09-29
   python_openssl_ver=1.1.0c   #2016-11-10
   python_sqlite_ver=3.15.2    #2016-11-28
   python_zlib_ver=1.2.8       #2013-04-28
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.29   #2016-11-08
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.6.4) # 2017-12-19
   python_gdbm_ver=1.13        #2017-03-11
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.2.3         #2016-12-30
   python_openssl_ver=1.1.0g   #2017-11-02
   python_sqlite_ver=3.21.0    #2017-10-24
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.31.1 #2017-12-19
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.6.5) # 2018-03-28
   python_gdbm_ver=1.14.1      #2018-01-03
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.2.3         #2016-12-30
   python_openssl_ver=1.1.0h   #2018-03-27
   python_sqlite_ver=3.22.0    #2018-01-22
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.32   #2018-03-21
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.7.1) #2018-10-20
   python_gdbm_ver=1.18        #2018-08-21
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.2.4         #2018-04-29
   python_openssl_ver=1.1.1    #2018-09-11
   python_sqlite_ver=3.25.2    #2018-09-25
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.32.1 #2018-07-16
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   httlib_failure=1
   ;;
3.7.2) #2018-12-24
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.6      #2010-09-20
   python_xz_ver=5.2.4         #2018-04-29
   python_openssl_ver=1.1.1a   #2018-11-20
   python_sqlite_ver=3.26.0    #2018-12-01
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.33   #2018-11-06
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   httlib_failure=1
   ;;
3.7.4) #2019-07-08
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.7      #2019-06-27
   python_xz_ver=5.2.4         #2018-04-29
   python_openssl_ver=1.1.1c   #2019-05-28
   python_sqlite_ver=3.28.0    #2019-04-16
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.34   #2019-06-14
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.7.10) #2021-02-15
   python_gdbm_ver=1.19        #2020-12-23
   python_readline_ver=8.1     #2020-12-06
   python_ncurses_ver=6.2      #2020-02-12
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1i   #2020-12-08
   python_sqlite_ver=3.34.1    #2021-01-20
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.36.2 #2021-02-12
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   ;;
3.8.0) #2019-10-14
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.4         #2018-04-29
   python_openssl_ver=1.1.1d   #2019-09-10
   python_sqlite_ver=3.30.1    #2019-10-10
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.2.1     #2014-11-12
   python_utillinux_ver=2.34   #2019-06-14
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=0
   sql_deterministic_chk=1
   ;;
3.8.1) #2019-12-18
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.4         #2018-04-29
   python_openssl_ver=1.1.1d   #2019-09-10
   python_sqlite_ver=3.30.1    #2019-10-10
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.34   #2019-06-14
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=0
   sql_deterministic_chk=0
   ;;
3.8.2) #2020-02-24
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.4         #2018-04-29
   python_openssl_ver=1.1.1d   #2019-09-10
   python_sqlite_ver=3.31.1    #2020-01-27
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.35.1 #2020-01-31
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=0
   sql_deterministic_chk=0
   ;;
3.8.3) #2020-05-13
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1g   #2020-04-21
   python_sqlite_ver=3.31.1    #2020-01-27
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.35.1 #2020-01-31
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=0
   sql_deterministic_chk=0
   ;;
3.8.5) #2020-07-20
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1g   #2020-04-21
   python_sqlite_ver=3.32.3    #2020-06-18
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.35.2 #2020-05-20
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=0
   sql_deterministic_chk=0
   ;;
3.9.0) #2020-10-05
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1h   #2020-09-22
   python_sqlite_ver=3.33.0    #2020-08-14
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.36   #2020-07-23
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.9.1) #2020-12-07
   python_gdbm_ver=1.18.1      #2018-10-27
   python_readline_ver=7.0     #2016-09-15
   python_ncurses_ver=6.0      #2015-08-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1h   #2020-09-22
   python_sqlite_ver=3.34.0    #2020-12-01
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.36.1 #2020-11-16
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.9.2) #2021-02-19
   python_gdbm_ver=1.19        #2020-12-23
   python_readline_ver=8.1     #2020-12-06
   python_ncurses_ver=6.2      #2020-02-12
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1j   #2021-02-16
   python_sqlite_ver=3.34.1    #2021-01-20
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.36.2 #2021-02-12
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.9.4) #2021-04-04
   python_gdbm_ver=1.19        #2020-12-23
   python_readline_ver=8.1     #2020-12-06
   python_ncurses_ver=6.2      #2020-02-12
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.5         #2020-03-17
   python_openssl_ver=1.1.1k   #2021-03-25
   python_sqlite_ver=3.35.4    #2021-04-02
   python_zlib_ver=1.2.11      #2017-01-15
   python_libffi_ver=3.3       #2019-11-23
   python_utillinux_ver=2.36.2 #2021-02-12
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.9.16) #2022-12-06
   python_gdbm_ver=1.23        #2022-02-04
   python_readline_ver=8.1.2   #2022-01-05
   python_ncurses_ver=6.3      #2021-11-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.9         #2022-11-30
   python_openssl_ver=1.1.1s   #2022-11-01
   python_sqlite_ver=3.40.0    #2022-11-16
   python_zlib_ver=1.2.13      #2022-10-12
   python_libffi_ver=3.4.4     #2022-10-23
   python_utillinux_ver=2.38.1 #2022-08-04
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.10.9) #2022-12-06
   python_gdbm_ver=1.23        #2022-02-04
   python_readline_ver=8.1.2   #2022-01-05
   python_ncurses_ver=6.3      #2021-11-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.2.9         #2022-11-30
   python_openssl_ver=1.1.1s   #2022-11-01
   python_sqlite_ver=3.40.0    #2022-11-16
   python_zlib_ver=1.2.13      #2022-10-12
   python_libffi_ver=3.4.4     #2022-10-23
   python_utillinux_ver=2.38.1 #2022-08-04
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.10.10) #2023-02-08
   python_gdbm_ver=1.23        #2022-02-04
   python_readline_ver=8.1.2   #2022-01-05
   python_ncurses_ver=6.3      #2021-11-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.4.1         #2023-01-11
   python_openssl_ver=1.1.1t   #2023-02-07
   python_sqlite_ver=3.40.1    #2022-12-28
   python_zlib_ver=1.2.13      #2022-10-12
   python_libffi_ver=3.4.4     #2022-10-23
   python_utillinux_ver=2.38.1 #2022-08-04
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.11.2) #2023-02-08
   python_gdbm_ver=1.23        #2022-02-04
   python_readline_ver=8.1.2   #2022-01-05
   python_ncurses_ver=6.3      #2021-11-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.4.1         #2023-01-11
   python_openssl_ver=1.1.1t   #2023-02-07
   python_sqlite_ver=3.40.1    #2022-12-28
   python_zlib_ver=1.2.13      #2022-10-12
   python_libffi_ver=3.4.4     #2022-10-23
   python_utillinux_ver=2.38.1 #2022-08-04
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   ;;
3.11.4) #2023-06-06
   python_gdbm_ver=1.23        #2022-02-04
   python_readline_ver=8.1.2   #2022-01-05
   python_ncurses_ver=6.3      #2021-11-08
   python_bzip2_ver=1.0.8      #2019-07-13
   python_xz_ver=5.4.3         #2023-05-04
   python_openssl_ver=1.1.1u   #2023-05-30
   python_sqlite_ver=3.42.0    #2023-05-16
   python_zlib_ver=1.2.13      #2022-10-12
   python_libffi_ver=3.4.4     #2022-10-23
   python_utillinux_ver=2.39   #2023-05-17
   python_tcl_ver=8.6.13
   python_tk_ver=8.6.13
   curses_failure=1
   sql_deterministic_chk=0
   ;;
*)
   echo "ERROR: Need review for Python ${1}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  python_bzip2_ver=${global_bzip2}
  python_ncurses_ver=${global_ncurses}
  python_openssl_ver=${global_openssl}
  python_readline_ver=${global_readline}
  python_utillinux_ver=${global_utillinux}
  python_xz_ver=${global_xz}
  python_zlib_ver=${global_zlib}
fi

# Python 3.3 is not compatible with OpenSSL 1.1.x
if [ "${python_v}" == "2.7.6" ] || [ "${python_v}" == "3.3.3" ] ; then
  python_openssl_ver=1.0.1e   #2013-02-11
fi
if [ "${python_v}" == "3.5.2" ] ; then
  python_openssl_ver=1.0.2h   #2016-05-03
fi

echo "Installing Python ${python_v}..."
python_srcdir=Python-${python_v}

check_modules
check_bzip2 ${python_bzip2_ver}
check_zlib ${python_zlib_ver}
check_xz ${python_xz_ver}
check_openssl ${python_openssl_ver}
check_libffi ${python_libffi_ver}
check_utillinux ${python_utillinux_ver}
check_ncurses ${python_ncurses_ver}
check_readline ${python_readline_ver}
check_sqlite ${python_sqlite_ver}
check_gdbm ${python_gdbm_ver}
check_tcl ${python_tcl_ver}
check_tk ${python_tk_ver}

downloadPackage Python-${python_v}.tgz

cd ${tmp}

if [ -d ${tmp}/${python_srcdir} ] ; then
  rm -rf ${tmp}/${python_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/Python-${python_v}.tgz
cd ${tmp}/${python_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to fix a segmentation fault with newer GCC
# Fix for over-aligned GC info
#
# https://src.fedoraproject.org/fork/churchyard/rpms/python2/blob/test_support/f/00293-fix-gc-alignment.patch
#
if [ "${python_v}" == "3.3.3" ] ; then
cat << eof > multiple.patch
--- Include/objimpl.h
+++ Include/objimpl.h
@@ -241,6 +241,18 @@
 #define PyObject_GC_Resize(type, op, n) \\
                 ( (type *) _PyObject_GC_Resize((PyVarObject *)(op), (n)) )
 
+/* Former over-aligned definition of PyGC_Head, used to compute the
+   size of the padding for the new version below. */
+union _gc_head;
+union _gc_head_old {
+    struct {
+        union _gc_head *gc_next;
+        union _gc_head *gc_prev;
+        Py_ssize_t gc_refs;
+    } gc;
+    long double dummy;
+};
+
 /* GC information is stored BEFORE the object structure. */
 #ifndef Py_LIMITED_API
 typedef union _gc_head {
@@ -249,7 +261,8 @@
         union _gc_head *gc_prev;
         Py_ssize_t gc_refs;
     } gc;
-    long double dummy;  /* force worst-case alignment */
+    double dummy;  /* force worst-case alignment */
+    char dummy_padding[sizeof(union _gc_head_old)];
 } PyGC_Head;
 
 extern PyGC_Head *_PyGC_generation0;
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -899,8 +899,12 @@
 static void*
 stack_overflow(void *min_sp, void *max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     void *sp = &buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
--- Modules/signalmodule.c
+++ Modules/signalmodule.c
@@ -538,7 +538,6 @@
     int result = -1;
     PyObject *iterator, *item;
     long signum;
-    int err;
 
     sigemptyset(mask);
 
@@ -560,11 +559,14 @@
         Py_DECREF(item);
         if (signum == -1 && PyErr_Occurred())
             goto error;
-        if (0 < signum && signum < NSIG)
-            err = sigaddset(mask, (int)signum);
-        else
-            err = 1;
-        if (err) {
+	if (0 < signum && signum < NSIG) {
+		/* bpo-33329: ignore sigaddset() return value as it can fail
+		 * for some reserved signals, but we want the \`range(1, NSIG)\`
+		 * idiom to allow selecting all valid signals.
+		 */
+		(void) sigaddset(mask, (int)signum);
+	}
+	else {
             PyErr_Format(PyExc_ValueError,
                          "signal number %ld out of range", signum);
             goto error;
eof
patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

if [ "${python_v}" == "3.5.2" ] ; then
cat << eof > multiple.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -951,18 +951,15 @@
 }
 
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-Py_uintptr_t
+static Py_uintptr_t
 stack_overflow(Py_uintptr_t min_sp, Py_uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     Py_uintptr_t sp = (Py_uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
--- Modules/signalmodule.c
+++ Modules/signalmodule.c
@@ -740,7 +740,6 @@
     int result = -1;
     PyObject *iterator, *item;
     long signum;
-    int err;
 
     sigemptyset(mask);
 
@@ -762,11 +761,14 @@
         Py_DECREF(item);
         if (signum == -1 && PyErr_Occurred())
             goto error;
-        if (0 < signum && signum < NSIG)
-            err = sigaddset(mask, (int)signum);
-        else
-            err = 1;
-        if (err) {
+	if (0 < signum && signum < NSIG) {
+		/* bpo-33329: ignore sigaddset() return value as it can fail
+		 * for some reserved signals, but we want the \`range(1, NSIG)\`
+		 * idiom to allow selecting all valid signals.
+		 */
+		(void) sigaddset(mask, (int)signum);
+	}
+	else {
             PyErr_Format(PyExc_ValueError,
                          "signal number %ld out of range", signum);
             goto error;
--- Lib/test/test_logging.py
+++ Lib/test/test_logging.py
@@ -1619,7 +1619,7 @@
         SysLogHandlerTest.tearDown(self)
         os.remove(self.address)
 
-@unittest.skipUnless(threading, 'Threading required for this test.')
+@unittest.skip('ssl.SSLError: [SSL: SSLV3_ALERT_CERTIFICATE_EXPIRED] sslv3 alert certificate expired (_ssl.c:645)')
 class HTTPHandlerTest(BaseTest):
     """Test for HTTPHandler."""
 
--- Lib/test/test_poplib.py
+++ Lib/test/test_poplib.py
@@ -11,7 +11,7 @@
 import time
 import errno
 
-from unittest import TestCase, skipUnless
+from unittest import TestCase, skipUnless, skip
 from test import support as test_support
 threading = test_support.import_module('threading')
 
@@ -346,7 +346,7 @@
         resp = self.client.stls()
         self.assertEqual(resp, expected)
 
-    @requires_ssl
+    @skip('ssl.SSLError: [SSL: SSLV3_ALERT_CERTIFICATE_EXPIRED] sslv3 alert certificate expired (_ssl.c:645)')
     def test_stls_context(self):
         expected = b'+OK Begin TLS negotiation'
         ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
--- Lib/test/test_urllib2net.py
+++ Lib/test/test_urllib2net.py
@@ -95,6 +95,7 @@
     # XXX The rest of these tests aren't very good -- they don't check much.
     # They do sometimes catch some major disasters, though.
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp(self):
         urls = [
             'ftp://ftp.debian.org/debian/README',
@@ -177,6 +178,7 @@
             opener.open(request)
             self.assertEqual(request.get_header('User-agent'),'Test-Agent')
 
+    @unittest.skip('ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:645)')
     def test_sites_no_connection_close(self):
         # Some sites do not send Connection: close header.
         # Verify that those work properly. (#issue12576)
@@ -289,6 +291,7 @@
 
     FTP_HOST = 'ftp://ftp.debian.org/debian/'
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_basic(self):
         self.assertIsNone(socket.getdefaulttimeout())
         with support.transient_internet(self.FTP_HOST, timeout=None):
@@ -296,6 +299,7 @@
             self.addCleanup(u.close)
             self.assertIsNone(u.fp.fp.raw._sock.gettimeout())
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_default_timeout(self):
         self.assertIsNone(socket.getdefaulttimeout())
         with support.transient_internet(self.FTP_HOST):
@@ -307,6 +311,7 @@
                 socket.setdefaulttimeout(None)
             self.assertEqual(u.fp.fp.raw._sock.gettimeout(), 60)
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_no_timeout(self):
         self.assertIsNone(socket.getdefaulttimeout())
         with support.transient_internet(self.FTP_HOST):
@@ -318,6 +323,7 @@
                 socket.setdefaulttimeout(None)
             self.assertIsNone(u.fp.fp.raw._sock.gettimeout())
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_timeout(self):
         with support.transient_internet(self.FTP_HOST):
             u = _urlopen_with_retry(self.FTP_HOST, timeout=60)
eof
patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

# test_socket.py issue - re: "test_aead_aes_gcm fails on Kernel 4.9"
# https://bugs.python.org/issue29324
if [ "${python_v}" == "3.6.0" ] ; then
cat << eof > multiple.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -1065,18 +1065,14 @@
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
 #define FAULTHANDLER_STACK_OVERFLOW
 
-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-uintptr_t
+static uintptr_t
 stack_overflow(uintptr_t min_sp, uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     uintptr_t sp = (uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
--- Modules/signalmodule.c
+++ Modules/signalmodule.c
@@ -735,7 +735,6 @@
     int result = -1;
     PyObject *iterator, *item;
     long signum;
-    int err;
 
     sigemptyset(mask);
 
@@ -757,11 +756,14 @@
         Py_DECREF(item);
         if (signum == -1 && PyErr_Occurred())
             goto error;
-        if (0 < signum && signum < NSIG)
-            err = sigaddset(mask, (int)signum);
-        else
-            err = 1;
-        if (err) {
+	if (0 < signum && signum < NSIG) {
+		/* bpo-33329: ignore sigaddset() return value as it can fail
+		 * for some reserved signals, but we want the \`range(1, NSIG)\`
+		 * idiom to allow selecting all valid signals.
+		 */
+		(void) sigaddset(mask, (int)signum);
+	}
+	else {
             PyErr_Format(PyExc_ValueError,
                          "signal number %ld out of range", signum);
             goto error;
--- Lib/test/test_logging.py
+++ Lib/test/test_logging.py
@@ -1677,7 +1677,7 @@
         SysLogHandlerTest.tearDown(self)
         os.remove(self.address)
 
-@unittest.skipUnless(threading, 'Threading required for this test.')
+@unittest.skip('ssl.SSLError: [SSL: SSLV3_ALERT_CERTIFICATE_EXPIRED] sslv3 alert certificate expired (_ssl.c:749)')
 class HTTPHandlerTest(BaseTest):
     """Test for HTTPHandler."""
 
--- Lib/test/test_poplib.py
+++ Lib/test/test_poplib.py
@@ -10,7 +10,7 @@
 import os
 import errno
 
-from unittest import TestCase, skipUnless
+from unittest import TestCase, skipUnless, skip
 from test import support as test_support
 threading = test_support.import_module('threading')
 
@@ -347,7 +347,7 @@
         resp = self.client.stls()
         self.assertEqual(resp, expected)
 
-    @requires_ssl
+    @skip('ssl.SSLError: [SSL: SSLV3_ALERT_CERTIFICATE_EXPIRED] sslv3 alert certificate expired (_ssl.c:749)')
     def test_stls_context(self):
         expected = b'+OK Begin TLS negotiation'
         ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
--- Lib/test/test_socket.py
+++ Lib/test/test_socket.py
@@ -5456,7 +5456,7 @@
             self.assertEqual(len(dec), msglen * multiplier)
             self.assertEqual(dec, msg * multiplier)
 
-    @support.requires_linux_version(4, 3)  # see test_aes_cbc
+    @support.requires_linux_version(4, 9)  # see issue29324
     def test_aead_aes_gcm(self):
         key = bytes.fromhex('c939cc13397c1d37de6ae0e1cb7c423c')
         iv = bytes.fromhex('b3d8cc017cbb89b39e0f67e2')
@@ -5479,8 +5479,7 @@
                 op.sendmsg_afalg(op=socket.ALG_OP_ENCRYPT, iv=iv,
                                  assoclen=assoclen, flags=socket.MSG_MORE)
                 op.sendall(assoc, socket.MSG_MORE)
-                op.sendall(plain, socket.MSG_MORE)
-                op.sendall(b'\\x00' * taglen)
+                op.sendall(plain)
                 res = op.recv(assoclen + len(plain) + taglen)
                 self.assertEqual(expected_ct, res[assoclen:-taglen])
                 self.assertEqual(expected_tag, res[-taglen:])
@@ -5488,7 +5487,7 @@
             # now with msg
             op, _ = algo.accept()
             with op:
-                msg = assoc + plain + b'\\x00' * taglen
+                msg = assoc + plain
                 op.sendmsg_afalg([msg], op=socket.ALG_OP_ENCRYPT, iv=iv,
                                  assoclen=assoclen)
                 res = op.recv(assoclen + len(plain) + taglen)
@@ -5499,7 +5498,7 @@
             pack_uint32 = struct.Struct('I').pack
             op, _ = algo.accept()
             with op:
-                msg = assoc + plain + b'\\x00' * taglen
+                msg = assoc + plain
                 op.sendmsg(
                     [msg],
                     ([socket.SOL_ALG, socket.ALG_SET_OP, pack_uint32(socket.ALG_OP_ENCRYPT)],
@@ -5507,7 +5506,7 @@
                      [socket.SOL_ALG, socket.ALG_SET_AEAD_ASSOCLEN, pack_uint32(assoclen)],
                     )
                 )
-                res = op.recv(len(msg))
+                res = op.recv(len(msg) + taglen)
                 self.assertEqual(expected_ct, res[assoclen:-taglen])
                 self.assertEqual(expected_tag, res[-taglen:])
 
@@ -5517,8 +5516,8 @@
                 msg = assoc + expected_ct + expected_tag
                 op.sendmsg_afalg([msg], op=socket.ALG_OP_DECRYPT, iv=iv,
                                  assoclen=assoclen)
-                res = op.recv(len(msg))
-                self.assertEqual(plain, res[assoclen:-taglen])
+                res = op.recv(len(msg) - taglen)
+                self.assertEqual(plain, res[assoclen:])
 
     @support.requires_linux_version(4, 3)  # see test_aes_cbc
     def test_drbg_pr_sha256(self):
--- Lib/test/test_urllib2net.py
+++ Lib/test/test_urllib2net.py
@@ -95,6 +95,7 @@
     # XXX The rest of these tests aren't very good -- they don't check much.
     # They do sometimes catch some major disasters, though.
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp(self):
         urls = [
             'ftp://ftp.debian.org/debian/README',
@@ -177,6 +178,7 @@
             opener.open(request)
             self.assertEqual(request.get_header('User-agent'),'Test-Agent')
 
+    @unittest.skip('ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:749)')
     def test_sites_no_connection_close(self):
         # Some sites do not send Connection: close header.
         # Verify that those work properly. (#issue12576)
@@ -289,6 +291,7 @@
 
     FTP_HOST = 'ftp://ftp.debian.org/debian/'
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_basic(self):
         self.assertIsNone(socket.getdefaulttimeout())
         with support.transient_internet(self.FTP_HOST, timeout=None):
@@ -296,6 +299,7 @@
             self.addCleanup(u.close)
             self.assertIsNone(u.fp.fp.raw._sock.gettimeout())
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_default_timeout(self):
         self.assertIsNone(socket.getdefaulttimeout())
         with support.transient_internet(self.FTP_HOST):
@@ -307,6 +311,7 @@
                 socket.setdefaulttimeout(None)
             self.assertEqual(u.fp.fp.raw._sock.gettimeout(), 60)
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_no_timeout(self):
         self.assertIsNone(socket.getdefaulttimeout())
         with support.transient_internet(self.FTP_HOST):
@@ -318,6 +323,7 @@
                 socket.setdefaulttimeout(None)
             self.assertIsNone(u.fp.fp.raw._sock.gettimeout())
 
+    @unittest.skip("ERROR: Resource 'ftp://ftp.debian.org/debian/' is not available")
     def test_ftp_timeout(self):
         with support.transient_internet(self.FTP_HOST):
             u = _urlopen_with_retry(self.FTP_HOST, timeout=60)
--- Lib/test/test_ftplib.py
+++ Lib/test/test_ftplib.py
@@ -16,7 +16,7 @@
 except ImportError:
     ssl = None
 
-from unittest import TestCase, skipUnless
+from unittest import TestCase, skipUnless, skip
 from test import support
 from test.support import HOST, HOSTv6
 threading = support.import_module('threading')
@@ -926,6 +926,7 @@
         self.client.ccc()
         self.assertRaises(ValueError, self.client.sock.unwrap)
 
+    @skip('ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:749)')
     def test_check_hostname(self):
         self.client.quit()
         ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
eof
patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

# Patch to fix an issue where test_faulthandler hangs indefinitely
# when Python is compiled with GCC10. This is caused by a compiler
# feature called tail call optimization, causing the resulting code
# to be an infinite loop.  This patch prevents tail call optimization
# from being applied to this code segment.
# https://github.com/python/cpython/pull/17467/files
#
# bpo-35998: Avoid TimeoutError in test_asyncio: test_start_tls_server_1()
#
if [ "${python_v}" == "3.6.4" ] ; then
cat << eof > multiple.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -1091,18 +1091,15 @@
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
 #define FAULTHANDLER_STACK_OVERFLOW
 
-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-uintptr_t
+static uintptr_t
 stack_overflow(uintptr_t min_sp, uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     uintptr_t sp = (uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
--- Modules/signalmodule.c
+++ Modules/signalmodule.c
@@ -759,7 +759,6 @@
     int result = -1;
     PyObject *iterator, *item;
     long signum;
-    int err;
 
     sigemptyset(mask);
 
@@ -781,11 +780,14 @@
         Py_DECREF(item);
         if (signum == -1 && PyErr_Occurred())
             goto error;
-        if (0 < signum && signum < NSIG)
-            err = sigaddset(mask, (int)signum);
-        else
-            err = 1;
-        if (err) {
+	if (0 < signum && signum < NSIG) {
+		/* bpo-33329: ignore sigaddset() return value as it can fail
+		 * for some reserved signals, but we want the \`range(1, NSIG)\`
+		 * idiom to allow selecting all valid signals.
+		 */
+		(void) sigaddset(mask, (int)signum);
+	}
+	else {
             PyErr_Format(PyExc_ValueError,
                          "signal number %ld out of range", signum);
             goto error;
--- Lib/test/test_logging.py
+++ Lib/test/test_logging.py
@@ -1742,7 +1742,7 @@
         self.server_class.address_family = socket.AF_INET
         super(IPv6SysLogHandlerTest, self).tearDown()
 
-@unittest.skipUnless(threading, 'Threading required for this test.')
+@unittest.skip('ssl.SSLError: [SSL: SSLV3_ALERT_CERTIFICATE_EXPIRED] sslv3 alert certificate expired (_ssl.c:777)')
 class HTTPHandlerTest(BaseTest):
     """Test for HTTPHandler."""
 
--- Lib/test/test_poplib.py
+++ Lib/test/test_poplib.py
@@ -10,7 +10,7 @@
 import os
 import errno
 
-from unittest import TestCase, skipUnless
+from unittest import TestCase, skipUnless, skip
 from test import support as test_support
 threading = test_support.import_module('threading')
 
@@ -349,7 +349,7 @@
         resp = self.client.stls()
         self.assertEqual(resp, expected)
 
-    @requires_ssl
+    @skip('ssl.SSLError: [SSL: SSLV3_ALERT_CERTIFICATE_EXPIRED] sslv3 alert certificate expired (_ssl.c:777)')
     def test_stls_context(self):
         expected = b'+OK Begin TLS negotiation'
         ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
--- Lib/test/test_urllib2net.py
+++ Lib/test/test_urllib2net.py
@@ -177,6 +177,7 @@
             opener.open(request)
             self.assertEqual(request.get_header('User-agent'),'Test-Agent')
 
+    @unittest.skip('ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:777)')
     def test_sites_no_connection_close(self):
         # Some sites do not send Connection: close header.
         # Verify that those work properly. (#issue12576)
--- Lib/test/test_ftplib.py
+++ Lib/test/test_ftplib.py
@@ -16,7 +16,7 @@
 except ImportError:
     ssl = None
 
-from unittest import TestCase, skipUnless
+from unittest import TestCase, skipUnless, skip
 from test import support
 from test.support import HOST, HOSTv6
 threading = support.import_module('threading')
@@ -939,6 +939,7 @@
         self.client.ccc()
         self.assertRaises(ValueError, self.client.sock.unwrap)
 
+    @skip('ssl.SSLError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:777)')
     def test_check_hostname(self):
         self.client.quit()
         ctx = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
eof
patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

if [ "${python_v}" == "3.7.1" ] ; then
cat << eof > multiple.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -1094,18 +1094,15 @@
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
 #define FAULTHANDLER_STACK_OVERFLOW

-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-uintptr_t
+static uintptr_t
 stack_overflow(uintptr_t min_sp, uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     uintptr_t sp = (uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
--- Lib/test/test_asyncio/test_sslproto.py
+++ Lib/test/test_asyncio/test_sslproto.py
@@ -423,11 +423,14 @@
 
     def test_start_tls_server_1(self):
         HELLO_MSG = b'1' * self.PAYLOAD_SIZE
+        ANSWER = b'answer'
 
         server_context = test_utils.simple_server_sslcontext()
         client_context = test_utils.simple_client_sslcontext()
+        answer = None
 
         def client(sock, addr):
+            nonlocal answer
             sock.settimeout(self.TIMEOUT)
 
             sock.connect(addr)
@@ -437,32 +440,36 @@
             sock.start_tls(client_context)
             sock.sendall(HELLO_MSG)
 
-            sock.shutdown(socket.SHUT_RDWR)
+            answer = sock.recv_all(len(ANSWER))
             sock.close()
 
         class ServerProto(asyncio.Protocol):
-            def __init__(self, on_con, on_eof, on_con_lost):
+            def __init__(self, on_con, on_con_lost):
                 self.on_con = on_con
-                self.on_eof = on_eof
                 self.on_con_lost = on_con_lost
                 self.data = b''
+                self.transport = None
 
             def connection_made(self, tr):
+                self.transport = tr
                 self.on_con.set_result(tr)
 
+            def replace_transport(self, tr):
+                self.transport = tr
+
             def data_received(self, data):
                 self.data += data
-
-            def eof_received(self):
-                self.on_eof.set_result(1)
+                if len(self.data) >= len(HELLO_MSG):
+                    self.transport.write(ANSWER)
 
             def connection_lost(self, exc):
+                self.transport = None
                 if exc is None:
                     self.on_con_lost.set_result(None)
                 else:
                     self.on_con_lost.set_exception(exc)
 
-        async def main(proto, on_con, on_eof, on_con_lost):
+        async def main(proto, on_con, on_con_lost):
             tr = await on_con
             tr.write(HELLO_MSG)
 
@@ -473,16 +480,16 @@
                 server_side=True,
                 ssl_handshake_timeout=self.TIMEOUT)
 
-            await on_eof
+            proto.replace_transport(new_tr)
+
             await on_con_lost
             self.assertEqual(proto.data, HELLO_MSG)
             new_tr.close()
 
         async def run_main():
             on_con = self.loop.create_future()
-            on_eof = self.loop.create_future()
             on_con_lost = self.loop.create_future()
-            proto = ServerProto(on_con, on_eof, on_con_lost)
+            proto = ServerProto(on_con, on_con_lost)
 
             server = await self.loop.create_server(
                 lambda: proto, '127.0.0.1', 0)
@@ -491,11 +498,12 @@
             with self.tcp_client(lambda sock: client(sock, addr),
                                  timeout=self.TIMEOUT):
                 await asyncio.wait_for(
-                    main(proto, on_con, on_eof, on_con_lost),
+                    main(proto, on_con, on_con_lost),
                     loop=self.loop, timeout=self.TIMEOUT)
 
             server.close()
             await server.wait_closed()
+            self.assertEqual(answer, ANSWER)
 
         self.loop.run_until_complete(run_main())
 
eof
patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

if [ "${python_v}" == "3.7.2" ] ; then
cat << eof > multiple.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -1094,18 +1094,15 @@
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
 #define FAULTHANDLER_STACK_OVERFLOW

-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-uintptr_t
+static uintptr_t
 stack_overflow(uintptr_t min_sp, uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     uintptr_t sp = (uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
--- Lib/test/test_asyncio/test_sslproto.py
+++ Lib/test/test_asyncio/test_sslproto.py
@@ -424,17 +424,14 @@
 
     def test_start_tls_server_1(self):
         HELLO_MSG = b'1' * self.PAYLOAD_SIZE
+        ANSWER = b'answer'
 
         server_context = test_utils.simple_server_sslcontext()
         client_context = test_utils.simple_client_sslcontext()
-        if sys.platform.startswith('freebsd'):
-            # bpo-35031: Some FreeBSD buildbots fail to run this test
-            # as the eof was not being received by the server if the payload
-            # size is not big enough. This behaviour only appears if the
-            # client is using TLS1.3.
-            client_context.options |= ssl.OP_NO_TLSv1_3
+        answer = None
 
         def client(sock, addr):
+            nonlocal answer
             sock.settimeout(self.TIMEOUT)
 
             sock.connect(addr)
@@ -443,33 +440,36 @@
 
             sock.start_tls(client_context)
             sock.sendall(HELLO_MSG)
-
-            sock.shutdown(socket.SHUT_RDWR)
+            answer = sock.recv_all(len(ANSWER))
             sock.close()
 
         class ServerProto(asyncio.Protocol):
-            def __init__(self, on_con, on_eof, on_con_lost):
+            def __init__(self, on_con, on_con_lost):
                 self.on_con = on_con
-                self.on_eof = on_eof
                 self.on_con_lost = on_con_lost
                 self.data = b''
+                self.transport = None
 
             def connection_made(self, tr):
+                self.transport = tr
                 self.on_con.set_result(tr)
 
+            def replace_transport(self, tr):
+                self.transport = tr
+
             def data_received(self, data):
                 self.data += data
-
-            def eof_received(self):
-                self.on_eof.set_result(1)
+                if len(self.data) >= len(HELLO_MSG):
+                    self.transport.write(ANSWER)
 
             def connection_lost(self, exc):
+                self.transport = None
                 if exc is None:
                     self.on_con_lost.set_result(None)
                 else:
                     self.on_con_lost.set_exception(exc)
 
-        async def main(proto, on_con, on_eof, on_con_lost):
+        async def main(proto, on_con, on_con_lost):
             tr = await on_con
             tr.write(HELLO_MSG)
 
@@ -480,16 +480,16 @@
                 server_side=True,
                 ssl_handshake_timeout=self.TIMEOUT)
 
-            await on_eof
+            proto.replace_transport(new_tr)
+
             await on_con_lost
             self.assertEqual(proto.data, HELLO_MSG)
             new_tr.close()
 
         async def run_main():
             on_con = self.loop.create_future()
-            on_eof = self.loop.create_future()
             on_con_lost = self.loop.create_future()
-            proto = ServerProto(on_con, on_eof, on_con_lost)
+            proto = ServerProto(on_con, on_con_lost)
 
             server = await self.loop.create_server(
                 lambda: proto, '127.0.0.1', 0)
@@ -498,11 +498,12 @@
             with self.tcp_client(lambda sock: client(sock, addr),
                                  timeout=self.TIMEOUT):
                 await asyncio.wait_for(
-                    main(proto, on_con, on_eof, on_con_lost),
+                    main(proto, on_con, on_con_lost),
                     loop=self.loop, timeout=self.TIMEOUT)
 
             server.close()
             await server.wait_closed()
+            self.assertEqual(answer, ANSWER)
 
         self.loop.run_until_complete(run_main())
 
eof
patch -Z -b -p0 < multiple.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

if [ "${python_v}" == "3.7.4" ] ; then
cat << eof > faulthandler.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -1094,18 +1094,15 @@
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
 #define FAULTHANDLER_STACK_OVERFLOW

-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-uintptr_t
+static uintptr_t
 stack_overflow(uintptr_t min_sp, uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     uintptr_t sp = (uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
eof
patch -Z -b -p0 < faulthandler.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

if [ "${python_v}" == "3.8.0" ] ; then
cat << eof > faulthandler.patch
--- Modules/faulthandler.c
+++ Modules/faulthandler.c
@@ -1097,18 +1097,15 @@
 #if defined(HAVE_SIGALTSTACK) && defined(HAVE_SIGACTION)
 #define FAULTHANDLER_STACK_OVERFLOW

-#ifdef __INTEL_COMPILER
-   /* Issue #23654: Turn off ICC's tail call optimization for the
-    * stack_overflow generator. ICC turns the recursive tail call into
-    * a loop. */
-#  pragma intel optimization_level 0
-#endif
-static
-uintptr_t
+static uintptr_t
 stack_overflow(uintptr_t min_sp, uintptr_t max_sp, size_t *depth)
 {
-    /* allocate 4096 bytes on the stack at each call */
-    unsigned char buffer[4096];
+    /* allocate (at least) 4096 bytes on the stack at each call
+     *
+     * Fix test_faulthandler on GCC 10. Use the "volatile" keyword in
+     * \`\`faulthandler._stack_overflow()\`\` to prevent tail call optimization on any
+     * compiler, rather than relying on compiler specific pragma. */
+    volatile unsigned char buffer[4096];
     uintptr_t sp = (uintptr_t)&buffer;
     *depth += 1;
     if (sp < min_sp || max_sp < sp)
eof
patch -Z -b -p0 < faulthandler.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
module load bzip2/${python_bzip2_ver}
module load zlib/${python_zlib_ver}
module load xz/${python_xz_ver}
module load openssl/${python_openssl_ver}
module load libffi/${python_libffi_ver}
module load util-linux/${python_utillinux_ver}
module load ncurses/${python_ncurses_ver}
module load readline/${python_readline_ver}
module load sqlite/${python_sqlite_ver}
module load gdbm/${python_gdbm_ver}
module load tk/${python_tk_ver}


if [ ! -z "${LIBFFI_INCLUDE}" ] ; then
  python_libffi_include=${LIBFFI_INCLUDE}
else
  python_libffi_include=${opt}/libffi-${python_libffi_ver}/include
fi


if [ "${python_v}" == "2.7.6" ] || [ "${python_v}" == "3.3.3" ] || [ "${python_v}" == "3.5.2" ] ; then

  config="./configure --prefix=${opt}/Python-${python_v} \
              --enable-shared \
  	    CXX=$(command -v g++)"
  export CPPFLAGS="-I${opt}/zlib-${python_zlib_ver}/include -I${opt}/bzip2-${python_bzip2_ver}/include -I${opt}/xz-${python_xz_ver}/include -I${python_libffi_include} -I${opt}/util-linux-${python_utillinux_ver}/include/uuid -I${opt}/ncurses-${python_ncurses_ver}/include/ncurses -I${opt}/readline-${python_readline_ver}/include -I${opt}/sqlite-${python_sqlite_ver}/include -I${opt}/gdbm-${python_gdbm_ver}/include -I${opt}/tcl-${python_tcl_ver}/include -I${opt}/tk-${python_tk_ver}/include -I${opt}/openssl-${python_openssl_ver}/include"
  export LDFLAGS="-L${opt}/zlib-${python_zlib_ver}/lib -L${opt}/bzip2-${python_bzip2_ver}/lib -L${opt}/xz-${python_xz_ver}/lib -L${opt}/libffi-${python_libffi_ver}/lib -L${opt}/util-linux-${python_utillinux_ver}/lib -L${opt}/ncurses-${python_ncurses_ver}/lib -L${opt}/readline-${python_readline_ver}/lib -L${opt}/sqlite-${python_sqlite_ver}/lib -L${opt}/gdbm-${python_gdbm_ver}/lib -L${opt}/openssl-${python_openssl_ver}/lib $(pkg-config --libs tk)"

elif [ "${python_v}" == "3.6.0" ] || [ "${python_v}" == "3.6.4" ] ; then

  config="./configure --prefix=${opt}/Python-${python_v} \
              --enable-shared \
  	    --enable-optimizations \
  	    CXX=$(command -v g++)"
  export CPPFLAGS="-I${opt}/zlib-${python_zlib_ver}/include -I${opt}/bzip2-${python_bzip2_ver}/include -I${opt}/xz-${python_xz_ver}/include -I${python_libffi_include} -I${opt}/util-linux-${python_utillinux_ver}/include/uuid -I${opt}/ncurses-${python_ncurses_ver}/include/ncurses -I${opt}/readline-${python_readline_ver}/include -I${opt}/sqlite-${python_sqlite_ver}/include -I${opt}/gdbm-${python_gdbm_ver}/include -I${opt}/tcl-${python_tcl_ver}/include -I${opt}/tk-${python_tk_ver}/include -I${opt}/openssl-${python_openssl_ver}/include"
  export LDFLAGS="-L${opt}/zlib-${python_zlib_ver}/lib -L${opt}/bzip2-${python_bzip2_ver}/lib -L${opt}/xz-${python_xz_ver}/lib -L${opt}/libffi-${python_libffi_ver}/lib -L${opt}/util-linux-${python_utillinux_ver}/lib -L${opt}/ncurses-${python_ncurses_ver}/lib -L${opt}/readline-${python_readline_ver}/lib -L${opt}/sqlite-${python_sqlite_ver}/lib -L${opt}/gdbm-${python_gdbm_ver}/lib -L${opt}/openssl-${python_openssl_ver}/lib $(pkg-config --libs tk)"

else

  config="./configure --prefix=${opt}/Python-${python_v} \
              --enable-shared \
  	    --with-openssl=${opt}/openssl-${python_openssl_ver} \
  	    --enable-optimizations \
  	    CXX=$(command -v g++)"
  export CPPFLAGS="-I${opt}/zlib-${python_zlib_ver}/include -I${opt}/bzip2-${python_bzip2_ver}/include -I${opt}/xz-${python_xz_ver}/include -I${python_libffi_include} -I${opt}/util-linux-${python_utillinux_ver}/include/uuid -I${opt}/ncurses-${python_ncurses_ver}/include/ncurses -I${opt}/readline-${python_readline_ver}/include -I${opt}/sqlite-${python_sqlite_ver}/include -I${opt}/gdbm-${python_gdbm_ver}/include -I${opt}/tcl-${python_tcl_ver}/include -I${opt}/tk-${python_tk_ver}/include"
  export LDFLAGS="-L${opt}/zlib-${python_zlib_ver}/lib -L${opt}/bzip2-${python_bzip2_ver}/lib -L${opt}/xz-${python_xz_ver}/lib -L${opt}/libffi-${python_libffi_ver}/lib -L${opt}/util-linux-${python_utillinux_ver}/lib -L${opt}/ncurses-${python_ncurses_ver}/lib -L${opt}/readline-${python_readline_ver}/lib -L${opt}/sqlite-${python_sqlite_ver}/lib -L${opt}/gdbm-${python_gdbm_ver}/lib $(pkg-config --libs tk)"

fi

export LIBS="-lz -lbz2 -llzma -lffi -luuid -lncurses -lreadline -lsqlite3"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo CPPFLAGS="${CPPFLAGS}"
  echo LDFLAGS="${LDFLAGS}"
  echo LIBS="${LIBS}"
  echo ''
  echo ${config}
  echo ''
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
#  if [ "${python_v}" == "3.6.4" ] ; then
#    #./python -m test -m test.test_logging.LogRecordTest.test_multiprocessing test_genericalias test_logging test_multiprocessing_fork -v
#    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${tmp}/Python-${python_v}
#    ./python -m test -m test_poplib
#    echo ''
#    echo '>> Poplib tests complete'
#    read k
#    ./python -m test -m test_multiprocessing_forkserver test_multiprocessing_fork test_multiprocessing_spawn -v
#    echo ''
#    echo '>> Multiprocessing tests complete'
#    read k
#  fi
  make test
  echo ''
  if [ ${curses_failure} -gt 0 ]; then
    echo 'NOTE: With Python 3.9.4 and Debian 11.5, I have observed that test_curses fails.'
    echo '      It seems there is a failure in test_background due to unexpected behavior'
    echo '      of the win.bkgd() function from libncurses.  This probably needs more investigation'
    echo '      but it might be fine.'
    echo ''
  fi
  if [ ${httlib_failure} -gt 0 ]; then
    echo ''
    echo 'NOTE: test_httlib fails in this version of Python with something about a self-signed'
    echo '      certificate not being accepted.  This may be related to OpenSSL 1.1.1'
    echo '      compatibility, but in any case is probably fine.'
    # make TESTS='test_ssl_new' V=1 test
    echo ''
  fi
  if [ ${sql_deterministic_chk} -gt 0 ] && [ "${python_sqlite_ver}" != "3.30.1" ] ; then
    echo ''
    echo 'NOTE: test_sqlite fails in Python 3.8 when linked with a version of Sqlite'
    echo "      newer than 3.32.0. (You have linked with version ${python_sqlite_ver}). This appears"
    echo "      to be a problem with the testsuite, and not a problem with the Python source"
    echo "      code itself.  Specific failed test: CheckFuncDeterministic"
    echo "      https://github.com/python/cpython/commit/c610d970f5373b143bf5f5900d4645e6a90fb460"
    echo ''
  fi
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

## Create a symlink to the executable
#cd ${opt}/Python-${python_v}/bin
#ln -sv python${python_v%.*} python

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/Python
cat << eof > ${MODULEPATH}/Python/${python_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts Python-${python_v} into your environment"
}

set VER ${python_v}
set PKG ${opt}/Python-\$VER

module-whatis   "Loads Python-${python_v}"
conflict Python
module load openssl/${python_openssl_ver}
module load zlib/${python_zlib_ver}
module load bzip2/${python_bzip2_ver}
module load xz/${python_xz_ver}
module load libffi/${python_libffi_ver}
module load util-linux/${python_utillinux_ver}
module load ncurses/${python_ncurses_ver}
module load readline/${python_readline_ver}
module load sqlite/${python_sqlite_ver}
module load gdbm/${python_gdbm_ver}
module load tk/${python_tk_ver}
prereq openssl/${python_openssl_ver}
prereq zlib/${python_zlib_ver}
prereq bzip2/${python_bzip2_ver}
prereq xz/${python_xz_ver}
prereq libffi/${python_libffi_ver}
prereq util-linux/${python_utillinux_ver}
prereq ncurses/${python_ncurses_ver}
prereq readline/${python_readline_ver}
prereq sqlite/${python_sqlite_ver}
prereq gdbm/${python_gdbm_ver}
prereq tk/${python_tk_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${python_srcdir}

unset CPPFLAGS
unset LDFLAGS
unset LIBS

}
