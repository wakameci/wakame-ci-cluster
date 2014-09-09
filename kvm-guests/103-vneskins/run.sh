#!/bin/sh -e
#execute kvm command
#
node_id=3
name=vm${node_id}

brname_virt=br0
ifname_virt=if-v${node_id}
mac_virt=02:00:00:00:00:0${node_id}

brname_mng=br1
ifname_mng=if-m${node_id}
mac_mng=02:00:01:00:00:0${node_id}

cpu_type=host
brname=br0
#mem_size=512
#mem_size=256
mem_size=128
cpu_num=1
vnc_addr=127.0.0.1
vnc_port=$((2000 + ${node_id}))
monitor_addr=127.0.0.1
monitor_port=$((4000 + ${node_id}))
serial_addr=127.0.0.1
serial_port=$((5000 + ${node_id}))
drive_type=virtio
nic_driver=virtio-net-pci
rtc="base=utc"
raw_file=./box-disk1.raw
pidfile=./${name}.pid
#
/usr/libexec/qemu-kvm -name ${name} -cpu ${cpu_type} -m ${mem_size} -smp ${cpu_num} -vnc ${vnc_addr}:${vnc_port} -k en-us -rtc ${rtc} -monitor telnet:127.0.0.1:${monitor_port},server,nowait -serial telnet:${serial_addr}:${serial_port},server,nowait -drive file=${raw_file},media=disk,boot=on,index=0,cache=none,if=${drive_type} \
-netdev tap,ifname=${ifname_virt},id=hostnet0,script=,downscript= -device ${nic_driver},netdev=hostnet0,mac=${mac_virt},bus=pci.0,addr=0x3 \
-netdev tap,ifname=${ifname_mng},id=hostnet2,script=,downscript= -device ${nic_driver},netdev=hostnet2,mac=${mac_mng},bus=pci.0,addr=0x5 \
-pidfile ${pidfile} -daemonize
# virt
ip link set ${ifname_virt} up
ovs-vsctl --if-exists del-port ${brname_virt} ${ifname_virt}
ovs-vsctl add-port ${brname_virt} ${ifname_virt}
# mng
ip link set ${ifname_mng} up
ovs-vsctl --if-exists del-port ${brname_mng} ${ifname_mng}
ovs-vsctl add-port ${brname_mng} ${ifname_mng}
