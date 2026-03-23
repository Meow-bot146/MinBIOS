# Makefile
# MinBIOS - Full BIOS ROM Makefile
# Builds a complete 64KB BIOS ROM image

AS = nasm
ASFLAGS = -f bin

all: minbios.rom

# Build the 64KB BIOS ROM
minbios.rom: bios.asm
	@echo "Building MinBIOS ROM (64KB)..."
	$(AS) $(ASFLAGS) bios.asm -o minbios.rom
	@SIZE=$$(stat -c%s minbios.rom 2>/dev/null || stat -f%z minbios.rom 2>/dev/null); \
	echo "✓ MinBIOS ROM built: $$SIZE bytes"; \
	if [ $$SIZE -eq 65536 ]; then \
		echo "✓ Size correct: 64KB"; \
	else \
		echo "✗ Warning: Expected 65536 bytes, got $$SIZE"; \
	fi
	@echo ""

# Test as ACTUAL BIOS in QEMU (replaces SeaBIOS)
test: minbios.rom
	@echo "=========================================="
	@echo "Testing MinBIOS as REAL BIOS"
	@echo "=========================================="
	@echo "This REPLACES SeaBIOS - MinBIOS is the actual firmware!"
	@echo "Press Ctrl+A then X to exit QEMU"
	@echo ""
	qemu-system-i386 -bios minbios.rom -nographic

# Test with GUI
test-gui: minbios.rom
	@echo "Testing MinBIOS with display..."
	qemu-system-i386 -bios minbios.rom

# Verify ROM structure
verify: minbios.rom
	@echo "=========================================="
	@echo "MinBIOS ROM Verification"
	@echo "=========================================="
	@echo ""
	@echo "File size:"
	@ls -lh minbios.rom
	@echo ""
	@echo "Reset vector (last 16 bytes):"
	@tail -c 16 minbios.rom | od -Ax -tx1
	@echo ""
	@echo "First 64 bytes:"
	@head -c 64 minbios.rom | od -Ax -tx1 -c
	@echo ""

# Disassemble parts of ROM
disasm: minbios.rom
	@echo "Disassembling first 256 bytes..."
	ndisasm -b 16 -o 0xF0000 minbios.rom | head -50
	@echo ""
	@echo "Disassembling reset vector (last 16 bytes)..."
	tail -c 16 minbios.rom > /tmp/reset.bin
	ndisasm -b 16 -o 0xFFFF0 /tmp/reset.bin
	rm /tmp/reset.bin

# Clean
clean:
	rm -f *.rom *.bin *.o

# Info
info:
	@echo "=========================================="
	@echo "MinBIOS - Full BIOS ROM"
	@echo "=========================================="
	@echo ""
	@echo "What is this?"
	@echo "  A complete, working BIOS ROM written in x86 assembly"
	@echo "  This is REAL firmware - not just a boot sector!"
	@echo ""
	@echo "Size: 64KB (65536 bytes)"
	@echo "Format: Raw binary ROM image"
	@echo "Architecture: x86 16-bit real mode"
	@echo ""
	@echo "Build commands:"
	@echo "  make         - Build the ROM"
	@echo "  make test    - Test in QEMU (text mode)"
	@echo "  make test-gui- Test in QEMU (with display)"
	@echo "  make verify  - Verify ROM structure"
	@echo "  make disasm  - Disassemble ROM"
	@echo ""
	@echo "How it works:"
	@echo "  1. CPU powers on, jumps to 0xFFFF0 (reset vector)"
	@echo "  2. Reset vector jumps to MinBIOS init code"
	@echo "  3. MinBIOS performs POST (Power-On Self Test)"
	@echo "  4. MinBIOS searches for bootable device"
	@echo "  5. MinBIOS loads boot sector and executes it"
	@echo ""
	@echo "This replaces SeaBIOS completely in QEMU!"
	@echo "=========================================="

.PHONY: all test test-gui verify disasm clean info
