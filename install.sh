#!/bin/bash

echo "ResolveDeb1Click v0.1.1"

# Navigate to the script's directory
cd "$(dirname "$0")" || { echo "Failed to change directory"; exit 1; }
cd ./scripts || { echo "Scripts directory not found"; exit 1; }

# Run Initialization
chmod +x initialize.sh
./initialize.sh

# Wait for user input before closing
echo "Installation completed. Press any key to continue..."
read -n 1

