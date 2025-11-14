#!/usr/bin/env bash

   as main.s -o main.o -arch arm64 \
&& ld main.o -o toss -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64 \
&& ./toss
