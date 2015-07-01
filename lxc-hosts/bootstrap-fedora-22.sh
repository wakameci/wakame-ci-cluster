#!/bin/bash
#
# requires:
#  bash
#
# usage:
#  $0 CTID (192.168.2.CTID)
#

. "${BASH_SOURCE[0]%/*}/bootstrap-common.sh"

distro_name=fedora
distro_ver=22

. "${BASH_SOURCE[0]%/*}/bootstrap-common-setup.sh"

### post-install

#### copy.txt

#### execscript

. "${BASH_SOURCE[0]%/*}/bootstrap-common-mount.sh"

# fedora-release-21-X.rpm does not provide /etc/yum.repos.d/*.repo
chroot ${rootfs_path} bash -ex <<EOS
  rpm -qa fedora-repos | egrep -q fedora-repos || {
    rpm -ivh http://ftp.jaist.ac.jp/pub/Linux/Fedora/releases/${distro_ver}/Everything/x86_64/os/Packages/f/fedora-repos-${distro_ver}-1.noarch.rpm
  }
  dnf repolist all
EOS

chroot ${rootfs_path} bash -ex <<EOS
  dnf install -y curl sudo
  dnf install -y qemu-kvm qemu-img
  dnf install -y parted kpartx e2fsprogs

  # fedora-22 lxc-1.1.2 does not work.
  dnf install -y http://ftp.riken.jp/Linux/fedora/releases/21/Everything/x86_64/os/Packages/l/lua-lxc-1.0.6-1.fc21.x86_64.rpm
  dnf install -y http://ftp.riken.jp/Linux/fedora/releases/21/Everything/x86_64/os/Packages/l/lxc-1.0.6-1.fc21.x86_64.rpm
  dnf install -y http://ftp.riken.jp/Linux/fedora/releases/21/Everything/x86_64/os/Packages/l/lxc-libs-1.0.6-1.fc21.x86_64.rpm
  dnf install -y http://ftp.riken.jp/Linux/fedora/releases/21/Everything/x86_64/os/Packages/p/python3-lxc-1.0.6-1.fc21.x86_64.rpm
  dnf install -y http://ftp.riken.jp/Linux/fedora/releases/21/Everything/x86_64/os/Packages/l/lxc-extra-1.0.6-1.fc21.x86_64.rpm
  dnf install -y http://ftp.riken.jp/Linux/fedora/releases/21/Everything/x86_64/os/Packages/l/lxc-templates-1.0.6-1.fc21.x86_64.rpm
EOS

. "${BASH_SOURCE[0]%/*}/bootstrap-common-adduser.sh"
. "${BASH_SOURCE[0]%/*}/bootstrap-common-umount.sh"

### start container

"${BASH_SOURCE[0]%/*}/lxc-start.sh" "${ctid}"

# setup kvm-host
lxc-attach -n ${ctid} -- bash -ex <<EOS
  cd /tmp
  until curl -fsSkL https://raw.githubusercontent.com/wakameci/wakame-ci-cluster/master/kvm-hosts/setup-${distro_name}-${distro_ver}.sh -o ./setup-${distro_name}-${distro_ver}.sh; do
    sleep 1
  done
  chmod +x ./setup-${distro_name}-${distro_ver}.sh
  sed -i s,--disablerepo=updates,, ./setup-${distro_name}-${distro_ver}.sh
  ls -l ./setup-${distro_name}-${distro_ver}.sh
  ./setup-${distro_name}-${distro_ver}.sh
  rm ./setup-${distro_name}-${distro_ver}.sh
EOS

# warm up device-mapper
"${BASH_SOURCE[0]%/*}/lxc-dmwarmup.sh" "${ctid}"

# > $ ping 192.168.2.249
# > ping: icmp open socket: Operation not permitted
# http://comments.gmane.org/gmane.linux.redhat.fedora.general/409425
lxc-attach -n ${ctid} -- bash -ex <<EOS
  dnf -y reinstall iputils
EOS
