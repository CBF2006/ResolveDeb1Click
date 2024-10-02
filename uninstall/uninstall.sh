#!/bin/bash

sudo apt-get remove davinci-resolve

echo "Removing Dependencies"
sudo apt autoremove

echo "DaVinci Resolve Uninstalled"

exit

