#!/bin/bash

# Functions for detecting and building doxygen
echo 'Loading doxygen...'

function doxygenInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check doxygen
if [ ! -f ${MODULEPATH}/doxygen/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_doxygen() {
if doxygenInstalled ${1}; then
  echo "doxygen ${1} is installed."
else
  build_doxygen ${1}
fi
}

function build_doxygen() {

# Get desired version number to install
doxygen_v=${1}
if [ -z "${doxygen_v}" ] ; then
  echo "ERROR: No doxygen version specified!"
  exit 2
fi
doxygen_srcdir=doxygen-${doxygen_v}

case ${doxygen_v} in
  1.8.6) # 2013-12-24
   doxygen_flex_ver=2.5.37   # 2012-08-03
   doxygen_bison_ver=3.0.2   # 2013-12-05
#   doxygen_cmake_ver=2.8.12.1 #2013-11-06
#   doxygen_libxml2_ver=2.9.1 # 2013-04-19
#   doxygen_python_ver=3.3.3  # 2013-11-17
   doxygen_python_ver=2.7.6  # 2013-11-10
   doxygen_build_system=gmake
   doxygen_manpath=1
  ;;
  1.8.12) # 2016-09-05
   doxygen_flex_ver=2.6.1    # 2016-03-01
   doxygen_bison_ver=3.0.4   # 2015-01-23
   doxygen_cmake_ver=3.6.1   # 2016-07-22
   doxygen_libxml2_ver=2.9.4 # 2016-05-23
   doxygen_python_ver=3.5.2  # 2016-06-27
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.13) # 2016-12-29
   doxygen_flex_ver=2.6.2    # 2016-10-24
   doxygen_bison_ver=3.0.4   # 2015-01-23
   doxygen_cmake_ver=3.6.3   # 2016-11-03
   doxygen_libxml2_ver=2.9.4 # 2016-05-23
   doxygen_python_ver=3.6.0  # 2016-12-23
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.14) # 2017-12-25
   doxygen_flex_ver=2.6.4    # 2017-05-06
   doxygen_bison_ver=3.0.4   # 2015-01-23
   doxygen_cmake_ver=3.10.1  # 2017-12-14
   doxygen_libxml2_ver=2.9.7 # 2017-11-02
   doxygen_python_ver=3.6.4  # 2017-12-19
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.15) # 2018-12-27
   doxygen_flex_ver=2.6.4    # 2017-05-06
   doxygen_bison_ver=3.2.4   # 2018-12-24
   doxygen_cmake_ver=3.13.2  # 2018-12-13
   doxygen_libxml2_ver=2.9.8 # 2018-03-05
   doxygen_python_ver=3.7.2  # 2018-12-24
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.16) # 2019-08-08
   doxygen_flex_ver=2.6.4    # 2017-05-06
   doxygen_bison_ver=3.4.1   # 2019-05-22
   doxygen_cmake_ver=3.15.2  # 2019-08-07
   doxygen_libxml2_ver=2.9.9 # 2019-01-03
   doxygen_python_ver=3.7.4  # 2019-07-08
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.17) # 2019-12-27
   doxygen_flex_ver=2.6.4    # 2017-05-06
   doxygen_bison_ver=3.5     # 2019-12-11
   doxygen_cmake_ver=3.16.2   # 2019-12-19
   doxygen_libxml2_ver=2.9.10 # 2019-10-30
   doxygen_python_ver=3.8.1   # 2019-12-18
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.18) # 2020-04-12
   doxygen_flex_ver=2.6.4    # 2017-05-06
   doxygen_bison_ver=3.5.4   # 2020-04-05
   doxygen_cmake_ver=3.17.1   # 2020-04-09
   doxygen_libxml2_ver=2.9.10 # 2019-10-30
   doxygen_python_ver=3.8.2   # 2020-02-24
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.8.20) # 2020-08-24
   doxygen_flex_ver=2.6.4    # 2017-05-06
   doxygen_bison_ver=3.7.1   # 2020-08-02
   doxygen_cmake_ver=3.18.2   # 2020-08-20
   doxygen_libxml2_ver=2.9.10 # 2019-10-30
   doxygen_python_ver=3.8.5   # 2020-07-20
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.9.0) # 2020-12-27
   doxygen_flex_ver=2.6.4    # 2017-05-06 - latest as of 2024-04-12
   doxygen_bison_ver=3.7.4   # 2020-11-14
   doxygen_cmake_ver=3.19.2   # 2020-12-16
   doxygen_libxml2_ver=2.9.10 # 2019-10-30
   doxygen_python_ver=3.9.1   # 2020-12-07
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  1.9.1) # 2021-01-08
   doxygen_flex_ver=2.6.4    # 2017-05-06 - latest as of 2024-04-12
   doxygen_bison_ver=3.7.4   # 2020-11-14
   doxygen_cmake_ver=3.19.2   # 2020-12-16
   doxygen_libxml2_ver=2.9.10 # 2019-10-30
   doxygen_python_ver=3.9.1   # 2020-12-07
   doxygen_build_system=cmake
   doxygen_manpath=0
  ;;
  *)
   echo "ERROR: Review needed for doxygen ${doxygen_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  doxygen_bison_ver=${global_bison}
