cmake_minimum_required(VERSION 4.1)
cmake_policy(SET CMP0135 NEW)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set_property(GLOBAL PROPERTY RULE_MESSAGES OFF)
include(FetchContent)

project(WeactBase LANGUAGES C CXX ASM)

include(cmake/mcu.cmake)
include(cmake/utils.cmake)

LOG_INFO("Version:.........." ${CMAKE_PROJECT_VERSION})
LOG_INFO("Host system:......" ${CMAKE_SYSTEM_NAME})
LOG_INFO("Build type:......." ${CMAKE_BUILD_TYPE})

# region Tests
message("******* [Unit test list] *******")
enable_testing()
# endregion
