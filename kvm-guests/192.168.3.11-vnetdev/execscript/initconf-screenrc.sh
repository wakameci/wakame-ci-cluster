#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}
ipaddr=10.0.1.10

cat > $1/home/kemumaki/.screenrc <<'EOS'
escape ^Ta
caption always '%?%F%{= mW}%:%{= Kk}%?%2n%f%07=%t%='
hardstatus alwayslastline '%m/%d %02c %{= .m}%H%{-} %L=%-w%45L>%{=u m.}%n %t%{-}%+w %-17<%=%{= .y}(%l)'
EOS
