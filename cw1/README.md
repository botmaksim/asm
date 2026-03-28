nasm -f elf32 cw1/task1.asm -o cw1/build/task1.o
nasm -f elf32 cw1/task2.asm -o cw1/build/task2.o
g++ -m32 main.cpp cw1/build/task1.o cw1/build/task2.o -o cw1/build/lab_solution -lm
./cw1/build/lab_solution