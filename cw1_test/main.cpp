#include <cmath>
#include <iomanip>
#include <iostream>
#include <vector>

extern "C" {

float __attribute__((fastcall))
CalculateCos(int N, float *delta) __asm__("CalculateCos");

void __attribute__((cdecl)) CreateVectorB(int *A, int N, int M,
                                          int *B) __asm__("CreateVectorB");
}

void task1() {
  int N;
  float delta = 0;
  std::cout << "\n--- Задание 1 (Ряд Тейлора) ---\n";
  std::cout << "Введите N: ";
  if (!(std::cin >> N))
    return;

  float result = CalculateCos(N, &delta);

  std::cout << std::fixed << std::setprecision(8);
  std::cout << "Приближенное cos(pi/4): " << result << std::endl;
  std::cout << "Реальное значение:      " << cos(M_PI / 4.0) << std::endl;
  std::cout << "Разница (delta):        " << delta << std::endl;
}

void task2() {
  int N, M;
  std::cout << "\n--- Задание 2 (Матрица) ---\n";
  std::cout << "Введите N (строки) и M (столбцы): ";
  if (!(std::cin >> N >> M))
    return;

  std::vector<int> A(N * M);
  std::vector<int> B(M);

  std::cout << "Введите элементы матрицы (" << N * M << " шт.):\n";
  for (int i = 0; i < N * M; ++i)
    std::cin >> A[i];

  CreateVectorB(A.data(), N, M, B.data());

  std::cout << "Вектор B: ";
  for (int i = 0; i < M; ++i)
    std::cout << B[i] << " ";
  std::cout << std::endl;
}

int main() {
  int choice;
  while (true) {
    std::cout << "\nМеню:\n1. Task 1\n2. Task 2\n0. Exit\n> ";
    if (!(std::cin >> choice) || choice == 0)
      break;
    if (choice == 1)
      task1();
    else if (choice == 2)
      task2();
  }
  return 0;
}