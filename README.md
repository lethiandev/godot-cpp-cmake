# CMake Build Scripts for GDNative C++ Bindings

This repo contains CMake scripts to ease cross-platform building of GDNative C++ bindings.

Supported platforms:
- Windows & Linux
- Android (Android NDK)
- WebAssembly (Emscripten)

Requires at least Godot Engine 3.1 with support for NativeScript 1.1, but may work with older Godot Engine releases.

Clone this repo with `--recurse-submodules` option. It'll clone this repo with all required dependencies such as godot-cpp and godot_headers direct from github's repository.

## Prerequisites

Before start building, you need [CMake 3.10+](https://cmake.org/) build scripts generator, [Python](https://www.python.org/) for GDNative C++ bindings' generator and [Android SDK](https://developer.android.com/studio) with NDK bundle installed. Optionally, you can use [Ninja build system](https://ninja-build.org/) - my personal choice - but these CMake scripts should work with any build system supported by your environment.

## Compiling

It's advisable to create separate subdirectories for each target platforms inside `/build` directory. For example, for _Windows x64_ build, name the subdirectory as `win64` and open it within Command Prompt (or Terminal, depends on your OS). For MSVC build, use MSVC's Native Command Prompt (x86 or x64). After the preparation, generate build scripts being inside the platform build directory using CMake as:

```
cd build\win64
cmake -G Ninja ..\.. -DGODOT_API_JSON=C:\Path\To\godot_api.json
```

This should work with Linux the same way. But for Android, it isn't more complicated. Bur first, you should ensure that you're having the latest NDK (tested on r19) version installed on your system with CMake toolchain file bundled. Assuming you have configured Android SDK properly, you can run the CMake tool with specified definitions:

```
cd build\android
cmake -G Ninja ..\.. -DCMAKE_SYSTEM_NAME=Android -DGODOT_API_JSON=C:\Path\To\godot_api.json
```

For Android build, CMake's script tries to find Android NDK's CMake Toolchain automatically using `ANDROID_NDK_ROOT` environment variable. Ensure first, that it's available on your system. Also remember to use `-DCMAKE_SYSTEM_NAME=Android` flag, as it does Android build scripts preparation.

Experimental Emscripten build is also available, but GDNative on JavaScript platform is currently not officialy supported by Godot Engine developers. To generate build scripts for Emscripten, use `-DCMAKE_SYSTEM_NAME=Emscripten` flag. As like for Android target, CMake's script will try to find Emscripten's toolchain using `EMSCRIPTEN` environment variable.

If you wish, you can supply toolchain file manually by defining `CMAKE_TOOLCHAIN_FILE` variable yourself.

To generate build scripts for release (optimized) targets, use CMake's `-DCMAKE_BUILD_TYPE` option as `-DCMAKE_BUILD_TYPE=Release`. Built libraries should be located under `/lib` root directory. Emscripten have special `MinSizeRel` build type, as it builds the library in favour of minimizing the library size also the performance loss is minimal.

## Troubleshooting

If you don't know how to obtain the godot_api.json file, just run Godot.exe within Command Prompt with `--gdnative-generate-json-api` option, just like:

```
Godot.exe --gdnative-generate-json-api godot_api.json
```

Generated godot_api.json file should be located inside the same directtory as Godot executable.
