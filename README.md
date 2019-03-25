# CMake Build Scripts for GDNative C++ Bindings

This repo contains CMake scripts to ease cross-platform building of GDNative C++ bindings.

Requires at least Godot Engine 3.1 RC1 with NativeScript 1.1. May work with older Godot Engine releases, but it's not tested.

To begin, clone this repo with `--recurse-submodules` option. It'll clone the repo with all required dependencies such as godot-cpp and godot_headers direct from github's repository.

## Prerequisite

You need [CMake](https://cmake.org/) generator at least 3.10 version, [Python](https://www.python.org/) for GDNative C++ bindings generator and [Android SDK](https://developer.android.com/studio) with NDK bundle. Optionally you can use [Ninja build system](https://ninja-build.org/), my personal choice, but these CMake scripts should work with any build system.

## Compiling

The best approach to compile the library is to create a subdirectory under the /build path. For example, for _Windows x64_ build, name the subdirectory as _win64_ and open it in Command Prompt. For MSVC build, use MSVC's Native Commands Prompt. To start, generate Ninja build files (or any other build system supported by your environment) using CMake as:

```
cd build\win64
cmake -G Ninja ..\.. -DGODOT_API_JSON=C:\Path\To\godot_json.api
```

This should work with Linux the same way. But for Android, it gets a bit more complicated. You should ensure that you have latest NDK version installed on your system with CMake toolchain file bundled. Assuming you have configured Android SDK properly, you can run the CMake tool with specified definitions:

```
cd build\android
cmake -G Ninja ..\.. -DCMAKE_SYSTEM_NAME=Android -DGODOT_API_JSON=C:\Path\To\godot_json.api
```

For Android build, CMake tries to find Android NDK's CMake Toolchain automatically using `ANDROID_NDK_ROOT` environment variable. Ensure first, that it's available on your system. Also remember to use `-DCMAKE_SYSTEM_NAME=Android` flag, as it does Android build preparations.

If you wish, you can supply toolchain file manually by defining `CMAKE_TOOLCHAIN_FILE` variable pointing to the toolchain file.

Experimental Emscripten build is available too, but GDNative on JavaScript platform is currently not officialy supported by Godot Engine developers. To build for Emscripten, use `-DCMAKE_SYSTEM_NAME=Emscripten` flag. As like for Android target, CMake script will try to find Emscripten's toolchain using EMSCRIPTEN environment variable.

To build release (optimized) targets, use CMake's -DCMAKE_BUILD_TYPE option as `-DCMAKE_BUILD_TYPE=Release`. Built libraries should be located under the /lib root directory.

## Troubleshooting

If you don't know how to obtain godot_json.api file, just run Godot.exe within a Command Prompt with an `--gdnative-generate-json-api` option, just like:

```
Godot.exe --gdnative-generate-json-api godot_json.api
```

Generated godot_json.api file should be located inside the same directtory as Godot executable.

If you ever encountered _NOTFOUND_ problem using `find_path/library` commands and you're using Android's CMake Toolchain, it may be caused because Android's Toolchain sets options `CMAKE_FIND_ROOT_PATH_MODE_LIBRARY/INCLUDE` to use only sysroot path. Put code shown below after `project` or before first use of `find_path/library`. It re-enables finding host located files.

```cmake
# Fix Android's CMake Toolchain to allow finding host libraries
if(CMAKE_SYSTEM_NAME STREQUAL Android)
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
endif()
```

It may require to be disabled when no more in use.
