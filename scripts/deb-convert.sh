#!/bin/bash

# Show the current working directory
echo "Current working directory: $(pwd)"

# Navigate to the /deb directory
cd ../deb || { echo "Deb directory not found"; exit 1; }

# Show the new working directory
echo "Changed to directory: $(pwd)"

# Automatically find the makeresolvedeb script
makeresolvedeb=$(find . -name 'makeresolvedeb*.sh' | head -n 1)

if [[ -z $makeresolvedeb ]]; then
  echo "MakeResolveDeb script not found!"
  exit 1
fi

# Automatically find the DaVinci Resolve or DaVinci Resolve Studio file
davinci_resolve=$(find . -name 'DaVinci_Resolve*_Linux.run' | head -n 1)

if [[ -z $davinci_resolve ]]; then
  echo "DaVinci Resolve installer not found!"
  exit 1
fi

# Extract just the file name of the DaVinci Resolve installer
davinci_resolve_basename=$(basename "$davinci_resolve")

# Debugging information
echo "Makeresolvedeb script found at: $makeresolvedeb"
echo "DaVinci Resolve installer found at: $davinci_resolve"
echo "DaVinci Resolve installer basename: $davinci_resolve_basename"

# Check if necessary dependencies are installed
dependencies=(fakeroot xorriso)

for dep in "${dependencies[@]}"; do
  if ! dpkg -l | grep -q "$dep"; then
    echo "Installing missing dependency: $dep"
    sudo apt-get install -y "$dep" || { echo "Failed to install $dep. Exiting."; exit 1; }
  fi
done

# Make the makeresolvedeb script executable
echo "Making the MakeResolveDeb script executable..."
chmod +x "$makeresolvedeb"

# Create DaVinci Resolve .deb file (no sudo)
echo "Running: $makeresolvedeb $davinci_resolve_basename"
if ! "$makeresolvedeb" "$davinci_resolve_basename"; then
  echo "Failed to execute $makeresolvedeb. Trying with sudo (can fix issues sometimes)"
  
  # Trying executing makeresolvedeb as sudo (if needed)
  echo "Running: sudo $makeresolvedeb $davinci_resolve_basename"
  sudo "$makeresolvedeb" "$davinci_resolve_basename" || { echo "Failed to execute $makeresolvedeb. Exiting."; exit 1; }
else
  echo "Conversion completed successfully."
fi

