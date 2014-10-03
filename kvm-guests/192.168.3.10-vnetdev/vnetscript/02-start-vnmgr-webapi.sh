#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

sudo start vnet-vnmgr
sudo start vnet-webapi
sudo status vnet-vnmgr
sudo status vnet-webapi
