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

lxc-ls --fancy
