#!/bin/bash

# Declare variables
essential_packages=(
    base-devel
    cmake
    curl
    fontconfig
    git
    glfw-wayland
    glslang
    libjpeg
    libusb
    mesa
    meson
    ninja
    nlohmann-json
    opencv
    pkgconf
    python-pip
    python3
    seatd
    vulkan-headers
    wget
    xcb-util-image
    xcb-util-keysyms
    xcb-util-renderutil
    xcb-util-wm
    xf86-video-amdgpu
)
aur_packages=(
    alacritty
    cmake
    doxygen
    libjpeg
    monado-git
    openhmd
    openxr-loader-git
    python
    systemd-devel
)
pip_packages=(
    libclang
    ffmpeg
)

# Exit on error
set -e

# Update system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --noconfirm "${essential_packages[@]}"

# Install yay package manager
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

# Install AUR packages using yay
for package in "${aur_packages[@]}"; do
    yay -S --noconfirm --needed "$package"
done

# Install pip packages
if ! command -v pipx &> /dev/null; then
    yay -S --noconfirm --needed python-pipx
    pipx ensurepath
fi

for package in "${pip_packages[@]}"; do
    if ! pipx list | grep -q "$package"; then
        pipx install "$package"
    fi
done

# Build and install flatbuffers v2.0.8 manually
if ! command -v flatc &> /dev/null; then
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
fi

# Clone the Monado repository
if [ ! -d "monado" ]; then
    git clone https://gitlab.freedesktop.org/monado/monado.git
fi

cd monado
cmake -G Ninja -S . -B build -DCMAKE_INSTALL_PREFIX=/usr
ninja -C build install
cd ..
rm -rf monado

# Set the CUDAToolkit_ROOT environment variable
if ! grep -q 'CUDAToolkit_ROOT' "$HOME/.bashrc"; then
    echo 'export CUDAToolkit_ROOT=/usr/local/cuda' >> "$HOME/.bashrc"
fi

# Install OpenXR-SDK
if [ ! -d "OpenXR-SDK" ]; then
    git clone https://github.com/KhronosGroup/OpenXR-SDK.git
fi

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
if [ ! -d "telescope" ]; then
    git clone https://github.com/StardustXR/telescope.git
fi

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
if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Reload the .bashrc file in the current terminal session
source "$HOME/.bashrc"

# Display a message indicating completion
echo "The PATH environment variable has been updated."
echo "Installation and setup completed successfully."
