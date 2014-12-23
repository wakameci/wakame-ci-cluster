#!/bin/bash
#
# requires:
#  bash
#
# usage:
#  $0
#
set -e
set -o pipefail
set -x

PATH=/bin:/usr/bin:/sbin:/usr/sbin

lxc-ls --fancy
