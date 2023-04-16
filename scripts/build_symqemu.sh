#!/bin/bash

DIR=/cb-multios

cd ${DIR}

cd symqemu
mkdir -p build
cd build

../configure \
  --audio-drv-list= \
  --disable-bluez \
  --disable-sdl \
  --disable-gtk \
  --disable-vte \
  --disable-opengl \
  --disable-virglrenderer \
  --disable-werror \
  --target-list=x86_64-linux-user \
  --enable-capstone=git \
  --symcc-source=/cb-multios/symcc \
  --symcc-build=/cb-multios/symcc/build

make -j $(nproc)
