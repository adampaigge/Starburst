#!/bin/bash

# Update system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --needed $(echo "a52dec adobe-source-sans-pro-fonts aspell-enbase-devel cmake curl ecryptfs-utils enchant exfat-utils faac faad2 flac fontconfig freetype2 fuse-exfat glfw-wayland glslang gst-libav gst-plugins-good gstreamer hunspell-en_US icedtea-web jasper jre8-openjdk lame languagetool libdca libdv libdvdcss libdvdnav libdvdread libglvnd libmad libmpeg2 libmythes libtheora libusb libvorbis libxv linux-firmware lsof mesa meson mythes-en ninja nlohmann-json opencv openssh openssl pkgconf pkgstats python python-pip python-pipx rsync seatd ttf-anonymous-prottf-bitstream-vera ttf-dejavu ttf-droid ttf-gentium ttf-liberation ttf-ubuntu-font-family ufw vulkan-headers wavpack wget x264 xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xf86-video-amdgpu xvidcore" | awk '!seen[$0]++')

#Install Cargo
curl https://sh.rustup.rs -sSf | sh

# Install yay package manager
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
cd ..
sudo rm -rf yay-git

# Install using yay
yay -S --needed alacritty openxr-loader-git cmake libjpeg monado-git OpenHMD OpenCV Doxygen systemd-devel python python3 python-pip

# Install using pip
sudo pip install libclang ffmpeg 

# Build and install flatbuffers v2.0.8 manually
sudo git clone --branch v2.0.8 https://github.com/google/flatbuffers.git
cd flatbuffers
sed -i 's/#include <string>/#include <string>\n#include <cstdint>/' tests/reflection_test.h
mkdir build
cd build
cmake ..
make
sudo make install
cd ..
cd ..
sudo rm -r -f flatbuffers

# Clone the Monado repository
sudo git clone https://gitlab.freedesktop.org/monado/monado.git
cmake -G Ninja -S monado -B build -DCMAKE_INSTALL_PREFIX=/usr
ninja -C build install
sudo rm -r -f monado

# Set the CUDAToolkit_ROOT environment variable
echo 'export CUDAToolkit_ROOT=/usr/local/cuda' >> "$HOME/.bashrc"

# Install OpenXR-SDK
sudo git clone https://github.com/KhronosGroup/OpenXR-SDK.git
cd OpenXR-SDK
cmake . -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -Bbuild
sudo ninja -C build install
cd .. 
sudo rm -r -f OpenXR-SDK

# Clone the WiVRn repository
sudo git clone https://github.com/Meumeu/WiVRn.git
cd WiVRn

# Build and set up WiVRn
cmake -B build-server . -GNinja -DWIVRN_BUILD_CLIENT=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build-server

# Set WiVRn as the active OpenXR runtime
mkdir -p ~/.config/openxr/1/
ln --relative --symbolic --force build-server/openxr_wivrn-dev.json ~/.config/openxr/1/active_runtime.json
cd ..
sudo rm -r -f WiVRn

# Clone the telescope repository
sudo git clone https://github.com/StardustXR/telescope.git
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
