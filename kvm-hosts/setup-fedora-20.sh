#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

LANG=C
LC_ALL=C

distro_name=fedora
distro_ver=20

# hold releasever
mkdir -p /etc/yum/vars
echo ${distro_ver} > /etc/yum/vars/releasever

# keep cache
function configure_keepcache() {
  local keepcache=1

  egrep -q ^keepcache= /etc/yum.conf && {
    sed -i "s,^keepcache=.*,keepcache=${keepcache}," /etc/yum.conf
  } || {
    echo keepcache=${keepcache} >> /etc/yum.conf
  }

  egrep ^keepcache= /etc/yum.conf
}
configure_keepcache

# %packages
addpkg=$(cat <<EOS | egrep -v '^%|^@|^#|^$'
%packages --nobase --ignoremissing
@Core
# vmbuilder
openssh
openssh-clients
openssh-server
rpm
yum
curl
dhclient
passwd
vim-minimal
sudo
# build kernel module
kernel-devel
gcc
perl
bzip2
# bootstrap
ntp
ntpdate
man
sudo
rsync
git
make
vim-minimal
screen
nmap
lsof
strace
tcpdump
traceroute
telnet
ltrace
bind-utils
sysstat
nc
wireshark
zip
# shared folder
nfs-utils
#
acpid
# additional packages: kemumaki
bridge-utils
iptables-services
## ci tool
#java-1.6.0-openjdk
java-1.7.0-openjdk
dejavu-sans-fonts
## compilers & rpm/yum build tools
make
gcc
gcc-c++
rpm-build
automake
createrepo
openssl-devel
zlib-devel
kernel-devel
perl
## vm image build tools
qemu-kvm
qemu-img
parted
kpartx
zip
## qemu dependency
# qemu-system-x86_64: symbol lookup error: qemu-system-x86_64: undefined symbol: glfs_discard_async
glusterfs
## 1box build
e2fsprogs
tar
## mussel
openssl
which
# beremetail/hardware
pciutils
lshw
%end
EOS
)

# enable to run script many times
# yum install --disablerepo=updates -y ${addpkg}
yum install -y ${addpkg}
# base's kpartx is broken.
yum update   --enablerepo=updates -y kpartx
# anti-shellshock
yum update   --enablerepo=updates -y bash
# kvm on lxc
yum install --enablerepo=updates -y lxc lxc-templates lxc-extra
# "udevadm settle" freeze
yum update   --enablerepo=updates -y device-mapper

# selinux
if [[ -f /etc/selinux/config ]]; then
  sed -i s,SELINUX=enforcing,SELINUX=disabled, /etc/selinux/config
fi

# sudo
sed -i "s/^\(^Defaults\s*requiretty\).*/# \1/" /etc/sudoers

# timezone
ln -fs /usr/share/zoneinfo/Japan /etc/localtime

#------------------------------------------------------------
# kemumaki
#------------------------------------------------------------

getent group  jenkins >/dev/null || groupadd -r jenkins
getent passwd jenkins >/dev/null || useradd  -g jenkins -d /var/lib/jenkins -s /bin/bash -r -m jenkins
usermod -s /bin/bash jenkins
chmod 755 /var/lib/jenkins

getent group  jenkins
getent passwd jenkins

usermod -s /bin/bash jenkins
egrep -w ^jenkins /etc/sudoers || {
  echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
}

mkdir -p -m 700 /var/lib/jenkins/.ssh
chmod       700 /var/lib/jenkins/.ssh

cat <<EOS > /var/lib/jenkins/.ssh/authorized_keys
ssh-dss AAAAB3NzaC1kc3MAAACBAJXPRxTHqW0DtVYK/G/unjaeKV2E3pZIdRFkWgGhImTw1HczMW81jBgGRL7NQS2ijrwr4QKZ+nergLslsl6IeKIF1G8q0wb3PFlFxy2cEdF+Z0kYgoLz0wV+zPEUfubLfl7Dvkg1+LZSwikohu18pM3tZa0wixypkJHIeKIJXIYLAAAAFQDqFSLlIDRXiUQHO+L/kD/qkg2ykwAAAIAQR+QuQvFLw2EOl8SNOT6nqOzjWE5VM2/9gGBMPhk2IhoAhxz7VgF1H5jPQMhe2nq1opTHsKd7pW7zi7cfO65qL/UQWtAlYvkoir8Gn7+UpYrPLa2wtLP+u2O8nB6ure56B/t5OhPib8FL0fXhF2vaURJ/nerfSAdbfL8Lk+9rngAAAIALY5M6hhtJCVT2uH400D3Dz+l3vG613UEFKahHZpIdVAwlMyQEFyRBd07Dfjw5u1KwRbyJX4u41MBmqhXDYPyPED/bB/CddOiR3tjq7Im9kMp9+P4NB4uo4088/ntfCFXgFHb10UBYBhI5VqqTx7DZ+KeG5SOckk2BDgEUrWEshw== kemumaki-login
EOS

