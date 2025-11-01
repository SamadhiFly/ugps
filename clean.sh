#!/usr/bin/env bash
#filename: build.sh

BUILD_NINJA_FILE=build.ninja
CMAKE_PRESETS_FILE=CMakePresets.json
CMAKE_PRESETS_CONFIG=config-openwrt
CMAKE_PRESETS_BUILD=build-openwrt

[ -e ${BUILD_NINJA_FILE} ] && echo "### cleaning..." && cmake --build --preset ${CMAKE_PRESETS_BUILD} --target clean

files=("build.ninja" "install_manifest.txt" "compile_commands.json" "CMakeCache.txt" "cmake_install.cmake")
for file in "${files[@]}"; do [ -f "$file" ] && echo "removing file ${file}" && rm -f "$file"; done

dirs=("CMakeFiles")
for dir in "${dirs[@]}"; do [ -d "$dir" ] && echo "removing dir ${dir}" && rm -rf "$dir"; done

