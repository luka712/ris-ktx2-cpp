//
// Created by lukaa on 18.4.2026..
//
#pragma once

#include <string.h>

// Symbol visibility.
//  - RIS_KTX2_STATIC   : defined (publicly) when the library is built as a static library.
//  - RIS_KTX2_BUILDING : defined privately while building the shared library itself.
#ifndef API_EXPORT

#if defined(RIS_KTX2_STATIC)
    #define API_EXPORT
#elif defined(_WIN32) || defined(_WIN64)
    #if defined(RIS_KTX2_BUILDING)
        #define API_EXPORT __declspec(dllexport)
    #else
        #define API_EXPORT __declspec(dllimport)
    #endif
#else
    // For Linux / macOS using GCC or Clang
    #define API_EXPORT __attribute__((visibility("default")))
#endif

#endif // API_EXPORT

#if defined(_WIN32)
    #define strdup _strdup
#endif
