# VMware Host Modules for Kernel 6.17+

VMware Workstation 17.6.4 kernel modules patched for Linux kernel 6.17+ compatibility.

## Compatibility

- **VMware Workstation**: 17.6.4
- **Kernel**: 6.17.x (tested on 6.17.0-5-generic)
- **Ubuntu**: 25.10 (Questing Quetzal)
- **Architecture**: x86_64

## Changes from Original VMware Modules

### vmmon Module Patches

1. **Timer API Update (Kernel 6.11+)**
   - `del_timer_sync()` → `timer_delete_sync()` in `linux/driver.c` and `linux/hostif.c`

2. **MSR API Update (Kernel 6.15+)**
   - `rdmsrl_safe()` → `rdmsrq_safe()` in `linux/hostif.c`

3. **Version Update**
   - `VMMON_VERSION` updated from 416 to 417 in `include/iocontrols.h`

4. **Build System**
   - Added `ccflags-y` to `Makefile.kernel` for modern kernel build compatibility

### vmnet Module Patches

1. **Network Lock Removal (Kernel 2.6.24+)**
   - `dev_base_lock` removed (replaced with no-op) in `vmnetInt.h`

2. **Build System**
   - Added `ccflags-y` to `Makefile.kernel`

## Installation

### Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y build-essential linux-headers-$(uname -r) git
```

### Build and Install

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/vmware-host-modules-kernel-6.17.git
cd vmware-host-modules-kernel-6.17

# Build modules
cd vmmon-only && make && cd ..
cd vmnet-only && make && cd ..

# Install modules
sudo mkdir -p /lib/modules/$(uname -r)/misc/
sudo install -m 644 vmmon-only/vmmon.ko /lib/modules/$(uname -r)/misc/
sudo install -m 644 vmnet-only/vmnet.ko /lib/modules/$(uname -r)/misc/

# Update module dependencies
sudo depmod -a

# Load modules
sudo modprobe vmmon
sudo modprobe vmnet

# Restart VMware services
sudo systemctl restart vmware
```

## Quick Install Script

A helper script is provided in `/usr/local/bin/rebuild-vmware-modules.sh` after installation.

## Known Issues

- **libxml2 warning**: VMware tools may show "no version information available" for libxml2. This is cosmetic and doesn't affect functionality.

## Testing

```bash
# Verify modules are loaded
lsmod | grep -E "vmmon|vmnet"

# Check module versions
modinfo vmmon | grep version
modinfo vmnet | grep version

# Test VMware
vmrun list
```

## Troubleshooting

### Version Mismatch Error

If you see "incorrect version of the vmmon kernel module", ensure `VMMON_VERSION` in `vmmon-only/include/iocontrols.h` matches your VMware version:

- VMware 17.6.x requires version **417**

### Module Won't Load

```bash
# Check kernel messages
sudo dmesg | tail -50

# Verify kernel version
uname -r

# Ensure headers are installed
ls /lib/modules/$(uname -r)/build
```

## Credits

Based on VMware Workstation 17.6.4 official modules with patches for modern kernel compatibility.

## License

These modules are distributed under the same license as VMware's original modules (GPL v2).

## Disclaimer

This is an unofficial patch. Use at your own risk. For production environments, consider using officially supported configurations.
