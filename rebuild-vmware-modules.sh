#!/bin/bash
# VMware kernel modules rebuild script for kernel 6.17+

set -e

KERNEL_VERSION=$(uname -r)
echo "Building VMware modules for kernel $KERNEL_VERSION"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build vmmon
echo "Building vmmon..."
cd vmmon-only
make clean
make
cd ..

# Build vmnet
echo "Building vmnet..."
cd vmnet-only
make clean
make
cd ..

# Install modules
echo "Installing modules..."
sudo mkdir -p /lib/modules/$KERNEL_VERSION/misc/
sudo install -m 644 vmmon-only/vmmon.ko /lib/modules/$KERNEL_VERSION/misc/
sudo install -m 644 vmnet-only/vmnet.ko /lib/modules/$KERNEL_VERSION/misc/

# Update module database
echo "Updating module dependencies..."
sudo depmod -a

# Restart VMware
echo "Restarting VMware services..."
sudo systemctl restart vmware 2>/dev/null || echo "VMware service not running"

echo ""
echo "✅ VMware modules rebuilt and installed successfully for kernel $KERNEL_VERSION!"
echo ""
echo "Modules installed:"
modinfo vmmon 2>/dev/null | grep -E "filename|version|vermagic" || echo "vmmon info not available"
echo ""
modinfo vmnet 2>/dev/null | grep -E "filename|version|vermagic" || echo "vmnet info not available"