cat <<EOS > /var/lib/jenkins/.ssh/config
Host *
        StrictHostKeyChecking no
        TCPKeepAlive yes
        UserKnownHostsFile /dev/null
        ForwardAgent yes
EOS

chown -R jenkins:jenkins /var/lib/jenkins/.ssh

getent group kvm && {
  gpasswd -a jenkins kvm
}

curl -fsSkL https://github.com/hansode/buildbook-rhel6/raw/master/jenkins.slave/guestroot/var/lib/jenkins/slave.jar -o /var/lib/jenkins/slave.jar
chown jenkins:jenkins /var/lib/jenkins/slave.jar

# ifcfg-vboxbr0
cat <<EOS > /etc/sysconfig/network-scripts/ifcfg-vboxbr0
DEVICE=vboxbr0
TYPE=Bridge
ONBOOT=yes

BOOTPROTO=static

IPADDR=10.0.2.2
NETMASK=255.255.255.0
NETWORK=10.0.2.0
BROADCAST=10.0.2.255
EOS

# ifcfg-kemumakibr0
cat <<EOS > /etc/sysconfig/network-scripts/ifcfg-kemumakibr0
DEVICE=kemumakibr0
TYPE=Bridge
ONBOOT=yes

BOOTPROTO=static

IPADDR=172.16.255.2
NETMASK=255.255.255.0
NETWORK=172.16.255.0
BROADCAST=172.16.255.255
EOS

# ifcfg-nestbr0
cat <<EOS > /etc/sysconfig/network-scripts/ifcfg-nestbr0
DEVICE=nestbr0
TYPE=Bridge
ONBOOT=yes

BOOTPROTO=static

IPADDR=172.16.2.2
NETMASK=255.255.255.0
NETWORK=172.16.2.0
BROADCAST=172.16.2.255
EOS

# iptables
cat <<EOS > /etc/sysconfig/iptables
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
$(
PRIMARY_NIC=${PRIMARY_NIC:-"em1 eth0"}
for ifname in ${PRIMARY_NIC}; do
  [[ -f /etc/sysconfig/network-scripts/ifcfg-${ifname} ]] || continue
  echo -A POSTROUTING -o ${ifname} -s 10.0.2.0/24     -j MASQUERADE
  echo -A POSTROUTING -o ${ifname} -s 172.16.255.0/24 -j MASQUERADE
  echo -A POSTROUTING -o ${ifname} -s 172.16.2.0/24   -j MASQUERADE
done
)
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport   22 -j ACCEPT
#-A INPUT -j REJECT --reject-with icmp-host-prohibited
#-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOS

# nested-kvm
# -> /sys/module/kvm_{intel,amd}/parameters/nested
for kvmmod in kvm_intel kvm_amd; do
  lsmod | grep ${kvmmod} || continue

  echo "options ${kvmmod/_/-} nested=1" > /etc/modprobe.d/${kvmmod/_/-}.conf


  case "$(< /sys/module/${kvmmod}/parameters/nested)" in
    Y)
      # kvm_intel
      ;;
    1)
      # kvm_amd
      ;;
    *)
      modprobe -r ${kvmmod}
      modprobe    ${kvmmod}
      ;;
  esac

  cat /sys/module/${kvmmod}/parameters/nested
done

# nbd
# -> /sys/module/nbd/parameters/*
echo "options nbd max_part=15" > /etc/modprobe.d/nbd.conf

# ip-forward
cat <<EOS > /etc/sysctl.d/enable-ip-forward.conf
net.ipv4.ip_forward = 1
EOS

#
systemctl disable firewalld.service
systemctl enable  iptables.service

systemctl disable NetworkManager.service
systemctl enable  network.service

## ntp
systemctl enable ntpdate
systemctl enable ntpd

systemctl start  ntpdate
systemctl start  ntpd

## NetworkManager.service -> network.service
for ifcfg in /etc/sysconfig/network-scripts/ifcfg-{e,p}*; do
  [[ -f ${ifcfg} ]] || continue
  sed -i "s,0=,=," ${ifcfg}
done
if systemctl status  NetowrkManager.service; then
   systemctl stop    NetworkManager.service
fi
systemctl start   network.service

## firewalld.service -> iptables.service
if systemctl status  firewalld.service; then
   systemctl stop    firewalld.service
fi
systemctl start   iptables.service

service network restart