#  cmake_ver=${global_cmake}
  doxygen_flex_ver=${global_flex}
fi

echo "Installing Doxygen ${doxygen_v}..."

check_modules
check_flex ${doxygen_flex_ver}
check_bison ${doxygen_bison_ver}
check_python ${doxygen_python_ver}
if [ "${doxygen_build_system}" == "cmake" ] ; then
  check_cmake ${doxygen_cmake_ver}
  check_libxml2 ${doxygen_libxml2_ver} # Needed only for testsuite
fi

downloadPackage ${doxygen_srcdir}.src.tar.gz

cd ${tmp}

if [ -d ${tmp}/${doxygen_srcdir} ] ; then
  rm -rf ${tmp}/${doxygen_srcdir}
fi

tar xvfz ${pkg}/${doxygen_srcdir}.src.tar.gz
cd ${tmp}/${doxygen_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

# In Doxygen 1.8.17, the testsuite is broken.  The path doesn't work in the python
# script as written, at least not on unix platforms.  The python needs to be
# fixed.  This problem was fixed in the next version of doxygen.
#
# Pull Request:
# https://github.com/doxygen/doxygen/pull/7470/commits/cd9dee013dc749a10bbe019c350e0e62b6635795
#
touch runtests.patch

if [ "${doxygen_v}" == "1.8.17" ] ; then
cat << eof > runtests.patch
--- testing/runtests.py
+++ testing/runtests.py
@@ -3,6 +3,7 @@
 from __future__ import print_function
 import argparse, glob, itertools, re, shutil, os, sys
 import subprocess
+import shlex
 
 config_reg = re.compile('.*\/\/\s*(?P<name>\S+):\s*(?P<value>.*)$')
 
@@ -28,10 +29,10 @@
 		return os.popen(cmd).read() # Python 2 without encoding
 	else:
 		if (getStderr):
-			proc = subprocess.run(cmd1,encoding=encoding,capture_output=True) # Python 3 with encoding
-			return proc.stderr
+			proc = subprocess.Popen(shlex.split(cmd1),stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding=encoding) # Python 3 with encoding
+			return proc.stderr.read()
 		else:
-			proc = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding=encoding) # Python 3 with encoding
+			proc = subprocess.Popen(shlex.split(cmd),stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding=encoding) # Python 3 with encoding
 			return proc.stdout.read()
 
 class Tester:
@@ -137,7 +138,7 @@
 				print('GENERATE_DOCBOOK=NO', file=f)
 			if (self.args.xhtml):
 				print('GENERATE_HTML=YES', file=f)
-			# HTML_OUTPUT can also be set locally
+			# HTML_OUTPUT can also have been set locally
 			print('HTML_OUTPUT=%s/html' % self.test_out, file=f)
 			print('HTML_FILE_EXTENSION=.xhtml', file=f)
 			if (self.args.pdf):
@@ -184,7 +185,7 @@
 					print('Non-existing file %s after \\'check:\\' statement' % check_file)
 					return
 				# convert output to canonical form
-				data = xpopen('%s --format --noblanks --nowarning %s' % (self.args.xmllint,check_file)).read()
+				data = xpopen('%s --format --noblanks --nowarning %s' % (self.args.xmllint,check_file))
 				if data:
 					# strip version
 					data = re.sub(r'xsd" version="[0-9.-]+"','xsd" version=""',data).rstrip('\\n')
