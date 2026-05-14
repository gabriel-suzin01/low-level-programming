# Low-Level Programming 🚀

This repository is a personal laboratory for low-level software development.
My goal is to build a solid foundation in computer architecture by bridging the gap between high-level logic and machine instructions.

# 🎯 Purpose

- **Portfolio**: Showcasing technical skills in memory management and hardware interaction.
- **Learning**: Documentation of my journey through C, Assembly, and the compilation pipeline. 

# 🛠️ Quick Start

To build the assembly projects, assemble the NASM files, link and execute:

```bash

# 1. Assemble
nasm -f elf64 main.asm -o main.o

# 2. Compile
ld main.o -o main

# 3. Execute
./main

```

To build the project, assemble the NASM files, compile the C code, and link them together:

```bash

# 1. Assemble (Assembly to Object)
nasm -f elf64 functions.asm -o functions.o

# 2. Compile (C to Object)
gcc -c main.c -o main.o

# 3. Link (GCC calls the linker and include the necessary libs)
gcc main.o functions.o -o program

# 4. Execute
./program

```

Developed for learning, portfolio and curiosity. 👨‍💻