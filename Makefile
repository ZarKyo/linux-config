CHECKPOINT_DISABLE ?= 1
all: ubuntu

ubuntu:
	cd ubuntu && bash pre-install.sh

ubuntu-laptop:
	cd ubuntu && bash pre-install.sh --laptop

clean:
	echo "TODO"

dist-clean:
	make clean
