#!/bin/bash

DIR=/cb-multios

cd ${DIR}
git clone https://github.com/AFLplusplus/AFLplusplus
cd AFLplusplus
make -j$(nproc) binary-only
make install
