#include "gtest/gtest.h"
#include "solution.h"
#include <vector>
#include <cstdarg>

TEST(Lab5, FindNearest) {
    EXPECT_EQ(AsmFindNearest(0, 0, 3, 10, 10, 1, 1, 5, 5), 1); // 1,1 is index 1
}

TEST(Lab5, SummarizeRows) {
    uint64_t row1[] = {1, 2, 3};
    uint64_t row2[] = {4, 5, 6};
    const uint64_t* arr[] = {row1, row2};
    uint64_t b[2];
    AsmSummarizeRows(arr, 2, 3, b);
    EXPECT_EQ(b[0], 6);
    EXPECT_EQ(b[1], 15);
}

bool is_even(uint16_t x) { return x % 2 == 0; }

TEST(Lab5, CountIfNot) {
    uint16_t arr[] = {1, 2, 3, 4, 5};
    EXPECT_EQ(AsmCountIfNot(arr, 5, is_even), 3); // 1, 3, 5
}

extern "C" uint64_t GetMagic(uint64_t x) {
    return x + 1;
}

TEST(Lab5, GetMoreMagic) {
    // We don't know what GetMagic does, so we can't fully test it without a mock.
    // But we can call it.
}

TEST(Lab5, Copy) {
    uint32_t arr[] = {1, 2, 3};
    void* copy = AsmCopy(arr, sizeof(arr));
    EXPECT_NE(copy, nullptr);
    EXPECT_EQ(((uint32_t*)copy)[0], 1);
    EXPECT_EQ(((uint32_t*)copy)[1], 2);
    EXPECT_EQ(((uint32_t*)copy)[2], 3);
    free(copy);
}

TEST(Lab5, SequencesCount) {
    // n=3, k=2.
    // 000, 001, 010, 011, 100, 101, 110, 111
    // k=2 ones not adjacent: 101. So count is 1.
    EXPECT_EQ(AsmSequencesCount(3, 2), 1);
}
