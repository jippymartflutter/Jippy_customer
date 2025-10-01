cmake_minimum_required(VERSION 3.22.1)
project(jippy_customer)

# Enable flexible page size support
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZE=ON -DANDROID_PAGE_SIZE=16384")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZE=ON -DANDROID_PAGE_SIZE=16384")

# Force linker to use 16KB page size alignment
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,page-size=16384")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-z,page-size=16384")

message(STATUS "Applied 16KB alignment flags for Android 15+ compatibility")
