#!/bin/bash

# Check if run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (with sudo)."
    exit 1
fi

# Directory where .deb files are stored
DEB_DIR="../deb"

# Find the first .deb file in the /deb directory
DEB_FILE=$(find "$DEB_DIR" -type f -name "*.deb" | head -n 1)

# Check if a .deb file exists in the directory
if [ -z "$DEB_FILE" ]; then
    echo "Error: No .deb file found in the 'deb' directory."
    exit 1
fi

# Install the found DaVinci Resolve .deb file
echo "Installing DaVinci Resolve from file: $DEB_FILE"
sudo dpkg -i "$DEB_FILE"

# Fix missing dependencies (if any)
echo "Fixing missing dependencies..."
sudo apt --fix-broken install -y

# Function to check if NVIDIA or AMD is used
function check_gpu_vendor() {
    if lspci | grep -i "nvidia" > /dev/null 2>&1; then
        echo "NVIDIA"
    elif lspci | grep -i "amd" > /dev/null 2>&1; then
        echo "AMD"
    else
        echo "Unknown"
    fi
}

# Detect GPU vendor
GPU_VENDOR=$(check_gpu_vendor)

# If NVIDIA is detected
if [ "$GPU_VENDOR" = "NVIDIA" ]; then
    echo "NVIDIA GPU detected."

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

# If AMD is detected
elif [ "$GPU_VENDOR" = "AMD" ]; then
    echo "AMD GPU detected."

    # Check if ROCm is installed
    if dpkg-query -l | grep -q "rocm"; then
        echo "ROCm is already installed. Skipping ROCm installation."
    else
        # Install ROCm
        echo "Installing ROCm libraries..."
        sudo mkdir --parents --mode=0755 /etc/apt/keyrings
        wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
            gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.2 noble main" | \
            sudo tee --append /etc/apt/sources.list.d/rocm.list
        echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | sudo tee /etc/apt/preferences.d/rocm-pin-600
        sudo apt update
        sudo apt install -y rocm-libs6.2.0 rocm-opencl-sdk6.2.0 rocminfo6.2.0
    fi

    # Set up ROCm environment paths
    echo "Setting up ROCm environment paths..."
    if ! grep -q "export PATH=/opt/rocm/bin" ~/.bashrc; then
        echo 'export PATH=/opt/rocm/bin:$PATH' >> ~/.bashrc
        echo 'export LD_LIBRARY_PATH=/opt/rocm/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
        source ~/.bashrc
    fi
else
    echo "No supported GPU detected. Exiting..."
    exit 1
fi

# Create the launch command with LD_PRELOAD and LD_LIBRARY_PATH
if [ "$GPU_VENDOR" = "NVIDIA" ]; then
    LD_LIBRARY_PATH_VAR="/usr/lib/x86_64-linux-gnu"
else
    LD_LIBRARY_PATH_VAR="/opt/rocm/lib"
fi

LAUNCH_COMMAND="env LD_PRELOAD=/lib/x86_64-linux-gnu/libglib-2.0.so.0:/lib/x86_64-linux-gnu/libgio-2.0.so.0:/lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so.0:/lib/x86_64-linux-gnu/libgmodule-2.0.so.0 LD_LIBRARY_PATH=$LD_LIBRARY_PATH_VAR /opt/resolve/bin/resolve"

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

