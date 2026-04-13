#ifndef SOLUTION_H_
#define SOLUTION_H_

#include <cstdint>

extern "C" int32_t AsmStrLen(const char* s);
extern "C" char* AsmStrChr(const char* s, char c);
extern "C" void AsmStrCpy(char* dst, const char* src);
extern "C" void AsmStrNCpy(char* dst, const char* src, uint32_t size);
extern "C" int32_t AsmStrCmp(const char* s1, const char* s2);
extern "C" char* AsmStrCat(char* dst, const char* src);
extern "C" char* AsmStrStr(const char* str, const char* substr);
extern "C" int64_t AsmStrToInt64(const char* s);
extern "C" void AsmIntToStr64(int64_t x, int32_t b, char* s);
extern "C" bool AsmSafeStrToUInt64(const char* s, uint64_t* result);

#endif // SOLUTION_H_
