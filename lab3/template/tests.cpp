#include "gtest/gtest.h"
#include <cstdint>
#include <cmath>
#include <string>
#include <algorithm>

extern "C" int32_t AsmBitCount(uint64_t n);
extern "C" int64_t AsmFactorial(int32_t n);
extern "C" bool AsmIsSquare(int64_t x);
extern "C" int32_t AsmRemoveDigits(int32_t x);
extern "C" int64_t AsmFormula(int64_t x, int64_t n);
extern "C" uint64_t AsmBankDeposit(uint64_t initial_sum, int32_t percentage, int32_t years);
extern "C" uint16_t AsmEvenDivisors(uint16_t n);
extern "C" uint64_t AsmInfiniteManipulations(uint64_t x);

int32_t CppBitCount(uint64_t n) {
    int32_t count = 0;
    while (n) {
        count += n & 1;
        n >>= 1;
    }
    return count;
}

TEST(Lab3, BitCount) {
    EXPECT_EQ(AsmBitCount(0), 0);
    EXPECT_EQ(AsmBitCount(1), 1);
    EXPECT_EQ(AsmBitCount(0xFFFFFFFFFFFFFFFF), 64);
    EXPECT_EQ(AsmBitCount(0x123456789ABCDEF0), CppBitCount(0x123456789ABCDEF0));
}

int64_t CppFactorial(int32_t n) {
    int64_t f = 1;
    int64_t i = 1;
    while (f <= n) {
        i++;
        f *= i;
    }
    return f;
}

TEST(Lab3, Factorial) {
    EXPECT_EQ(AsmFactorial(0), 1);
    EXPECT_EQ(AsmFactorial(1), 2);
    EXPECT_EQ(AsmFactorial(5), 6);
    EXPECT_EQ(AsmFactorial(24), 120);
    EXPECT_EQ(AsmFactorial(119), 120);
}

bool CppIsSquare(int64_t x) {
    if (x < 0) return false;
    int64_t r = std::round(std::sqrt(x));
    return r * r == x;
}

TEST(Lab3, IsSquare) {
    EXPECT_EQ(AsmIsSquare(0), true);
    EXPECT_EQ(AsmIsSquare(1), true);
    EXPECT_EQ(AsmIsSquare(4), true);
    EXPECT_EQ(AsmIsSquare(5), false);
    EXPECT_EQ(AsmIsSquare(-1), false);
    EXPECT_EQ(AsmIsSquare(1000000000000000000LL), true);
    EXPECT_EQ(AsmIsSquare(1000000000000000001LL), false);
}

int32_t CppRemoveDigits(int32_t x) {
    if (x == 0) return 0;
    bool neg = x < 0;
    int64_t temp = std::abs((int64_t)x);
    int64_t res = 0;
    int64_t mult = 1;
    while (temp > 0) {
        int d = temp % 10;
        if (d % 2 != 0) {
            res += d * mult;
            mult *= 10;
        }
        temp /= 10;
    }
    return neg ? -res : res;
}

TEST(Lab3, RemoveDigits) {
    EXPECT_EQ(AsmRemoveDigits(0), 0);
    EXPECT_EQ(AsmRemoveDigits(12345), 135);
    EXPECT_EQ(AsmRemoveDigits(-12345), -135);
    EXPECT_EQ(AsmRemoveDigits(2468), 0);
    EXPECT_EQ(AsmRemoveDigits(-2468), 0);
    EXPECT_EQ(AsmRemoveDigits(13579), 13579);
}

int64_t CppFormula(int64_t x, int64_t n) {
    int64_t a = 1;
    int64_t p = 1;
    for (int64_t k = 1; k <= n; ++k) {
        int64_t term1;
        if (__builtin_mul_overflow(a, x, &term1)) return -1;
        int64_t term2 = (k % 2 == 1) ? -(k + 1) : (k + 1);
        int64_t next_a;
        if (__builtin_add_overflow(term1, term2, &next_a)) return -1;
        a = next_a;
        if (__builtin_mul_overflow(p, a, &p)) return -1;
    }
    return p;
}

TEST(Lab3, Formula) {
    EXPECT_EQ(AsmFormula(2, 3), CppFormula(2, 3));
    EXPECT_EQ(AsmFormula(1, 5), CppFormula(1, 5));
    EXPECT_EQ(AsmFormula(10, 10), CppFormula(10, 10));
    EXPECT_EQ(AsmFormula(1000000, 100), -1);
}

uint64_t CppBankDeposit(uint64_t initial_sum, int32_t percentage, int32_t years) {
    uint64_t sum = initial_sum;
    for (int i = 0; i < years; ++i) {
        sum += (sum * percentage) / 100;
    }
    return sum;
}

TEST(Lab3, BankDeposit) {
    EXPECT_EQ(AsmBankDeposit(1000, 10, 1), 1100);
    EXPECT_EQ(AsmBankDeposit(1000, 10, 2), 1210);
    EXPECT_EQ(AsmBankDeposit(1000, 0, 10), 1000);
}

uint16_t CppEvenDivisors(uint16_t n) {
    uint16_t count = 0;
    for (uint16_t q = 1; q * q < n; ++q) {
        if (n % q == 0) {
            if (q < n / q - 1) {
                count++;
            }
        }
    }
    return count;
}

TEST(Lab3, EvenDivisors) {
    EXPECT_EQ(AsmEvenDivisors(20), CppEvenDivisors(20));
    EXPECT_EQ(AsmEvenDivisors(100), CppEvenDivisors(100));
    EXPECT_EQ(AsmEvenDivisors(1), CppEvenDivisors(1));
}

uint64_t CppInfiniteManipulations(uint64_t x) {
    int bits = CppBitCount(x);
    if (bits == 0 || bits == 64) return 0;
    uint64_t min_val = (1ULL << bits) - 1;
    uint64_t max_val = min_val << (64 - bits);
    return max_val - min_val;
}

TEST(Lab3, InfiniteManipulations) {
    EXPECT_EQ(AsmInfiniteManipulations(0), 0);
    EXPECT_EQ(AsmInfiniteManipulations(~0ULL), 0);
    EXPECT_EQ(AsmInfiniteManipulations(1), CppInfiniteManipulations(1));
    EXPECT_EQ(AsmInfiniteManipulations(0x0F), CppInfiniteManipulations(0x0F));
}
