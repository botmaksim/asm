cmake_minimum_required(VERSION 3.10)

# Enable C, C++, and Assembly (NASM) languages
project(kr_2022_v1 C CXX ASM_NASM)

# Require C++17 (Google Test heavily uses modern C++ features)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Google Test requires threading support on most platforms
find_package(Threads REQUIRED)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/solution_src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/tests_src)

# 1. Define the Google Test/Mock library
add_library(gtest_files STATIC
    gtest/gtest-all.cc
    gmock/gmock-all.cc
    gtest/gtest_main.cc
)
target_link_libraries(gtest_files Threads::Threads)

# 2. Define the asm_utils library
add_library(asm_utils STATIC
    utils/utils.cc
    utils/asm_utils.asm
)

# 3. Define the main executable
add_executable(${PROJECT_NAME} solution.asm tests.cpp)

# Link the libraries to your executable
target_link_libraries(${PROJECT_NAME} asm_utils gtest_files)