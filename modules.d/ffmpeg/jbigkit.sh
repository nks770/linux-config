#!/bin/bash

# Functions for detecting and building JBIG-KIT
echo 'Loading JBIG-KIT...'

function jbigkitInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check jbigkit
if [ ! -f ${MODULEPATH}/jbigkit/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_jbigkit() {
if jbigkitInstalled ${1}; then
  echo "JBIG-KIT ${1} is installed."
else
  build_jbigkit ${1}
fi
}

function build_jbigkit() {

# Get desired version number to install
jbigkit_v=${1}
if [ -z "${jbigkit_v}" ] ; then
  jbigkit_v=2.1
fi

#case ${jbigkit_v} in
#  2.1) # 2014-04-08
#   jbigkit_zlib_ver=1.2.11 # 2017-01-15
#  ;;
#  *)
#   echo "ERROR: Review needed for JBIG-KIT ${jbigkit_v}"
#   exit 4 # Please review
#  ;;
#esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  jbigkit_zlib_ver=${global_zlib}
#  jbigkit_xz_ver=${global_xz}
#fi

echo "Installing JBIG-KIT ${jbigkit_v}..."
jbigkit_srcdir=jbigkit-${jbigkit_v}

check_modules

downloadPackage jbigkit-${jbigkit_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${jbigkit_srcdir} ] ; then
  rm -rf ${tmp}/${jbigkit_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/jbigkit-${jbigkit_v}.tar.gz
cd ${tmp}/${jbigkit_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Multiple patches for various issues
# These patches are mostly sourced from Debian sources
# http://deb.debian.org/debian/pool/main/j/jbigkit/jbigkit_2.1-6.1.debian.tar.xz
#
# Patch pbmtojbg.c and pbmtojbg85.c
# - Removes some harmless compiler warnings, and one potential truncated file.
# Patch jbig.c
# - Fixes bug in jbg_newlen(): check for end-of-file within MARKER_NEWLEN
# Patch Makefiles
# - Add install target
# - Build shared library
# - Link binaries against shared library
# - Add missing $(LDFLAGS) for hardening flags
# - Use $(AR) for cross-compilation and options s to avoid ranlib usage
# - Add additional generated files to clean target
# - Adjust LD_LIBRARY_PATH for tests, since they are now dynamically linked
#
# - I also edited the Makefile to allow customization of install PREFIX
#
cat << eof > jbigkit.patch
--- Makefile
+++ Makefile
@@ -1,15 +1,19 @@
 # Unix makefile for JBIG-KIT
 
 # Select an ANSI/ISO C compiler here, GNU gcc is recommended
-CC = gcc
+CC ?= gcc
 
 # Options for the compiler: A high optimization level is suggested
-CFLAGS = -O2 -W -Wno-unused-result
+CFLAGS ?= -O2 -W -Wno-unused-result
 # CFLAGS = -O -g -W -Wall -Wno-unused-result -ansi -pedantic # -DDEBUG
 
-export CC CFLAGS
+# Install prefix
+PREFIX ?= ${opt}/jbigkit-${jbigkit_v}
+
+export CC CFLAGS PREFIX
 
 VERSION=2.1
+.PHONY: all lib pbm test clean install
 
 all: lib pbm
 	@echo "Enter 'make test' in order to start some automatic tests."
@@ -42,3 +46,15 @@
 release:
 	rsync -t jbigkit-\$(VERSION).tar.gz \$(HOME)/public_html/download/
 	rsync -t jbigkit-\$(VERSION)/CHANGES \$(HOME)/public_html/jbigkit/
+
+install: all
+	install -d \$(PREFIX)/lib
+	install -m 644 libjbig/*.so.* libjbig/*.a \$(PREFIX)/lib
+	/sbin/ldconfig -n \$(PREFIX)/lib
+	ln -sfv libjbig.so.0 \$(PREFIX)/lib/libjbig.so
+	install -d \$(PREFIX)/include
+	install -m 644 libjbig/*.h \$(PREFIX)/include
+	install -d \$(PREFIX)/bin
+	install -m 755 pbmtools/jbgtopbm pbmtools/jbgtopbm85 pbmtools/pbmtojbg pbmtools/pbmtojbg85 \$(PREFIX)/bin
+	install -d \$(PREFIX)/share/man/man1
+	install -m 644 pbmtools/*.1 \$(PREFIX)/share/man/man1
--- libjbig/Makefile
+++ libjbig/Makefile
@@ -1,28 +1,30 @@
 # Unix makefile for the JBIG-KIT library
 
 # Select an ANSI/ISO C compiler here, GNU gcc is recommended
-CC = gcc
+CC ?= gcc
 
 # Options for the compiler: A high optimization level is suggested
-CFLAGS = -g -O -W -Wall -ansi -pedantic # --coverage
+CFLAGS ?= -g -O -W -Wall -ansi -pedantic # --coverage
 
-all: libjbig.a libjbig85.a tstcodec tstcodec85
+all: libjbig.a libjbig.so libjbig85.a tstcodec tstcodec85
 
 tstcodec: tstcodec.o jbig.o jbig_ar.o
-	\$(CC) \$(CFLAGS) -o tstcodec tstcodec.o jbig.o jbig_ar.o
+	\$(CC) \$(CFLAGS) -o tstcodec tstcodec.o jbig.o jbig_ar.o \$(LDFLAGS)
 
 tstcodec85: tstcodec85.o jbig85.o jbig_ar.o
-	\$(CC) \$(CFLAGS) -o tstcodec85 tstcodec85.o jbig85.o jbig_ar.o
+	\$(CC) \$(CFLAGS) -o tstcodec85 tstcodec85.o jbig85.o jbig_ar.o \$(LDFLAGS)
 
 libjbig.a: jbig.o jbig_ar.o
 	rm -f libjbig.a
-	ar rc libjbig.a jbig.o jbig_ar.o
-	-ranlib libjbig.a
+	\$(AR) rcs \$@ jbig.o jbig_ar.o
+
+libjbig.so: jbig.o jbig_ar.o jbig85.o
+	\$(CC) -shared -Wl,-soname,libjbig.so.0 -o libjbig.so.0 $+ \$(LDFLAGS)
+	ln -sf libjbig.so.0 libjbig.so
 
 libjbig85.a: jbig85.o jbig_ar.o
 	rm -f libjbig85.a
-	ar rc libjbig85.a jbig85.o jbig_ar.o
-	-ranlib libjbig85.a
+	\$(AR) rcs \$@ jbig85.o jbig_ar.o
 
 jbig.o: jbig.c jbig.h jbig_ar.h
 jbig85.o: jbig85.c jbig85.h jbig_ar.h
@@ -51,5 +53,6 @@
 
 clean:
 	rm -f *.o *.gcda *.gcno *.gcov *.plist *~ core gmon.out dbg_d\=??.pbm
+	rm -f *.so* *.a *.la
 	rm -f t82test.pbm
 	rm -f tstcodec tstcodec85
--- libjbig/jbig.c
+++ libjbig/jbig.c
@@ -3267,7 +3267,9 @@
     else if (p[0] == MARKER_ESC)
       switch (p[1]) {
       case MARKER_NEWLEN:
-	y = (((long) bie[ 8] << 24) | ((long) bie[ 9] << 16) |
+	if (p + 5 >= bie + len)
+          return JBG_EAGAIN;
+        y = (((long) bie[ 8] << 24) | ((long) bie[ 9] << 16) |
 	     ((long) bie[10] <<  8) |  (long) bie[11]);
 	yn = (((long) p[2] << 24) | ((long) p[3] << 16) |
 	      ((long) p[4] <<  8) |  (long) p[5]);
--- pbmtools/Makefile
+++ pbmtools/Makefile
@@ -1,11 +1,12 @@
 # Unix makefile for the JBIG-KIT PBM tools
 
 # Select an ANSI/ISO C compiler here, e.g. GNU gcc is recommended
-CC = gcc
+CC ?= gcc
 
 # Options for the compiler
-CFLAGS = -g -O -W -Wall -Wno-unused-result -ansi -pedantic # --coverage
-CPPFLAGS = -I../libjbig 
+CFLAGS ?= -g -O -W -Wall -Wno-unused-result -ansi -pedantic # --coverage
+override CPPFLAGS += -I../libjbig
+export LD_LIBRARY_PATH := \$(if \$(LD_LIBRARY_PATH),\$(LD_LIBRARY_PATH):)../libjbig
 
 .SUFFIXES: .1 .5 .txt \$(SUFFIXES)
 .PHONY: txt test test82 test85 clean
@@ -14,31 +15,23 @@
 
 txt: pbmtojbg.txt jbgtopbm.txt pbm.txt pgm.txt
 
-pbmtojbg: pbmtojbg.o ../libjbig/libjbig.a
-	\$(CC) \$(CFLAGS) -o pbmtojbg pbmtojbg.o -L../libjbig -ljbig
+pbmtojbg: pbmtojbg.o
+	\$(CC) \$(CFLAGS) -o pbmtojbg pbmtojbg.o -L../libjbig -ljbig \$(LDFLAGS)
 
-jbgtopbm: jbgtopbm.o ../libjbig/libjbig.a
-	\$(CC) \$(CFLAGS) -o jbgtopbm jbgtopbm.o -L../libjbig -ljbig
+jbgtopbm: jbgtopbm.o
+	\$(CC) \$(CFLAGS) -o jbgtopbm jbgtopbm.o -L../libjbig -ljbig \$(LDFLAGS)
 
-pbmtojbg85: pbmtojbg85.o ../libjbig/libjbig85.a
-	\$(CC) \$(CFLAGS) -o pbmtojbg85 pbmtojbg85.o -L../libjbig -ljbig85
+pbmtojbg85: pbmtojbg85.o
+	\$(CC) \$(CFLAGS) -o pbmtojbg85 pbmtojbg85.o -L../libjbig -ljbig \$(LDFLAGS)
 
-jbgtopbm85: jbgtopbm85.o ../libjbig/libjbig85.a
-	\$(CC) \$(CFLAGS) -o jbgtopbm85 jbgtopbm85.o -L../libjbig -ljbig85
+jbgtopbm85: jbgtopbm85.o
+	\$(CC) \$(CFLAGS) -o jbgtopbm85 jbgtopbm85.o -L../libjbig -ljbig \$(LDFLAGS)
 
 jbgtopbm.o: jbgtopbm.c ../libjbig/jbig.h
 pbmtojbg.o: pbmtojbg.c ../libjbig/jbig.h
 jbgtopbm85.o: jbgtopbm85.c ../libjbig/jbig85.h
 pbmtojbg85.o: pbmtojbg85.c ../libjbig/jbig85.h
 
-../libjbig/libjbig.a: ../libjbig/jbig.c ../libjbig/jbig.h \\
-	../libjbig/jbig_ar.c ../libjbig/jbig_ar.h
-	make -C ../libjbig libjbig.a
-
-../libjbig/libjbig85.a: ../libjbig/jbig85.c ../libjbig/jbig85.h \\
-	../libjbig/jbig_ar.c ../libjbig/jbig_ar.h
-	make -C ../libjbig libjbig85.a
-
 analyze:
 	clang \$(CPPFLAGS) --analyze *.c
 
@@ -96,6 +89,8 @@
 	cmp test-\$(IMG).pgm ../examples/\$(IMG).pgm
 
 test85: pbmtojbg jbgtopbm pbmtojbg85 jbgtopbm85 test-t82.pbm
+	export LD_LIBRARY_PATH=\`pwd\`/../libjbig
+	echo \$(LD_LIBRARY_PATH)
 	make IMG=t82 "OPTIONSP=-p 0"      dotest85
 	make IMG=t82 "OPTIONSP=-p 8"      dotest85
 	make IMG=t82 "OPTIONSP=-p 8 -r"   dotest85b
--- pbmtools/pbmtojbg.c
+++ pbmtools/pbmtojbg.c
@@ -86,7 +86,11 @@
       while ((c = getc(f)) != EOF && !(c == 13 || c == 10)) ;
   if (c != EOF) {
     ungetc(c, f);
-    fscanf(f, "%lu", &i);
+    if(fscanf(f, "%lu", &i) != 1) {
+      /* should never fail, since c must be a digit */
+      fprintf(stderr, "Unexpected failure reading digit '%c'\\n", c);
+      exit(1);
+    }
   }
 
   return i;
@@ -300,7 +304,9 @@
     break;
   case '4':
     /* PBM raw binary format */
-    fread(bitmap[0], bitmap_size, 1, fin);
+    if (fread(bitmap[0], bitmap_size, 1, fin) != 1) {
+      /* silence compiler warnings; ferror/feof checked below */
+    }
     break;
   case '2':
   case '5':
@@ -312,8 +318,18 @@
 	for (j = 0; j < bpp; j++)
 	  image[x * bpp + (bpp - 1) - j] = v >> (j * 8);
       }
-    } else
-      fread(image, width * height, bpp, fin);
+    } else {
+      if (fread(image, width * height, bpp, fin) != (size_t) bpp) {
+        if (ferror(fin)) {
+          fprintf(stderr, "Problem while reading input file '%s", fnin);
+          perror("'");
+          exit(1);
+        } else {
+          fprintf(stderr, "Unexpected end of input file '%s'!\\n", fnin);
+          exit(1);
+        }
+      }
+    }
     jbg_split_planes(width, height, planes, encode_planes, image, bitmap,
 		     use_graycode);
     free(image);
