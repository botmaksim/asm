Техническое задание:
TA.pdf

Билд:
```bash
nasm -f elf32 task1.asm -o build/task1.o
nasm -f elf32 task2.asm -o build/task2.o
g++ -m32 main.cpp build/task1.o build/task2.o -o build/lab_solution -lm
./build/lab_solution