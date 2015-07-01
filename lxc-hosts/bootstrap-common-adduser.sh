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
  /usr/local/bin/add-github-user.sh unakatsuo
  /usr/local/bin/add-github-user.sh metallion
  /usr/local/bin/add-github-user.sh rakshasa
  /usr/local/bin/add-github-user.sh k-oyakata
  /usr/local/bin/add-github-user.sh akry
  /usr/local/bin/add-github-user.sh triggers
  /usr/local/bin/add-github-user.sh toros11
  /usr/local/bin/add-github-user.sh mopster
EOS
