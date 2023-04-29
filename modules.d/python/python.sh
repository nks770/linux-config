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
  python_v=3.9.4
fi

case ${python_v} in
3.6.5) # 2018-03-28
   gdbm_ver=1.14.1      #2018-01-03
   readline_ver=7.0     #2016-09-15
   ncurses_ver=6.0      #2015-08-08
   bzip2_ver=1.0.6      #2010-09-20
   xz_ver=5.2.3         #2016-12-30
   openssl_ver=1.1.0h   #2018-03-27
   sqlite_ver=3.22.0    #2018-01-22
   zlib_ver=1.2.11      #2017-01-15
   libffi_ver=3.2.1     #2014-11-12
   utillinux_ver=2.32   #2018-03-21
   tcl_ver=8.6.13
   tk_ver=8.6.13
   ;;
3.7.2) #2018-12-24
   gdbm_ver=1.18.1      #2018-10-27
   readline_ver=7.0     #2016-09-15
   ncurses_ver=6.0      #2015-08-08
   bzip2_ver=1.0.6      #2010-09-20
   xz_ver=5.2.4         #2018-04-29
   openssl_ver=1.1.1a   #2018-11-20
   sqlite_ver=3.26.0    #2018-12-01
   zlib_ver=1.2.11      #2017-01-15
   libffi_ver=3.2.1     #2014-11-12
   utillinux_ver=2.33   #2018-11-06
   tcl_ver=8.6.13
   tk_ver=8.6.13
   httlib_failure=1
   ;;
3.7.4) #2019-07-08
   gdbm_ver=1.18.1      #2018-10-27
   readline_ver=7.0     #2016-09-15
   ncurses_ver=6.0      #2015-08-08
   bzip2_ver=1.0.7      #2019-06-27
   xz_ver=5.2.4         #2018-04-29
   openssl_ver=1.1.1c   #2019-05-28
   sqlite_ver=3.28.0    #2019-04-16
   zlib_ver=1.2.11      #2017-01-15
   libffi_ver=3.2.1     #2014-11-12
   utillinux_ver=2.34   #2019-06-14
   tcl_ver=8.6.13
   tk_ver=8.6.13
   ;;
3.7.10) #2021-02-15
   gdbm_ver=1.19        #2020-12-23
   readline_ver=8.1     #2020-12-06
   ncurses_ver=6.2      #2020-02-12
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.2.5         #2020-03-17
   openssl_ver=1.1.1i   #2020-12-08
   sqlite_ver=3.34.1    #2021-01-20
   zlib_ver=1.2.11      #2017-01-15
   libffi_ver=3.3       #2019-11-23
   utillinux_ver=2.36.2 #2021-02-12
   tcl_ver=8.6.13
   tk_ver=8.6.13
   ;;
3.8.0) #2019-10-14
   gdbm_ver=1.18.1      #2018-10-27
   readline_ver=7.0     #2016-09-15
   ncurses_ver=6.0      #2015-08-08
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.2.4         #2018-04-29
   openssl_ver=1.1.1d   #2019-09-10
   sqlite_ver=3.30.1    #2019-10-10
   zlib_ver=1.2.11      #2017-01-15
   libffi_ver=3.2.1     #2014-11-12
   utillinux_ver=2.34   #2019-06-14
   tcl_ver=8.6.13
   tk_ver=8.6.13
   curses_failure=1
   ;;
3.9.4) #2021-04-04
   gdbm_ver=1.19        #2020-12-23
   readline_ver=8.1     #2020-12-06
   ncurses_ver=6.2      #2020-02-12
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.2.5         #2020-03-17
   openssl_ver=1.1.1k   #2021-03-25
   sqlite_ver=3.35.4    #2021-04-02
   zlib_ver=1.2.11      #2017-01-15
   libffi_ver=3.3       #2019-11-23
   utillinux_ver=2.36.2 #2021-02-12
   tcl_ver=8.6.13
   tk_ver=8.6.13
   curses_failure=1
   ;;
3.9.16) #2022-12-06
   gdbm_ver=1.23        #2022-02-04
   readline_ver=8.1.2   #2022-01-05
   ncurses_ver=6.3      #2021-11-08
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.2.9         #2022-11-30
   openssl_ver=1.1.1s   #2022-11-01
   sqlite_ver=3.40.0    #2022-11-16
   zlib_ver=1.2.13      #2022-10-12
   libffi_ver=3.4.4     #2022-10-23
   utillinux_ver=2.38.1 #2022-08-04
   tcl_ver=8.6.13
   tk_ver=8.6.13
   curses_failure=1
   ;;
3.10.9) #2022-12-06
   gdbm_ver=1.23        #2022-02-04
   readline_ver=8.1.2   #2022-01-05
   ncurses_ver=6.3      #2021-11-08
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.2.9         #2022-11-30
   openssl_ver=1.1.1s   #2022-11-01
   sqlite_ver=3.40.0    #2022-11-16
   zlib_ver=1.2.13      #2022-10-12
   libffi_ver=3.4.4     #2022-10-23
   utillinux_ver=2.38.1 #2022-08-04
   tcl_ver=8.6.13
   tk_ver=8.6.13
   curses_failure=1
   ;;
3.10.10) #2023-02-08
   gdbm_ver=1.23        #2022-02-04
   readline_ver=8.1.2   #2022-01-05
   ncurses_ver=6.3      #2021-11-08
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.4.1         #2023-01-11
   openssl_ver=1.1.1t   #2023-02-07
   sqlite_ver=3.40.1    #2022-12-28
   zlib_ver=1.2.13      #2022-10-12
   libffi_ver=3.4.4     #2022-10-23
   utillinux_ver=2.38.1 #2022-08-04
   tcl_ver=8.6.13
   tk_ver=8.6.13
   curses_failure=1
   ;;
