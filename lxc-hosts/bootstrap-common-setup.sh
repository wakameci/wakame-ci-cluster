#!/bin/bash
#
# requires:
#  bash
#

### create container

lxc-create -n ${ctid} -t ${distro_name} -- -R ${distro_ver}

### configure networking

install_lxc_conf ${ctid}
install_ifcfg    ${ctid}

### configure hostname

sed -i s,^HOSTNAME=.*,HOSTNAME=${hostname}, ${rootfs_path}/etc/sysconfig/network
echo ${hostname} > ${rootfs_path}/etc/hostname
