# Monoalphabetic Substitution Cipher

A simple implementation of a monoalphabetic substitution cipher written entirely in x86-64 assembly language using NASM.

## Features

- Text encryption using a 26-character substitution key
- Text decryption to recover original plaintext
- Case-preserving encryption (maintains uppercase/lowercase)
- Non-alphabetic characters remain unchanged
- Input validation for substitution keys
- Console-based user interface
- Error handling for invalid inputs

## Requirements

- Linux x86-64 system
- NASM (Netwide Assembler) version 2.14 or higher
- GNU Make
- GNU Linker (ld)

## Installation

1. Install dependencies:
```bash
sudo apt-get update
sudo apt-get install nasm build-essential make
```

2. Clone or download the project files

3. Build the project:
```bash
make
```

## Usage

1. Run the program:
```bash
./monoalphabetic_cipher
```

2. Select operation mode:
   - Enter 'E' for encryption
   - Enter 'D' for decryption

3. Enter the text you want to encrypt/decrypt (max 256 characters)

4. Enter the substitution key (must be exactly 26 unique letters)
   - Example key: `QWERTYUIOPASDFGHJKLZXCVBNM`

5. The program will display the result

### Example Session

```
Monoalphabetic Substitution Cipher
==================================

Select mode:
  E - Encrypt
  D - Decrypt
Enter your choice: E
Enter text (max 256 characters):
Hello World!
Enter substitution key (26 unique letters):
QWERTYUIOPASDFGHJKLZXCVBNM

Result:
Itssg Vgksr!
```

## Substitution Key Format

The substitution key must:
- Contain exactly 26 characters
- Include each letter of the alphabet exactly once
- Use only alphabetic characters (A-Z, case insensitive)

The key represents the mapping where:
- Position 1 (A) maps to the 1st character in the key
- Position 2 (B) maps to the 2nd character in the key
- And so on...

## Project Structure

```
monoalphabetic-cipher/
├── src/
│   ├── main.asm           # Main program entry point
│   ├── cipher.asm         # Encryption/decryption logic
│   ├── validation.asm     # Input validation routines
│   └── utils.asm          # Utility functions
├── include/
│   ├── constants.inc      # Program constants
│   └── macros.inc         # Assembly macros
├── Makefile               # Build configuration
└── README.md              # This file
```

## Building from Source

### Standard Build
```bash
make
```

### Debug Build
```bash
make debug
```

### Clean Build Artifacts
```bash
make clean
```

### Run After Building
```bash
make run
```

## Technical Details

- **Architecture**: x86-64 Linux
- **Assembler**: NASM (Netwide Assembler)
- **System Calls**: Linux x86-64 ABI
- **Maximum Input**: 256 characters
- **Character Encoding**: ASCII

## Implementation Notes

1. The program uses Linux system calls directly for I/O operations
2. All text processing is done in-place for efficiency
3. The decryption function creates a reverse lookup table for O(1) character mapping
4. Non-alphabetic characters (numbers, punctuation, spaces) pass through unchanged
5. Case is preserved by detecting and restoring the original case after substitution

## Error Handling

The program validates:
- Mode selection (must be E or D)
- Key length (must be exactly 26 characters)
- Key composition (only alphabetic characters)
- Key uniqueness (all 26 letters must be present)

## Limitations

- This is a simple monoalphabetic cipher and is NOT cryptographically secure
- Maximum input length is 256 characters
- Only supports English alphabet (A-Z)
- Console-based interface only

## Testing

Test cases to verify:
1. Basic encryption/decryption with mixed case
2. Handling of non-alphabetic characters
3. Invalid key rejection (wrong length, duplicates, non-alpha)
4. Maximum length input
5. Empty input handling

### Sample Test Key
```
ZYXWVUTSRQPONMLKJIHGFEDCBA
```
This key reverses the alphabet (A→Z, B→Y, etc.)

## Security Notice

**WARNING**: Monoalphabetic substitution ciphers are trivially breakable using frequency analysis and should NOT be used for any real security purposes. This implementation is for educational purposes only.

## License

Educational use only. Not for production cryptographic applications.

## Troubleshooting

1. **"Permission denied" error**: Make the file executable with `chmod +x monoalphabetic_cipher`
2. **"Command not found" for nasm**: Install NASM with `sudo apt-get install nasm`
3. **Linking errors**: Ensure you're on a Linux x86-64 system
4. **Invalid key errors**: Check that your key has exactly 26 unique letters