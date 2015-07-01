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
distro_ver=20

### create container

lxc-create -n ${ctid} -t ${distro_name} -- -R ${distro_ver}

### configure networking

install_lxc_conf ${ctid}
install_ifcfg    ${ctid}

### configure hostname

sed -i s,^HOSTNAME=.*,HOSTNAME=${hostname}, ${rootfs_path}/etc/sysconfig/network
echo ${hostname} > ${rootfs_path}/etc/hostname

### post-install

#### copy.txt

#### execscript

mount -o bind /proc ${rootfs_path}/proc

chroot ${rootfs_path} bash -ex <<EOS
  yum install -y curl sudo
  yum install -y qemu-kvm qemu-img
  yum install -y parted kpartx e2fsprogs
  yum install -y lxc lxc-extra lxc-templates
EOS

chroot ${rootfs_path} bash -ex <<EOS
  usermod -L root
  until curl -fsSkL https://raw.githubusercontent.com/hansode/add-github-user.sh/master/add-github-user.sh -o /usr/local/bin/add-github-user.sh; do
    sleep 1
  done
  chmod +x /usr/local/bin/add-github-user.sh
  /usr/local/bin/add-github-user.sh axsh
  /usr/local/bin/add-github-user.sh hansode
  /usr/local/bin/add-github-user.sh t-iwano
EOS

umount ${rootfs_path}/proc

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
  yum -y reinstall iputils
EOS
