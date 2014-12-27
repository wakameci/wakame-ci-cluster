SHELL=/bin/bash

all: setup

setup:
	git submodule update --init --recursive
