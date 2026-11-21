# Build the assembly version (needs NASM and ld, 64-bit Linux)
shape_generator: src/shape_generator.asm
	nasm -f elf64 src/shape_generator.asm -o shape_generator.o
	ld shape_generator.o -o shape_generator

clean:
	rm -f shape_generator shape_generator.o

.PHONY: clean
