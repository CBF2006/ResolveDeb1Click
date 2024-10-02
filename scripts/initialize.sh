#!/bin/bash

# Automatically find the DaVinci Resolve ZIP file
resolve_zip=$(find ../deb -name 'DaVinci_Resolve*.zip' | head -n 1)

if [[ -n $resolve_zip ]]; then
  if [ ! -d "${resolve_zip%.zip}" ]; then
    echo "Unzipping DaVinci Resolve ZIP file..."
    unzip "$resolve_zip" -d ../deb
  else
    echo "DaVinci Resolve is already unzipped. Skipping..."
  fi
else
  echo "DaVinci Resolve ZIP file not found!"
  exit 1
fi

# Automatically find the MakeResolveDeb tarball file in the ../deb directory
makeresolvedeb_tar=$(find ../deb -name 'makeresolvedeb*.tar.gz' | head -n 1)

if [[ -n $makeresolvedeb_tar ]]; then
  if [ ! -f "${makeresolvedeb_tar%.tar.gz}.sh" ]; then
    echo "Extracting MakeResolveDeb tar.gz file..."
    tar zxvf "$makeresolvedeb_tar" -C ../deb
  else
    echo "MakeResolveDeb script is already extracted. Skipping..."
  fi
else
  echo "MakeResolveDeb tar.gz file not found!"
  exit 1
fi

# Check if a .deb DaVinci Resolve file is present in the ../deb directory
deb_file=$(find ../deb -name 'davinci-resolve*.deb' | head -n 1)

if [[ -n $deb_file ]]; then
  echo "DaVinci Resolve .deb file found: $deb_file"
  echo "Skipping conversion step..."
else
  # Enabling execution of necessary scripts
  chmod +x deb-convert.sh install-root.sh

  # Converting Resolve .run file into .deb
  echo "Converting DaVinci Resolve .run file into .deb..."
  sudo ./deb-convert.sh || { echo "Failed to run deb-convert.sh"; exit 1; }
fi

# Proceed with the installation using the .deb file
echo "Running install-root.sh to complete the installation..."
cd ../scripts || { echo "Scripts directory not found"; exit 1; }
sudo ./install-root.sh || { echo "Failed to run install-root.sh"; exit 1; }

