#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

readonly abs_dirname=$(cd ${BASH_SOURCE[0]%/*} && pwd)
box_path=${1}

[[ -n "${box_path}" ]]

time tar zxvf ${box_path}
time sync
