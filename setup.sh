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

# Cleanup
cd $PICO_HOME
rm -r openocd picotool