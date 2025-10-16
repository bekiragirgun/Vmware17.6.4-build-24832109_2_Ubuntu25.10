# VMware Host Modules for Kernel 6.17+

VMware Workstation 17.6.4 kernel modules patched for Linux kernel 6.17+ compatibility.

## Compatibility

- **VMware Workstation**: 17.6.4 build-24832109
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

## Quick Install

```bash
git clone https://github.com/bekiragirgun/Vmware17.6.4-build-24832109_2_Ubuntu25.10.git
cd Vmware17.6.4-build-24832109_2_Ubuntu25.10
sudo make install
```

## Manual Installation

### Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y build-essential linux-headers-$(uname -r) git
```

### Build and Install

```bash
# Build modules
make

# Install modules
sudo make install

# Load modules
sudo modprobe vmmon
sudo modprobe vmnet

# Restart VMware services
sudo systemctl restart vmware
```

## Rebuild Script

For kernel updates, use the provided script:

```bash
./rebuild-vmware-modules.sh
```

Or use the Makefile:

```bash
sudo make reload
```

## Available Make Targets

- `make` or `make all` - Build both modules
- `make vmmon` - Build only vmmon
- `make vmnet` - Build only vmnet
- `make clean` - Clean build artifacts
- `make install` - Build and install modules
- `make load` - Load modules and restart VMware
- `make unload` - Unload modules and stop VMware
- `make reload` - Unload, rebuild, install, and load

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

### Build Errors

If you encounter build errors:

1. Ensure you have the correct kernel headers:
   ```bash
   sudo apt-get install linux-headers-$(uname -r)
   ```

2. Clean and rebuild:
   ```bash
   make clean
   make
   ```

## File Structure

```
.
├── vmmon-only/          # VMware monitor module
│   ├── include/         # Header files
│   ├── linux/          # Linux-specific code
│   ├── common/         # Common code
│   └── bootstrap/      # Bootstrap code
├── vmnet-only/         # VMware network module
├── Makefile            # Build system
├── rebuild-vmware-modules.sh  # Rebuild script
└── README.md           # This file
```

## Credits

Based on VMware Workstation 17.6.4 official modules with patches for modern kernel compatibility.

Patches developed using Claude Code: https://claude.com/claude-code

## License

These modules are distributed under the same license as VMware's original modules (GPL v2).

## Disclaimer

This is an unofficial patch. Use at your own risk. For production environments, consider using officially supported configurations.

## Contributing

Feel free to open issues or submit pull requests for improvements or fixes.

## Author

Bekir Agirgun (@bekiragirgun)

Generated with assistance from Claude Code
