# DaVinci Resolve Installer for Debian-based Linux (Ubuntu/Mint)
**This was originally designed in Linux Mint 22.** *If you run into issues on other distributions, let me know!*

## What does ResolveDeb1Click do?
- Extracts .zip/.tar.gz files for Resolve & MakeResolveDeb
- Converts the .run installation into a .deb file (using MakeResolveDeb)
- Installs all necessary dependencies
- Installs ROCm/CUDA toolkits
- Adds custom menu entry

TLDR: ResolveDeb1Click takes the pain of installing DaVinci Resolve on modern Debian-based Linux operating systems, and **makes a simple 1-click procees**

## Current Version - v0.1.1
Released October 3, 2024

[Patch Notes](https://github.com/CBF2006/ResolveDeb1Click/releases/tag/v0.1.1)

## Installation
1. [Download DaVinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve) (.zip)
   * *DaVinci Resolve or DaVinci Resolve Studio works*

2. [Download MakeResolveDeb](https://www.danieltufvesson.com/makeresolvedeb)

3. [Download the latest release of ResolveDeb1Click](https://github.com/CBF2006/ResolveDeb1Click/releases) (.zip)

4. Extract the ResolveDeb1Click-0.1.1.zip

![image](https://github.com/user-attachments/assets/38996127-f762-4d70-98fa-459a53da9dd4)


## 5. Place the "MakeResolveDeb" & "DaVinci_Resolve" .zip/.tar.gz files inside the /deb folder

### 6. Make "install.sh" Executable
![image](https://github.com/user-attachments/assets/2f25f0c2-5442-478c-9796-b822be77a9c7)

![image](https://github.com/user-attachments/assets/712fca90-d810-4120-b8ad-c084898496fc)


or **Terminal** `chmod +x ./ResolveDeb1Click-v1.0/install.sh`
* *(For new Linux users)* **please use `cd "directory here"` to navigate to the right directory**
  * ex. `cd Downloads` **the Terminal is case-sensitive**

### 7. Run "install.sh"
- If prompted, click "Run in Terminal"

You should be all set!

### If it does NOT run:
This was built in Linux Mint so bugs are possible with other Debian distros

1. Open Terminal
2. `cd "folder directory here"`
3. `./install.sh`

## How to Uninstall

### "Navigate to ./uninstall/uninstall.sh"
1. Make it executable (see above)
2. Run "uninstall.sh"

## Supported Systems
 - amd64-based systems
 - **AMD & NVIDIA GPUs**
