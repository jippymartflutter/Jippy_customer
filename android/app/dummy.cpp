// Dummy C++ file to enable CMake build and 16 KB page size migration
// This file is required for the CMake project to be recognized

#include <jni.h>

extern "C" JNIEXPORT jint JNICALL
Java_com_jippymart_customer_MainActivity_dummyFunction(JNIEnv* env, jobject thiz) {
    return 0;
}
