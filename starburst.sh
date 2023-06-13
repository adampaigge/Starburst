#!/bin/bash

# Install essential packages
sudo pacman -Syu --needed a52dec adobe-source-sans-pro-fonts android-tools aspell-enbase-devel avahi base-devel bluez ca-certificates cjson clang cmake config cuda curl doxygen ecryptfs-utils eigen enchant exfat-utils faac faad2 ffmpeg flac font freetype2 fuse-exfat git glfw-wayland glibc glslang glslang-tools gst-libav gst-plugins-good gstreamer hidapi hunspell-en_US icedtea-web jasper jdk jre8-open lame languagetool libbsd libdca libdv libdvdcss libdvdnav libdvdread libegl libeigen3 libglvnd libjpeg libmad libmpeg2 libmythes libopenxr-dev libopenxr-loader1 libopenxr-utils libopenxr1-monado libtheora libudev libusb libuvc libv41 libv4l libvorbis libvulkan libx11 libx11-xcb libxcb libxcursor libxext libxi libxinerama libxkbcommon-x11 libxrandr libxtst libxv libxxf86vm linux-firmware lsof mesa meson monado-cli monado-gui mythes-en ninja nlohmann-json nvidia opencv openssh openssl openxr openxr-layer-apidump openxr-layer-corevalidationpatch patch pkg-config pkgconf pkgstats python python-pip python-pipx python3 rsync sdl2 seatd systemd ttf-anonymous-pro ttf-bitstream-vera ttf-dejavu ttf-droid ttf-gentium ttf-liberation ttf-ubuntu-font-family ufw unzip v4l-utils vulkan-devel vulkan-headers vulkan-loader vulkan-tools wavpack wayland wayland-protocols wget x264 xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xcb-util-xrm xf86-video-amdgpu xr-hardware xvidcore

# Install Rust
curl https://sh.rustup.rs -sSf | sh 
source "$HOME/.cargo/env"

# Install yay package manager
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
cd ..
sudo rm -rf yay-git

# Install using yay
yay -S --needed alacritty python2 python2-setuptools openxr-loader-git cmake libjpeg monado monado-git openhmd-git OpenCV Doxygen systemd-devel python OpenXR python3 python-pip libuvc ninja

# Install using pip
python -m venv myenv
source myenv/bin/activate
sudo pip install libclang ffmpeg 
deactivate

# Run Supernova (Monado and OpenXR check)

# Build and install flatbuffers v2.0.8 manually
sudo git clone --branch v2.0.8 https://github.com/google/flatbuffers.git
cd flatbuffers
sudo 
sed -i 's/#include <string>/#include <string>\n#include <cstdint>/' tests/reflection_test.h
sudo mkdir build
cd build
sudo cmake ..
sudo make
sudo make install
cd ../..
sudo rm -r -f flatbuffers

# Set the CUDAToolkit_ROOT environment variable
echo 'export CUDAToolkit_ROOT=/usr/local/cuda' >> "$HOME/.bashrc"

# Install OpenXR-SDK
git clone https://github.com/KhronosGroup/OpenXR-SDK.git
cd OpenXR-SDK
sudo cmake . -G -DCMAKE_INSTALL_PREFIX=/usr -Bbuild
sudo ninja -C build install
cd ..

# Install Monado
sh
sudo git clone https://gitlab.freedesktop.org/monado/monado.git
cd monado
sudo meson build
sudo ninja -C build install -j24
cd ..

# Install WiVRn
sudo git clone https://github.com/Meumeu/WiVRn.git
cd WiVRn
sudo cmake -B build-server . -GNinja -DWIVRN_BUILD_CLIENT=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
sudo cmake --build build-server
sudo mkdir -p ~/.config/openxr/1/
sudo ln --relative --symbolic --force build-server/openxr_wivrn-dev.json ~/.config/openxr/1/active_runtime.json
cd ..
sudo rm -r -f WiVRn

# Setup Stardust
sudo git clone https://github.com/StardustXR/telescope.git
cd telescope

sudo chown -R $USER:$USER *.sh

sudo ./setup.sh
sudo ./hmd-setup.sh
cd repos/server
sudo cargo build
sudo cargo install --path .
sudo cargo install flatland magnetar comet

# Append the export statement to the .bashrc file
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"

# Reload the .bashrc file in the current terminal session
source "$HOME/.bashrc"

# Display a message indicating completion
echo "The PATH environment variable has been updated."

echo "Installation and setup completed successfully."
