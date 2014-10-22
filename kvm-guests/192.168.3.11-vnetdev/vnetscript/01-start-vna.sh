#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

sudo stop vnet-vna || true

sudo start vnet-vna
sudo status vnet-vna
