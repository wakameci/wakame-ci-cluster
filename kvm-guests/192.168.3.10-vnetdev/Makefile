ODGS  := $(wildcard draw/*.odg)
PNGS  := $(patsubst %.odg,%.png,${ODGS})
KVMNETWORK := 10.0.1.0/24

all:
	./init-bridges.sh
	./replace.sh
	(cd ../192.168.3.11-vnetdev/ && ./replace.sh)

ipmasq_on:i
	sudo iptables -t nat -A POSTROUTING -s ${KVMNETWORK} -o eth0 -j MASQUERADE
	sudo iptables -t nat -L --line

ipmasq_off:
	sudo iptables -t nat -D POSTROUTING -s ${KVMNETWORK} -o eth0 -j MASQUERADE
	sudo iptables -t nat -L --line

updatefig: ${PNGS}

%.png: %.odg
	unoconv -n -f png -o $@.tmp $< 2> /dev/null   || \
          unoconv -f png -o $@.tmp $<                 || \
	  unoconv -n -f png -o $@.tmp $< 2> /dev/null || \
          unoconv -f png -o $@.tmp $<
	convert -resize 800x $@.tmp $@
	rm -f $@.tmp

.PHONY: distclean
