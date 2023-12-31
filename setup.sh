#!/bin/bash

PICO_HOME="$HOME/pico"

echo "Pico home is:" "$PICO_HOME"
echo "Creating folder: $PICO_HOME"
mkdir -p "$PICO_HOME"

sudo apt -y update

# Setup pico-sdk
cd "$PICO_HOME"
echo "Setup Pico SDK"
sudo apt -y install git python3 python-is-python3 cmake gcc-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib gcc g++ gdb-multiarch minicom screen
git clone https://github.com/raspberrypi/pico-sdk.git
cd pico-sdk
git submodule update --init
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -DPICO_SDK_TESTS_ENABLED=0
make -j$(proc)
echo 'Adding export PICO_SDK_PATH="$HOME/pico/pico-sdk" to your .bashrc file'
grep -q 'PICO_SDK_PATH' $HOME/.bashrc || printf '\nexport PICO_SDK_PATH="$HOME/pico/pico-sdk"\n' >> $HOME/.bashrc
export PICO_SDK_PATH="$HOME/pico/pico-sdk"

# Setup pico-examples
cd $PICO_HOME
echo "Setup Pico examples"
git clone https://github.com/raspberrypi/pico-examples.git
cd pico-examples
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(proc)

# Setup Debug Probe
cd $PICO_HOME
echo "Setup Debug Probe (openocd)"
sudo apt -y install automake autoconf build-essential texinfo libtool libftdi-dev libusb-1.0-0-dev gdb-multiarch pkg-config
git clone https://github.com/raspberrypi/openocd.git --branch rp2040-v0.12.0 --depth=1 --no-single-branch
cd openocd
./bootstrap
./configure
make -j$(nproc)
sudo make install
sudo cp contrib/60-openocd.rules /etc/udev/rules.d/

# Setup picotool
cd $PICO_HOME
echo "Setup picotool"
sudo apt -y install build-essential pkg-config libusb-1.0-0-dev cmake
git clone https://github.com/raspberrypi/picotool.git
cd picotool
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install
cd ..
sudo cp udev/99-picotool.rules /etc/udev/rules.d/

# Run debug tools without being sudo
sudo usermod -aG plugdev $(id -nu)
sudo udevadm control --reload-rules && sudo udevadm trigger

# Install VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes --output /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
sudo apt -y update
sudo apt install -y code
code --install-extension marus25.cortex-debug
code --install-extension ms-vscode.cmake-tools
code --install-extension ms-vscode.cpptools

# Cleanup
cd $PICO_HOME
rm -r openocd picotool