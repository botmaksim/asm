# x86-64 Assembly: Educational Coursework & Systems Archive

[![BSU FAMCS](https://img.shields.io/badge/BSU%20FAMCS-Curriculum%20Archive-blue.svg)](https://fpmi.bsu.by/)
[![Architecture](https://img.shields.io/badge/Architecture-x86--64-6E4C13.svg)](#)
[![CMake](https://img.shields.io/badge/CMake-3.14%2B-blue.svg)](https://cmake.org/)
[![GoogleTest](https://img.shields.io/badge/GoogleTest-Unit%20Tests-brightgreen.svg)](https://github.com/google/googletest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An educational systems repository containing progressive x86-64 assembly implementations and automated unit verification suites for the Low-Level Systems Programming curriculum at Belarusian State University, Faculty of Applied Mathematics and Computer Science. Maintained as a public reference for subsequent academic cohorts.

---

## Table of Contents
1. [Curriculum Overview](#curriculum-overview)
2. [ABI Compliance](#abi-compliance)
3. [Prerequisites](#prerequisites)
4. [Build & Verification](#build--verification)
5. [Directory Structure](#directory-structure)
6. [License](#license)

---

## Curriculum Overview

| Module | Technical Focus | Architecture Concepts |
| :--- | :--- | :--- |
| **`lab1`** | Basic Data Movement | General-purpose registers, immediate values, direct and indirect memory addressing |
| **`lab2`** | Integer Arithmetic & Flags | Arithmetic instructions, zero flag, carry flag, overflow flag, conditional branching |
| **`lab3`** | Control Flow & Loops | Unconditional and conditional jumps, loop primitives, stack pointer alignment |
| **`lab4`** | Subroutines & Stack Frames | Activation records, base pointer management, return addresses, stack cleanup |
| **`lab5`** | Bitwise Operations | Logic gates, shift instructions, arithmetic shifts, bitmask parsing |
| **`lab6`** | String & Array Primitives | Sequential scanning instructions, block data moves, direction flag management |
| **`lab7`** | System Calls & C Interoperability | Kernel trap invocation, standard C runtime bindings, parameter passing |
| **`cw1`** | Comprehensive Coursework | Algorithmic assembly routine coupled with a complete C++ GoogleTest harness |

---

## ABI Compliance

All routines adhere strictly to the System V AMD64 Application Binary Interface:

| Category | Register Allocation |
| :--- | :--- |
| **Integer / Pointer Arguments** | `RDI`, `RSI`, `RDX`, `RCX`, `R8`, `R9` in sequential order |
| **Return Value** | `RAX` for 64-bit scalar outputs, `RDX:RAX` for 128-bit results |
| **Callee-Saved Registers** | `RBX`, `RSP`, `RBP`, `R12`, `R13`, `R14`, `R15` preserved across invocations |
| **Caller-Saved Scratch** | `RAX`, `RCX`, `RDX`, `RSI`, `RDI`, `R8`, `R9`, `R10`, `R11` |
| **Stack Alignment** | 16-byte aligned before any `call` instruction |

---

## Prerequisites

Provision the required toolchains on the host machine:

* **Assembler**: NASM 2.14+ or Yasm
* **C++ Compiler**: GCC 9+ or Clang 10+
* **Build System**: CMake 3.14+
* **Testing**: GoogleTest development libraries

```bash
sudo apt update
sudo apt install -y nasm build-essential cmake libgtest-dev
```

---

## Build & Verification

To compile the coursework module and execute the verification test suite:

```bash
# Clone the repository
git clone https://github.com/botmaksim/asm.git
cd asm/cw1

# Configure and compile
cmake -B build -S .
cmake --build build -j$(nproc)

# Run automated tests
./build/solution_tests
```

---

## Directory Structure

```text
asm/
├── build.md            # Generic build reference notes
├── lab1/               # Lab 1 source and templates
├── lab2/               # Lab 2 source and templates
├── lab3/               # Lab 3 source and templates
├── lab4/               # Lab 4 source and templates
├── lab5/               # Lab 5 source and templates
├── lab6/               # Lab 6 source and templates
├── lab7/               # Lab 7 source and templates
├── cw1/                # Coursework module with automated test harness
│   ├── CMakeLists.txt  # Build definitions
│   ├── solution.asm    # Optimized assembly core
│   ├── solution.h      # C++ interface header
│   └── tests.cpp       # GoogleTest and GoogleMock test suite
└── cw1_test/           # Verification benchmarks
```

---

## License

This repository is distributed under the [MIT License](LICENSE).
