#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
    if [[ "$distro" == "arch" ]]; then
       echo "Arch Linux Detected"
       sudo pacman -S --needed brotli figlet simg-tools
       #aur=rar
    else
       sudo apt install figlet img2simg brotli 
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install brotli img2simg figlet 
fi
