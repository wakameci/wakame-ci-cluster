#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

sudo start vnet-vna
sudo status vnet-vna
