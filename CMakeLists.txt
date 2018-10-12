cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

# allow custom path for json api file
set(GODOT_API_JSON "" CACHE PATH "Path to godot_api.json file for bindings generator")

# CMAKE_BUILD_TYPE cannot be empty
if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Debug")
endif()

# limit CMAKE_BUILD_TYPE up to Debug and Release targets
set(CMAKE_CONFIGURATION_TYPES "Debug;Release")
if(NOT ${CMAKE_BUILD_TYPE} IN_LIST CMAKE_CONFIGURATION_TYPES)
	message(FATAL_ERROR "CMAKE_BUILD_TYPE can be one of the [Release|Debug] options")
endif()

# setup Android build config compatible with a Godot template apk
if(CMAKE_SYSTEM_NAME STREQUAL Android)
	message(STATUS "Android build setup")
	set(CMAKE_ANDROID_API 27 CACHE STRING "Android target API level")
	set(CMAKE_ANDROID_API_MIN 18 CACHE STRING "Android minimal API level")
	set(CMAKE_ANDROID_ARCH_ABI armeabi-v7a CACHE STRING "Android target architecture")
	# prefer godot compatible runtime (instead of newer libc++)
	set(CMAKE_ANDROID_STL_TYPE gnustl_static)
	# allow only clang toolchain
	set(CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION clang)
	# enable neon floating point support
	set(CMAKE_ANDROID_ARM_NEON ON)
endif()

project(GodotCpp VERSION 1.0.0 LANGUAGES CXX)

# force linking with a static runtime library on msvc compilers
# TODO: add an option to configure it
if (MSVC)
	string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
endif()

# generate c++ bindings for godot api
# uses a binding_generator.py script from the godot-cpp submodule
# executes the generator on a cmake configuration step only once
message(STATUS "Generating Godot C++ binding source files...")

if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/godot-cpp/src/__icalls.cpp")
	execute_process(
		COMMAND python "${CMAKE_CURRENT_SOURCE_DIR}/generate.py" "${GODOT_API_JSON}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/godot-cpp"
	)
else()
	message(STATUS "Bindings are already generated")
endif()

# list all generated source files
# the source files may vary between the API versions, use files globbing
file(GLOB GENERATED_SOURCE_FILES "godot-cpp/src/*.cpp")

# add godot-cpp library target
add_library(godot-cpp STATIC
	godot-cpp/src/core/AABB.cpp
	godot-cpp/src/core/Array.cpp
	godot-cpp/src/core/Basis.cpp
	godot-cpp/src/core/Color.cpp
	godot-cpp/src/core/Dictionary.cpp
	godot-cpp/src/core/GodotGlobal.cpp
	godot-cpp/src/core/NodePath.cpp
	godot-cpp/src/core/Plane.cpp
	godot-cpp/src/core/PoolArrays.cpp
	godot-cpp/src/core/Quat.cpp
	godot-cpp/src/core/Rect2.cpp
	godot-cpp/src/core/RID.cpp
	godot-cpp/src/core/String.cpp
	godot-cpp/src/core/Transform.cpp
	godot-cpp/src/core/Transform2D.cpp
	godot-cpp/src/core/Variant.cpp
	godot-cpp/src/core/Vector2.cpp
	godot-cpp/src/core/Vector3.cpp
	${GENERATED_SOURCE_FILES}
)

target_include_directories(godot-cpp PUBLIC
	godot-cpp/godot_headers
	godot-cpp/include
	godot-cpp/include/core
)

target_compile_features(godot-cpp PUBLIC
	cxx_std_14
)

# differ library names based on build setup
# the formula is godot-cpp.[system].[opt?].[arch].[lib|a]
if(CMAKE_SYSTEM_NAME STREQUAL Android)
	set(LIB_SUFFIX_DEBUG "android.${CMAKE_ANDROID_ARCH_ABI}")
	set(LIB_SUFFIX_RELEASE "android.opt.${CMAKE_ANDROID_ARCH_ABI}")
else()
	message(STATUS "System name: ${CMAKE_SYSTEM_NAME}")
	if(WIN32)
		set(LIB_SUFFIX_DEBUG "windows")
		set(LIB_SUFFIX_RELEASE "windows.opt")
	elseif(UNIX OR CMAKE_SYSTEM_NAME STREQUAL "Linux")
		message(STATUS "Name were set")
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

set_target_properties(godot-cpp PROPERTIES
	OUTPUT_NAME_DEBUG "godot-cpp.${LIB_SUFFIX_DEBUG}"
	OUTPUT_NAME_RELEASE "godot-cpp.${LIB_SUFFIX_RELEASE}"
	ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
	LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
)
