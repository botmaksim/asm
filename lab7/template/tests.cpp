#include "gtest/gtest.h"
#include "solution.h"
#include <cmath>

TEST(Lab7, Task1) {
    float x = 2.0f;
    float y = 1.0f;
    float result;
    AsmTask1(&x, &y, &result);
    float expected = std::sqrt(42.0f * x) / (24.0f * y - 24.0f * y * y + 17.0f);
    EXPECT_NEAR(result, expected, 1e-5);
}

TEST(Lab7, Task2) {
    double x = 1.0;
    double result = AsmTask2(x);
    double expected = std::sin(x) + 2 * std::cos(x) - std::tan(2 * x);
    EXPECT_NEAR(result, expected, 1e-5);
}

TEST(Lab7, Task3) {
    double x = 2.0;
    double y = 3.0;
    double result;
    AsmTask3(x, y, &result);
    double expected = x * x * std::log2(1 + std::abs(2 * y - 1)) - std::log10(std::exp(1.0));
    EXPECT_NEAR(result, expected, 1e-5);
}

TEST(Lab7, Task4) {
    double a[] = {1.0, 4.0, 9.0};
    int32_t b[] = {2, 3, 4};
    double result = AsmTask4(3, a, b);
    double expected = a[0] - 2 * std::sqrt(a[1]) * b[1] + 4 * std::sqrt(a[2]) * b[2] * b[2];
    EXPECT_NEAR(result, expected, 1e-5);
}

TEST(Lab7, Task5) {
    double x[] = {1.0, 2.0, 3.0};
    double y[] = {1.0, 2.0, 3.0000001};
    EXPECT_TRUE(AsmTask5(3, x, y));
    double z[] = {1.0, 2.0, 3.1};
    EXPECT_FALSE(AsmTask5(3, x, z));
}

TEST(Lab7, Task6) {
    double x = 2.0;
    double y = 3.0;
    double result;
    AsmTask6(x, y, &result);
    double expected = x * x * std::log2(1 + std::abs(2 * y - 1)) - std::log10(std::exp(1.0));
    EXPECT_NEAR(result, expected, 1e-5);
}

TEST(Lab7, Task7) {
    uint32_t values1[] = {100, 200, 511, 500};
    EXPECT_FALSE(AsmTask7(4, values1));
    uint32_t values2[] = {100, 200, 512, 500};
    EXPECT_TRUE(AsmTask7(4, values2));
    uint32_t values3[] = {0xFFFFFFFF};
    EXPECT_TRUE(AsmTask7(1, values3));
}

TEST(Lab7, Task8) {
    double x[] = {1.0, 2.0, 3.0};
    double y[] = {4.0, 6.0, 8.0};
    double result = AsmTask8(3, x, y);
    double expected = std::sqrt(9.0 + 16.0 + 25.0);
    EXPECT_NEAR(result, expected, 1e-5);
}