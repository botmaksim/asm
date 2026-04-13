#include "gtest/gtest.h"
#include "solution.h"
#include <cstring>
#include <string>

// ---------------------------------------------------------

TEST(Lab6, StrLen) {
    EXPECT_EQ(AsmStrLen(""), 0);
    EXPECT_EQ(AsmStrLen("a"), 1);
    EXPECT_EQ(AsmStrLen("hello"), 5);
    EXPECT_EQ(AsmStrLen("hello world"), 11);
}

TEST(Lab6, StrChr) {
    const char* s = "hello world";
    EXPECT_EQ(AsmStrChr(s, 'h'), s);
    EXPECT_EQ(AsmStrChr(s, 'o'), s + 4);
    EXPECT_EQ(AsmStrChr(s, 'd'), s + 10);
    EXPECT_EQ(AsmStrChr(s, 'x'), nullptr);
    EXPECT_EQ(AsmStrChr(s, '\0'), s + 11);
}

TEST(Lab6, StrCpy) {
    char dst[20];
    AsmStrCpy(dst, "hello");
    EXPECT_STREQ(dst, "hello");
    AsmStrCpy(dst, "");
    EXPECT_STREQ(dst, "");
}

TEST(Lab6, StrNCpy) {
    char dst[20] = "xxxxxxxxxxxxxxx";
    AsmStrNCpy(dst, "hello", 3);
    EXPECT_EQ(dst[0], 'h');
    EXPECT_EQ(dst[1], 'e');
    EXPECT_EQ(dst[2], 'l');
    EXPECT_EQ(dst[3], 'x');

    AsmStrNCpy(dst, "hi", 5);
    EXPECT_STREQ(dst, "hi");
    EXPECT_EQ(dst[3], '\0');
    EXPECT_EQ(dst[4], '\0');
}

TEST(Lab6, StrCmp) {
    EXPECT_EQ(AsmStrCmp("hello", "hello"), 0);
    EXPECT_LT(AsmStrCmp("abc", "abd"), 0);
    EXPECT_GT(AsmStrCmp("abd", "abc"), 0);
    EXPECT_LT(AsmStrCmp("a", "aa"), 0);
    EXPECT_GT(AsmStrCmp("aa", "a"), 0);
    EXPECT_EQ(AsmStrCmp("", ""), 0);
}

TEST(Lab6, StrCat) {
    char dst[20] = "hello";
    EXPECT_EQ(AsmStrCat(dst, " world"), dst);
    EXPECT_STREQ(dst, "hello world");
    EXPECT_EQ(AsmStrCat(dst, ""), dst);
    EXPECT_STREQ(dst, "hello world");
}

TEST(Lab6, StrStr) {
    const char* s = "hello world";
    EXPECT_EQ(AsmStrStr(s, "hello"), s);
    EXPECT_EQ(AsmStrStr(s, "world"), s + 6);
    EXPECT_EQ(AsmStrStr(s, "o w"), s + 4);
    EXPECT_EQ(AsmStrStr(s, "x"), nullptr);
    EXPECT_EQ(AsmStrStr(s, ""), s);
}

TEST(Lab6, StrToInt64) {
    EXPECT_EQ(AsmStrToInt64("0"), 0);
    EXPECT_EQ(AsmStrToInt64("123"), 123);
    EXPECT_EQ(AsmStrToInt64("-123"), -123);
    EXPECT_EQ(AsmStrToInt64("9223372036854775807"), 9223372036854775807LL);
    EXPECT_EQ(AsmStrToInt64("-9223372036854775808"), -9223372036854775807LL - 1);
}

TEST(Lab6, IntToStr64) {
    char s[100];
    AsmIntToStr64(0, 10, s);
    EXPECT_STREQ(s, "0");
    AsmIntToStr64(123, 10, s);
    EXPECT_STREQ(s, "123");
    AsmIntToStr64(-123, 10, s);
    EXPECT_STREQ(s, "-123");
    AsmIntToStr64(255, 16, s);
    EXPECT_STREQ(s, "ff");
    AsmIntToStr64(-255, 16, s);
    EXPECT_STREQ(s, "-ff");
    AsmIntToStr64(9223372036854775807LL, 10, s);
    EXPECT_STREQ(s, "9223372036854775807");
}

TEST(Lab6, SafeStrToUInt64) {
    uint64_t result;
    EXPECT_TRUE(AsmSafeStrToUInt64("0", &result));
    EXPECT_EQ(result, 0);
    EXPECT_TRUE(AsmSafeStrToUInt64("123", &result));
    EXPECT_EQ(result, 123);
    EXPECT_TRUE(AsmSafeStrToUInt64("18446744073709551615", &result));
    EXPECT_EQ(result, 18446744073709551615ULL);
    
    EXPECT_FALSE(AsmSafeStrToUInt64("18446744073709551616", &result)); // Overflow
    EXPECT_FALSE(AsmSafeStrToUInt64("-1", &result)); // Negative
    EXPECT_FALSE(AsmSafeStrToUInt64("123a", &result)); // Invalid char
}

// ---------------------------------------------------------