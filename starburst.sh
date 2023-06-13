#!/bin/bash



# Install essential packages
yes | sudo pacman -Syu --needed $(echo "cargo xr-hardware base-devel git wget unzip cmake ninja libeigen3 curl patch python pkg-config libx11 libx11-xcb libxxf86vm libxrandr xcb-util-xrm libxcb xcb-util-wm xcb-util-cursor libvulkan glslang glslang-tools mesa ca-certificates libusb libudev hidapi wayland wayland-protocols base-devel git wget unzip cmake meson ninja libeigen3 curl patch python pkgconf libx11 libx11-xcb libxxf86vm libxrandr xcb-util-xrm libxcb xcb-util-wm xcb-util-cursor vulkan-tools mesa ca-certificates libusb libudev hidapi wayland libuvc ffmpeg opencv v4l-utils cjson sdl2 libegl libbsd libuvc ffmpeg opencv v4l-utils cjson sdl2 libegl libbsd libopenxr-utils openxr-layer-corevalidation openxr-layer-apidump monado-cli monado-gui libopenxr-loader1 libopenxr-dev libopenxr1-monado libuvc libjpeg ffmpeg libx11 opencv hidapi libxtst libxcb xcb-util doxygen  xcb-util-xrm xcb-util-wm xcb-util-cursor python-pipx libv41 eigen vulkan-headers systemd vulkan-loader ninja libxkbcommon-x11 avahi libxcb glslang git ffmpeg libjpeg base-devel meson cmake pkgconf glfw-wayland libx11 libxcursor libxrandr libxi libxinerama wayland wayland-protocols wget curl fontconfig openxr seatd cargo glibc mesa nvidia libxext libglvnd xf86-video-amdgpu python3 python-pip android-tools vulkan-headers eigen nlohmann-json glslang libusb libv4l libxcb xcb-util-image xcb-util-wm xcb-util-keysyms xcb-util-renderutil opencv ffmpeg libjpeg bluez clang cuda a52dec adobe-source-sans-pro-fonts aspell-enbase-devel cmake curl ecryptfs-utils enchant exfat-utils faac faad2 flac fontconfig freetype2 fuse-exfat glfw-wayland glslang gst-libav gst-plugins-good gstreamer hunspell-en_US icedtea-web jasper jre8-openjdk lame languagetool libdca libdv libdvdcss libdvdnav libdvdread libglvnd libmad libmpeg2 libmythes libtheora libusb libvorbis libxv linux-firmware lsof mesa meson mythes-en ninja nlohmann-json opencv openssh openssl pkgconf pkgstats python python-pip python-pipx rsync seatd ttf-anonymous-prottf-bitstream-vera ttf-dejavu ttf-droid ttf-gentium ttf-liberation ttf-ubuntu-font-family ufw vulkan-headers wavpack wget x264 xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xf86-video-amdgpu xvidcore" | awk '!seen[$0]++')

curl https://sh.rustup.rs -sSf | sh -s

# Install yay package manager
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER ./yay-git
cd yay-git
makepkg -si --noconfirm
cd ..
sudo rm -rf yay-git



# Install using yay
yay -S --needed alacritty cargo openxr-loader-git cmake libjpeg monado monado-git openhmd-git OpenCV Doxygen systemd-devel python OpenXR python3 python-pip libuvc

# Install using pip
sudo pip install libclang ffmpeg 

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
sudo apt install build-essential cmake libgl1-mesa-dev libvulkan-dev libx11-xcb-dev libxcb-dri2-0-dev libxcb-glx0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-randr0-dev libxrandr-dev libxxf86vm-dev mesa-common-dev
git clone https://github.com/KhronosGroup/OpenXR-SDK.git
cd OpenXR-SDK
cmake . -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -Bbuild
ninja -C build install

sh
sudo add-apt-repository ppa:monado-xr/monado
sudo apt-get update
sudo apt install libopenxr-loader1 libopenxr-dev libopenxr-utils build-essential git wget unzip cmake meson ninja-build libeigen3-dev curl patch python3 pkg-config libx11-dev libx11-xcb-dev libxxf86vm-dev libxrandr-dev libxcb-randr0-dev libvulkan-dev glslang-tools 
libglvnd-dev libgl1-mesa-dev ca-certificates libusb-1.0-0-dev libudev-dev libhidapi-dev libwayland-dev libuvc-dev libavcodec-dev libopencv-dev libv4l-dev 
libcjson-dev libsdl2-dev libegl1-mesa-dev 

sh
git clone https://gitlab.freedesktop.org/monado/monado.git
cd monado
meson build
sudo ninja -C build install -j24

# Clone the WiVRn repository
sudo git clone https://github.com/Meumeu/WiVRn.git
cd WiVRn

# Build and set up WiVRn
cmake -B build-server . -GNinja -DWIVRN_BUILD_CLIENT=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build-server

# Set WiVRn as the active OpenXR runtime
sudo mkdir -p ~/.config/openxr/1/
sudo ln --relative --symbolic --force build-server/openxr_wivrn-dev.json ~/.config/openxr/1/active_runtime.json
cd ..
sudo rm -r -f WiVRn

# Clone the telescope repository
sudo git clone https://github.com/StardustXR/telescope.git
cd telescope

# Take ownership of .sh scripts
sudo chown -R $USER:$USER *.sh

# Execute setup.sh
sudo ./setup.sh

# Execute hmd-setup.sh
sudo ./hmd-setup.sh

# Change into the server folder
cd repos/server

# Build and install the server
sudo cargo build
sudo cargo install --path .

# Install flatland
sudo cargo install flatland magnetar comet

# Append the export statement to the .bashrc file
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"

# Reload the .bashrc file in the current terminal session
source "$HOME/.bashrc"

# Display a message indicating completion
echo "The PATH environment variable has been updated."

echo "Installation and setup completed successfully."
