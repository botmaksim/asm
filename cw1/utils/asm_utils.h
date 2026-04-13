#ifndef ASM_UTILS_H_
#define ASM_UTILS_H_

#include "utils.h"

extern "C" void JunkRegistersWindows(void);
extern "C" void JunkRegistersUnix(void);

extern "C" uint64_t RunWindowsAsmFunctionWithChecks(void*, uint64_t, uint64_t, uint64_t);
extern "C" uint64_t RunUnixAsmFunctionWithChecks(void*, uint64_t, uint64_t, uint64_t);

extern "C" uint64_t RunWinedAsmFunction(void*, uint64_t, uint64_t, uint64_t);
extern "C" uint64_t RunWinedAsmFunctionWithChecks(void*, uint64_t, uint64_t, uint64_t);

#ifdef __linux__
#define JunkRegisters JunkRegistersUnix
#elif _WIN32
#define JunkRegisters JunkRegistersWindows
#endif

template<
    uint64_t Arg1Mask,
    uint64_t Arg2Mask,
    uint64_t Arg3Mask
>
uint64_t RunAsmFunctionWithChecks(
    void* f, uint64_t arg0 = 0, uint64_t arg1 = 0, uint64_t arg2 = 0) {
  // Note regarding garbage in high bits:
  // https://stackoverflow.com/questions/40475902/is-garbage-allowed-in-high-bits-of-parameter-and-return-value-registers-in-x86-6
  arg0 = (12345678901234567ull & (~Arg1Mask)) + arg0;
  arg1 = (12378367823563523ull & (~Arg2Mask)) + arg1;
  arg2 = (12343987329805340ull & (~Arg3Mask)) + arg2;
  JunkRegisters();
#ifdef WINDOWS_ADAPTER_MODE
  return RunWinedAsmFunctionWithChecks(f, arg0, arg1, arg2);
#elif __linux__
  return RunUnixAsmFunctionWithChecks(f, arg0, arg1, arg2);
#elif _WIN32
  return RunWindowsAsmFunctionWithChecks(f, arg0, arg1, arg2);
#else
  FAIL() << "Unsupported platform";
#endif
}

#define ASSERT_TRUE_EX(expr)                                                   \
  if (isRegularTest) {                                                         \
    ASSERT_TRUE(expr);                                                         \
  } else {                                                                     \
    ASSERT_TRUE(expr);                                                         \
    ASSERT_EQ(expr, true);                                                     \
    ASSERT_EQ(expr, 1);                                                        \
  }

#define ASSERT_FALSE_EX(expr)                                                  \
  if (isRegularTest) {                                                         \
    ASSERT_FALSE(expr);                                                        \
  } else {                                                                     \
    ASSERT_FALSE(expr);                                                        \
    ASSERT_EQ(expr, false);                                                    \
    ASSERT_EQ(expr, 0);                                                        \
  }

#define ASM_TEST_A(SuitName, CaseName, FnName, AsmFn, WrappedFn,               \
                   timeout_millis, iters, seed)                                \
  void SuitName##CaseName##TestFn(                                             \
      decltype((AsmFn)), __attribute__((unused)) bool isRegularTest);          \
  SAFE_TEST_A(SuitName, CaseName##_Regular, timeout_millis, iters, seed) {     \
    SuitName##CaseName##TestFn(AsmFn, true);                                   \
  }                                                                            \
  SAFE_TEST_A(SuitName, CaseName##_Wrapped, timeout_millis, iters, seed) {     \
    SuitName##CaseName##TestFn(WrappedFn, false);                              \
  }                                                                            \
  void SuitName##CaseName##TestFn(                                             \
      decltype((AsmFn)) FnName, __attribute__((unused)) bool isRegularTest)

// The following macro can be used to automatically populate two versions of the
// test (regular and wrapped). FnName is the name of the function used in the
// test body, AsmFn is the one from the assembly file (for direct call) and
// WrappedFn is the name of the proxy function for 'wrapped' tests.
#define ASM_TEST_N(SuitName, CaseName, FnName, AsmFn, WrappedFn)               \
  ASM_TEST_A(SuitName, CaseName, FnName, AsmFn, WrappedFn, 30'000, 3, 30051997)

// The following macro may be used when several subprojects have same test names
// (e.g. when you have to variants of the same assignment) to avoid
// misunderstanding of IDEs when running specific tests/suits.
#define ASM_TEST_V(Variant, SuitName, CaseName)                                \
  ASM_TEST_N(SuitName##_##Variant, CaseName,                                   \
             SuitName, Asm##SuitName, SuitName##Wrapper)

#define ASM_TEST(SuitName, CaseName)                                           \
  ASM_TEST_N(SuitName, CaseName, SuitName, Asm##SuitName, SuitName##Wrapper)

constexpr uint64_t kInt64Mask = 0xFFFFFFFFFFFFFFFFll;
constexpr uint64_t kInt32Mask = 0xFFFFFFFFll;
constexpr uint64_t kInt16Mask = 0xFFFFll;
constexpr uint64_t kInt8Mask = 0xFFll;
constexpr uint64_t kUnusedMask = 0x0;

#endif  // ASM_UTILS_H_
