#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

ssh_target=jenkins@172.16.255.11

cd /data/kvm-guests/11-master
pwd

ssh ${ssh_target} <<EOS
  sudo shutdown -h now
EOS

sleep 20
sync

sudo $SHELL -e <<'EOS'
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

  time rsync -avx ./mnt1/ ./mnt2/
  time sync

  umount ./mnt1
  umount ./mnt2
  rmdir mnt1 mnt2

  time tar zxvf /data/boxes/kemukins-6.5-x86_64.kvm.box
  time sync

  ./kemukins-init.sh
  ./run.sh
EOS

sleep 20
sync

ssh ${ssh_target} <<EOS
  time sudo yum update -y --disablerepo='*' --enablerepo=jenkins jenkins

  chkconfig --list jenkins
  sudo chkconfig jenkins on
  chkconfig --list jenkins

  date
  sudo service jenkins restart
  date
EOS
