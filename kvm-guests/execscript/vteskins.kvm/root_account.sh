#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail

chroot_dir=${1}

mkdir -p -m 700 ${chroot_dir}/root/.ssh
chmod       700 ${chroot_dir}/root/.ssh

cat <<'EOS' > ${chroot_dir}/root/.ssh/config
Host *
        StrictHostKeyChecking no
        TCPKeepAlive yes
        UserKnownHostsFile /dev/null
        ForwardAgent yes
EOS

chmod 600 ${chroot_dir}/root/.ssh/config

cat <<'EOS' > ${chroot_dir}/root/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA6f1rIZIr8yinc1FNsQGDZ4Dy76oyHNvIi/AM24CTQUFpR4CF
NVHaixr2XMtRxuOGjdaVELKR33GF/nKtgbSm4nmVmEOhONtFlHswM9rfLFA0FeAW
jr79X3shZyM41AQ3uyIjMGm9DPyBmSJCGA7rBkil4H5J7zJhKlRhycIYvtFRE6q4
kwUurvjpQEau59+GnkugqCnHK4XvdpY9YxAvRPdOfTf2I90vTWWrzOUIr/n/Vxr+
0BQ/cJAc0jrMbXNZZarw+FT0nzgQJoLCz8tecLGjttHeSDFdc+Z081gXB3AY3KiJ
BTbvs165DBHt91sEc2vxjdnAM2GfYsKGX4cfBwIBIwKCAQEAkxRR99g44fxL/1et
LW6qXlENuzfHul5DiykspzrgN6V1YCTmBEIUV3AIkhlmmkXfjFr+nMgD64kvp0DE
1S+5WyfaX7V7SE9QTrPVJ+ipiZF/0zxl81N6sQuRVsWusSc4+UioZ5Lr3EbyYEFr
X5RZNyZZow2Njwm5axB3+ymL5abwpPPD1p4hSd9JgdL1v1r6x3HqMTV02B0ZTGsP
agcHQCtMba403TiCe6MhX3KNNRi8WXqbIdoVlIZWvEbR6lo27L8rcX+xWI1xp067
avw8E4ZGj3BhTo1lwXVQ0NZjFPqbN6fgLdpeIT2qbpISs/JpNM6UAIUJwbZJveNB
qcYB2wKBgQD2Y+RBW8rDBKRGc8GFwUR5APfmFx8UHDTmwNVJalivktWnpuS48e+W
0in0SiI8sjkFgxiYAk6bvG3J87gbcqSOgIC4+Hk0A4bjg8ueO7X5yuRmn79T1Lzv
ikQyAne49TalrJpeH17B6KOM9Qeb5/rGHnTu3wWEjLQBwUOfYD1rmwKBgQDzHbcF
eRBN+p/zrIb/R6GV66ojFDWnt3/U03O4ijf0KSKV+Um6jCr3cLgw9oyOQI38ugUq
LzCBXx4OsvrAHT9E+CihbjODjtAmXlzL3j5K49S1j/cG6tlMB1BZpKKR5TZk+mvR
4rb1IXv6Cgqoq0dRI9zorgCU2zooUH4VzkjfBQKBgA4UVi+e2GLqUoeu19vB5qfU
K2w71ePkWstbeebwIlMs9kQYKlO2DbDYzzKH5LMC3q/bmwFfN7EgtdEGnM5eUovM
1CfTryeLLEeD37/mJ6fftUexW2PgRU+EPmlB+DZ0aYXPWUc0/hm1hbBIhBeJmU0m
T9Mir9uwRMzmeOSJKBTHAoGBAKa1SkzlTQJFdP7ctFdHD7dCg0tBDtln4qCQ/uTx
EGzpAcXsxNewkn3Jot+/AUuZ+vZw7ZlE7g+RrjX3ElfZinhvptUYXdaN0I9Wpggj
Xeo106+zLQwOwOOtPmla8yI2xjadFrvOqVeh7pzTr4maBQRwXPdSvpH1abU+glgY
bHurAoGBAIR/gIAb8mQvwxezVX3lFveaP6wwl2L8Igco+ZfnqXsXOWYC1Ob+NWPD
IdblKepx+eopdnOUV4Gvv5LzA1WK1leOP9iF4pVaH29T6F/aVJFFtW7EPjsLavq0
DJg+STqnpf3XIFzH9BuhzgfqDwKHyh/5pd4217Mr84kqepUCoSJh
-----END RSA PRIVATE KEY-----
EOS

chmod 600 ${chroot_dir}/root/.ssh/id_rsa