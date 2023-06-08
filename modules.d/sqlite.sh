#!/bin/bash

# Functions for detecting and building sqlite
echo 'Loading sqlite...'

function sqliteInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check sqlite
if [ ! -f ${MODULEPATH}/sqlite/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_sqlite() {
if sqliteInstalled ${1}; then
  echo "sqlite ${1} is installed."
else
  build_sqlite ${1}
fi
}

function build_sqlite() {

# Get desired version number to install
sqlite_v=${1}
if [ -z "${sqlite_v}" ] ; then
  sqlite_v=3.41.0
fi

case ${sqlite_v} in
3.21.0) # 2017-10-24
   sql_srcdir=sqlite-autoconf-3210000
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.22.0) # 2018-01-22
   sql_srcdir=sqlite-autoconf-3220000
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.26.0) # 2018-12-01
   sql_srcdir=sqlite-autoconf-3260000
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.28.0) # 2019-04-16
   sql_srcdir=sqlite-autoconf-3280000
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.30.1) # 2019-10-10
   sql_srcdir=sqlite-autoconf-3300100
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.34.1) # 2021-01-20
   sql_srcdir=sqlite-autoconf-3340100
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.35.4) # 2021-04-02
   sql_srcdir=sqlite-autoconf-3350400
   zlib_ver=1.2.11 # 2017-01-15
   ;;
3.40.0) # 2022-11-16
   sql_srcdir=sqlite-autoconf-3400000
   zlib_ver=1.2.13 # 2022-10-12
   ;;
3.40.1) # 2022-12-28
   sql_srcdir=sqlite-autoconf-3400100
   zlib_ver=1.2.13 # 2022-10-12
   ;;
3.41.0) # 2023-02-21
   sql_srcdir=sqlite-autoconf-3410000
   zlib_ver=1.2.13 # 2022-10-12
   ;;
3.41.2) # 2023-03-22
   sql_srcdir=sqlite-autoconf-3410200
   zlib_ver=1.2.13 # 2022-10-12
   ;;
*)
   sql_srcdir=unknown
   zlib_ver=1.2.13
   ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  zlib_ver=${global_zlib}
fi

echo "Installing sqlite ${sqlite_v}..."

check_modules
check_zlib ${zlib_ver}
module purge
module load zlib/${zlib_ver}

downloadPackage ${sql_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${sql_srcdir} ] ; then
  rm -rf ${tmp}/${sql_srcdir}
fi

tar xvfz ${pkg}/${sql_srcdir}.tar.gz
cd ${tmp}/${sql_srcdir}

if [ "${sqlite_v}" == "3.21.0" ] ; then
  config="./configure --prefix=${opt}/sqlite-${sqlite_v} --enable-fts5"
  export CPPFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_SECURE_DELETE -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1"
else
  config="./configure --prefix=${opt}/sqlite-${sqlite_v} --enable-fts3 --enable-fts4 --enable-fts5"
  export CPPFLAGS="-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS3_TOKENIZER=1 -DSQLITE_ENABLE_FTS4=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_SECURE_DELETE -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1"
fi

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  module list
  echo CPPFLAGS="${CPPFLAGS}"
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

# sqlite does not have a testsuite
#if [ ${run_tests} -gt 0 ] ; then
#  make test
#  echo '>> Tests complete'
#  read k
#fi

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
mkdir -pv ${MODULEPATH}/sqlite
cat << eof > ${MODULEPATH}/sqlite/${sqlite_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts sqlite-${sqlite_v} into your environment"
}

set VER ${sqlite_v}
set PKG ${opt}/sqlite-\$VER

module-whatis   "Loads sqlite-${sqlite_v}"
conflict sqlite
module load zlib/${zlib_ver}
prereq zlib/${zlib_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${sql_srcdir}

unset CPPFLAGS

}
