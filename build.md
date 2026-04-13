rm -rf build CMakeCache.txt CMakeFiles
cmake -B build -S .
cmake --build build
./build/solution_tests