LXC Hosts
=========

Setup scripts for LXC host / LXC host for Nested KVM.

## Getting Started

### Add a new lxc container

```
$ sudo ./bootstrap-<distro_name>-<distro_ver>.sh [CTID]
```

### Container Operations

#### List container(s).

```
$ sudo lxc-ls
```

#### Show the container info.

```
$ sudo lxc-info -n [CTID]
```

#### Stop the container.

```
$ sudo lxc-stop -n [CTID]
```

#### Start the container

Don't use `lxc-start -n [CTID]`. Because `lxc-start` won't setup proper device files for kvm host.

```
$ sudo ./lxc-start.sh [CTID]
```

## Usage

### `bootstrap-<distro_ver>-<distro_name>.sh`

```
$ sudo ./bootstrap-centos-6.sh  [CTID]
$ sudo ./bootstrap-centos-7.sh  [CTID]
$ sudo ./bootstrap-fedora-20.sh [CTID]
$ sudo ./bootstrap-fedora-21.sh [CTID]
$ sudo ./bootstrap-fedora-22.sh [CTID]
```

### lxc helpers

```
$ sudo ./lxc-ls.sh
$ sudo ./lxc-device.sh [CTID]
$ sudo ./lxc-start.sh  [CTID]
```

### Setup a bridge/ether pair for KVM on LXC environment

```
$ sudo ./setup-kol-pair.sh <base_if> <bridge_if>
$ sudo ./setup-kol-pair.sh em1       kemumakikol0
```

### Add a user in the container

```
$ sudo ./adduser-in-lxc.sh [CTID] [GitHub-user]
```
