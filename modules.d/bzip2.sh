#!/bin/bash

# Functions for detecting and building bzip2
echo 'Loading bzip2...'

function bzip2Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check bzip2
if [ ! -f ${MODULEPATH}/bzip2/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_bzip2() {
if bzip2Installed ${1}; then
  echo "bzip2 ${1} is installed."
else
  build_bzip2 ${1}
fi
}

function build_bzip2() {

# Get desired version number to install
bzip2_v=${1}
if [ -z "${bzip2_v}" ] ; then
  echo "ERROR: No bzip2 version specified!"
  exit 2
fi

echo "Installing bzip2 ${bzip2_v}..."
bzip2_srcdir=bzip2-${bzip2_v}

check_modules
module purge

downloadPackage bzip2-${bzip2_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${bzip2_srcdir} ] ; then
  rm -rf ${tmp}/${bzip2_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/bzip2-${bzip2_v}.tar.gz
cd ${tmp}/bzip2-${bzip2_v}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi


if [ "${bzip2_v}" == "1.0.6" ] ; then
  minorpatch=6
fi
if [ "${bzip2_v}" == "1.0.7" ] ; then
  minorpatch=7
fi
if [ "${bzip2_v}" == "1.0.8" ] ; then
  minorpatch=8
fi

# This patch is mostly based on a Debian diff on the Makefile
# https://packages.debian.org/sid/bzip2
# It solves a couple of problems:
#  - Adding CPPFLAGS to the build
#  - Building the shared libraries
#
# bunzip2 and bzcat are just the same as bzip2
# The Debian patch makes them hard links (ln)
# I changed it to make them symlinks (ln -s -f)
touch makefile.patch

if [ ! -z "${minorpatch}" ] ; then
cat << eof > makefile.patch
--- a/Makefile
+++ b/Makefile
@@ -12,6 +12,8 @@
 # in the file LICENSE.
 # ------------------------------------------------------------------
 
+somajor=1.0
+sominor=\$(somajor).${minorpatch}
 SHELL=/bin/sh
 
 # To assist in cross-compiling
@@ -37,29 +39,50 @@
 
 all: libbz2.a bzip2 bzip2recover test
 
-bzip2: libbz2.a bzip2.o
-	\$(CC) \$(CFLAGS) \$(LDFLAGS) -o bzip2 bzip2.o -L. -lbz2
+bzip2: libbz2.so bzip2.o
+	\$(CC) \$(CFLAGS) \$(CPPFLAGS) \$(LDFLAGS) -o bzip2 bzip2.o -L. -lbz2
 
 bzip2recover: bzip2recover.o
-	\$(CC) \$(CFLAGS) \$(LDFLAGS) -o bzip2recover bzip2recover.o
+	\$(CC) \$(CFLAGS) \$(CPPFLAGS) \$(LDFLAGS) -o bzip2recover bzip2recover.o
 
 libbz2.a: \$(OBJS)
 	rm -f libbz2.a
 	\$(AR) cq libbz2.a \$(OBJS)
-	@if ( test -f \$(RANLIB) -o -f /usr/bin/ranlib -o \\
-		-f /bin/ranlib -o -f /usr/ccs/bin/ranlib ) ; then \\
+	@if ( test -f \$(RANLIB) || test -f /usr/bin/ranlib || \\
+		test -f /bin/ranlib || test -f /usr/ccs/bin/ranlib ) ; then \\
 		echo \$(RANLIB) libbz2.a ; \\
 		\$(RANLIB) libbz2.a ; \\
 	fi
 
+libbz2.so: libbz2.so.\$(somajor)
+	ln -sf \$^ \$@
+
+libbz2.so.\$(somajor): libbz2.so.\$(sominor)
+	ln -sf \$^ \$@
+
+libbz2.so.\$(sominor): \$(OBJS:%.o=%.sho)
+	\$(CC) -o libbz2.so.\$(sominor) -shared \$(LDFLAGS) \\
+	  -Wl,-soname,libbz2.so.\$(somajor) \$^ -lc
+
+\$(OBJS:%.o=%.sho) bzip2.sho bzip2recover.sho: %.sho: %.c
+	\$(CC) \$(CFLAGS) \$(CPPFLAGS) -fPIC -o \$@ -c $<
+\$(OBJS) bzip2.o bzip2recover.o: %.o: %.c
+	\$(CC) \$(CFLAGS) \$(CPPFLAGS) -o \$@ -c $<
+
 check: test
 test: bzip2
 	@cat words1
+	LD_LIBRARY_PATH=.:\$\$LD_LIBRARY_PATH \\
 	./bzip2 -1  < sample1.ref > sample1.rb2
+	LD_LIBRARY_PATH=.:\$\$LD_LIBRARY_PATH \\
 	./bzip2 -2  < sample2.ref > sample2.rb2
+	LD_LIBRARY_PATH=.:\$\$LD_LIBRARY_PATH \\
 	./bzip2 -3  < sample3.ref > sample3.rb2
+	LD_LIBRARY_PATH=.:\$\$LD_LIBRARY_PATH \\
 	./bzip2 -d  < sample1.bz2 > sample1.tst
+	LD_LIBRARY_PATH=.:\$\$LD_LIBRARY_PATH \\
 	./bzip2 -d  < sample2.bz2 > sample2.tst
+	LD_LIBRARY_PATH=.:\$\$LD_LIBRARY_PATH \\
 	./bzip2 -ds < sample3.bz2 > sample3.tst
 	cmp sample1.bz2 sample1.rb2 
 	cmp sample2.bz2 sample2.rb2
@@ -69,15 +92,15 @@
 	cmp sample3.tst sample3.ref
 	@cat words3
 
-install: bzip2 bzip2recover
+install: bzip2 bzip2recover libbz2.a
 	if ( test ! -d \$(PREFIX)/bin ) ; then mkdir -p \$(PREFIX)/bin ; fi
 	if ( test ! -d \$(PREFIX)/lib ) ; then mkdir -p \$(PREFIX)/lib ; fi
 	if ( test ! -d \$(PREFIX)/man ) ; then mkdir -p \$(PREFIX)/man ; fi
 	if ( test ! -d \$(PREFIX)/man/man1 ) ; then mkdir -p \$(PREFIX)/man/man1 ; fi
 	if ( test ! -d \$(PREFIX)/include ) ; then mkdir -p \$(PREFIX)/include ; fi
 	cp -f bzip2 \$(PREFIX)/bin/bzip2
-	cp -f bzip2 \$(PREFIX)/bin/bunzip2
-	cp -f bzip2 \$(PREFIX)/bin/bzcat
+	ln -s -f \$(PREFIX)/bin/bzip2 \$(PREFIX)/bin/bunzip2
+	ln -s -f \$(PREFIX)/bin/bzip2 \$(PREFIX)/bin/bzcat
 	cp -f bzip2recover \$(PREFIX)/bin/bzip2recover
 	chmod a+x \$(PREFIX)/bin/bzip2
 	chmod a+x \$(PREFIX)/bin/bunzip2
@@ -87,7 +110,7 @@
 	chmod a+r \$(PREFIX)/man/man1/bzip2.1
 	cp -f bzlib.h \$(PREFIX)/include
 	chmod a+r \$(PREFIX)/include/bzlib.h
-	cp -f libbz2.a \$(PREFIX)/lib
+	cp -fa libbz2.a libbz2.so* \$(PREFIX)/lib
 	chmod a+r \$(PREFIX)/lib/libbz2.a
 	cp -f bzgrep \$(PREFIX)/bin/bzgrep
 	ln -s -f \$(PREFIX)/bin/bzgrep \$(PREFIX)/bin/bzegrep
@@ -109,30 +132,10 @@
 	echo ".so man1/bzdiff.1" > \$(PREFIX)/man/man1/bzcmp.1
 
 clean: 
-	rm -f *.o libbz2.a bzip2 bzip2recover \\
+	rm -f *.o *.sho libbz2.a libbz2.so* bzip2 bzip2recover \\
 	sample1.rb2 sample2.rb2 sample3.rb2 \\
 	sample1.tst sample2.tst sample3.tst
 
-blocksort.o: blocksort.c
-	@cat words0
-	\$(CC) \$(CFLAGS) -c blocksort.c
-huffman.o: huffman.c
-	\$(CC) \$(CFLAGS) -c huffman.c
-crctable.o: crctable.c
-	\$(CC) \$(CFLAGS) -c crctable.c
-randtable.o: randtable.c
-	\$(CC) \$(CFLAGS) -c randtable.c
-compress.o: compress.c
-	\$(CC) \$(CFLAGS) -c compress.c
-decompress.o: decompress.c
-	\$(CC) \$(CFLAGS) -c decompress.c
-bzlib.o: bzlib.c
-	\$(CC) \$(CFLAGS) -c bzlib.c
-bzip2.o: bzip2.c
-	\$(CC) \$(CFLAGS) -c bzip2.c
-bzip2recover.o: bzip2recover.c
-	\$(CC) \$(CFLAGS) -c bzip2recover.c
-
 
 distclean: clean
 	rm -f manual.ps manual.html manual.pdf
eof
fi
patch -p1 -b < makefile.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

#make -f Makefile-libbz2_so
#
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Build phase 1 complete'
#  read k
#fi
#
#make clean
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Build phase 2 complete'
#  read k
#fi

make

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

## bzip2 does not have separate tests to run
#if [ ${run_tests} -gt 0 ] ; then
#  make test
#  # Note 'make check' also works
#  echo '>> Tests complete'
#  read k
#fi

#make -n install PREFIX=/opt/bzip2-${bzip2_v}
make install PREFIX=/opt/bzip2-${bzip2_v}
cp -afv bzip2-shared /opt/bzip2-${bzip2_v}/bin/bzip2
cp -afv libbz2.so* /opt/bzip2-${bzip2_v}/lib/

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
mkdir -pv ${MODULEPATH}/bzip2
cat << eof > ${MODULEPATH}/bzip2/${bzip2_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts bzip2-${bzip2_v} into your environment"
}

set VER ${bzip2_v}
set PKG ${opt}/bzip2-\$VER

module-whatis   "Loads bzip2-${bzip2_v}"
conflict bzip2

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/man

eof

cd ${root}
rm -rf ${tmp}/${bzip2_srcdir}

}
