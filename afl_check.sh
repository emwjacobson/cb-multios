#!/bin/bash

AFL_BUILD_DIR=/cb-multios/build_afl/challenges

for CHALLENGE_DIR in ${AFL_BUILD_DIR}/*; do
  CHALLENGE_NAME=`basename ${CHALLENGE_DIR}`

  printf "======== ${CHALLENGE_NAME} ========\n"

  afl-whatsup -s ${CHALLENGE_DIR}/out 2>/dev/null

  printf "\n\n"
done

