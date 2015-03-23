#!/bin/bash

set -e
set -o pipefail
set -x

whereami=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function for_all_layer_1() {
  local cmd="$1"

  for i in 1 2 3 4 5; do
    (
      cd ${whereami}/../9${i}-vteskins/
      $cmd
    )
  done
}

function for_all_layer_2() {
  local cmd="$1"

  for i in 1 2 3 4 5 6; do
    (
      cd ${whereami}/../10${i}-vneskins/
      $cmd
    )
  done
}

./init-bridges.sh

# Set the PATH variable so chrooted centos will know where to find stuff
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

for_all_layer_2 "./build.sh"
for_all_layer_2 "./pack-box.sh"
for_all_layer_1 "./replace.sh"
