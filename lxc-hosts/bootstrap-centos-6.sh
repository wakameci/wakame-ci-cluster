#!/bin/bash
#
# requires:
#  bash
#
# usage:
#  $0 CTID (192.168.2.CTID)
#

. "${BASH_SOURCE[0]%/*}/bootstrap-common.sh"

distro_name=centos
distro_ver=6

. "${BASH_SOURCE[0]%/*}/bootstrap-common-setup.sh"

### configure /dev/pts
# PTY allocation request failed on channel 0
# via http://comments.gmane.org/gmane.linux.kernel.containers.lxc.general/2901
cat <<-'EOS' > ${rootfs_path}/etc/init/devpts.conf
	start on startup
	exec mount -t devpts none /dev/pts -o rw,noexec,nosuid,gid=5,mode=0620
	EOS

### configure udev
# lxc-template disables /sbin/start_udevd in /etc/rc.d/rc.sysinit.
# however device-mapper depends on udevd.
# if udevd is not running, udevadm command will fail and /dev/mapper/loopNpN will not exist.
cat <<-'EOS' > ${rootfs_path}/etc/init/lxc-udev.conf
	start on startup
	exec /sbin/udevd
	EOS

### post-install

#### copy.txt

#### execscript

. "${BASH_SOURCE[0]%/*}/bootstrap-common-mount.sh"

chroot ${rootfs_path} bash -ex <<EOS
  yum install -y curl sudo
  yum install -y qemu-kvm qemu-img
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
