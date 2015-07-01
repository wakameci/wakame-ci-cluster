#!/bin/bash
#
# requires:
#  bash
#

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
