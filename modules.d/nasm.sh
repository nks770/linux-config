#!/bin/bash

# Functions for detecting and building NASM
echo 'Loading nasm...'

function nasmInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check nasm
if [ ! -f ${MODULEPATH}/nasm/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_nasm() {
if nasmInstalled ${1}; then
  echo "nasm ${1} is installed."
else
  build_nasm ${1}
fi
}

function build_nasm() {

# Get desired version number to install
nasm_v=${1}
if [ -z "${nasm_v}" ] ; then
  nasm_v=2.13.03
fi
nasm_srcdir=nasm-${nasm_v}

echo "Installing nasm ${nasm_v}..."

check_modules

downloadPackage nasm-${nasm_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${nasm_srcdir} ] ; then
  rm -rf ${tmp}/${nasm_srcdir}
fi

tar xvfz ${pkg}/nasm-${nasm_v}.tar.gz
cd ${tmp}/${nasm_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# Patch to enable compilation with GCC 8
touch nasmlib.patch

if [ "${nasm_v}" == "xxx2.13.03" ] ; then
cat << eof > nasmlib.patch
Index: include/nasmlib.h
===================================================================
--- include/nasmlib.h   2018-02-07 21:40:15.000000000 +0000
+++ include/nasmlib.h   2021-04-24 04:10:58.917451792 +0000
@@ -188,10 +188,8 @@
 int64_t readstrnum(char *str, int length, bool *warn);

 /*
- * seg_init: Initialise the segment-number allocator.
  * seg_alloc: allocate a hitherto unused segment number.
  */
-void pure_func seg_init(void);
 int32_t pure_func seg_alloc(void);

 /*
eof
patch -Z -b -p0 < nasmlib.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

config="./configure --prefix=${opt}/nasm-${nasm_v}"

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
  make test
  echo ''
  echo "NOTE: You are probably seeing a lot of errors like \"Can't compare at <...> file stdout\""
  echo 'Per online at https://bugzilla.opensuse.org/show_bug.cgi?id=1084631 :'
cat << eof
> is this OK?

Short answer: Yes.

Long answer: NASM unit tests are mostly focused on regression detection. What they are suppose to be used for,

1. make
2. make golden
3. <do changes here>
4. make
5. make test

The \`make test\` then compares output of the "golden" output with the test run. If there are any changes, it *could* indicate a regression that need to be investigated.

The "golden" directory of binaries is not shipped by upstream that's why it's complaining. But nasm is called before the attempted comparison so if there is some major nasm failure on execution, like segfault, I think we would see it in the log.
eof
  echo ''
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
mkdir -pv ${MODULEPATH}/nasm
cat << eof > ${MODULEPATH}/nasm/${nasm_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts nasm-${nasm_v} into your environment"
}

set VER ${nasm_v}
set PKG ${opt}/nasm-\$VER

module-whatis   "Loads nasm-${nasm_v}"
conflict nasm

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${nasm_srcdir}

}
