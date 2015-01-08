# wakame-ci-cluster

Script to create VM instances.

## Install

```
$ git checkout https://github.com/wakameci/wakame-ci-cluster.git
$ cd wakame-ci-cluster
$ git submodule update --init --recursive
```

## Usage

First, download base images.


```
$ cd boxes
$ ./download-boxes.sh
```

Select flavor of instance.

```
$ cd ../kvm-guests
$ ls
101-vneskins/  11-master/             20-kemumaki/  92-vteskins/
102-vneskins/  12-kemumaki/           51-vnetkins/  93-vteskins/
103-vneskins/  13-kemumaki/           52-vnetkins/  94-vteskins/
104-vneskins/  14-kemumaki/           53-vnetkins/  execscript/
105-vneskins/  192.168.3.10-vnetdev/  90-vteskins/
106-vneskins/  192.168.3.11-vnetdev/  91-vteskins/
$ cd 192.168.3.11-vnetdev
```

Create instance.

```
$ ./replace.sh
$ ps aux|grep qemu
root     28625 68.8  1.1 1964512 181164 ?      Sl   18:21   0:08 qemu-system-x86_64 -enable-kvm -name kemu311 -cpu qemu64,+vmx -m 1024 -smp 1 -vnc 127.0.0.1:11311 -k en-us -rtc base=utc -monitor telnet:127.0.0.1:14311,server,nowait -serial telnet:127.0.0.1:15311,server,nowait -drive file=./box-disk1.raw,media=disk,boot=on,index=0,cache=none,if=virtio -netdev tap,ifname=kemu311-14311-0,id=hostnet0,script=,downscript= -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:51:06:48,bus=pci.0,addr=0x3 -pidfile kvm.pid -daemonize
```

Login the instance with usename := "kemumaki" and password := "kemumaki".

```
$ telnet localhost 15311
--snip--
10-vnetdev login: kemumaki
Password: kemumaki
[kemumaki@10-vnetdev ~]$ uname -a
Linux 10-vnetdev 2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
[kemumaki@10-vnetdev ~]$ sudo shutdown -h now
```
