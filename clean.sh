#!/usr/bin/env bash
#filename: clean.sh

TARGET_FILE_NAME='ugps'
TARGET_FILE_EXT='.elf'

BUILD_NINJA_FILE='build.ninja'
CMAKE_PRESETS_FILE='CMakePresets.json'
CMAKE_PRESETS_CONFIG='config-openwrt'
CMAKE_PRESETS_BUILD='build-openwrt'

[ -e ${TARGET_FILE_NAME}${TARGET_FILE_EXT} ] && echo "### deleting target ${TARGET_FILE_NAME}${TARGET_FILE_EXT}" && rm -f ${TARGET_FILE_NAME}${TARGET_FILE_EXT}

[ -e ${BUILD_NINJA_FILE} ] && echo "### cleaning..." && cmake --build --preset ${CMAKE_PRESETS_BUILD} --target clean

files=(".ninja_deps" ".ninja_log" "build.ninja" "install_manifest.txt" "compile_commands.json" "CMakeCache.txt" "cmake_install.cmake")
for file in "${files[@]}"; do [ -f "$file" ] && echo "removing file ${file}" && rm -f "$file"; done

dirs=(".cache" ".cmake" ".lupdate" "CMakeFiles" "${TARGET_FILE_NAME}_autogen")
for dir in "${dirs[@]}"; do [ -d "$dir" ] && echo "removing dir ${dir}" && rm -rf "$dir"; done

echo "### clean.sh done."
exit 0
