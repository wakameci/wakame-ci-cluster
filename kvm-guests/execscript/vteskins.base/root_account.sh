#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

mkdir -p -m 700 ${chroot_dir}/root/.ssh
chmod       700 ${chroot_dir}/root/.ssh

cat <<EOS > ${chroot_dir}/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/+QxDMCBfOKGAZH8CprLyG773HLzypqI/muToRxLojzJ/uge5ldwuKwlKBkEIfgMOYj8U18kZGaBtwO5jG9R7eensFlnIkJrTnDoiyH0aD1UyfM8V2ZuWIHbtM/aKhif4utYD2uJ/2zJaZVj5vpB9WUGB19XA3AOO11BiRTgD7nWxeGW1FERh1tVycHZFp+JijfquPbaM3VzQz0ZEpXhnRXZVzOpC/fX3WZTxT+BXTSiRuw42cpCVCDPNGabYk0hin7RqlhoyVXo9/BsruktpeqVb54XuQXaejfhOOo+EmMsEqaWFefQDCkSu33RSM7XBWHht7L4rJFccJJlXEEpH vnet@kagami
EOS

chmod 600 ${chroot_dir}/root/.ssh/authorized_keys

chroot $1 $SHELL -ex <<'EOS'
  usermod -U root
  echo root:root | chpasswd
EOS

cat <<'EOS' > ${chroot_dir}/root/.ssh/config
Host *
        StrictHostKeyChecking no
        TCPKeepAlive yes
        UserKnownHostsFile /dev/null
        ForwardAgent yes
EOS

chmod 600 ${chroot_dir}/root/.ssh/config

cat <<'EOS' > ${chroot_dir}/root/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin
PATH=/opt/axsh/openvnet/ruby/bin/:$PATH

export PATH
EOS

chmod 644 ${chroot_dir}/root/.bash_profile
