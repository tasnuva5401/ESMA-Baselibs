#!/bin/bash -fx

# --------------
# MAIN VARIABLES
# --------------

package_name='hdfeos'
tarball='HDF-EOS2.20v1.00.tar.Z'
base_url='https://observer.gsfc.nasa.gov/ftp/edhs/hdfeos/latest_release/'

export LMOD_SH_DBG_ON=0

# From http://stackoverflow.com/a/246128/1876449
# ----------------------------------------------
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
MAINDIR=$(dirname $SCRIPTDIR)

cd $SCRIPTDIR

# -----------------
# Detect usual bits
# -----------------

ARCH=$(uname -s)
MACH=$(uname -m)
NODE=$(uname -n)

case $ARCH in
   "Darwin")
      checksum='shasum -a 512 --check'
   ;;
   *)
      checksum='sha512sum -c'
   ;;
esac
sumfile=$SCRIPTDIR/${package_name}.sha512

if type wget > /dev/null ; then
  fetch='wget'
else
  fetch='curl'
fi

# ---------------
# Get the tarball
# ---------------
if [[ ! -f ${SCRIPTDIR}/${tarball} ]]
then
   $fetch -O $SCRIPTDIR/${tarball} ${base_url}${tarball}
fi

# ------------------
# Verify the tarball
# ------------------
$checksum $CURRDIR/$sumfile > /dev/null
retval=$?
if [[ $retval != 0 ]]
then
   echo "ERROR! Checksum for $tarball bad!"
   exit 1
fi

# ----------------
# Extract and link
# ----------------

# Get the name of the directory the tar command will make
tar_dir_name=$(tar tzf $SCRIPTDIR/$tarball | head -1 | cut -f2 -d"/")

# Untar to MAINDIR
if [[ ! -d $MAINDIR/$tar_dir_name ]]
then
   tar xf $SCRIPTDIR/$tarball -C $MAINDIR
fi

exit 0
