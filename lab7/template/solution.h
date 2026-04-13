#ifndef SOLUTION_H_
#define SOLUTION_H_

#include <cstdint>

extern "C" void AsmTask1(const float* x, const float* y, float* result);
extern "C" double AsmTask2(double x);
extern "C" void AsmTask3(double x, double y, double* result);
extern "C" double AsmTask4(uint32_t n, const double* a, const int32_t* b);
extern "C" bool AsmTask5(uint32_t n, const double* x, const double* y);
extern "C" void AsmTask6(double x, double y, double* result);
extern "C" bool AsmTask7(uint32_t size, const uint32_t* values);
extern "C" double AsmTask8(uint32_t n, const double* x, const double* y);

#endif // SOLUTION_H_