#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

sudo /bin/bash -e <<EOS
  ../common/stop.sh
EOS

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
  ./build.sh
  ../common/qcow2-init.sh
  ./run.sh
EOS
