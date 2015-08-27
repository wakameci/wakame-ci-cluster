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
  ../common/qcow2-init.sh
  ../common/run.sh
EOS
