#!/usr/bin/env bash

if [[ $# -gt 0 ]] && [[ $1 == "-g" ]] ; then
  flag="-g"
fi

   as $flag -ffreestanding -nostdlib main.s -o main.o -arch arm64 \
&& ld main.o -o toss -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 \
&& ./toss
