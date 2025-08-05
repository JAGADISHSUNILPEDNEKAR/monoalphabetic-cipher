# Makefile for Monoalphabetic Cipher

# Assembler and linker
AS = nasm
LD = ld

# Flags
ASFLAGS = -f elf64 -I include/
LDFLAGS = -nostdlib

# Source files
SRCS = src/main.asm src/cipher.asm src/validation.asm src/utils.asm
OBJS = $(SRCS:.asm=.o)

# Target executable
TARGET = monoalphabetic_cipher

# Default target
all: $(TARGET)

# Link object files
$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

# Assemble source files
%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

# Clean build artifacts
clean:
	rm -f $(OBJS) $(TARGET)

# Run the program
run: $(TARGET)
	./$(TARGET)

# Debug build
debug: ASFLAGS += -g -F dwarf
debug: clean $(TARGET)

# Install (optional)
install: $(TARGET)
	install -m 755 $(TARGET) /usr/local/bin/

# Uninstall (optional)
uninstall:
	rm -f /usr/local/bin/$(TARGET)

.PHONY: all clean run debug install uninstall