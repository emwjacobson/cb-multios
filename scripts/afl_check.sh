#!/bin/bash

ROOT_DIR=/cb-multios
PERSISTENT_ROOT=/persistent

CHALLENGES_SRC=${ROOT_DIR}/challenges

for CHALLENGE_DIR in ${CHALLENGES_SRC}/*; do
  CHALLENGE_NAME=`basename ${CHALLENGE_DIR}`
  PERSISTENT_LOCAL=${PERSISTENT_ROOT}/${CHALLENGE_NAME}; mkdir -p ${PERSISTENT_LOCAL}

  printf "======== ${CHALLENGE_NAME} ========\n"

  afl-whatsup -s ${PERSISTENT_LOCAL}/out 2>/dev/null

  printf "\n\n"
done

