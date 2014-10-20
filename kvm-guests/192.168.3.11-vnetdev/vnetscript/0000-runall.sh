#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

01-start-vna.sh
02-start-lxc.sh
03-connect-tap-to-vswitch.sh
04-login-lxc1.sh
