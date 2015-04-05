#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)

time tar zScvf ${abs_dirname##*/}.kvm.box box-disk1.raw run.sh
