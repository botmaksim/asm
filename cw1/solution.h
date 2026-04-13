#ifndef SOLUTION_H_
#define SOLUTION_H_

#include <cstdint>

extern "C" uint32_t AsmSimpleFn(uint32_t a, uint32_t b, uint32_t c);
extern "C" const char *AsmOverflow(uint32_t x);
extern "C" int64_t AsmFxy(int32_t x, int32_t y);
extern "C" int64_t AsmArray(const int16_t *array, int16_t size);
extern "C" int64_t AsmEvenOdd(int64_t *array, int64_t size);
extern "C" int64_t AsmAlpha(int64_t x, int64_t y, int64_t z,
                            int64_t (*Delta)(int64_t));
extern "C" uint64_t AsmRecursion(int16_t m, uint64_t n);
extern "C" void Asm2d(int64_t **array, int64_t rows_count,
                      int64_t columns_count);

#endif // SOLUTION_H_
