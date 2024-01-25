#!/bin/bash

# Functions for detecting and building OpenSSL
echo 'Loading OpenSSL...'

function opensslInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check openssl
if [ ! -f ${MODULEPATH}/openssl/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_openssl() {
if opensslInstalled ${1}; then
  echo "OpenSSL ${1} is installed."
else
  build_openssl ${1}
fi
}

function build_openssl() {

# Get desired version number to install
openssl_v=${1}
if [ -z "${openssl_v}" ] ; then
  echo "ERROR: No aribb24 version specified!"
  exit 2
fi

case ${openssl_v} in
1.0.1e) # 2013-02-11
   openssl_zlib_ver=1.2.7  # 2012-05-02
   cert_error_warn=1
   openssl_manpath=etc/ssl/man
   ;;
1.1.0g) # 2017-11-02
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.0h) # 2018-03-27
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.0l) # 2019-09-10
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1a) # 2018-11-20
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1c) # 2019-05-28
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1d) # 2019-09-10
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1i) # 2020-12-08
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1k) # 2021-03-25
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1n) # 2022-03-15
   openssl_zlib_ver=1.2.11 # 2017-01-15
   cert_error_warn=1
   openssl_manpath=share/man
   ;;
1.1.1s) # 2022-11-01
   openssl_zlib_ver=1.2.13 # 2022-10-12
   cert_error_warn=0
   openssl_manpath=share/man
   ;;
1.1.1t) # 2023-02-07
   openssl_zlib_ver=1.2.13 # 2022-10-12
   cert_error_warn=0
   openssl_manpath=share/man
   ;;
1.1.1u) # 2023-05-30
   openssl_zlib_ver=1.2.13 # 2022-10-12
   cert_error_warn=0
   openssl_manpath=share/man
   ;;
*)
   echo "ERROR: Review needed for openssl ${openssl_v}"
   exit 4
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  openssl_zlib_ver=${global_zlib}
fi

echo "Installing OpenSSL ${openssl_v}..."
openssl_srcdir=openssl-${openssl_v}

check_modules
check_zlib ${openssl_zlib_ver}

