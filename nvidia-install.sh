#!/bin/bash

# Check if run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (with sudo)."
    exit 1
fi

# Set the path to the .deb file
DEB_FILE="./deb/davinci-resolve_19.0.1-mrd1.7.2_amd64.deb"

# Check if the .deb file exists
if [ ! -f "$DEB_FILE" ]; then
    echo "Error: DaVinci Resolve .deb file not found in the 'deb' subfolder."
    exit 1
fi

# Install DaVinci Resolve .deb file
echo "Installing DaVinci Resolve..."
sudo dpkg -i "$DEB_FILE"

# Fix missing dependencies (if any)
echo "Fixing missing dependencies..."
sudo apt --fix-broken install -y

# Check if NVIDIA driver is installed
echo "Checking for installed NVIDIA drivers..."
if nvidia-smi > /dev/null 2>&1; then
    echo "NVIDIA driver is already installed. Skipping driver installation."
else
    # If NVIDIA driver is not installed, install it
    echo "NVIDIA driver not found. Installing NVIDIA drivers..."
    sudo ubuntu-drivers autoinstall
fi

# Install CUDA Toolkit if not already installed
if ! dpkg-query -l | grep -q "nvidia-cuda-toolkit"; then
    echo "Installing NVIDIA CUDA Toolkit..."
    sudo apt update
    sudo apt install -y nvidia-cuda-toolkit
else
    echo "NVIDIA CUDA Toolkit is already installed."
fi

# Set up CUDA environment paths
echo "Setting up CUDA environment paths..."
if ! grep -q "export PATH=/usr/local/cuda/bin" ~/.bashrc; then
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    source ~/.bashrc
fi

# Create the launch command with LD_PRELOAD and LD_LIBRARY_PATH
LAUNCH_COMMAND="env LD_PRELOAD=/lib/x86_64-linux-gnu/libglib-2.0.so.0:/lib/x86_64-linux-gnu/libgio-2.0.so.0:/lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so.0:/lib/x86_64-linux-gnu/libgmodule-2.0.so.0 LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu /opt/resolve/bin/resolve"

# Modify DaVinci Resolve menu entry
echo "Modifying DaVinci Resolve menu entry..."
MENU_ENTRY_PATH="/usr/share/applications/com.blackmagicdesign.resolve.desktop"

if [ -f "$MENU_ENTRY_PATH" ]; then
    sudo sed -i "s|Exec=.*|Exec=$LAUNCH_COMMAND|" "$MENU_ENTRY_PATH"
    echo "Menu entry updated."
else
    echo "Warning: DaVinci Resolve menu entry not found, skipping this step."
fi

# Reboot prompt
echo "Installation completed. It's recommended to reboot the system."
read -p "Do you want to reboot now? (y/n): " choice
if [ "$choice" = "y" ]; then
    sudo reboot
else
    echo "Please reboot the system manually to apply changes."
fi

