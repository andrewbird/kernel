#!/bin/sh

# Where we get the test suite from
TUSER='andrewbird'
TREPO='dosemu2'
TBRANCH='freedos-testing'

# Ideally we'd target a directory called 'test' but that already exists so work around it.
TGT="test-dosemu2"

# Get the test directory from Dosemu2
rm -rf ${TGT}
wget -O - --no-verbose https://github.com/${TUSER}/${TREPO}/archive/refs/heads/${TBRANCH}.tar.gz | \
tar -zx ${TREPO}-${TBRANCH}/test && mv ${TREPO}-${TBRANCH}/test ${TGT} && rmdir ${TREPO}-${TBRANCH}

# Originally from dosemu2
sudo add-apt-repository -y ppa:jwt27/djgpp-toolchain

sudo apt install -y \
  nasm \
  python3-cpuinfo \
  python3-pexpect \
  mtools \
  gcc-djgpp \
  djgpp-dev \
  qemu-system-common \
  gdb \
  valgrind \
  gcc-ia16-elf \
  libi86-ia16-elf \
  genisoimage \
  bridge-utils \
  libvirt-daemon \
  libvirt-daemon-system

# Get the files we need to test with
${TGT}/test_dosemu.py --get-test-binaries

# Install the FAT mount helper
sudo cp ${TGT}/dosemu_fat_mount.sh /bin/.
sudo chown root:root /bin/dosemu_fat_mount.sh
sudo chmod 755 /bin/dosemu_fat_mount.sh

# Install the TAP helper
sudo cp ${TGT}/dosemu_tap_interface.sh /bin/.
sudo chown root:root /bin/dosemu_tap_interface.sh
sudo chmod 755 /bin/dosemu_tap_interface.sh
