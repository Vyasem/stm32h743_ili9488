
#remove files block
function(remove_files TARGET)
	if(EXISTS ${TARGET})
		file(REMOVE_RECURSE ${TARGET})
	endif()
endfunction()

set(REMOVE_LIST
	${CMAKE_CURRENT_SOURCE_DIR}/Drivers
	${CMAKE_CURRENT_SOURCE_DIR}/.mxproject
	${CMAKE_CURRENT_SOURCE_DIR}/Makefile
)

foreach(TARGET ${REMOVE_LIST})
	remove_files(${TARGET})
endforeach()

#end block


#hal block
FetchContent_Declare(
  CMSISV6
  GIT_REPOSITORY https://github.com/ARM-software/CMSIS_6.git
  GIT_TAG v6.3.0
)

FetchContent_Declare(
  CMSIS_DEVICE_H7
  GIT_REPOSITORY https://github.com/STMicroelectronics/cmsis-device-h7
  GIT_TAG v1.10.7
)

FetchContent_Declare(
  STM32H7XX_HAL_DRIVER
  GIT_REPOSITORY https://github.com/STMicroelectronics/stm32h7xx-hal-driver.git
  GIT_TAG v1.11.6
)

FetchContent_Declare(
	CMSIS_SVD
	GIT_REPOSITORY https://github.com/cmsis-svd/cmsis-svd-data.git
	GIT_TAG        main
)

FetchContent_MakeAvailable(CMSISV6 CMSIS_DEVICE_H7 STM32H7XX_HAL_DRIVER CMSIS_SVD)

file(GLOB_RECURSE STM32_HAL_SOURCES ${stm32h7xx_hal_driver_SOURCE_DIR}/Src/*.c)
list(FILTER STM32_HAL_SOURCES EXCLUDE REGEX ".+template.c")

file(COPY ${cmsis_svd_SOURCE_DIR}/data/STMicro/STM32H743x.svd DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

add_library(stm32h7_hal STATIC ${STM32_HAL_SOURCES})
target_include_directories(stm32h7_hal PUBLIC
	${PROJECT_SOURCE_DIR}/Core/Inc
	${stm32h7xx_hal_driver_SOURCE_DIR}/Inc
	${cmsisv6_SOURCE_DIR}/CMSIS/Core/Include
	${cmsis_device_h7_SOURCE_DIR}/Include
)

target_compile_definitions(stm32h7_hal PUBLIC
	__STM32H7xx_FAMILY
	STM32H743xx
	USE_HAL_DRIVER
	USE_FULL_LL_DRIVER
)
#end block

#freertos block
FetchContent_Declare(
	FreeRTOS
	GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
	GIT_TAG V11.3.0
)

add_library(freertos_config INTERFACE)

target_include_directories(freertos_config
    INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/config
)
set(FREERTOS_HEAP "4" CACHE STRING "" FORCE)
set(FREERTOS_PORT "GCC_ARM_CM7" CACHE STRING "" FORCE)
FetchContent_MakeAvailable(FreeRTOS)

set(FREERTOS_DIR ${freertos_SOURCE_DIR})
file(GLOB FREERTOS_SOURCES ${FREERTOS_DIR}/*.c)

set(FREERTOS_PORT_DIR ${FREERTOS_DIR}/portable/GCC/ARM_CM7/r0p1)
list(APPEND FREERTOS_SOURCES ${FREERTOS_PORT_DIR}/port.c)
list(APPEND FREERTOS_SOURCES ${FREERTOS_DIR}/portable/MemMang/heap_4.c)

add_library(freertos_app STATIC ${FREERTOS_SOURCES})
set_target_properties(freertos_app PROPERTIES
	SKIP_LINTING ON
)

target_include_directories(freertos_app PUBLIC
	${FREERTOS_DIR}/include
	${FREERTOS_PORT_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/config
)

target_compile_definitions(freertos_app PRIVATE
	projCOVERAGE_TEST=0
)

target_compile_options(freertos_app PRIVATE
	${CMAKE_C_FLAGS}
	-Ofast -s
)

target_compile_options(freertos_app PRIVATE
	-Wno-pedantic
	-Wno-unused-variable
)

#end block

file(GLOB_RECURSE CODE_SOURCES
	${PROJECT_SOURCE_DIR}/Core/Src/*.c
	${PROJECT_SOURCE_DIR}/Core/Src/*.cpp
	${PROJECT_SOURCE_DIR}/app/*.cpp
)

set(SOURCES
	${CODE_SOURCES}
	${PROJECT_SOURCE_DIR}/startup_stm32h743xx.s
)

add_executable(${PROJECT_NAME} ${SOURCES})

target_include_directories(${PROJECT_NAME} PRIVATE
	${PROJECT_SOURCE_DIR}/Core/Inc
	${PROJECT_SOURCE_DIR}/app
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
	$<$<CONFIG:DEBUG>:"DEBUG">
	$<$<CONFIG:RELASE>:"NDEBUG">
	#LIBS_FREERTOS_MALLOC
)

target_link_libraries(${PROJECT_NAME} PRIVATE
	#littlefs
	stm32h7_hal
	freertos_app
)

target_link_options(${PROJECT_NAME} PRIVATE
    -T${PROJECT_SOURCE_DIR}/STM32H743xx_FLASH.ld
)


set(MCU_OUTPUT_FILENAME ${PROJECT_NAME} CACHE INTERNAL "MCU filename")

add_custom_command(TARGET ${PROJECT_NAME}
    POST_BUILD
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    # - Create image for the app (with the boot):
    COMMAND ${CMAKE_OBJCOPY} ARGS -O ihex -I elf32-littlearm ${PROJECT_NAME} ${MCU_OUTPUT_FILENAME}.hex
)
