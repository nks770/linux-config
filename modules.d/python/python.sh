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
   ;;
*)
   echo "ERROR: Need review for Python ${1}"
   exit 4
   ;;
esac

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
  echo 'NOTE: With Python 3.9.4 and Debian 11.5, I have observed that test_curses fails.'
  echo '      It seems there is a failure in test_background due to unexpected behavior'
  echo '      of the win.bkgd() function from libncurses.  This probably needs more investigation'
  echo '      but it might be fine.'
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