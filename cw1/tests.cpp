#include "solution.h"

#include <algorithm>
#include <memory>

#include "utils/asm_utils.h"
#include "utils/utils.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

namespace {

// ===========================================================================

const uint64_t kModule = 104042026;

uint32_t SimpleFnWrapper(uint32_t a, uint32_t b, uint32_t c) {
  return RunAsmFunctionWithChecks<kInt32Mask, kInt32Mask, kInt32Mask>(
      (void *)AsmSimpleFn, (uint64_t)a, (uint64_t)b, (uint64_t)c);
}

uint32_t CppSimpleFn(int64_t a, int64_t b, int64_t c) {
  assert((a >= 0) && (b >= 0) && (c >= 0));
  int64_t t = GetByModule(12ll + 2ll * b + c, kModule);
  t = GetByModule(t * t, kModule);
  return GetByModule(a * t, kModule);
}

ASM_TEST_V(V1, SimpleFn, Sample_Small) {
  EXPECT_EQ(SimpleFn(0, 0, 0), 0);
  EXPECT_EQ(SimpleFn(1, 2, 3), 361);
  EXPECT_EQ(SimpleFn(4, 5, 6), 3136);
}

ASM_TEST_V(V1, SimpleFn, Sample_Large) {
  EXPECT_EQ(SimpleFn(123, 456, 7890123), 20118765);
  EXPECT_EQ(SimpleFn(1'000, 1'000'000, 1'000'000'000), 10767416);
}

ASM_TEST_V(V1, SimpleFn, Random_Small) {
  for (int t = 0; t < 1'000'000; ++t) {
    uint32_t a = SRandom64(0, 42);
    uint32_t b = SRandom64(0, 42);
    uint32_t c = SRandom64(0, 42);
    ASSERT_EQ(SimpleFn(a, b, c), CppSimpleFn(a, b, c));
  }
}

ASM_TEST_V(V1, SimpleFn, Random_Medium) {
  for (int t = 0; t < 1'000'000; ++t) {
    uint32_t a = SRandom64(123, 45678);
    uint32_t b = SRandom64(123, 45678);
    uint32_t c = SRandom64(123, 45678);
    ASSERT_EQ(SimpleFn(a, b, c), CppSimpleFn(a, b, c));
  }
}

ASM_TEST_V(V1, SimpleFn, Random_Large) {
  for (int t = 0; t < 1'000'000; ++t) {
    uint32_t a = SRandom64(INT32_MAX / 2, UINT32_MAX - 100);
    uint32_t b = SRandom64(INT32_MAX / 2, UINT32_MAX - 100);
    uint32_t c = SRandom64(INT32_MAX / 2, UINT32_MAX - 100);
    ASSERT_EQ(SimpleFn(a, b, c), CppSimpleFn(a, b, c));
  }
}

// ===========================================================================

uint32_t CppSimpleFn_NoMulA(int64_t a, int64_t b, int64_t c) {
  assert((a >= 0) && (b >= 0) && (c >= 0));
  int64_t t = GetByModule(12ll + 2ll * b + c, kModule);
  t = GetByModule(t * t, kModule);
  return t;
}

ASM_TEST_V(V1_NoMulA, SimpleFn, Sample_Small) {
  EXPECT_EQ(SimpleFn(0, 0, 0), 144);
  EXPECT_EQ(SimpleFn(1, 2, 3), 361);
  EXPECT_EQ(SimpleFn(4, 5, 6), 784);
}

ASM_TEST_V(V1_NoMulA, SimpleFn, Sample_Large) {
  EXPECT_EQ(SimpleFn(123, 456, 7890123), 19152709);
  EXPECT_EQ(SimpleFn(1'000, 1'000'000, 1'000'000'000), 12046804);
}

ASM_TEST_V(V1_NoMulA, SimpleFn, Random_Small) {
  for (int t = 0; t < 1'000'000; ++t) {
    uint32_t a = SRandom64(0, 42);
    uint32_t b = SRandom64(0, 42);
    uint32_t c = SRandom64(0, 42);
    ASSERT_EQ(SimpleFn(a, b, c), CppSimpleFn_NoMulA(a, b, c));
  }
}

ASM_TEST_V(V1_NoMulA, SimpleFn, Random_Medium) {
  for (int t = 0; t < 1'000'000; ++t) {
    uint32_t a = SRandom64(123, 45678);
    uint32_t b = SRandom64(123, 45678);
    uint32_t c = SRandom64(123, 45678);
    ASSERT_EQ(SimpleFn(a, b, c), CppSimpleFn_NoMulA(a, b, c));
  }
}

ASM_TEST_V(V1_NoMulA, SimpleFn, Random_Large) {
  for (int t = 0; t < 1'000'000; ++t) {
    uint32_t a = SRandom64(INT32_MAX / 2, UINT32_MAX - 100);
    uint32_t b = SRandom64(INT32_MAX / 2, UINT32_MAX - 100);
    uint32_t c = SRandom64(INT32_MAX / 2, UINT32_MAX - 100);
    ASSERT_EQ(SimpleFn(a, b, c), CppSimpleFn_NoMulA(a, b, c));
  }
}

// ===========================================================================

const char *kOverflow = "Overflow";
const char *kNoOverflow = "None";

const char *OverflowWrapper(uint32_t x) {
  return (const char *)RunAsmFunctionWithChecks<kInt32Mask, 0, 0>(
      (void *)AsmOverflow, (uint64_t)x);
}

const char *CppOverflow(uint32_t x) {
  if ((x > INT32_MAX) ||
      ((uint64_t)x * (uint64_t)(x + 3) > (uint64_t)INT32_MAX)) {
    return kOverflow;
  } else {
    return kNoOverflow;
  }
}

ASM_TEST_V(V1, Overflow, Sample) {
  EXPECT_STREQ(Overflow(0), kNoOverflow);
  EXPECT_STREQ(Overflow(42), kNoOverflow);
  EXPECT_STREQ(Overflow(123), kNoOverflow);
  EXPECT_STREQ(Overflow(1'000'000), kOverflow);
  EXPECT_STREQ(Overflow(2'000'000), kOverflow);
}

ASM_TEST_V(V1, Overflow, Random_Small) {
  for (int x = 0; x < 1'000; ++x) {
    ASSERT_STREQ(Overflow(x), CppOverflow(x));
  }
}

ASM_TEST_V(V1, Overflow, Random_Medium) {
  for (int x = 0; x < 1'000'000; ++x) {
    ASSERT_STREQ(Overflow(x), CppOverflow(x));
  }
}

ASM_TEST_V(V1, Overflow, Random_Large) {
  for (int t = 0; t < 123456; ++t) {
    uint32_t x = SRandom64(INT32_MAX / 2, UINT32_MAX);
    ASSERT_STREQ(Overflow(x), CppOverflow(x));
  }
}

// ===========================================================================

int64_t FxyWrapper(int32_t x, int32_t y) {
  return (int64_t)RunAsmFunctionWithChecks<kInt32Mask, kInt32Mask, 0>(
      (void *)AsmFxy, (uint64_t)x, (uint64_t)y);
}

int64_t CppFxy(int32_t x, int32_t y) {
  assert(y > 0);

  int64_t result = 0;
  int64_t x_pow = 1;
  int64_t coeff = -1;

  for (int i = 0; i < y; ++i) {
    coeff = -coeff;
    assert(!__builtin_mul_overflow(x_pow, x, &x_pow));

    int64_t value;
    assert(!__builtin_mul_overflow(coeff, x_pow, &value));
    assert(!__builtin_add_overflow(result, value, &result));
  }

  return result;
}

ASM_TEST_V(V1, Fxy, Trivial) {
  std::vector<std::pair<int32_t, uint16_t>> testcases = {
      {1, 1},
      {1, 2},
      {5, 3},
      {2, 4},
  };
  for (const auto &t : testcases) {
    ASSERT_EQ(Fxy(t.first, t.second), CppFxy(t.first, t.second))
        << "x=" << t.first << " y=" << t.second << '\n';
  }
}

ASM_TEST_V(V1, Fxy, Positives) {
  std::vector<std::pair<int32_t, int32_t>> testcases = {
      {0, 1},  {0, 1024}, {1, 1},  {1, 2},  {1, 4096},
      {2, 16}, {2, 31},   {2, 32}, {2, 48}, {2, 60},
  };
  for (const auto &t : testcases) {
    ASSERT_EQ(Fxy(t.first, t.second), CppFxy(t.first, t.second))
        << "x=" << t.first << " y=" << t.second << '\n';
  }
}

ASM_TEST_V(V1, Fxy, Negatives) {
  std::vector<std::pair<int32_t, uint16_t>> testcases = {
      {0, 1},   {0, 1024}, {-1, 1},  {-1, 2},  {-1, 4096},
      {-2, 16}, {-2, 31},  {-2, 32}, {-2, 48}, {-2, 60},
  };
  for (const auto &t : testcases) {
    ASSERT_EQ(Fxy(t.first, t.second), CppFxy(t.first, t.second))
        << "x=" << t.first << " y=" << t.second << '\n';
  }
}

ASM_TEST_V(V1, Fxy, Random) {
  for (int test_no = 0; test_no < 1'000; ++test_no) {
    int32_t x = SRandom64(-100, 100);
    int32_t y = SRandom64(1, 8);
    ASSERT_EQ(Fxy(x, y), CppFxy(x, y)) << "x=" << x << " y=" << y << '\n';
  }
}

// ===========================================================================

int64_t ArrayWrapper(const int16_t *array, int16_t size) {
  return (int64_t)RunAsmFunctionWithChecks<kInt64Mask, kInt16Mask, 0>(
      (void *)AsmArray, (uint64_t)array, (uint64_t)size);
}

int64_t CppArray(const int16_t *array, int16_t size) {
  assert(size >= 0);

  int64_t result = 0;

  for (int i = 0; i < size; ++i) {
    if (array[i] > i) {
      assert(!__builtin_add_overflow(result, array[i], &result));
    }
  }

  return result;
}

ASM_TEST_V(V1, Array, Sample) {
  std::vector<std::vector<int16_t>> testcases = {
      {42, 43},
      {1, 2, 3, 4, 5},
      {0, 1, 2, 3, 4, 5},
      {-1, 0, 1, 2, 3, 4, 5},
      {-1, -2, -3, -4, -5},
  };
  for (const auto &testcase : testcases) {
    RUN_ON_RO_ARRAY(int16_t, testcase, [&](const int16_t *ptr, size_t n) {
      ASSERT_EQ(Array(ptr, n), CppArray(ptr, n));
    });
  }
}

ASM_TEST_V(V1, Array, Small) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int16_t> testcase = RandomInt16Array(SRandom64(1, 100), 0, 200);
    RUN_ON_RO_ARRAY(int16_t, testcase, [&](const int16_t *ptr, size_t n) {
      ASSERT_EQ(Array(ptr, n), CppArray(ptr, n));
    });
  }
}

