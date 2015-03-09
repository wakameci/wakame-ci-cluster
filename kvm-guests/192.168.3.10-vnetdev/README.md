# Run 4 LXC instances on 2 KVM instances

## Network Structure

![](draw/network_structure.png)

## Build

Simply, type "make".

```
$ git clone https://github.com/wakameci/wakame-ci-cluster.git
$ cd wakame-ci-cluster/kvm-guests/192.168.3.10-vnetdev/
$ make
$ ps aux|grep qemu-|grep root
root     15480  9.7  4.0 5425116 671340 ?      Sl   19:22   1:14 qemu-system-x86_64 -enable-kvm -name kemu310 -cpu qemu64,+vmx -m 1024 -smp 1 -vnc 127.0.0.1:11310 -k en-us -rtc base=utc -monitor telnet:127.0.0.1:14310,server,nowait -serial telnet:127.0.0.1:15310,server,nowait -drive file=./box-disk1.raw,media=disk,boot=on,index=0,cache=none,if=virtio -netdev tap,ifname=kemu310-14310-0,id=hostnet0,script=,downscript= -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:51:06:47,bus=pci.0,addr=0x3 -netdev tap,ifname=kemu310-14310-1,id=hostnet1,script=,downscript= -device virtio-net-pci,netdev=hostnet1,mac=52:54:00:51:16:47,bus=pci.0,addr=0x4 -pidfile kvm.pid -daemonize
root     25325 13.0  1.4 5604284 236364 ?      Sl   19:33   0:09 qemu-system-x86_64 -enable-kvm -name kemu311 -cpu qemu64,+vmx -m 1024 -smp 1 -vnc 127.0.0.1:11311 -k en-us -rtc base=utc -monitor telnet:127.0.0.1:14311,server,nowait -serial telnet:127.0.0.1:15311,server,nowait -drive file=./box-disk1.raw,media=disk,boot=on,index=0,cache=none,if=virtio -netdev tap,ifname=kemu311-14311-0,id=hostnet0,script=,downscript= -device virtio-net-pci,netdev=hostnet0,mac=52:54:00:51:06:48,bus=pci.0,addr=0x3 -netdev tap,ifname=kemu311-14311-1,id=hostnet1,script=,downscript= -device virtio-net-pci,netdev=hostnet1,mac=52:54:00:51:16:48,bus=pci.0,addr=0x4 -pidfile kvm.pid -daemonize
```

```
$ brctl show
bridge name	bridge id		STP enabled	interfaces
vnet_mng_br0		8000.62fb6f507bcb	no		kemu310-14310-1
							kemu311-14311-1
vnet_ovs_br0		8000.964537a5533c	no		kemu310-14310-0
							kemu311-14311-0
```

Both KVM's are now running and need some further configuring.

## Configuration

### KVM1

Connect to KVM1 :

```
$ telnet localhost 15310
```
And run the configuration script
```
 0000-runall.sh
```
This wil automatically connect you to lxc1, you can log in with the following credentials. 

```
localhost login: root
Password: root
```
Bring the eth0 interface up :
```
[root@localhost ~]# ifup eth0
[root@localhost ~]# ifconfig |grep -A 1 eth0
eth0      Link encap:Ethernet  HWaddr 00:18:51:E5:35:01
          inet addr:10.0.0.200  Bcast:10.0.0.255  Mask:255.255.255.0
```

This also needs to be done on lxc2. You can now SSH to the KVM :

```
$ ssh 10.0.1.10
login : root
password : root
```

Open lxc2 :

```
[root@10-vnetdev ~]# lxc-console -n lxc2
```

And bring the eth0 interface up

```
[root@localhost ~]# ifup eth0
[root@localhost ~]# ifconfig |grep -A 1 eth0
eth0      Link encap:Ethernet  HWaddr 00:18:51:E5:35:02
          inet addr:10.0.0.201  Bcast:10.0.0.255  Mask:255.255.255.0
```

The KVM is now fully up and running. lxc1 and lxc2 should be able to ping eachother

```
[root@10-vnetdev ~]# ovs-vsctl show
4de9be19-b1d0-46c7-abfd-063f8c4184cf
    Bridge "br0"
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: standalone
        Port "eth0"
            Interface "eth0"
        Port "veth_kvm1lxc2"
            Interface "veth_kvm1lxc2"
        Port "veth_kvm1lxc1"
            Interface "veth_kvm1lxc1"
        Port "br0"
            Interface "br0"
                type: internal
    ovs_version: "2.3.1"
```

### KVM2

The same process needs to be repeated for KVM2.

Connect to the KVM :

```
$ telnet localhost 15311
```
And run the configuration script
```
$ 0000-runall.sh
```
This wil automatically connect you to lxc1, you can log in with the following credentials. 

```
localhost login: root
Password: root
```
Bring the eth0 interface up :
```
[root@localhost ~]# ifup eth0
[root@localhost ~]# ifconfig |grep -A 1 eth0
eth0      Link encap:Ethernet  HWaddr 00:18:51:E5:35:03
          inet addr:10.0.0.202  Bcast:10.0.0.255  Mask:255.255.255.0
```

This also needs to be done on lxc2. You can now SSH to the KVM :

```
$ ssh 10.0.1.11
login : root
password : root
```

Open lxc2 :

```
[root@11-vnetdev ~]#  lxc-console -n lxc2
```

And bring the eth0 interface up

```
[root@localhost ~]# ifup eth0
[root@localhost ~]# ifconfig |grep -A 1 eth0
eth0      Link encap:Ethernet  HWaddr 00:18:51:E5:35:04
          inet addr:10.0.0.203  Bcast:10.0.0.255  Mask:255.255.255.0
```

The KVM is now fully up and running. lxc1 and lxc2 should be able to ping eachother.

```
[root@11-vnetdev ~]# ovs-vsctl show
88a97019-146c-43d6-838d-0343eccc58e9
    Bridge "br0"
        Controller "tcp:127.0.0.1:6633"
            is_connected: true
        fail_mode: standalone
        Port "br0"
            Interface "br0"
                type: internal
        Port "veth_kvm2lxc2"
            Interface "veth_kvm2lxc2"
        Port "eth0"
            Interface "eth0"
        Port "veth_kvm2lxc1"
            Interface "veth_kvm2lxc1"
    ovs_version: "2.3.1"
```

## Internet access on KVM

Please type "make ipmasq_on", if you want to touch internet on KVMs.

```
$ make ipmasq_on
sudo iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -L --line
Chain PREROUTING (policy ACCEPT)
num  target     prot opt source               destination

Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
num  target     prot opt source               destination
1    MASQUERADE  all  --  10.0.1.0/24          anywhere
```
