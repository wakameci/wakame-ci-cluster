#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

01-init-database.sh
02-start-vnmgr-webapi.sh
03-setup-openvnet.sh
04-start-vna.sh
05-start-lxc.sh
06-connect-tap-to-vswitch.sh
07-login-lxc1.sh
