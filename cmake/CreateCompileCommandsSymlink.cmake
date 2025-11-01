# cmake/CreateCompileCommandsSymlink.cmake
#
# 简化版：在配置阶段判断并在源码目录创建针对构建目录的 compile_commands.json 的符号链接（或复制）。
# 规则：
# 1) 如果 CMAKE_BINARY_DIR 和 CMAKE_SOURCE_DIR 指向同一个实际目录（REALPATH），则什么也不做。
# 2) 否则，在 CMAKE_BINARY_DIR（以及可选的 CMAKE_CFG_INTDIR 子目录）查找 compile_commands.json，
# 若存在则在 CMAKE_SOURCE_DIR 下创建名为 compile_commands.json 的符号链接（若创建失败，则复制）。
# 3) 不创建任何 add_custom_target/add_custom_command；仅在配置阶段尝试一次。

include_guard(GLOBAL)

include(CMakeParseArguments)

function(create_compile_commands_symlink)
  # 可选参数：LINK_PATH（默认 ${CMAKE_SOURCE_DIR}/compile_commands.json）
  cmake_parse_arguments(CC_SYMLINK "" "LINK_PATH" "" ${ARGN})

  if(NOT CC_SYMLINK_LINK_PATH)
    set(CC_SYMLINK_LINK_PATH "${CMAKE_SOURCE_DIR}/compile_commands.json")
  endif()

  # 解析真实路径以判断是否为 in-source build
  get_filename_component(_bin_dir_real "${CMAKE_BINARY_DIR}" REALPATH)
  get_filename_component(_src_dir_real "${CMAKE_SOURCE_DIR}" REALPATH)

  if(_bin_dir_real STREQUAL _src_dir_real)
    message(STATUS "CreateCompileCommandsSymlink: CMAKE_BINARY_DIR and CMAKE_SOURCE_DIR are the same (${_src_dir_real}); skipping symlink creation.")
    return()
  endif()

  # 候选位置
  set(_candidates "${CMAKE_BINARY_DIR}/compile_commands.json")

  if(DEFINED CMAKE_CFG_INTDIR)
    list(APPEND _candidates "${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR}/compile_commands.json")
  endif()

  set(_found_candidate "")

  foreach(_cand IN LISTS _candidates)
    if(EXISTS "${_cand}")
      set(_found_candidate "${_cand}")
      break()
    endif()
  endforeach()

  if(NOT _found_candidate)
    message(STATUS "CreateCompileCommandsSymlink: No compile_commands.json found in build directory; skipping.")
    return()
  endif()

  # 目标路径为绝对路径
  get_filename_component(_link_abs "${CC_SYMLINK_LINK_PATH}" ABSOLUTE)

  # 如果目标已存在且指向相同文件，则无需操作
  if(EXISTS "${_link_abs}")
    get_filename_component(_cand_real "${_found_candidate}" REALPATH)
    get_filename_component(_link_real "${_link_abs}" REALPATH)

    if(_cand_real STREQUAL _link_real)
      message(STATUS "CreateCompileCommandsSymlink: Link already points to the build compile_commands.json; nothing to do.")
      return()
    endif()
  endif()

  # 删除旧文件并尝试创建符号链接；失败则复制
  execute_process(COMMAND ${CMAKE_COMMAND} -E remove "${_link_abs}" RESULT_VARIABLE _rm_ret)
  execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${_found_candidate}" "${_link_abs}" RESULT_VARIABLE _ln_ret OUTPUT_QUIET ERROR_QUIET)

  if(NOT _ln_ret EQUAL 0)
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different "${_found_candidate}" "${_link_abs}")
    message(STATUS "CreateCompileCommandsSymlink: Copied compile_commands.json from ${_found_candidate} to ${_link_abs}")
  else()
    message(STATUS "CreateCompileCommandsSymlink: Created symlink from ${_found_candidate} to ${_link_abs}")
  endif()
endfunction()
