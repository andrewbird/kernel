#! /bin/bash

KVER=8632

if [ ! -f _output/gcc/kgc${KVER}.sys ] ; then
  echo GCC built kernel not present
  exit 1
fi

if [ ! -f _output/wc/kwc${KVER}.sys ] ; then
  echo Watcom built kernel not present
  exit 1
fi

if [ ! -f _output/wc_dos/kwc38632.sys ] ; then
  echo Watcom DOS built kernel not present
  exit 1
fi

if [ ! -f _output/tc_dos/ktc8632.sys ] && [ -d ${HOME}/.dosemu/drive_c/tc201 ] ; then
  echo Turbo C 2.01 built kernel not present
  exit 1
fi

echo Kernels have all been built
find _output -ls

cd test
if ! ./test.sh ../_output/gcc/kgc${KVER}.sys diskgc bootgc 'boot gcc: '
then
  echo GCC boot test failed
  exit 2
fi
if ! ./test.sh ../_output/wc/kwc${KVER}.sys diskwc bootwc 'boot wc: '
then
  echo OpenWatcom boot test failed
  exit 2
fi
if ! ./test.sh ../_output/wc_dos/kwc38632.sys diskwcd bootwcd 'boot wcd: '
then
  echo 'OpenWatcom(DOS) boot test failed'
  exit 2
fi
if [ -d ${HOME}/.dosemu/drive_c/tc201 ] ; then
  if ! ./test.sh ../_output/tc_dos/ktc8632.sys disktcd boottcd 'boot tcd: '
  then
    echo 'Turbo C 2.01 boot test failed'
    exit 2
  fi
fi
cd ..

echo Now run Dosemu2\'s test suite
TGT="test-dosemu2"

if [ ! -d "${TGT}" ] ; then
  echo "{TGT}" does not exist, run ci_test_prereq.sh
  exit 3
fi

export SKIP_EXPENSIVE=1

export TEST_DOSEMU=/usr/bin/dosemu
export TEST_CMDDIR=/usr/share/dosemu/dosemu2-cmds-0.3
export NO_FAILFAST=1

# Use the production FreeCOM from FreeDOS 1.3
tar -xf test-binaries/FR-DOS-1.30.tar command.com
export FDOS_COMMAND_COM="$(pwd)/command.com"

echo "##########################################################################"
echo "#                     Testing Cross Compiled GCC build                   #"
echo "##########################################################################"
KDIR="_output/gcc"
cp ${KDIR}/kgc8632.sys ${KDIR}/kernel.sys
export FDOS_KERNEL_SYS="${KDIR}/kernel.sys"
export FDOS_SHARE_COM="${KDIR}/share.com"
export FDOS_COUNTRY_SYS="${KDIR}/country.sys"
"${TGT}"/test_dosemu.py FRDOSGITTestCase
mkdir ${KDIR}/failures
for f in test_dosemu*.log test_dosemu*.xpt ;  do
  [ -e "$f" ] && mv "$f" ${KDIR}/failures/.
done

echo "##########################################################################"
echo "#                  Testing Cross Compiled Watcom build                   #"
echo "##########################################################################"
KDIR="_output/wc"
cp ${KDIR}/kwc8632.sys ${KDIR}/kernel.sys
export FDOS_KERNEL_SYS="${KDIR}/kernel.sys"
#export FDOS_SHARE_COM="${KDIR}/share.com"  # Share not currently buildable with watcom, so use gcc build
export FDOS_COUNTRY_SYS="${KDIR}/country.sys"
"${TGT}"/test_dosemu.py FRDOSGITTestCase
mkdir ${KDIR}/failures
for f in test_dosemu*.log test_dosemu*.xpt ;  do
  [ -e "$f" ] && mv "$f" ${KDIR}/failures/.
done

echo "##########################################################################"
echo "#                  Testing Native Compiled Watcom build                  #"
echo "##########################################################################"
KDIR="_output/wc_dos"
cp ${KDIR}/kwc38632.sys ${KDIR}/kernel.sys
export FDOS_KERNEL_SYS="${KDIR}/kernel.sys"
#export FDOS_SHARE_COM="${KDIR}/share.com"  # Share not currently buildable with watcom, so use gcc build
export FDOS_COUNTRY_SYS="${KDIR}/country.sys"
"${TGT}"/test_dosemu.py FRDOSGITTestCase
mkdir ${KDIR}/failures
for f in test_dosemu*.log test_dosemu*.xpt ;  do
  [ -e "$f" ] && mv "$f" ${KDIR}/failures/.
done

echo "##########################################################################"
echo "#                  Testing Native Compiled TurboC build                  #"
echo "##########################################################################"
KDIR="_output/tc_dos"
cp ${KDIR}/ktc8632.sys ${KDIR}/kernel.sys
export FDOS_KERNEL_SYS="${KDIR}/kernel.sys"
export FDOS_SHARE_COM="${KDIR}/share.com"
export FDOS_COUNTRY_SYS="${KDIR}/country.sys"
"${TGT}"/test_dosemu.py FRDOSGITTestCase
mkdir ${KDIR}/failures
for f in test_dosemu*.log test_dosemu*.xpt ;  do
  [ -e "$f" ] && mv "$f" ${KDIR}/failures/.
done

# Now see if we have any failures and return the appropriate error code
for i in _output/*/failures/test_*.*.*.log ; do
  test -f $i || exit 0
done

exit 1
