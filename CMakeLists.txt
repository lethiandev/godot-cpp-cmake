cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

# GODOT_API_JSON variable is REQUIRED
set(GODOT_API_JSON "" CACHE FILEPATH "Path to godot_api.json file for bindings generator")
if (NOT EXISTS "${GODOT_API_JSON}" OR IS_DIRECTORY "${GODOT_API_JSON}")
	message(FATAL_ERROR "Path GODOT_API_JSON to godot_api.json file is required")
endif()

# CMAKE_BUILD_TYPE cannot be empty
if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Debug")
endif()

# Default Android settings to follow Godot's build
# Use $ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake toolchain
if(CMAKE_SYSTEM_NAME STREQUAL Android)
	set(CMAKE_TOOLCHAIN_FILE "$ENV{ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" CACHE FILEPATH "Android NDK's CMake toolchain file")
	set(ANDROID_PLATFORM android-28 CACHE STRING "Android target platform API level")
	set(ANDROID_ABI armeabi-v7a CACHE STRING "Android target ABI architecture")
	set(ANDROID_TOOLCHAIN clang)
	set(ANDROID_STL c++_shared)
endif()

# Settings for Emscripten build
# Use $EMSCRIPTEN/cmake/Modules/Platform/Emscripten.cmake toolchain
if(CMAKE_SYSTEM_NAME STREQUAL Emscripten)
	set(CMAKE_TOOLCHAIN_FILE "$ENV{EMSCRIPTEN}/cmake/Modules/Platform/Emscripten.cmake" CACHE FILEPATH "Emscripten's CMake toolchain file")
endif()

# Start GodotCpp library project
project(GodotCpp VERSION 1.0.0 LANGUAGES CXX)

# Force MSVC to statically linking with CRT
if (MSVC)
	string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
endif()

# Generate Godot's GDNative <-> C++ bindings using JSON file
message(STATUS "Generating Godot C++ binding source files...")
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/godot-cpp/src/gen/__icalls.cpp")
	set(GENERATOR_COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/generate.py")
	set(GENERATOR_COMMAND "${GENERATOR_COMMAND}" "${GODOT_API_JSON}")
	execute_process(
		COMMAND python ${GENERATOR_COMMAND}
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/godot-cpp"
	)
else()
	message(STATUS "Bindings are already generated")
endif()

# List all binding C++ source files
file(GLOB GDNATIVECPP_CORE_SOURCE_FILES "godot-cpp/src/core/*.cpp")
file(GLOB GDNATIVECPP_GENERATED_SOURCE_FILES "godot-cpp/src/gen/*.cpp")

# Create library target
add_library(GodotCppLibrary STATIC
	${GDNATIVECPP_CORE_SOURCE_FILES}
	${GDNATIVECPP_GENERATED_SOURCE_FILES}
)

target_include_directories(GodotCppLibrary PUBLIC
	godot-cpp/godot_headers
	godot-cpp/include
	godot-cpp/include/core
	godot-cpp/include/gen
)

target_compile_features(GodotCppLibrary PUBLIC
	cxx_std_14
)

# Build library name for the library
# The formula is: godot-cpp.[system].[opt?].[arch].[lib|a]
if(CMAKE_SYSTEM_NAME STREQUAL Android)
	set(LIB_SUFFIX_DEBUG "android.${ANDROID_ABI}")
	set(LIB_SUFFIX_RELEASE "android.opt.${ANDROID_ABI}")
elseif(CMAKE_SYSTEM_NAME STREQUAL Emscripten)
	set(LIB_SUFFIX_DEBUG "javascript")
	set(LIB_SUFFIX_RELEASE "javascript.opt")
else()
	if(WIN32)
		set(LIB_SUFFIX_DEBUG "windows")
		set(LIB_SUFFIX_RELEASE "windows.opt")
	elseif(UNIX OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
		set(LIB_SUFFIX_DEBUG "x11")
		set(LIB_SUFFIX_RELEASE "x11.opt")
	endif()

	if (CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(LIB_SUFFIX_DEBUG "${LIB_SUFFIX_DEBUG}.64")
		set(LIB_SUFFIX_RELEASE "${LIB_SUFFIX_RELEASE}.64")
	else()
		set(LIB_SUFFIX_DEBUG "${LIB_SUFFIX_DEBUG}.32")
		set(LIB_SUFFIX_RELEASE "${LIB_SUFFIX_RELEASE}.32")
	endif()
endif()

# Configure the library name and output path
set_target_properties(GodotCppLibrary PROPERTIES
	OUTPUT_NAME_DEBUG "godot-cpp.${LIB_SUFFIX_DEBUG}"
	OUTPUT_NAME_RELEASE "godot-cpp.${LIB_SUFFIX_RELEASE}"
	ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
	LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
)
