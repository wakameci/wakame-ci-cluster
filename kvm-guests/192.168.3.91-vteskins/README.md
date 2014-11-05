# Development test environment for OpenVNet

## Network Structure

xxx T.B.D. xxx

## Build

Simply, type "make".

```
$ git clone https://github.com/wakameci/wakame-ci-cluster.git
$ cd wakame-ci-cluster/kvm-guests/192.168.3.91-vteskins/
$ make
$ ps aux|grep qemu-|grep root
```

## Usage

First, type "make ipmasq_on" to touch internet on KVMs.

```
$ make ipmasq_on
sudo iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -j MASQUERADE
sudo iptables -t nat -L --line
Chain PREROUTING (policy ACCEPT)
num  target     prot opt source               destination

Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
num  target     prot opt source               destination
1    RETURN     all  --  192.168.122.0/24     base-address.mcast.net/24
2    RETURN     all  --  192.168.122.0/24     255.255.255.255
3    MASQUERADE  tcp  --  192.168.122.0/24    !192.168.122.0/24     masq ports: 1024-65535
4    MASQUERADE  udp  --  192.168.122.0/24    !192.168.122.0/24     masq ports: 1024-65535
5    MASQUERADE  all  --  192.168.122.0/24    !192.168.122.0/24
6    MASQUERADE  all  --  10.0.1.0/24          anywhere
```


Second, run following command on a console.

```
$ telnet localhost 15091
itest1 login: kemukins
Password: kemukins
[kemukins@itest1 ~]$ git clone https://github.com/axsh/openvnet-testspec.git
[kemukins@itest1 openvnet-testspec]$ bundle install --without=development
[kemukins@itest1 openvnet-testspec]$ ./bin/dev-spec
```
