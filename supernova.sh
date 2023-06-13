#!/bin/bash

#This script installs the dependencies for Monado and OpenXR (I hope)

# Update the package manager
sudo pacman -Syu

# Install required dependencies for Monado
sudo pacman -S cmake meson ninja git pkgconf libxrandr libxinerama libxcursor libxi libxinerama libxxf86vm libxss libxdamage libxfixes libxcomposite libxrender libglvnd libnotify libpulse libusb hidapi libdrm libinput libunwind

# Install required dependencies for OpenXR
sudo pacman -S vulkan-icd-loader

# Clone Monado repository
git clone https://gitlab.freedesktop.org/monado/monado.git

# Enter Monado directory
cd monado

# Build and install Monado
meson build
ninja -C build
sudo ninja -C build install

# Install OpenXR runtime
sudo ln -sf /usr/local/share/openxr/1.0.0/ /usr/share/openxr/loader/

echo "Dependencies installed and Monado, OpenXR installed successfully!"
