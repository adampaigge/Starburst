#!/bin/bash
#automatically shuts the script down when you encounter an error
set -e

# Update System and Install essential packages
sudo pacman -Syu --needed dkms linux-headers a52dec adobe-source-sans-pro-fonts android-tools avahi base-devel bluez ca-certificates cjson clang cmake cuda curl ecryptfs-utils eigen enchant exfat-utils faac faad2 ffmpeg flac freetype2 fuse-exfat git glibc glslang gst-libav gst-plugins-good gstreamer hidapi hunspell-en_US icedtea-web jasper lame languagetool libbsd libdca libdv libdvdcss libdvdnav libdvdread libegl libglvnd libjpeg libmad libmpeg2 libmythes libtheora libusb libvorbis libx11 libxcb libxcursor libxext libxi libxinerama libxkbcommon-x11 libxrandr libxtst libxv libxxf86vm linux-firmware lsof mesa mythes-en ninja nlohmann-json nvidia opencv openssh openssl openxr patch pkg-config pkgconf pkgstats python python-pip python-pipx python3 rsync sdl2 seatd systemd ttf-anonymous-pro ttf-bitstream-vera ttf-dejavu ttf-droid  ttf-liberation ttf-ubuntu-font-family ufw unzip v4l-utils vulkan-devel vulkan-headers vulkan-tools wavpack wayland wayland-protocols wget x264 xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xcb-util-xrm xf86-video-amdgpu xvidcore
# glfw-wayland

# Install Rust
curl https://sh.rustup.rs -sSf | sh 
source "$HOME/.cargo/env"
rustup default stable 

# Install yay package manager
git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
cd ..
sudo rm -rf yay-git

# Install packages using yay
yay -S --noconfirm --needed python2 python2-setuptools doxygen-clang cmake libjpeg openhmd-git systemd-devel python python3 python-pip libuvc ninja openxr-loader-git monado-git
# openxr-loader-git OpenXR

# Install using pip
python -m venv myenv
source myenv/bin/activate
pip install libclang ffmpeg 
deactivate
sudo rm -r -f myenv

# Build and install flatbuffers v2.0.8 manually
git clone --branch v2.0.8 https://github.com/google/flatbuffers.git
cd flatbuffers
sudo sed -i 's/#include <string>/#include <string>\n#include <cstdint>/' tests/reflection_test.h
sudo mkdir build
cd build
sudo cmake ..
sudo make
sudo make install
cd ../..
sudo rm -r -f flatbuffers

# Set the CUDAToolkit_ROOT environment variable
export CUDAToolkit_ROOT=/usr/local/cuda

# Install OpenXR-SDK
git clone https://github.com/KhronosGroup/OpenXR-SDK.git
sudo chown -R $USER:$USER ./OpenXR-SDK
cd OpenXR-SDK
sudo cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -Bbuild
sudo ninja -C build install
cd ..

# Install Monado
# git clone https://gitlab.freedesktop.org/monado/monado.git
# sudo mkdir build
# cd build
# cmake .. -DCMAKE_BUILD_TYPE=Debug -G "Unix Makefiles"
# cmake --build .
# cmake --build . --target install
# cd ../..
# rm -r -f monado

# Install WiVRn
# git clone https://github.com/Meumeu/WiVRn.git
# cd WiVRn
# sudo cmake -B build-server . -GNinja -DWIVRN_BUILD_CLIENT=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
# sudo cmake --build build-server
# sudo mkdir -p ~/.config/openxr/1/
# sudo ln --relative --symbolic --force build-server/openxr_wivrn-dev.json ~/.config/openxr/1/active_runtime.json
# cd ..
# sudo rm -r -f WiVRn

# Setup Stardust
git clone https://github.com/StardustXR/telescope.git
cd telescope
sudo chown -R $USER:$USER *.sh

./setup.sh
./hmd-setup.sh
cd repos/server
cargo build
cargo install --path .
cargo install flatland magnetar comet

# Append the export statement to the .bashrc file
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"

# Reload the .bashrc file in the current terminal session
source "$HOME/.bashrc"

# Display a message indicating completion
echo "The PATH environment variable has been updated."

echo "Installation and setup completed successfully."
