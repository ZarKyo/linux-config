CHECKPOINT_DISABLE ?= 1
all: ubuntu

ubuntu:
	cd ubuntu && bash pre-install.sh

clean:
	echo "TODO"

dist-clean:
	make clean
