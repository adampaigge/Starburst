#!/bin/bash

# Update system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --noconfirm cargo python-pipx ninja libxkbcommon-x11 avahi libxcb glslang ffmpeg libjpeg base-devel meson cmake pkgconf glfw-wayland libx11 libxcursor libxrandr libxi libxinerama wayland wayland-protocols wget curl fontconfig openxr seatd cargo glibc mesa nvidia libxext libglvnd xf86-video-amdgpu python3 python-pip android-tools vulkan-headers eigen nlohmann-json glslang libusb libv4l libxcb xcb-util-image xcb-util-wm xcb-util-keysyms xcb-util-renderutil opencv ffmpeg libjpeg bluez clang cuda

# Install yay package manager
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Install using yay
yay -S  --noconfirm --mflags --skipinteg --nocheck alacritty openxr-loader-git cmake libjpeg monado-git OpenHMD OpenCV Doxygen systemd-devel python python3 python-pip

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
cd ..
cd ..
rm -r -f flatbuffers

# Clone the Monado repository
git clone https://gitlab.freedesktop.org/monado/monado.git
cmake -G Ninja -S monado -B build -DCMAKE_INSTALL_PREFIX=/usr
ninja -C build install
rm -r -f monado

# Set the CUDAToolkit_ROOT environment variable
echo 'export CUDAToolkit_ROOT=/usr/local/cuda' >> "$HOME/.bashrc"

# Install OpenXR-SDK
git clone https://github.com/KhronosGroup/OpenXR-SDK.git
cd OpenXR-SDK
cmake . -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -Bbuild
sudo ninja -C build install
cd .. 
rm -r -f OpenXR-SDK


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
ln --relative --symbolic --force build-server/openxr_wivrn-dev.json ~/.config/openxr/1/active_runtime.json
cd ..
rm -r -f WiVRn

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
cd repos
cd server

# Build and install the server
cargo build
cargo install --path .


# Return to the telescope folder
cd ..

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
