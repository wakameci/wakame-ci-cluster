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
  ./build.sh
  ../common/qcow2-init.sh
  ./run.sh
EOS