ASM_TEST_V(V1, Array, Large) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int16_t> testcase =
        RandomInt16Array(SRandom64(1000, INT16_MAX));
    RUN_ON_RO_ARRAY(int16_t, testcase, [&](const int16_t *ptr, size_t n) {
      ASSERT_EQ(Array(ptr, n), CppArray(ptr, n));
    });
  }
}

// ===========================================================================

int64_t EvenOddWrapper(int64_t *array, int64_t size) {
  return (int64_t)RunAsmFunctionWithChecks<kInt64Mask, kInt64Mask, 0>(
      (void *)AsmEvenOdd, (uint64_t)array, (uint64_t)size);
}

std::vector<int64_t> CppEvenOdd(const std::vector<int64_t> &array) {
  std::vector<int64_t> result;
  for (int64_t element : array) {
    if (element % 2 == 0) {
      result.push_back(element / 2);
    }
  }
  return result;
}

ASM_TEST_V(V1, EvenOdd, Sample) {
  std::vector<std::vector<int64_t>> testcases = {
      {42, 43},
      {1, 2, 3, 4, 5},
      {0, 1, 2, 3, 4, 5},
      {-1, 0, 1, 2, 3, 4, 5},
      {-1, -2, -3, -4, -5},
  };
  for (const auto &input : testcases) {
    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, EvenPositives) {
  for (int test_no = 0; test_no < 1000; ++test_no) {
    std::vector<int64_t> input = RandomInt64Array(SRandom32(1, 1000), 1, 10000);
    for (int64_t &element : input) {
      element *= 2;
    }

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, EvenNegatives) {
  for (int test_no = 0; test_no < 1000; ++test_no) {
    std::vector<int64_t> input =
        RandomInt64Array(SRandom32(1, 1000), -1000, -1);
    for (int64_t &element : input) {
      element *= 2;
    }

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, Positives) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int64_t> input =
        RandomInt64Array(SRandom32(1, 100'000), 1, 10000);

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, Negatives) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int64_t> input =
        RandomInt64Array(SRandom32(1, 100'000), -1000, -1);

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, LargePositives) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int64_t> input =
        RandomInt64Array(SRandom32(1, 100'000), INT32_MAX, INT64_MAX);

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, LargeNegatives) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int64_t> input =
        RandomInt64Array(SRandom32(1, 100'000), INT64_MIN, INT32_MIN);

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, CompletelyRandom) {
  for (int test_no = 0; test_no < 100; ++test_no) {
    std::vector<int64_t> input =
        RandomInt64Array(SRandom32(1, 100'000), INT64_MIN + 10, INT64_MAX - 10);

    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

ASM_TEST_V(V1, EvenOdd, AnswerIsEmpty) {
  std::vector<std::vector<int64_t>> testcases = {
      {-1, -3, -5, -7, -9},
      {1, 3, 5, 7, 9},
      {-1, -3, -9223372036854775807, -7, -9},
      {1, 3, 5, 9223372036854775807, 9},
      {-1, -3, -9223372036854775807, -7, -9},
      {1, 3, 5, 9223372036854775807, 9, 1, 3, 5, 9223372036854775807, 9},
      {},
  };
  for (const auto &input : testcases) {
    std::vector<int64_t> work_array = AddNumericArrayBorders(input);
    int64_t output_size =
        EvenOdd(work_array.data() + kNumericArrayBorderSize, input.size());
    std::vector<int64_t> output;
    ASSERT_TRUE(RemoveNumericArrayBorders(work_array, &output));
    ASSERT_LE(output_size, output.size());
    output.resize(output_size);

    std::vector<int64_t> answer = CppEvenOdd(input);

    ASSERT_THAT(output, testing::ElementsAreArray(answer));
  }
}

// ===========================================================================

enum class AlphaTestingMode { kSample, kFormula, kCondition, kYetAnotherTest };

AlphaTestingMode alpha_testing_mode = AlphaTestingMode::kSample;
bool alpha_testing_enable_junk = false;

} // anonymous namespace

extern "C" int64_t Gamma(int64_t x) {
  if (alpha_testing_enable_junk) {
    JunkRegisters();
  }
  switch (alpha_testing_mode) {
  case AlphaTestingMode::kSample: {
    return x * 2 + 42;
    break;
  }
  case AlphaTestingMode::kFormula: {
    return x * x + x * 123 - 17;
    break;
  }
  case AlphaTestingMode::kCondition: {
    return (x > 0) ? 1 : 0;
    break;
  }
  case AlphaTestingMode::kYetAnotherTest: {
    return x;
    break;
  }
  }
  return 42;
}

namespace {

int64_t Delta(int64_t x) {
  if (alpha_testing_enable_junk) {
    JunkRegisters();
  }
  switch (alpha_testing_mode) {
  case AlphaTestingMode::kSample: {
    return -x;
    break;
  }
  case AlphaTestingMode::kFormula: {
    return x / 2 + 42;
    break;
  }
  case AlphaTestingMode::kCondition: {
    return (x) ? x : -17;
    break;
  }
  case AlphaTestingMode::kYetAnotherTest: {
    return (x > 0) ? -12345 : 12345;
    break;
  }
  }
  return 42;
}

int64_t CppAlpha(int64_t x, int64_t y, int64_t z) {
  return Gamma(x) + std::min(std::min(y, z), Delta(Gamma(x)));
}

SAFE_TEST_V(V1, Alpha, Sample) {
  alpha_testing_enable_junk = false;
  alpha_testing_mode = AlphaTestingMode::kSample;
  ASSERT_EQ(AsmAlpha(1, 2, 3, Delta), CppAlpha(1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, 22, 1, Delta), CppAlpha(333, 22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, 33, Delta), CppAlpha(11, 22, 33));
}

SAFE_TEST_V(V1, Alpha, Main_Regular) {
  alpha_testing_enable_junk = false;

  alpha_testing_mode = AlphaTestingMode::kSample;
  ASSERT_EQ(AsmAlpha(1, 2, 3, Delta), CppAlpha(1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, 22, 1, Delta), CppAlpha(333, 22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, 33, Delta), CppAlpha(11, 22, 33));

  alpha_testing_mode = AlphaTestingMode::kFormula;
  ASSERT_EQ(AsmAlpha(-1, 2, 3, Delta), CppAlpha(-1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, -33, Delta), CppAlpha(11, 22, -33));
  ASSERT_EQ(AsmAlpha(1, 2, -3, Delta), CppAlpha(1, 2, -3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(-11, 22, 33, Delta), CppAlpha(-11, 22, 33));

  alpha_testing_mode = AlphaTestingMode::kCondition;
  ASSERT_EQ(AsmAlpha(-1, 2, 3, Delta), CppAlpha(-1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, -33, Delta), CppAlpha(11, 22, -33));
  ASSERT_EQ(AsmAlpha(1, 2, -3, Delta), CppAlpha(1, 2, -3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(-11, 22, 33, Delta), CppAlpha(-11, 22, 33));

  alpha_testing_mode = AlphaTestingMode::kYetAnotherTest;
  ASSERT_EQ(AsmAlpha(-1, 2, 3, Delta), CppAlpha(-1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, -33, Delta), CppAlpha(11, 22, -33));
  ASSERT_EQ(AsmAlpha(1, 2, -3, Delta), CppAlpha(1, 2, -3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(-11, 22, 33, Delta), CppAlpha(-11, 22, 33));
}

SAFE_TEST_V(V1, Alpha, Main_WithJunk) {
  alpha_testing_enable_junk = true;

  alpha_testing_mode = AlphaTestingMode::kSample;
  ASSERT_EQ(AsmAlpha(1, 2, 3, Delta), CppAlpha(1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, 22, 1, Delta), CppAlpha(333, 22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, 33, Delta), CppAlpha(11, 22, 33));

  alpha_testing_mode = AlphaTestingMode::kFormula;
  ASSERT_EQ(AsmAlpha(-1, 2, 3, Delta), CppAlpha(-1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, -33, Delta), CppAlpha(11, 22, -33));
  ASSERT_EQ(AsmAlpha(1, 2, -3, Delta), CppAlpha(1, 2, -3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(-11, 22, 33, Delta), CppAlpha(-11, 22, 33));

  alpha_testing_mode = AlphaTestingMode::kCondition;
  ASSERT_EQ(AsmAlpha(-1, 2, 3, Delta), CppAlpha(-1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, -33, Delta), CppAlpha(11, 22, -33));
  ASSERT_EQ(AsmAlpha(1, 2, -3, Delta), CppAlpha(1, 2, -3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(-11, 22, 33, Delta), CppAlpha(-11, 22, 33));

  alpha_testing_mode = AlphaTestingMode::kYetAnotherTest;
  ASSERT_EQ(AsmAlpha(-1, 2, 3, Delta), CppAlpha(-1, 2, 3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(11, 22, -33, Delta), CppAlpha(11, 22, -33));
  ASSERT_EQ(AsmAlpha(1, 2, -3, Delta), CppAlpha(1, 2, -3));
  ASSERT_EQ(AsmAlpha(333, -22, 1, Delta), CppAlpha(333, -22, 1));
  ASSERT_EQ(AsmAlpha(-11, 22, 33, Delta), CppAlpha(-11, 22, 33));
}

// ===========================================================================

uint64_t RecursionWrapper(int16_t m, uint64_t n) {
  assert(m > 0);
  return RunAsmFunctionWithChecks<kInt16Mask, kInt64Mask, 0>(
      (void *)AsmRecursion, (uint64_t)m, (uint64_t)n);
}

int64_t CppRecursion(int64_t m, int64_t n) {
  assert(m > 0 && m <= INT16_MAX);
  if (n <= 0) {
    return 5;
  } else {
    int64_t a = CppRecursion(m, n - 3);
    int64_t b = CppRecursion(m, n / 2);
    int64_t c = CppRecursion(m, n - 1);
    return GetByModule(a + b * c, m);
  }
}

ASM_TEST_V(V1, Recursion, Small) {
  EXPECT_EQ(Recursion(32000, 0), 5);
  EXPECT_EQ(Recursion(32000, 1), 30);
  EXPECT_EQ(Recursion(32000, 2), 905);
  EXPECT_EQ(Recursion(32000, 3), 27155);
}

ASM_TEST_V(V1, Recursion, Large) {
  for (int n = 0; n < 42; ++n) {
    for (int test_no = 0; test_no < 5; ++test_no) {
      int16_t m = SRandom32(1, INT16_MAX);
      ASSERT_EQ(Recursion(m, n), CppRecursion(m, n))
          << "m=" << m << " n=" << n << '\n';
    }
  }
}

// ===========================================================================

void Array2dWrapper(int64_t **array, int64_t rows_count,
                    int64_t columns_count) {
  assert(rows_count >= 0 && columns_count >= 0);
  RunAsmFunctionWithChecks<kInt64Mask, kInt64Mask, kInt64Mask>(
      (void *)Asm2d, (uint64_t)array, rows_count, columns_count);
}

//.............................................................................
// Option 1: Ignore out-of-bounds checks

struct Array2dBypassDirection {
  int i_begin;
  int i_step;
  int i_finish;
  int j_begin;
  int j_step;
  int j_finish;
};

std::vector<Array2dBypassDirection>
GetArray2dBypassDirections(const std::vector<std::vector<int64_t>> &array) {
  return {
      Array2dBypassDirection{0, 1, (int)array.size(), 0, 1,
                             (int)array[0].size()},
      Array2dBypassDirection{0, 1, (int)array.size(), (int)array[0].size() - 1,
                             -1, -1},
      Array2dBypassDirection{(int)array.size() - 1, -1, -1, 0, 1,
                             (int)array[0].size()},
      Array2dBypassDirection{(int)array.size() - 1, -1, -1,
                             (int)array[0].size() - 1, -1, -1},
  };
}

bool CppArray2d_Ignore(std::vector<std::vector<int64_t>> *array,
                       Array2dBypassDirection direction) {
  assert(!array->empty());
  int m = (*array)[0].size();

  const auto &out_of_borders = [&](int i, int j) {
    return (i < 0 || i >= array->size() || j < 0 || j >= m);
  };

  bool has_changes = false;
  for (int i = direction.i_begin; i != direction.i_finish;
       i += direction.i_step) {
    assert((*array)[i].size() == m);
    for (int j = direction.j_begin; j != direction.j_finish;
         j += direction.j_step) {
      int64_t element = (*array)[i][j];

      if (!out_of_borders(i - 1, j) && element >= (*array)[i - 1][j]) {
        continue;
      }
      if (!out_of_borders(i + 1, j) && element >= (*array)[i + 1][j]) {
        continue;
      }
      if (!out_of_borders(i, j - 1) && element >= (*array)[i][j - 1]) {
        continue;
      }
      if (!out_of_borders(i, j + 1) && element >= (*array)[i][j + 1]) {
        continue;
      }

      (*array)[i][j] = 42;
      has_changes = true;
    }
  }

  return has_changes;
}

ASM_TEST_N(Array2d_V1_Ignore, Sample, Array2d, Asm2d, Array2dWrapper) {
  std::vector<std::vector<int64_t>> golden_data = {
      {11, 22, 33, 44, 55},   {11, 1, 33, 2, 55},   {11, 22, 44444, 44, 55},
      {11, -10, 33, 735, 55}, {11, 22, 33, 44, 55},
  };
  int rows_count = golden_data.size();
  int columns_count = golden_data[0].size();

  auto **ptr = new int64_t *[rows_count];
  for (int i = 0; i < rows_count; ++i) {
    ptr[i] = new int64_t[columns_count];
    for (int j = 0; j < columns_count; ++j) {
      ptr[i][j] = golden_data[i][j];
    }
  }

  Array2d(ptr, rows_count, columns_count);

  bool test_passed = false;
  for (auto direction : GetArray2dBypassDirections(golden_data)) {
    auto data = golden_data;
    bool has_changes = CppArray2d_Ignore(&data, direction);
    (void)has_changes;
    // assert(has_changes);

    bool subtest_passed = true;
    for (int i = 0; i < rows_count && subtest_passed; ++i) {
      for (int j = 0; j < columns_count; ++j) {
        if (ptr[i][j] != data[i][j]) {
          subtest_passed = false;
          break;
        }
      }
    }

    if (subtest_passed) {
      test_passed = true;
      break;
    }
  }

  ASSERT_TRUE(test_passed);

  for (int i = 0; i < rows_count; ++i) {
    delete[] ptr[i];
  }
  delete[] ptr;
}

ASM_TEST_N(Array2d_V1_Ignore, Small, Array2d, Asm2d, Array2dWrapper) {
  for (int test_i = 0; test_i < 50; ++test_i) {
    int32_t rows_count = SRandom64(1, 50);
    int32_t columns_count = SRandom64(1, 50);

    std::vector<std::vector<int64_t>> golden_data;
    for (int i = 0; i < rows_count; ++i) {
      golden_data.push_back(RandomInt64Array(columns_count, 0, 100));
    }

    auto **ptr = new int64_t *[rows_count];
    for (int i = 0; i < rows_count; ++i) {
      ptr[i] = new int64_t[columns_count];
      for (int j = 0; j < columns_count; ++j) {
        ptr[i][j] = golden_data[i][j];
      }
    }

    Array2d(ptr, rows_count, columns_count);

    bool test_passed = false;
    for (auto direction : GetArray2dBypassDirections(golden_data)) {
      auto data = golden_data;
      bool has_changes = CppArray2d_Ignore(&data, direction);
      (void)has_changes;
      // assert(has_changes);

      bool subtest_passed = true;
      for (int i = 0; i < rows_count && subtest_passed; ++i) {
        for (int j = 0; j < columns_count; ++j) {
          if (ptr[i][j] != data[i][j]) {
            subtest_passed = false;
            break;
          }
        }
      }

      if (subtest_passed) {
        test_passed = true;
        break;
      }
    }

    ASSERT_TRUE(test_passed) << "Test # " << test_i;

    for (int i = 0; i < rows_count; ++i) {
      delete[] ptr[i];
    }
    delete[] ptr;
  }
}

ASM_TEST_N(Array2d_V1_Ignore, Large, Array2d, Asm2d, Array2dWrapper) {
  for (int test_i = 0; test_i < 50; ++test_i) {
    int32_t rows_count = SRandom64(1, 100);
    int32_t columns_count = SRandom64(1, 100);

    std::vector<std::vector<int64_t>> golden_data;
    for (int i = 0; i < rows_count; ++i) {
      golden_data.push_back(
          RandomInt64Array(columns_count, INT64_MIN + 10, INT64_MAX - 10));
    }

    auto **ptr = new int64_t *[rows_count];
    for (int i = 0; i < rows_count; ++i) {
      ptr[i] = new int64_t[columns_count];
      for (int j = 0; j < columns_count; ++j) {
        ptr[i][j] = golden_data[i][j];
      }
    }

    Array2d(ptr, rows_count, columns_count);

    bool test_passed = false;
    for (auto direction : GetArray2dBypassDirections(golden_data)) {
      auto data = golden_data;
      bool has_changes = CppArray2d_Ignore(&data, direction);
      (void)has_changes;
      // assert(has_changes);

      bool subtest_passed = true;
      for (int i = 0; i < rows_count && subtest_passed; ++i) {
        for (int j = 0; j < columns_count; ++j) {
          if (ptr[i][j] != data[i][j]) {
            subtest_passed = false;
            break;
          }
        }
      }

      if (subtest_passed) {
        test_passed = true;
        break;
      }
    }

    ASSERT_TRUE(test_passed) << "Test # " << test_i;

    for (int i = 0; i < rows_count; ++i) {
      delete[] ptr[i];
    }
    delete[] ptr;
  }
}

//.............................................................................
// Option 2: If any neighbour does not exist - change to 42

bool CppArray2d_ReplaceIfNull(std::vector<std::vector<int64_t>> *array) {
  assert(!array->empty());
  int m = (*array)[0].size();

  const auto &out_of_borders = [&](int i, int j) {
    return (i < 0 || i >= array->size() || j < 0 || j >= m);
  };

  bool has_changes = false;
  for (int i = 0; i < array->size(); ++i) {
    assert((*array)[i].size() == m);
    for (int j = 0; j < m; ++j) {
      if (out_of_borders(i - 1, j) || out_of_borders(i + 1, j) ||
          out_of_borders(i, j - 1) || out_of_borders(i, j + 1)) {
        (*array)[i][j] = 42;
        has_changes = true;
        continue;
      }

      int64_t element = (*array)[i][j];
      if ((element < (*array)[i - 1][j]) && (element < (*array)[i + 1][j]) &&
          (element < (*array)[i][j - 1]) && (element < (*array)[i][j + 1])) {
        (*array)[i][j] = 42;
        has_changes = true;
      }
    }
  }

  return has_changes;
}

ASM_TEST_N(Array2d_V1_ReplaceIfNull, Sample, Array2d, Asm2d, Array2dWrapper) {
  std::vector<std::vector<int64_t>> golden_data = {
      {11, 22, 33, 44, 55},   {11, 1, 33, 2, 55},   {11, 22, 44444, 44, 55},
      {11, -10, 33, 735, 55}, {11, 22, 33, 44, 55},
  };
  int rows_count = golden_data.size();
  int columns_count = golden_data[0].size();

  auto **ptr = new int64_t *[rows_count];
  for (int i = 0; i < rows_count; ++i) {
    ptr[i] = new int64_t[columns_count];
    for (int j = 0; j < columns_count; ++j) {
      ptr[i][j] = golden_data[i][j];
    }
  }

  Array2d(ptr, rows_count, columns_count);
  bool has_changes = CppArray2d_ReplaceIfNull(&golden_data);
  assert(has_changes);

  for (int i = 0; i < rows_count; ++i) {
    for (int j = 0; j < columns_count; ++j) {
      ASSERT_THAT(ptr[i][j], golden_data[i][j]);
    }
  }

  for (int i = 0; i < rows_count; ++i) {
    delete[] ptr[i];
  }
  delete[] ptr;
}

ASM_TEST_N(Array2d_V1_ReplaceIfNull, Small, Array2d, Asm2d, Array2dWrapper) {
  for (int test_i = 0; test_i < 50; ++test_i) {
    int32_t rows_count = SRandom64(1, 50);
    int32_t columns_count = SRandom64(1, 50);

    std::vector<std::vector<int64_t>> golden_data;
    for (int i = 0; i < rows_count; ++i) {
      golden_data.push_back(RandomInt64Array(columns_count, 0, 100));
    }

    auto **ptr = new int64_t *[rows_count];
    for (int i = 0; i < rows_count; ++i) {
      ptr[i] = new int64_t[columns_count];
      for (int j = 0; j < columns_count; ++j) {
        ptr[i][j] = golden_data[i][j];
      }
    }

    Array2d(ptr, rows_count, columns_count);
    bool has_changes = CppArray2d_ReplaceIfNull(&golden_data);
    assert(has_changes);

    for (int i = 0; i < rows_count; ++i) {
      for (int j = 0; j < columns_count; ++j) {
        ASSERT_THAT(ptr[i][j], golden_data[i][j]);
      }
    }

    for (int i = 0; i < rows_count; ++i) {
      delete[] ptr[i];
    }
    delete[] ptr;
  }
}

ASM_TEST_N(Array2d_V1_ReplaceIfNull, Large, Array2d, Asm2d, Array2dWrapper) {
  for (int test_i = 0; test_i < 50; ++test_i) {
    int32_t rows_count = SRandom64(1, 100);
    int32_t columns_count = SRandom64(1, 100);

    std::vector<std::vector<int64_t>> golden_data;
    for (int i = 0; i < rows_count; ++i) {
      golden_data.push_back(
          RandomInt64Array(columns_count, INT64_MIN + 10, INT64_MAX - 10));
    }

    auto **ptr = new int64_t *[rows_count];
    for (int i = 0; i < rows_count; ++i) {
      ptr[i] = new int64_t[columns_count];
      for (int j = 0; j < columns_count; ++j) {
        ptr[i][j] = golden_data[i][j];
      }
    }

    Array2d(ptr, rows_count, columns_count);
    bool has_changes = CppArray2d_ReplaceIfNull(&golden_data);
    assert(has_changes);

    for (int i = 0; i < rows_count; ++i) {
      for (int j = 0; j < columns_count; ++j) {
        ASSERT_THAT(ptr[i][j], golden_data[i][j]);
      }
    }

    for (int i = 0; i < rows_count; ++i) {
      delete[] ptr[i];
    }
    delete[] ptr;
  }
}

// ===========================================================================

bool CppArray2dAdvanced(std::vector<std::vector<int64_t>> *array) {
  assert(!array->empty());
  int m = (*array)[0].size();

  const auto &out_of_borders = [&](int i, int j) {
    return (i < 0 || i >= array->size() || j < 0 || j >= m);
  };

  std::vector<std::vector<int64_t>> input_array = *array;

  bool has_changes = false;
  for (int i = 0; i < array->size(); ++i) {
    assert((*array)[i].size() == m);
    for (int j = 0; j < m; ++j) {
      if (out_of_borders(i - 1, j) || out_of_borders(i + 1, j) ||
          out_of_borders(i, j - 1) || out_of_borders(i, j + 1)) {
        (*array)[i][j] = 42;
        has_changes = true;
        continue;
      }

      int64_t element = input_array[i][j];
      if (element < input_array[i - 1][j] && element < input_array[i + 1][j] &&
          element < input_array[i][j - 1] && element < input_array[i][j + 1]) {
        (*array)[i][j] = 42;
        has_changes = true;
      }
    }
  }

  return has_changes;
}

ASM_TEST_N(Array2d_V1_Advanced, Sample, Array2d, Asm2d, Array2dWrapper) {
  std::vector<std::vector<int64_t>> golden_data = {
      {11, 22, 33, 44, 55},   {11, 1, 33, 2, 55},   {11, 22, 44444, 44, 55},
      {11, -10, 33, 735, 55}, {11, 22, 33, 44, 55},
  };
  int rows_count = golden_data.size();
  int columns_count = golden_data[0].size();

  auto **ptr = new int64_t *[rows_count];
  for (int i = 0; i < rows_count; ++i) {
    ptr[i] = new int64_t[columns_count];
    for (int j = 0; j < columns_count; ++j) {
      ptr[i][j] = golden_data[i][j];
    }
  }

  Array2d(ptr, rows_count, columns_count);
  bool has_changes = CppArray2dAdvanced(&golden_data);
  assert(has_changes);

  for (int i = 0; i < rows_count; ++i) {
    for (int j = 0; j < columns_count; ++j) {
      ASSERT_THAT(ptr[i][j], golden_data[i][j]);
    }
  }

  for (int i = 0; i < rows_count; ++i) {
    delete[] ptr[i];
  }
  delete[] ptr;
}

ASM_TEST_N(Array2d_V1_Advanced, Small, Array2d, Asm2d, Array2dWrapper) {
  for (int test_i = 0; test_i < 50; ++test_i) {
    int32_t rows_count = SRandom64(1, 50);
    int32_t columns_count = SRandom64(1, 50);

    std::vector<std::vector<int64_t>> golden_data;
    for (int i = 0; i < rows_count; ++i) {
      golden_data.push_back(RandomInt64Array(columns_count, 0, 100));
    }

    auto **ptr = new int64_t *[rows_count];
    for (int i = 0; i < rows_count; ++i) {
      ptr[i] = new int64_t[columns_count];
      for (int j = 0; j < columns_count; ++j) {
        ptr[i][j] = golden_data[i][j];
      }
    }

    Array2d(ptr, rows_count, columns_count);
    bool has_changes = CppArray2dAdvanced(&golden_data);
    assert(has_changes);

    for (int i = 0; i < rows_count; ++i) {
      for (int j = 0; j < columns_count; ++j) {
        ASSERT_THAT(ptr[i][j], golden_data[i][j]);
      }
    }

    for (int i = 0; i < rows_count; ++i) {
      delete[] ptr[i];
    }
    delete[] ptr;
  }
}

ASM_TEST_N(Array2d_V1_Advanced, Large, Array2d, Asm2d, Array2dWrapper) {
  for (int test_i = 0; test_i < 50; ++test_i) {
    int32_t rows_count = SRandom64(1, 100);
    int32_t columns_count = SRandom64(1, 100);

    std::vector<std::vector<int64_t>> golden_data;
    for (int i = 0; i < rows_count; ++i) {
      golden_data.push_back(
          RandomInt64Array(columns_count, INT64_MIN + 10, INT64_MAX - 10));
    }

    auto **ptr = new int64_t *[rows_count];
    for (int i = 0; i < rows_count; ++i) {
      ptr[i] = new int64_t[columns_count];
      for (int j = 0; j < columns_count; ++j) {
        ptr[i][j] = golden_data[i][j];
      }
    }

    Array2d(ptr, rows_count, columns_count);
    bool has_changes = CppArray2dAdvanced(&golden_data);
    assert(has_changes);

    for (int i = 0; i < rows_count; ++i) {
      for (int j = 0; j < columns_count; ++j) {
        ASSERT_THAT(ptr[i][j], golden_data[i][j]);
      }
    }

    for (int i = 0; i < rows_count; ++i) {
      delete[] ptr[i];
    }
    delete[] ptr;
  }
}

// ===========================================================================

} // anonymous namespace
