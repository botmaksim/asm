#ifndef SOLUTION_H_
#define SOLUTION_H_

#include <cstdint>

// 1. Найти номер точки (xi, yi), ближайшей к заданной (x, y).
extern "C" uint32_t AsmFindNearest(uint32_t x, uint32_t y, uint32_t n,
                                   uint32_t x1, uint32_t y1, ...);

// 2. Сумма элементов каждой строки двумерного массива по модулю 2^64.
extern "C" void AsmSummarizeRows(const uint64_t **a, uint32_t n, uint32_t m,
                                 uint64_t *b);

// 3. Количество элементов, НЕ удовлетворяющих предикату.
extern "C" uint32_t AsmCountIfNot(const uint16_t *a, uint32_t n,
                                  bool (*pred)(uint16_t x));

// 4. Вычислить (GetMagic(1) * GetMagic(GetMagic(2)) *
// GetMagic(GetMagic(GetMagic(3))))^2
extern "C" uint64_t AsmGetMoreMagic();

// 5. Создать копию массива в динамической памяти.
extern "C" void *AsmCopy(const void *data, uint32_t size);

// 6. Количество последовательностей длины N из 0 и 1, где K единиц не стоят
// рядом.
extern "C" uint64_t AsmSequencesCount(uint64_t n, uint64_t k);

#endif // SOLUTION_H_