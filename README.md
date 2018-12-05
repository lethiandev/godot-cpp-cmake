# CMake for Godot C++ Bindings

This project provides CMake scripts for compiling a Godot C++ bindings to simplify the cross-platform library building.

CMake scripts are updated to work with Nativescript 1.1 API (Godot 3.1), if you're looking for Nativescript 1.0 compatible version with Godot 3.0, checkout 3.0 branch instead.

First of all, clone this repo with a `--recurse-submodules` option. It'll clone the repo with the required submodules as well.

## Compiling

You'll need a CMake generator at least 3.10.0 version installed on your environment. You can obtain the generator from the official [CMake website](https://cmake.org/). Also download and add a [Ninja build system](https://ninja-build.org/) into your system's `PATH` variable.

### Windows

On Windows, you'll need a MinGW or a Visual Studio (express editions will work too) compiler installed on your environment.

1. Make a new directory under the `build` root directory.
```
mkdir build\windows
```
2. Move to the newly created directory.
```
cd build\windows
```
3. Run the CMake generator.

```bash
cmake -G Ninja ..\.. -DCMAKE_CXX_COMPILER=cl
# or by using a MinGW with a GNU's compiler:
cmake -G Ninja ..\.. -DCMAKE_CXX_COMPILER=g++
```

To choose between the build targets - `Debug` and `Release`, use the `-DCMAKE_BUILD_TYPE=<Target>` option.

```bash
# i.e. for release library build
cmake -G Ninja ..\.. -DCMAKE_CXX_COMPILER=cl -DCMAKE_BUILD_TYPE=Release
```

CMake'll run a Godot C++ Bindings generator only once on a configuration step. To start building the static library, just type a `ninja` command.

```bash
ninja
```

The static library is stored under the `lib` root directory.

### Linux

On Linux, the process is similar to the Windows build steps, but may require some changes. Instead of the `windows` directory, create a `linux` directory and use a GNU's `g++` compiler instead of the `cl`. Also remember about the path separators. The backslashes `\` are used on Windows and slashes `/` on linuxes.

```bash
cmake -G Ninja ../.. -DCMAKE_CXX_COMPILER=g++
```

And run the build by typing a `ninja` command in the terminal.

```bash
ninja
```

Static library is stored under  the `lib` root directory.

### Android

To build an Android version of the library, use a CMake with an option `CMAKE_SYSTEM_NAME=Android`. Also remember to create a `android` directory under the `build` root directory.

```
cmake -G Ninja ../.. -DCMAKE_SYSTEM_NAME=Android
ninja
```

To change a build architecture, you may need to edit the `CMakeCache.txt` file.

Static library can be found under the `lib` root directory.
