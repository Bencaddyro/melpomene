#!/bin/bash

for name in "$@"
do 
find "/home/bencaddyro/larsen/melpomene" -name "$(basename "$name")" -delete;
done

