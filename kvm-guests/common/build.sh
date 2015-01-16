#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

[[ -f ./metadata/vmspec.conf ]]
.     ./metadata/vmspec.conf

sudo /bin/bash -e <<EOS
  if [[ -f ./prebuild.sh ]]; then
    ./prebuild.sh
  fi

  ../common/unpack-box.sh ${box_path}
  ../common/kemumaki-init.sh
EOS
