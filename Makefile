CHECKPOINT_DISABLE ?= 1

.PHONY: all ubuntu ubuntu-laptop ubuntu-vm ubuntu-vm-laptop clean dist-clean

all: ubuntu

ubuntu:
	cd ubuntu/ && bash pre-install.sh

ubuntu-laptop:
	cd ubuntu/ && bash pre-install.sh --laptop

ubuntu-vm:
	cd ubuntu/ && bash pre-install.sh --vm

clean:
	echo "TODO"

dist-clean:
	make clean
