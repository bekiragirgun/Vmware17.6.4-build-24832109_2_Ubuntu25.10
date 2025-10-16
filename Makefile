#!/usr/bin/make -f

VM_UNAME = $(shell uname -r)

.PHONY: all clean install vmmon vmnet

all: vmmon vmnet

vmmon:
	@echo "Building vmmon module..."
	$(MAKE) -C vmmon-only

vmnet:
	@echo "Building vmnet module..."
	$(MAKE) -C vmnet-only

clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C vmmon-only clean
	$(MAKE) -C vmnet-only clean

install: all
	@echo "Installing modules for kernel $(VM_UNAME)..."
	sudo mkdir -p /lib/modules/$(VM_UNAME)/misc/
	sudo install -m 644 vmmon-only/vmmon.ko /lib/modules/$(VM_UNAME)/misc/
	sudo install -m 644 vmnet-only/vmnet.ko /lib/modules/$(VM_UNAME)/misc/
	sudo depmod -a
	@echo "Modules installed successfully!"
	@echo "Load with: sudo modprobe vmmon && sudo modprobe vmnet"

unload:
	@echo "Unloading VMware modules..."
	-sudo systemctl stop vmware
	-sudo rmmod vmnet vmmon
	@echo "Modules unloaded"

load:
	@echo "Loading VMware modules..."
	sudo modprobe vmmon
	sudo modprobe vmnet
	sudo systemctl restart vmware
	@echo "Modules loaded and VMware restarted"

reload: unload install load