downloadPackage openssl-${openssl_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openssl_srcdir} ] ; then
  rm -rf ${tmp}/${openssl_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openssl-${openssl_v}.tar.gz
cd ${tmp}/${openssl_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to fix issues with installing the documentation.
if [ "${openssl_v}" == "1.0.1e" ] ; then
cat << eof > pod.patch
--- doc/apps/cms.pod
+++ doc/apps/cms.pod
@@ -450,28 +450,28 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 the operation was completely successfully.
 
-=item 1 
+=item Z<>1
 
 an error occurred parsing the command options.
 
-=item 2
+=item Z<>2
 
 one of the input files could not be read.
 
-=item 3
+=item Z<>3
 
 an error occurred creating the CMS file or when reading the MIME
 message.
 
-=item 4
+=item Z<>4
 
 an error occurred decrypting or verifying the message.
 
-=item 5
+=item Z<>5
 
 the message was verified correctly but an error occurred writing out
 the signers certificates.
--- doc/apps/smime.pod
+++ doc/apps/smime.pod
@@ -308,28 +308,28 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 the operation was completely successfully.
 
-=item 1 
+=item Z<>1
 
 an error occurred parsing the command options.
 
-=item 2
+=item Z<>2
 
 one of the input files could not be read.
 
-=item 3
+=item Z<>3
 
 an error occurred creating the PKCS#7 file or when reading the MIME
 message.
 
-=item 4
+=item Z<>4
 
 an error occurred decrypting or verifying the message.
 
-=item 5
+=item Z<>5
 
 the message was verified correctly but an error occurred writing out
 the signers certificates.
--- doc/crypto/X509_STORE_CTX_get_error.pod
+++ doc/crypto/X509_STORE_CTX_get_error.pod
@@ -278,6 +278,8 @@
 an application specific error. This will never be returned unless explicitly
 set by an application.
 
+=back
+
 =head1 NOTES
 
 The above functions should be used instead of directly referencing the fields
--- doc/ssl/SSL_COMP_add_compression_method.pod
+++ doc/ssl/SSL_COMP_add_compression_method.pod
@@ -53,11 +53,11 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The operation succeeded.
 
-=item 1
+=item Z<>1
 
 The operation failed. Check the error queue to find out the reason.
 
--- doc/ssl/SSL_CTX_add_session.pod
+++ doc/ssl/SSL_CTX_add_session.pod
@@ -52,13 +52,13 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
  The operation failed. In case of the add operation, it was tried to add
  the same (identical) session twice. In case of the remove operation, the
  session was not found in the cache.
 
-=item 1
+=item Z<>1
  
  The operation succeeded.
 
--- doc/ssl/SSL_CTX_load_verify_locations.pod
+++ doc/ssl/SSL_CTX_load_verify_locations.pod
@@ -100,13 +100,13 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The operation failed because B<CAfile> and B<CApath> are NULL or the
 processing at one of the locations specified failed. Check the error
 stack to find out the reason.
 
-=item 1
+=item Z<>1
 
 The operation succeeded.
 
--- doc/ssl/SSL_CTX_set_client_CA_list.pod
+++ doc/ssl/SSL_CTX_set_client_CA_list.pod
@@ -66,16 +66,16 @@
 
 =over 4
 
-=item 1
-
-The operation succeeded.
-
-=item 0
+=item Z<>0
 
 A failure while manipulating the STACK_OF(X509_NAME) object occurred or
 the X509_NAME could not be extracted from B<cacert>. Check the error stack
 to find out the reason.
 
+=item Z<>1
+
+The operation succeeded.
+
 =back
 
 =head1 EXAMPLES
--- doc/ssl/SSL_CTX_set_session_id_context.pod
+++ doc/ssl/SSL_CTX_set_session_id_context.pod
@@ -64,13 +64,13 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The length B<sid_ctx_len> of the session id context B<sid_ctx> exceeded
 the maximum allowed length of B<SSL_MAX_SSL_SESSION_ID_LENGTH>. The error
 is logged to the error stack.
 
-=item 1
+=item Z<>1
 
 The operation succeeded.
 
--- doc/ssl/SSL_CTX_set_ssl_version.pod
+++ doc/ssl/SSL_CTX_set_ssl_version.pod
@@ -42,11 +42,11 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The new choice failed, check the error stack to find out the reason.
 
-=item 1
+=item Z<>1
 
 The operation succeeded.
 
--- doc/ssl/SSL_CTX_use_psk_identity_hint.pod
+++ doc/ssl/SSL_CTX_use_psk_identity_hint.pod
@@ -81,6 +81,8 @@
 
 Return values from the server callback are interpreted as follows:
 
+=over 4
+
 =item > 0
 
 PSK identity was found and the server callback has provided the PSK
@@ -94,9 +96,11 @@
 connection will fail with decryption_error before it will be finished
 completely.
 
-=item 0
+=item Z<>0
 
 PSK identity was not found. An "unknown_psk_identity" alert message
 will be sent and the connection setup fails.
 
+=back
+
 =cut
--- doc/ssl/SSL_accept.pod
+++ doc/ssl/SSL_accept.pod
@@ -44,17 +44,17 @@
 
 =over 4
 
-=item 1
-
-The TLS/SSL handshake was successfully completed, a TLS/SSL connection has been
-established.
-
-=item 0
+=item Z<>0
 
 The TLS/SSL handshake was not successful but was shut down controlled and
 by the specifications of the TLS/SSL protocol. Call SSL_get_error() with the
 return value B<ret> to find out the reason.
 
+=item Z<>1
+
+The TLS/SSL handshake was successfully completed, a TLS/SSL connection has been
+established.
+
 =item E<lt>0
 
 The TLS/SSL handshake was not successful because a fatal error occurred either
--- doc/ssl/SSL_clear.pod
+++ doc/ssl/SSL_clear.pod
@@ -56,12 +56,12 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The SSL_clear() operation could not be performed. Check the error stack to
 find out the reason.
 
-=item 1
+=item Z<>1
 
 The SSL_clear() operation was successful.
 
--- doc/ssl/SSL_connect.pod
+++ doc/ssl/SSL_connect.pod
@@ -41,17 +41,17 @@
 
 =over 4
 
-=item 1
-
-The TLS/SSL handshake was successfully completed, a TLS/SSL connection has been
-established.
-
-=item 0
+=item Z<>0
 
 The TLS/SSL handshake was not successful but was shut down controlled and
 by the specifications of the TLS/SSL protocol. Call SSL_get_error() with the
 return value B<ret> to find out the reason.
 
+=item Z<>1
+
+The TLS/SSL handshake was successfully completed, a TLS/SSL connection has been
+established.
+
 =item E<lt>0
 
 The TLS/SSL handshake was not successful, because a fatal error occurred either
--- doc/ssl/SSL_do_handshake.pod
+++ doc/ssl/SSL_do_handshake.pod
@@ -45,17 +45,17 @@
 
 =over 4
 
-=item 1
-
-The TLS/SSL handshake was successfully completed, a TLS/SSL connection has been
-established.
-
-=item 0
+=item Z<>0
 
 The TLS/SSL handshake was not successful but was shut down controlled and
 by the specifications of the TLS/SSL protocol. Call SSL_get_error() with the
 return value B<ret> to find out the reason.
 
+=item Z<>1
+
+The TLS/SSL handshake was successfully completed, a TLS/SSL connection has been
+established.
+
 =item E<lt>0
 
 The TLS/SSL handshake was not successful because a fatal error occurred either
--- doc/ssl/SSL_read.pod
+++ doc/ssl/SSL_read.pod
@@ -86,7 +86,7 @@
 The read operation was successful; the return value is the number of
 bytes actually read from the TLS/SSL connection.
 
-=item 0
+=item Z<>0
 
 The read operation was not successful. The reason may either be a clean
 shutdown due to a "close notify" alert sent by the peer (in which case
--- doc/ssl/SSL_session_reused.pod
+++ doc/ssl/SSL_session_reused.pod
@@ -27,11 +27,11 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 A new session was negotiated.
 
-=item 1
+=item Z<>1
 
 A session was reused.
 
--- doc/ssl/SSL_set_fd.pod
+++ doc/ssl/SSL_set_fd.pod
@@ -35,11 +35,11 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The operation failed. Check the error stack to find out why.
 
-=item 1
+=item Z<>1
 
 The operation succeeded.
 
--- doc/ssl/SSL_set_session.pod
+++ doc/ssl/SSL_set_session.pod
@@ -37,11 +37,11 @@
 
 =over 4
 
-=item 0
+=item Z<>0
 
 The operation failed; check the error stack to find out the reason.
 
-=item 1
+=item Z<>1
 
 The operation succeeded.
 
--- doc/ssl/SSL_shutdown.pod
+++ doc/ssl/SSL_shutdown.pod
@@ -92,18 +92,18 @@
 
 =over 4
 
-=item 1
-
-The shutdown was successfully completed. The "close notify" alert was sent
-and the peer's "close notify" alert was received.
-
-=item 0
+=item Z<>0
 
 The shutdown is not yet finished. Call SSL_shutdown() for a second time,
 if a bidirectional shutdown shall be performed.
 The output of L<SSL_get_error(3)|SSL_get_error(3)> may be misleading, as an
 erroneous SSL_ERROR_SYSCALL may be flagged even though no error occurred.
 
+=item Z<>1
+
+The shutdown was successfully completed. The "close notify" alert was sent
+and the peer's "close notify" alert was received.
+
 =item -1
 
 The shutdown was not successful because a fatal error occurred either
--- doc/ssl/SSL_write.pod
+++ doc/ssl/SSL_write.pod
@@ -79,7 +79,7 @@
 The write operation was successful, the return value is the number of
 bytes actually written to the TLS/SSL connection.
 
-=item 0
+=item Z<>0
 
 The write operation was not successful. Probably the underlying connection
 was closed. Call SSL_get_error() with the return value B<ret> to find out,
eof
patch -Z -b -p0 < pod.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

# Patch to fix an issue in OpenSSL 1.1.1d with zlib, which causes
# the test 20-test_enc.t to fail.  Apparently, "this filter was
# lacking support to check if there's any more pending dzta,
# which may result in the last zlib block being lost."
# https://github.com/openssl/openssl/pull/9876
# The below patch is copied from commit 6beb8b39ba8e4cb005c1fcd2586ba19e17f04b95
if [ "${openssl_v}" == "1.1.1d" ] ; then
cat << eof > c_zlib.patch
--- crypto/comp/c_zlib.c
+++ crypto/comp/c_zlib.c
@@ -598,6 +598,28 @@
         BIO_copy_next_retry(b);
         break;

+    case BIO_CTRL_WPENDING:
+        if (ctx->obuf == NULL)
+            return 0;
+
+        if (ctx->odone) {
+            ret = ctx->ocount;
+        } else {
+            ret = ctx->ocount;
+            if (ret == 0)
+                /* Unknown amount pending but we are not finished */
+                ret = 1;
+        }
+        if (ret == 0)
+            ret = BIO_ctrl(next, cmd, num, ptr);
+        break;
+
+    case BIO_CTRL_PENDING:
+        ret = ctx->zin.avail_in;
+        if (ret == 0)
+            ret = BIO_ctrl(next, cmd, num, ptr);
+        break;
+
     default:
         ret = BIO_ctrl(next, cmd, num, ptr);
         break;
eof
patch -Z -b -p0 < c_zlib.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi
fi

module purge
module load zlib/${openssl_zlib_ver}

config="./config -v --prefix=${opt}/openssl-${openssl_v} \
	    --openssldir=${opt}/openssl-${openssl_v}/etc/ssl \
	    shared zlib-dynamic enable-md2 enable-rc5"

if [ ${debug} -gt 0 ] ; then
  ./config -h
  echo ''
  module list
  echo zlib: $(pkg-config --libs zlib)
  echo ''
  echo ${config}
  echo ''
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  if [ "${openssl_v}" == "1.0.1e" ] ; then
    echo '>> Configure complete'
    echo ''
    read k
  else
    echo '>> Configure complete'
    echo ''
    echo 'Press enter for additional info...'
    read k
    perl configdata.pm --dump
    echo ''
    echo '>> Press enter to proceed with build'
    read k
  fi
fi

if [ "${openssl_v}" == "1.0.1e" ] ; then
  make depend
  if [ ! $? -eq 0 ] ; then
    echo "ERROR: 'make depend' failed with return code $?"
    exit 4
  fi
  if [ ${debug} -gt 0 ] ; then
    echo '>> "make depend" succeeded (step 1 of 2)'
    read k
  fi

  make all
  if [ ! $? -eq 0 ] ; then
    echo "ERROR: 'make all' failed with return code $?"
    exit 4
  fi
  if [ ${debug} -gt 0 ] ; then
    echo '>> "make all" succeeded (step 2 of 2)'
    read k
  fi
else
  make -j ${ncpu}
  if [ ! $? -eq 0 ] ; then
    echo "ERROR: 'make' failed with return code $?"
    exit 4
  fi
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make test
  if [ ${cert_error_warn} -gt 0 ]; then
    echo ''
    echo 'NOTE: Test 80_test_ssl_new.t fails due to a known expired certificate.'
    echo '      For more detailed info, try: `make test TESTS=test_ssl_new V=1`'
    echo '      This produces a lot of text...'
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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/openssl
cat << eof > ${MODULEPATH}/openssl/${openssl_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts openssl-${openssl_v} into your environment"
}

set VER ${openssl_v}
set PKG ${opt}/openssl-\$VER

module-whatis   "Loads openssl-${openssl_v}"
conflict openssl
module load zlib/${openssl_zlib_ver}
prereq zlib/${openssl_zlib_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/${openssl_manpath}
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${openssl_srcdir}

}
