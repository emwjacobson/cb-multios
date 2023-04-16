#!/bin/bash

DIR=/cb-multios

cd ${DIR}
cd symcc
git submodule update --init --recursive
mkdir build
cd build
cmake -G Ninja -DZ3_TRUST_SYSTEM_VERSION=ON -DQSYM_BACKEND=ON ..
ninja
