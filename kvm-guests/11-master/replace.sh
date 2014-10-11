#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

distro_ver=6.5
[[ -a distro_ver.conf ]] && . distro_ver.conf
box_path=../../boxes/kemukins-${distro_ver}-x86_64.kvm.box

sudo ./stop.sh

sudo /bin/bash -ex <<'EOS'
  timestamp=$(date +%Y%m%d.%s).$$

  cur=./box-disk2.raw
  old=./old/box-disk2.raw.${timestamp}
  new=./box-disk2.raw

  mkdir -p old
  mv -i ${cur} ${old}

  ./mk2nd-disk.sh

  mkdir -p mnt1 mnt2
  mount -o loop -o ro ${old} ./mnt1/
  mount -o loop       ${new} ./mnt2/

  time rsync -ax ./mnt1/ ./mnt2/
  time sync

  umount ./mnt1
  umount ./mnt2
  rmdir mnt1 mnt2
EOS

sudo /bin/bash -ex <<EOS
  time tar zxvf ${box_path}
  time sync

  ./kemukins-init.sh
  ./run.sh
EOS
