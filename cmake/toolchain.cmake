set(CMAKE_SYSTEM_NAME "Generic")

set(CMAKE_ASM_COMPILER arm-none-eabi-gcc CACHE FILEPATH "ARM assembler")
set(CMAKE_C_COMPILER arm-none-eabi-gcc CACHE FILEPATH "ARM C compiler")
set(CMAKE_CXX_COMPILER arm-none-eabi-g++ CACHE FILEPATH "ARM C++ compiler")
set(CMAKE_LINKER arm-none-eabi-ld CACHE FILEPATH "ARM linker")
set(CMAKE_AR arm-none-eabi-gcc-ar CACHE FILEPATH "ARM archiver")
set(CMAKE_RANLIB arm-none-eabi-gcc-ranlib CACHE FILEPATH "ARM ranlib")
set(CMAKE_OBJCOPY arm-none-eabi-objcopy CACHE FILEPATH "ARM objcopy")
set(CMAKE_OBJDUMP arm-none-eabi-objdump CACHE FILEPATH "ARM objdump")

set(CPU_PARAMETERS -mcpu=cortex-m7
	-mthumb
	-mfpu=fpv5-sp-d16
	-mfloat-abi=hard)

add_compile_options(
	${CPU_PARAMETERS}
	-Wall
	-Wextra
	-Wpedantic
	-Wno-unused-parameter
	-fno-exceptions
	-fdata-sections
	-ffunction-sections
	-fdiagnostics-color=always
	-fno-exceptions
	"$<$<COMPILE_LANGUAGE:CXX>:-Wno-volatile;-fno-rtti>"
	# Full debug configuration
	"$<$<CONFIG:DEBUG>:-O0;-g3;-ggdb>"
	# Release
	"$<$<CONFIG:RELEASE>:-Os;-s>"
	# Release with DEBUG
	"$<$<CONFIG:RelWithDebInfo>:-Os;-g3;-ggdb>"
)

add_link_options(
	${CPU_PARAMETERS}
	-Wl,-Map=${CMAKE_PROJECT_NAME}.map
	-specs=nano.specs
	-specs=nosys.specs
	-Wl,--start-group
	-Wl,--end-group
	-Wl,--print-memory-usage
	-Wl,--gc-sections
)
# endregion