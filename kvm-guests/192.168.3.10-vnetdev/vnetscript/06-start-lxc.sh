#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

sudo lxc-start -d -n lxc1
sudo lxc-info -n lxc1