@@ -326,7 +327,7 @@
 			tests.append(glob.glob('%s/*.xml' % (docbook_output)))
 			tests.append(glob.glob('%s/*/*/*.xml' % (docbook_output)))
 			tests = ' '.join(list(itertools.chain.from_iterable(tests))).replace(self.args.outputdir +'/','').replace('\\\\','/')
-			exe_string = '%s --nonet --postvalid %s' % (self.args.xmllint,tests)
+			exe_string = '%s --noout --nonet --postvalid %s' % (self.args.xmllint,tests)
 			exe_string1 = exe_string
 			exe_string += ' %s' % (redirx)
 			exe_string += ' %s more "%s/temp"' % (separ,docbook_output)
@@ -346,7 +347,11 @@
 				redirx=' 2> %s/temp >nul:'%html_output
 			else:
 				redirx='2>%s/temp >/dev/null'%html_output
-			exe_string = '%s --path dtd --nonet --postvalid %s/*xhtml' % (self.args.xmllint,html_output)
+			check_file = []
+			check_file.append(glob.glob('%s/*.xhtml' % (html_output)))
+			check_file.append(glob.glob('%s/*/*/*.xhtml' % (html_output)))
+			check_file = ' '.join(list(itertools.chain.from_iterable(check_file))).replace(self.args.outputdir +'/','').replace('\\\\','/')
+			exe_string = '%s --noout --path dtd --nonet --postvalid %s' % (self.args.xmllint,check_file)
 			exe_string1 = exe_string
 			exe_string += ' %s' % (redirx)
 			exe_string += ' %s more "%s/temp"' % (separ,html_output)
eof
patch -Z -b -p0 < runtests.patch
if [ ! $? -eq 0 ] ; then
  exit 4
fi
fi

if [ ${debug} -gt 0 ] ; then
  echo '>> Patching complete'
  read k
fi

if [ "${doxygen_build_system}" == "cmake" ] ; then
  mkdir -v ${tmp}/${doxygen_srcdir}/build
  cd ${tmp}/${doxygen_srcdir}/build
fi

module purge
module load flex/${doxygen_flex_ver}
module load bison/${doxygen_bison_ver}
module load Python/${doxygen_python_ver}
if [ "${doxygen_build_system}" == "cmake" ] ; then
  module load cmake/${doxygen_cmake_ver}
  module load libxml2/${doxygen_libxml2_ver}
fi

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  if [ "${doxygen_build_system}" == "cmake" ] ; then
  echo cmake -L -G \"Unix Makefiles\" \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
      -DCMAKE_BUILD_TYPE=Release \
      -Dbuild_doc=OFF \
      -DCMAKE_INSTALL_PREFIX=${opt}/doxygen-${doxygen_v} ..
  else
    ./configure --help
    echo ''
    echo ./configure --prefix ${opt}/doxygen-${doxygen_v} --python python
    echo ''
  fi
  read k
fi

if [ "${doxygen_build_system}" == "cmake" ] ; then
cmake -L -G "Unix Makefiles" \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \
      -DCMAKE_BUILD_TYPE=Release \
      -Dbuild_doc=OFF \
      -DCMAKE_INSTALL_PREFIX=${opt}/doxygen-${doxygen_v} ..
else
./configure --prefix ${opt}/doxygen-${doxygen_v} --python python
fi

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
  make tests
  if [ "${doxygen_v}" == "1.8.16" ] ; then
    echo ''
    echo 'NOTE: One test, 012_cite.dox, is known to fail.'
  fi
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
mkdir -pv ${MODULEPATH}/doxygen
cat << eof > ${MODULEPATH}/doxygen/${doxygen_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts doxygen-${doxygen_v} into your environment"
}

set VER ${doxygen_v}
set PKG ${opt}/doxygen-\$VER

module-whatis   "Loads doxygen-${doxygen_v}"
conflict doxygen

prepend-path PATH \$PKG/bin
eof
if [ ${doxygen_manpath} -gt 0 ] ; then
echo "prepend-path MANPATH \$PKG/man" >> ${MODULEPATH}/doxygen/${doxygen_v}
fi
echo "" >> ${MODULEPATH}/doxygen/${doxygen_v}


cd ${root}
rm -rf ${tmp}/${doxygen_srcdir}

}
