#!/bin/bash

AFL_BUILD_DIR=/cb-multios/build_afl/challenges
AFL_NUM_FOLLOWERS=1

PIDS=()

i=0
for CHALLENGE_DIR in ${AFL_BUILD_DIR}/*; do
  CHALLENGE_NAME=`basename ${CHALLENGE_DIR}`

  printf "Processing ${CHALLENGE_NAME}\n\n"
  
  # Make an "in" and "out" directory for AFL-Fuzz
  mkdir -p ${CHALLENGE_DIR}/in ${CHALLENGE_DIR}/out
  echo "AAAAAAAAAAAAAAAAAAAAAAAAA" > ${CHALLENGE_DIR}/in/init

  # Details on multi-core/system Fuzzing
  # https://github.com/AFLplusplus/AFLplusplus/blob/stable/docs/fuzzing_in_depth.md

  # Current strategy: Single Main
  afl-fuzz -i ${CHALLENGE_DIR}/in -o ${CHALLENGE_DIR}/out -D \
    -p explore -- ${CHALLENGE_DIR}/${CHALLENGE_NAME} > main.out &
  PIDS[${i}]=$!

  printf "Started Fuzzing ${CHALLENGE_NAME} PID: ${PIDS[${i}]}"

  i=`expr $i + 1`
  printf "\n"
done

for pid in ${PIDS[*]}; do
    wait $pid
done
