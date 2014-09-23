#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

boxes="
  kemukins-6.4-x86_64.kvm.box
  kemukins-6.5-x86_64.kvm.box
  vzkemukins-6.5-x86_64.kvm.box
  minimal-6.4-x86_64.kvm.box
  minimal-6.5-x86_64.kvm.box
"

function download_file() {
  local filename=${1}

  curl -fSkLR http://dlc.wakame.axsh.jp/wakameci/kemukins-box-rhel6/current/${filename} -o ${filename}.tmp
  mv ${filename}.tmp ${filename}
}

for box in ${boxes}; do
  echo ... ${box}

  download_file ${box}.md5
  remote_md5=$(< ${box}.md5)

  if [[ -f ${box} ]]; then
    local_md5=$(md5sum ${box} | awk '{print $1}')
    [[ "${remote_md5}" == "${local_md5}" ]] && continue
  fi

  download_file ${box}
done
