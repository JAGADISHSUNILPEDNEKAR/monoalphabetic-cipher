#!/bin/bash

# test.sh - Test script for monoalphabetic cipher

echo "Monoalphabetic Cipher Test Suite"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Build the project first
echo -e "\nBuilding project..."
make clean > /dev/null 2>&1
make > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful!${NC}"

# Test function
run_test() {
    local test_name=$1
    local mode=$2
    local text=$3
    local key=$4
    local expected=$5
    
    echo -e "\n${test_name}"
    echo "Mode: $mode"
    echo "Text: $text"
    echo "Key: $key"
    
    # Run the cipher
    result=$(echo -e "${mode}\n${text}\n${key}" | ./monoalphabetic_cipher 2>&1 | grep -A1 "Result:" | tail -n1)
    
    echo "Result: $result"
    echo "Expected: $expected"
    
    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
}

# Test cases
echo -e "\n\nRunning Tests..."
echo "================"

# Test 1: Basic encryption
run_test "Test 1: Basic Encryption" "E" "HELLO" "QWERTYUIOPASDFGHJKLZXCVBNM" "ITSSG"

# Test 2: Basic decryption
run_test "Test 2: Basic Decryption" "D" "ITSSG" "QWERTYUIOPASDFGHJKLZXCVBNM" "HELLO"

# Test 3: Mixed case encryption
run_test "Test 3: Mixed Case Encryption" "E" "Hello World" "QWERTYUIOPASDFGHJKLZXCVBNM" "Itssg Vgksr"

# Test 4: With numbers and punctuation
run_test "Test 4: Numbers and Punctuation" "E" "Test 123!" "QWERTYUIOPASDFGHJKLZXCVBNM" "Ztkz 123!"

# Test 5: Reverse alphabet key
run_test "Test 5: Reverse Alphabet" "E" "ABC" "ZYXWVUTSRQPONMLKJIHGFEDCBA" "ZYX"

# Test invalid key length
echo -e "\n\nTest 6: Invalid Key Length"
echo -e "E\nHELLO\nABC" | ./monoalphabetic_cipher 2>&1 | grep -q "Error: Key must be exactly 26 characters"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}PASS - Correctly rejected short key${NC}"
else
    echo -e "${RED}FAIL - Did not reject short key${NC}"
fi

# Test duplicate characters in key
echo -e "\n\nTest 7: Duplicate Characters in Key"
echo -e "E\nHELLO\nAAAABBBBCCCCDDDDEEEEFFFFGG" | ./monoalphabetic_cipher 2>&1 | grep -q "Error: Key must contain 26 unique letters"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}PASS - Correctly rejected key with duplicates${NC}"
else
    echo -e "${RED}FAIL - Did not reject key with duplicates${NC}"
fi

# Test non-alphabetic characters in key
echo -e "\n\nTest 8: Non-alphabetic Characters in Key"
echo -e "E\nHELLO\n123456789012345678901234567" | ./monoalphabetic_cipher 2>&1 | grep -q "Error: Key must contain only alphabetic characters"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}PASS - Correctly rejected non-alphabetic key${NC}"
else
    echo -e "${RED}FAIL - Did not reject non-alphabetic key${NC}"
fi

# Test round-trip encryption/decryption
echo -e "\n\nTest 9: Round-trip Encryption/Decryption"
original="The Quick Brown Fox Jumps Over The Lazy Dog!"
key="QWERTYUIOPASDFGHJKLZXCVBNM"

# Encrypt
encrypted=$(echo -e "E\n${original}\n${key}" | ./monoalphabetic_cipher 2>&1 | grep -A1 "Result:" | tail -n1)
echo "Original: $original"
echo "Encrypted: $encrypted"

# Decrypt
decrypted=$(echo -e "D\n${encrypted}\n${key}" | ./monoalphabetic_cipher 2>&1 | grep -A1 "Result:" | tail -n1)
echo "Decrypted: $decrypted"

if [ "$original" = "$decrypted" ]; then
    echo -e "${GREEN}PASS - Round-trip successful${NC}"
else
    echo -e "${RED}FAIL - Round-trip failed${NC}"
fi

echo -e "\n\nTest suite completed!"