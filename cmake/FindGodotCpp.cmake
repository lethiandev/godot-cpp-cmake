# GodotCpp module find script for CMake generator
#
# Copy /cmake directory to your own project's root path
# Also setup GODOT_CPP_PATH variable pointing to the godot-cpp-cmake repo
# i.e. cmake -G Ninja -DGODOT_CPP_PATH="<godot-cpp-cmake>" ../..
# Don't forget about setting up the CMAKE_MODULE_PATH variable too
#
# Repo: https://github.com/lethiandev/godot-cpp-cmake
# Emitted targets: GodotCpp::GodotCpp
cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

# Store GODOT_CPP_PATH as cache variable
set(GODOT_CPP_PATH "" CACHE PATH "Path to the godot-cpp-cmake repository")

# Require for GODOT_CPP_PATH path
if(NOT IS_DIRECTORY "${GODOT_CPP_PATH}")
	message(FATAL_ERROR "The GODOT_CPP_PATH path is required")
endif()

# Library name to find
if(CMAKE_SYSTEM_NAME STREQUAL Android)
	set(GODOT_CPP_LIB_SUFFIX_DEBUG "android.${CMAKE_ANDROID_ARCH_ABI}")
	set(GODOT_CPP_LIB_SUFFIX_RELEASE "android.opt.${CMAKE_ANDROID_ARCH_ABI}")
else()
	if(WIN32)
		set(GODOT_CPP_LIB_SUFFIX_DEBUG "windows")
		set(GODOT_CPP_LIB_SUFFIX_RELEASE "windows.opt")
	elseif(UNIX OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
		set(GODOT_CPP_LIB_SUFFIX_DEBUG "x11")
		set(GODOT_CPP_LIB_SUFFIX_RELEASE "x11.opt")
	endif()

	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(GODOT_CPP_LIB_SUFFIX_DEBUG "${GODOT_CPP_LIB_SUFFIX_DEBUG}.64")
		set(GODOT_CPP_LIB_SUFFIX_RELEASE "${GODOT_CPP_LIB_SUFFIX_RELEASE}.64")
	else()
		set(GODOT_CPP_LIB_SUFFIX_DEBUG "${GODOT_CPP_LIB_SUFFIX_DEBUG}.32")
		set(GODOT_CPP_LIB_SUFFIX_RELEASE "${GODOT_CPP_LIB_SUFFIX_RELEASE}.32")
	endif()
endif()

set(GODOT_CPP_LIBRARY_NAME "godot-cpp")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
	set(GODOT_CPP_LIBRARY_NAME "${GODOT_CPP_LIBRARY_NAME}.${GODOT_CPP_LIB_SUFFIX_RELEASE}")
else()
	set(GODOT_CPP_LIBRARY_NAME "${GODOT_CPP_LIBRARY_NAME}.${GODOT_CPP_LIB_SUFFIX_DEBUG}")
endif()

# Find include directories
find_path(GODOT_CPP_INCLUDE_DIR_HEADERS gdnative_api_struct.gen.h HINTS "${GODOT_CPP_PATH}/godot-cpp" PATH_SUFFIXES godot_headers)
find_path(GODOT_CPP_INCLUDE_DIR_CORE core/Godot.hpp HINTS "${GODOT_CPP_PATH}/godot-cpp" PATH_SUFFIXES include)
find_path(GODOT_CPP_INCLUDE_DIR_GEN gen/Object.hpp HINTS "${GODOT_CPP_PATH}/godot-cpp" PATH_SUFFIXES include)

# Find the library
find_library(GODOT_CPP_LIBRARY "${GODOT_CPP_LIBRARY_NAME}" HINTS "${GODOT_CPP_PATH}" PATH_SUFFIXES lib)

# Handle find_package's QUIET, REQUIRED etc. arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GodotCpp REQUIRED_VARS
	GODOT_CPP_LIBRARY
	GODOT_CPP_INCLUDE_DIR_HEADERS
	GODOT_CPP_INCLUDE_DIR_CORE
	GODOT_CPP_INCLUDE_DIR_GEN
)

# Build include directories list
set(GODOT_CPP_INCLUDE_DIR
	"${GODOT_CPP_INCLUDE_DIR_HEADERS}"
	"${GODOT_CPP_INCLUDE_DIR_CORE}"
	"${GODOT_CPP_INCLUDE_DIR_CORE}/core"
	"${GODOT_CPP_INCLUDE_DIR_GEN}/gen"
)

# Add imported target to the CMake build
add_library(GodotCpp::GodotCpp STATIC IMPORTED)
set_target_properties(GodotCpp::GodotCpp PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES "${GODOT_CPP_INCLUDE_DIR}"
	IMPORTED_LOCATION "${GODOT_CPP_LIBRARY}"
)
