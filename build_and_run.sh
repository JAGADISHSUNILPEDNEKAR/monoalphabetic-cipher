#!/bin/bash

# build_and_run.sh - Quick build and run script

echo "Building Monoalphabetic Cipher..."

# Clean previous build
make clean > /dev/null 2>&1

# Build the project
make

if [ $? -eq 0 ]; then
    echo -e "\nBuild successful! Running program...\n"
    ./monoalphabetic_cipher
else
    echo -e "\nBuild failed! Check error messages above."
    exit 1
fi