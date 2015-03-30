Boxes
=====

Boxes are the package format for Wakame CI environments. A box can be used by anyone on KVM host.

## Downloading boxes

Download all box files.

```
$ ./download-boxes.sh
```

Download the box file.

```
$ ./download-boxes.sh [box-name]
$ ./download-boxes.sh [box-name] [box-name] [box-name] ...
```

## Discovering boxes

The available catalog of boxes is defined with `boxes` in [download-boxes.sh](download-boxes.sh).

```
boxes="
    kemumaki-6.x-x86_64.kvm.box
     minimal-6.x-x86_64.kvm.box
   kagechiyo-6.x-x86_64.kvm.box
     ...
"
```

## Links

+ [kemumaki-box-rhel6](https://github.com/wakameci/kemumaki-box-rhel6)
+ [kemumaki-box-rhel7](https://github.com/wakameci/kemumaki-box-rhel7)
