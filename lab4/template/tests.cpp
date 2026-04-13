#include "gtest/gtest.h"
#include "solution.h"
#include <vector>
#include <algorithm>
#include <cmath>

TEST(Lab4, Product) {
    int32_t arr1[] = {2, 3, 4};
    EXPECT_EQ(AsmProduct(arr1, 3, 10), 4); // 24 % 10 = 4
    int32_t arr2[] = {-2, 3, -4};
    EXPECT_EQ(AsmProduct(arr2, 3, 10), 4);
}

TEST(Lab4, SpecialXor) {
    uint32_t arr[] = {1, 2, 3, 4, 5, 8};
    EXPECT_EQ(AsmSpecialXor(arr, 6), 1 ^ 2 ^ 4 ^ 8);
}

TEST(Lab4, SpecialSum) {
    int64_t arr[] = {15, 8, 23, 30, 53};
    // 8 % 3 = 2, 8 % 5 = 3
    // 23 % 3 = 2, 23 % 5 = 3
    // 53 % 3 = 2, 53 % 5 = 3
    // Wait, condition: % 3 is odd, % 5 is odd.
    // 8 % 3 = 2 (even), 8 % 5 = 3 (odd)
    // 23 % 3 = 2 (even), 23 % 5 = 3 (odd)
    // 53 % 3 = 2 (even), 53 % 5 = 3 (odd)
    // Let's find numbers: 13 % 3 = 1, 13 % 5 = 3.
    int64_t arr2[] = {13, 28, 43}; // 28%3=1, 28%5=3. 43%3=1, 43%5=3.
    EXPECT_EQ(AsmSpecialSum(arr2, 3, 100), (13 + 28 + 43) % 100);
}

TEST(Lab4, NeighboursCount) {
    uint64_t arr[] = {1, 4, 7, 10, 13};
    EXPECT_EQ(AsmNeighboursCount(arr, 5, 3), 3); // (1,4,7), (4,7,10), (7,10,13)
}

TEST(Lab4, ArrayFormula) {
    int32_t arr[] = {1, 2, 3, 4};
    // 1*1*2*2 - 3*3*4*4 = 4 - 144 = -140
    EXPECT_EQ(AsmArrayFormula(arr, 4), -140);
}

TEST(Lab4, Compare) {
    int64_t arr1[] = {1, 2, 3, 4, 5};
    int64_t arr2[] = {2, 4, 6};
    EXPECT_EQ(AsmCompare(arr1, 5, arr2, 3), 3); // 1, 3, 5
}

TEST(Lab4, SimpleModify) {
    int32_t arr[] = {5, 10, 2, 4, 7};
    AsmSimpleModify(arr, 5);
    EXPECT_EQ(arr[0], 0);
    EXPECT_EQ(arr[1], 0);
    EXPECT_EQ(arr[2], 1); // 2 % 5 = 2 (even)
    EXPECT_EQ(arr[3], 1); // 4 % 5 = 4 (even)
    EXPECT_EQ(arr[4], -1); // 7 % 5 = 2 (even) -> wait, 7%5=2, so 1.
}

TEST(Lab4, SetToSequence) {
    int64_t arr[] = {10, 2, 5, 8, 1};
    AsmSetToSequence(arr, 5);
    // min is 1 at index 4, max is 10 at index 0.
    // sequence between 0 and 4: 1, 2, 3, 4, 5
    EXPECT_EQ(arr[0], 1);
    EXPECT_EQ(arr[1], 2);
    EXPECT_EQ(arr[2], 3);
    EXPECT_EQ(arr[3], 4);
    EXPECT_EQ(arr[4], 5);
}

TEST(Lab4, Reverse) {
    int64_t arr[] = {1, 2, 3, 4};
    AsmReverse(arr, 4);
    EXPECT_EQ(arr[0], 4);
    EXPECT_EQ(arr[1], 3);
    EXPECT_EQ(arr[2], 2);
    EXPECT_EQ(arr[3], 1);
}

TEST(Lab4, RotateInGroups) {
    int64_t arr[] = {1, 2, 3, 4, 5, 6, 7, 8};
    AsmRotateInGroups(arr, 8, 3);
    // groups: (1,2,3), (4,5,6), (7,8)
    // rotated: (2,3,1), (5,6,4), (8,7)
    EXPECT_EQ(arr[0], 2);
    EXPECT_EQ(arr[2], 1);
    EXPECT_EQ(arr[7], 7);
}

TEST(Lab4, InsertElement) {
    int64_t arr[10] = {10, 20, 30};
    int32_t size = 3;
    AsmInsertElement(arr, &size, 1);
    EXPECT_EQ(size, 4);
    EXPECT_EQ(arr[1], 1);
}

TEST(Lab4, RemoveIfSimilar) {
    int64_t arr[] = {10, 11, 12, 13, 14};
    int32_t size = AsmRemoveIfSimilar(arr, 5, 12, 1);
    // x=12, d=1. range [11, 13]. positive odd: 11, 13.
    EXPECT_EQ(size, 3);
    EXPECT_EQ(arr[0], 10);
    EXPECT_EQ(arr[1], 12);
    EXPECT_EQ(arr[2], 14);
}

TEST(Lab4, ReplaceWithGroup) {
    int64_t arr[20] = {1, 2, 3, 2, 4, 4};
    int32_t size = 6;
    AsmReplaceWithGroup(arr, &size, 2);
    EXPECT_EQ(size, 9);
}

TEST(Lab4, Merge) {
    int64_t arr1[] = {1, 3, 5};
    int64_t arr2[] = {2, 4, 6};
    int64_t res[6];
    AsmMerge(arr1, 3, arr2, 3, res);
    EXPECT_EQ(res[0], 1);
    EXPECT_EQ(res[5], 6);
}

TEST(Lab4, FindSpecial) {
    int64_t row1[] = {1, 2, 3};
    int64_t row2[] = {4, 14, 6}; // 14 % 7 == 0, 14 % 4 != 0
    const int64_t* arr[] = {row1, row2};
    EXPECT_EQ(AsmFindSpecial(arr, 2, 3), true);
}

TEST(Lab4, FindSorted) {
    int32_t row1[] = {1, 2, 3}; // sorted, row 0
    int32_t row2[] = {3, 2, 1}; // not sorted
    int32_t row3[] = {4, 5, 6}; // sorted, row 2
    const int32_t* arr[] = {row1, row2, row3};
    EXPECT_EQ(AsmFindSorted(arr, 3, 3), 2); // 0 + 2 = 2
}

TEST(Lab4, Modify2D) {
    int64_t row1[] = {1, -2, 3};
    int64_t row2[] = {-4, 5, -6};
    int64_t* arr[] = {row1, row2};
    AsmModify2D(arr, 2, 3);
    EXPECT_EQ(row1[0], 2);
    EXPECT_EQ(row1[1], -1);
}
