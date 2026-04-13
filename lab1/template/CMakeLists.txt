cmake_minimum_required(VERSION 3.7)

project(asm_lab)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 14)

if (MINGW)
    set(THREADS_OPTION "-mthreads")
else (MINGW)
    set(THREADS_OPTION "-pthread")
endif (MINGW)

# Fix for MacOS+clang:
# string(APPEND CMAKE_ASM_NASM_FLAGS "--prefix _")

enable_language(ASM_NASM)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} "-no-pie -Wall -Wextra -Wno-sign-compare -Wno-attributes")
set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS} "-fno-omit-frame-pointer ${THREADS_OPTION}")

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/gtest)

add_executable(solution_tests solution.asm tests.cpp gtest/gtest-all.cc gtest/gtest_main.cc)