--- pbmtools/pbmtojbg85.c
+++ pbmtools/pbmtojbg85.c
@@ -70,7 +70,11 @@
       while ((c = getc(f)) != EOF && !(c == 13 || c == 10)) ;
   if (c != EOF) {
     ungetc(c, f);
-    fscanf(f, "%lu", &i);
+    if(fscanf(f, "%lu", &i) != 1) {
+      /* should never fail, since c must be a digit */
+      fprintf(stderr, "Unexpected failure reading digit '%c'\\n", c);
+      exit(1);
+    }
   }
 
   return i;
@@ -237,7 +241,9 @@
       break;
     case '4':
       /* PBM raw binary format */
-      fread(next_line, bpl, 1, fin);
+      if (fread(next_line, bpl, 1, fin) != 1) {
+        /* silence compiler warnings; ferror/feof checked below */
+      }
       break;
     default:
       fprintf(stderr, "Unsupported PBM type P%c!\\n", type);
eof
patch -N -Z -b -p0 < jbigkit.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

module purge

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
mkdir -pv ${MODULEPATH}/jbigkit
cat << eof > ${MODULEPATH}/jbigkit/${jbigkit_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts jbigkit-${jbigkit_v} into your environment"
}

set VER ${jbigkit_v}
set PKG ${opt}/jbigkit-\$VER

module-whatis   "Loads jbigkit-${jbigkit_v}"
conflict jbigkit

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${jbigkit_srcdir}

}
