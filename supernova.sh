#!/bin/bash

# Update system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --noconfirm base-devel libglvnd freetype2 cmake curl fontconfig glfw-wayland glslang libjpeg libusb meson ninja nlohmann-json opencv pkgconf python-pip python-pipx python3 seatd vulkan-headers wget xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xf86-video-amdgpu mesa

# Install yay package manager
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Install using yay
yay -S --noconfirm --mflags --skipinteg --nocheck alacritty cmake doxygen libjpeg monado-git openhmd openxr-loader-git python systemd-devel

# Install using pip
pip install libclang ffmpeg

# Build and install flatbuffers v2.0.8 manually
git clone --branch v2.0.8 https://github.com/google/flatbuffers.git
cd flatbuffers
sed -i 's/#include <string>/#include <string>\n#include <cstdint>/' tests/reflection_test.h
mkdir build
cd build
cmake ..
make
sudo make install
cd ../..
rm -rf flatbuffers

# Clone the Monado repository
git clone https://gitlab.freedesktop.org/monado/monado.git
cmake -G Ninja -S monado -B build -DCMAKE_INSTALL_PREFIX=/usr
ninja -C build install
rm -rf monado

# Set the CUDAToolkit_ROOT environment variable
echo 'export CUDAToolkit_ROOT=/usr/local/cuda' >> "$HOME/.bashrc"

# Install OpenXR-SDK
git clone https://github.com/KhronosGroup/OpenXR-SDK.git
cd OpenXR-SDK
cmake . -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -B build
sudo ninja -C build install
cd ..
rm -rf OpenXR-SDK

# Delete the WiVRn folder if it exists
if [ -d "WiVRn" ]; then
    rm -rf WiVRn
fi

# Clone the WiVRn repository
git clone https://github.com/Meumeu/WiVRn.git
cd WiVRn

# Build and set up WiVRn
cmake -B build-server . -GNinja -DWIVRN_BUILD_CLIENT=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build-server

# Set WiVRn as the active OpenXR runtime
mkdir -p ~/.config/openxr/1/
ln -s -f $(realpath build-server/openxr_wivrn-dev.json) ~/.config/openxr/1/active_runtime.json
cd ..
rm -rf WiVRn

# Clone the telescope repository
git clone https://github.com/StardustXR/telescope.git
cd telescope

# Take ownership of .sh scripts
sudo chown -R $USER:$USER *.sh

# Execute setup.sh
./setup.sh

# Execute hmd-setup.sh
./hmd-setup.sh

# Change into the server folder
cd repos/server

# Build and install the server
cargo build
cargo install --path .

# Return to the telescope folder
cd ../..

# Change into the flatland folder
cd flatland

# Install flatland
cargo install flatland

# Append the export statement to the .bashrc file
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"

# Reload the .bashrc file in the current terminal session
source "$HOME/.bashrc"

# Display a message indicating completion
echo "The PATH environment variable has been updated."
echo "Installation and setup completed successfully."
