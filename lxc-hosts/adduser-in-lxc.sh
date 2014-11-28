#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -e

ctid=${1}
user=${2}

[[ -n "${ctid}" ]]
[[ -n "${user}" ]]

lxc-attach -n ${ctid} -- /usr/local/bin/add-github-user.sh ${user}
