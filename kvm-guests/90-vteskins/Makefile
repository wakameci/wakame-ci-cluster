export PATH := /bin:/sbin:/usr/bin:/usr/sbin

all:
	./init-bridges.sh
	build_layer2 build_layer1

build_layer2:
	for i in 1 2 3 4 5 6 ; do \
	  (cd ../10$$i-vneskins/ && ./build.sh && ./pack-box.sh) \
	done

build_layer1:
	for i in 0 1 2 3 4 5 ; do \
	  (cd ../9$$i-vteskins/ && ./replace.sh) \
	done

stop:
	for i in 0 1 2 3 4 5 ; do \
	  (cd ../9$$i-vteskins/ && sudo ./stop.sh) \
	done

run:
	for i in 0 1 2 3 4 5 ; do \
	  (cd ../9$$i-vteskins/ && sudo ./run.sh) \
	done