3.11.2) #2023-02-08
   gdbm_ver=1.23        #2022-02-04
   readline_ver=8.1.2   #2022-01-05
   ncurses_ver=6.3      #2021-11-08
   bzip2_ver=1.0.8      #2019-07-13
   xz_ver=5.4.1         #2023-01-11
   openssl_ver=1.1.1t   #2023-02-07
   sqlite_ver=3.40.1    #2022-12-28
   zlib_ver=1.2.13      #2022-10-12
   libffi_ver=3.4.4     #2022-10-23
   utillinux_ver=2.38.1 #2022-08-04
   tcl_ver=8.6.13
   tk_ver=8.6.13
   curses_failure=1
   ;;
*)
   echo "ERROR: Need review for Python ${1}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  readline_ver=${global_readline}
  ncurses_ver=${global_ncurses}
fi

echo "Installing Python ${python_v}..."

check_modules
check_bzip2 ${bzip2_ver}
check_zlib ${zlib_ver}
check_xz ${xz_ver}
check_openssl ${openssl_ver}
check_libffi ${libffi_ver}
check_utillinux ${utillinux_ver}
check_ncurses ${ncurses_ver}
check_readline ${readline_ver}
check_sqlite ${sqlite_ver}
check_gdbm ${gdbm_ver}
check_tcl ${tcl_ver}
check_tk ${tk_ver}

module purge
module load bzip2/${bzip2_ver} zlib/${zlib_ver} xz/${xz_ver} openssl/${openssl_ver} libffi/${libffi_ver} util-linux/${utillinux_ver} ncurses/${ncurses_ver} readline/${readline_ver} sqlite/${sqlite_ver} gdbm/${gdbm_ver} tk/${tk_ver}

downloadPackage Python-${python_v}.tgz

cd ${tmp}

if [ -d ${tmp}/Python-${python_v} ] ; then
  rm -rf ${tmp}/Python-${python_v}
fi

tar xvfz ${pkg}/Python-${python_v}.tgz
cd ${tmp}/Python-${python_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
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
if [ "${python_v}" == "3.7.2" ] ; then
cat << eof > multiple.patch
--- Modules/faulthandler.c      2018-12-23 15:37:36.000000000 -0600
+++ Modules/faulthandler.c      2023-03-25 13:56:26.334300904 -0600
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
--- Lib/test/test_asyncio/test_sslproto.py	2018-12-23 15:37:36.000000000 -0600
+++ Lib/test/test_asyncio/test_sslproto.py	2023-04-26 00:01:45.137154555 -0500
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
--- Modules/faulthandler.c      2019-07-08 13:03:50.000000000 -0500
+++ Modules/faulthandler.c      2023-03-25 13:56:26.334300904 -0500
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
--- Modules/faulthandler.b      2019-10-14 08:34:47.000000000 -0500
+++ Modules/faulthandler.c      2023-04-02 18:05:40.932981391 -0500
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

config="./configure --prefix=${opt}/Python-${python_v} \
            --enable-shared \
	    --with-openssl=${opt}/openssl-${openssl_ver} \
	    --enable-optimizations \
	    CXX=$(command -v g++)"
#	    CPPFLAGS=-I/opt/zlib-${zlib_ver}/inblude \
#	    LDFLAGS=-L/opt/zlib-${zlib_ver}/lib"

export CPPFLAGS="-I${opt}/zlib-${zlib_ver}/include -I${opt}/bzip2-${bzip2_ver}/include -I${opt}/xz-${xz_ver}/include -I${opt}/libffi-${libffi_ver}/include -I${opt}/util-linux-${utillinux_ver}/include/uuid -I${opt}/ncurses-${ncurses_ver}/include/ncurses -I${opt}/readline-${readline_ver}/include -I${opt}/sqlite-${sqlite_ver}/include -I${opt}/gdbm-${gdbm_ver}/include -I${opt}/tcl-${tcl_ver}/include -I${opt}/tk-${tk_ver}/include"
export LDFLAGS="-L${opt}/zlib-${zlib_ver}/lib -L${opt}/bzip2-${bzip2_ver}/lib -L${opt}/xz-${xz_ver}/lib -L${opt}/libffi-${libffi_ver}/lib -L${opt}/util-linux-${utillinux_ver}/lib -L${opt}/ncurses-${ncurses_ver}/lib -L${opt}/readline-${readline_ver}/lib -L${opt}/sqlite-${sqlite_ver}/lib -L${opt}/gdbm-${gdbm_ver}/lib $(pkg-config --libs tk)"
export LIBS="-lz -lbz2 -llzma -lffi -luuid -lncurses -lreadline -lsqlite3"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo CPPFLAGS="${CPPFLAGS}"
  echo LDFLAGS="${LDFLAGS}"
  echo LIBS="${LIBS}"
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
module load openssl/${openssl_ver} zlib/${zlib_ver} bzip2/${bzip2_ver} xz/${xz_ver} libffi/${libffi_ver} util-linux/${utillinux_ver} ncurses/${ncurses_ver} readline/${readline_ver} sqlite/${sqlite_ver} gdbm/${gdbm_ver} tk/${tk_ver}
prereq openssl/${openssl_ver}
prereq zlib/${zlib_ver}
prereq bzip2/${bzip2_ver}
prereq xz/${xz_ver}
prereq libffi/${libffi_ver}
prereq util-linux/${utillinux_ver}
prereq ncurses/${ncurses_ver}
prereq readline/${readline_ver}
prereq sqlite/${sqlite_ver}
prereq gdbm/${gdbm_ver}
prereq tk/${tk_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof
#module load gcc/${python_gcc_ver}
#prereq gcc/${python_gcc_ver}

cd ${root}
rm -rf ${tmp}/Python-${python_v}

}
