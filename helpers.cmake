include(CheckIncludeFiles)
include(CheckCXXSymbolExists)
include(CheckSymbolExists)

#[==========================================================================[
check_symbol
----------------

A wrapper function around ``check_cxx_symbol_exists``, or ``check_symbol_exists``.

.. code:: cmake

   check_symbol(
       SYMBOL [symbol]
       FILES [files...]
       INCLUDE_DIRS [directories...]
       RETURN_VAR [return_variable]
   )

Check if the given ``SYMBOL`` can be found after constructing a ``CXX`` file and
including ``FILES``. Optionally add header includes by setting the ``INCLUDE_DIRS``
argument. Set the mode to ``check_cxx_symbol_exists`` or ``check_symbol_exists``
to control the function used to check symbols. Defaults to ``check_cxx_symbol_exists``.

Writes the cached result to ``RETURN_VAR`` and defines a compilation definition macro
with the name contained in the ``RETURN_VAR`` variable.
#]==========================================================================]
function(check_symbol)
    set(one_value_args SYMBOL VAR MODE)
    set(multi_value_args FILES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_VAR)
    check_required_arg(_SYMBOL)
    check_required_arg(_FILES)

    prepare_check_function(_VAR)

    if("${_MODE}" STREQUAL "check_symbol_exists")
        cmake_helpers_status("check_symbol" "using check_symbol_exists")
        check_symbol_exists(${_SYMBOL} ${_FILES} ${_VAR})
    elseif(NOT DEFINED _MODE OR "${_MODE}" STREQUAL "check_cxx_symbol_exists")
        cmake_helpers_status("check_symbol" "using check_cxx_symbol_exists")
        check_cxx_symbol_exists(${_SYMBOL} ${_FILES} ${_VAR})
    else()
        cmake_helpers_error("check_symbol" "invalid mode: ${_MODE}")
        return()
    endif()

    if(${_VAR})
        add_compile_definitions("${_VAR}=1")
    endif()
endfunction()

function(cmake_helpers_status function message)
    set(multi_value_args ADD_MESSAGES)
    cmake_parse_arguments("" "" "" "${multi_value_args}" ${ARGN})

    set(message_prefix "cmake-helpers: ${function} - ")
    message(STATUS "${message_prefix}${message}")

    foreach(add_message IN LISTS _ADD_MESSAGES)
        string(REPLACE " " ";" add_message_list "${add_message}")

        list(LENGTH add_message_list add_message_length)
        if (${add_message_length} GREATER 1)
            list (GET add_message_list 0 key)
            list (GET add_message_list 1 value)

            if (NOT "${value}" STREQUAL "")
                message(STATUS "${message_prefix}    ${key} = ${value}")
            endif ()
        endif()
    endforeach()
endfunction()

function(cmake_helpers_error function message)
    message(FATAL_ERROR "cmake-helpers: ${function} - ${message}")
endfunction()

#[==========================================================================[
program_dependencies
----------------

Adds program dependencies using ``find_package`` and ``target_link_libraries``.

.. code:: cmake

   program_dependencies(
       <TARGET>
       <DEPENDENCY_NAME>
       VERSION [version]
       VISIBILITY [visibility]
       COMPONENTS [components...]
       LINK_COMPONENTS [link_components...]
   )

Finds a program dependency using ``find_package`` and then links it to an
existing target using ``target_link_libraries``. Treats all dependencies
and components as ``REQUIRED``. ``LINK_COMPONENTS`` optionally specifies the
the components that should be linked to the target, and if not present defaults
to ``COMPONENTS``. ``DIRECT_LINK`` specifies linking a dependency as
``${DEPENDENCY_NAME}`` rather than ``${DEPENDENCY_NAME}::${DEPENDENCY_NAME}``.
#]==========================================================================]
function(program_dependencies TARGET DEPENDENCY_NAME)
    set(one_value_args VERSION VISIBILITY)
    set(multi_value_args LINK_COMPONENTS FIND_PACKAGE_ARGS)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    if(NOT ${DEPENDENCY_NAME}_FOUND)
        get_property(before_importing DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)

        find_package(${DEPENDENCY_NAME} ${_VERSION} ${_FIND_PACKAGE_ARGS})

        # Set a property containing the imported targets of this find package call.
        get_property(after_importing DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY IMPORTED_TARGETS)
        list(REMOVE_ITEM after_importing ${before_importing})

        if (after_importing)
            list(JOIN after_importing ", " imports)
            cmake_helpers_status("program dependencies" "found ${DEPENDENCY_NAME} with components: ${imports}")
        endif()

        set(imported_targets_name "_program_dependencies_${DEPENDENCY_NAME}")
        set_property(DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}" "${after_importing}")

        get_property(name DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}")
    endif()

    # Override the components if linking manually.
    get_property(components DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY "${imported_targets_name}")
    if(DEFINED _LINK_COMPONENTS)
        set(components ${_LINK_COMPONENTS})
    endif()

    if(DEFINED components)
        list(LENGTH components length)
        if(${length} EQUAL 0)
            # Return early if there is nothing to link.
            return()
        endif()

        math(EXPR loop "${length} - 1")

        foreach(index RANGE 0 ${loop})
            list(GET components ${index} component)

            target_link_libraries(${TARGET} ${_VISIBILITY} ${component})
            cmake_helpers_status("program dependencies" "component ${component} linked to ${TARGET}")
        endforeach()
    endif()

    cmake_helpers_status(
            "program dependencies"
            "linked ${DEPENDENCY_NAME} to ${TARGET}"
            ADD_MESSAGES "version ${_VERSION}" "visibility ${_VISIBILITY}"
    )
endfunction()

#[==========================================================================[
check_includes
----------------

A wrapper function around ``check_include_files`` for ``CXX`` files.

.. code:: cmake

   check_includes(
       REQUIRES [requires...]
       INCLUDE_DIRS [directories...]
       RETURN_VAR [return_variable]
   )

Check if the given ``REQUIRES`` may be included in a ``CXX`` source file.
Optionally search through additional header includes by setting the
``INCLUDE_DIRS`` argument.

Writes the cached result to ``RETURN_VAR`` and defines a compilation definition macro
with the name contained in the ``RETURN_VAR`` variable.
#]==========================================================================]
function(check_includes)
    set(one_value_args VAR LANGUAGE)
    set(multi_value_args INCLUDES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_VAR)
    check_required_arg(_INCLUDES)

    prepare_check_function(_VAR)

    list(JOIN _INCLUDES ", " includes)
    cmake_helpers_status("check_includes" "checking ${includes} can be included" ADD_MESSAGES "language ${_LANGUAGE}")

    if(NOT DEFINED _LANGUAGE)
        check_include_files("${_INCLUDES}" "${_VAR}")
    elseif("${_LANGUAGE}" STREQUAL "CXX" OR "${_LANGUAGE}" STREQUAL "C")
        check_include_files("${_INCLUDES}" "${_VAR}" LANGUAGE ${_LANGUAGE})
    else()
        cmake_helpers_error("check_symbol" "invalid language: ${_LANGUAGE}")
        return()
    endif()

    if(${_VAR})
        add_compile_definitions("${_VAR}=1")
    endif()
endfunction()

#[==========================================================================[
prepare_check_function
----------------

A macro which is used within ``check_includes`` and ``check_symbol`` to set up
common logic and variables.

.. code:: cmake

   prepare_check_function(
       <RETURN_VAR>
       <INCLUDE_DIRS>
   )

Returns early if ``RETURN_VAR`` is defined. Sets ``CMAKE_REQUIRED_INCLUDES``
if ``INCLUDE_DIRS`` is defined. Assumes that ``RETURN_VAR`` and ``INCLUDE_DIRS``
is passed as a variable name and not a variable value.
#]==========================================================================]
macro(prepare_check_function RETURN_VAR)
    if(DEFINED ${${RETURN_VAR}})
        add_compile_definitions("${${RETURN_VAR}}=1")

        cmake_helpers_status("prepare_check_function" "check result for \"${${RETURN_VAR}}\" cached with value: ${${${RETURN_VAR}}}")
        return()
    endif()
endmacro()

#[==========================================================================[
setup_testing
----------------

A macro which sets up testing for an executable.

.. code:: cmake

   setup_testing(
       <TEST_EXECUTABLE_NAME>
       <LIBRARY_NAME>
   )

Enabled testing and links ``GTest`` to ``TEST_EXECUTABLE_NAME``. Links ``LIBRARY_NAME``
to ``TEST_EXECUTABLE_NAME``.
#]==========================================================================]
macro(setup_testing TEST_EXECUTABLE_NAME LIBRARY_NAME)
    include(GoogleTest)

    target_link_libraries(${TEST_EXECUTABLE_NAME} PUBLIC ${LIBRARY_NAME})
    enable_testing()

    program_dependencies(
        ${TEST_EXECUTABLE_NAME}
        GTest
        LINK_COMPONENTS
        GTest::gtest
        GTest::gtest_main
        GTest::gmock
        VISIBILITY
        PUBLIC
        FIND_PACKAGE_ARGS
        REQUIRED
    )

    set(gtest_force_shared_crt
        ON
        CACHE BOOL "" FORCE
    )

    if(TARGET ${TEST_EXECUTABLE_NAME})
        gtest_discover_tests(${TEST_EXECUTABLE_NAME})
    endif()
endmacro()

#[==========================================================================[
check_required_arg
----------------

A macro which is used to check for required ``cmake_parse_arguments``
arguments.

.. code:: cmake

   check_required_arg(
       <ARG>
       <ARG_NAME>
   )

Check if ``ARG`` is defined, printing an error message with ``ARG_NAME``
and returning early if not.
#]==========================================================================]
macro(check_required_arg ARG)
    string(REGEX REPLACE "^_" "" ARG_NAME ${ARG})
    if(NOT DEFINED ${ARG})
        message(FATAL_ERROR "cmake-helpers: required parameter ${ARG_NAME} not set")
        return()
    endif()
endmacro()

macro(header_file_set_variable_value line_end)
    foreach(file_name IN LISTS _TARGET_FILE_NAMES)
        file(STRINGS "${file_name}" lines)

        foreach(line IN LISTS lines)
            string(STRIP "${line}" line)
            set(variable_value "${variable_value}\"${line}\\n\"${line_end}\n")
        endforeach()
    endforeach()
    string(STRIP "${variable_value}" variable_value)

    # No line ending for last element. Escape to treat special characters.
    string(REGEX REPLACE "\\${line_end}$" "" variable_value "${variable_value}")
endmacro()

#[==========================================================================[
create_header_file
----------------

A function which creates a header file containing to contents of a ```file_name``.

.. code:: cmake

   create_header_file(
       <TARGET_FILE_NAME>
       <HEADER_FILE_NAME>
       <VARIABLE_NAME>
   )

Read ``TARGET_FILE_NAMES`` and create a string_view with their contents inside
``HEADER_FILE_NAME`` with the name ``VARIABLE_NAME`` and namespace ``NAMESPACE``.
#]==========================================================================]
function(create_header_file header_file_name variable_name)
    set(one_value_args NAMESPACE OUTPUT_DIR TARGET VISIBILITY MODE)
    set(multi_value_args TARGET_FILE_NAMES)
    cmake_parse_arguments("" "" "${one_value_args}" "${multi_value_args}" ${ARGN})

    check_required_arg(_TARGET_FILE_NAMES)

    # Get the correct define comment and namespace comment.
    string(TOUPPER "${header_file_name}" header_stem)
    string(REPLACE "." "_" header_stem ${header_stem})

    string(TOUPPER "${_NAMESPACE}" namespace_upper)
    string(REPLACE "::" "_" namespace_upper "${namespace_upper}")

    set(def_header "${namespace_upper}_${header_stem}")

    if(NOT DEFINED _MODE OR "${_MODE}" STREQUAL "constexpr_auto")
        cmake_helpers_status("create_header_file" "using constexpr_auto")
        header_file_set_variable_value("")
        set(variable_declaration [[constexpr auto ${variable_name} = ${variable_value};]])
    elseif("${_MODE}" STREQUAL "const_char")
        header_file_set_variable_value("")
        cmake_helpers_status("create_header_file" "using const_char")
        set(variable_declaration [[const char* ${variable_name} = ${variable_value};]])
    elseif("${_MODE}" STREQUAL "define_constant")
        # Double escape this to because it's entering a macro expansion.
        header_file_set_variable_value("\\\\")
        cmake_helpers_status("create_header_file" "using define_constant")
        set(variable_declaration [[#define ${variable_name} ${variable_value}]])
    else()
        cmake_helpers_error("create_header_file" "invalid mode: ${_MODE}")
        return()
    endif()

    if(DEFINED _NAMESPACE)
        # Note extra newlines.
        set(namespace_start [[namespace ${_NAMESPACE} {]])
        set(namespace_end [[} // ${_NAMESPACE}]])
    endif()

    set(template [[
        // Auto-generated by my cmake-helpers
        #ifndef ${def_header}
        #define ${def_header}

        ${namespace_start}
        ${variable_declaration}
        ${namespace_end}

        #endif // ${def_header}
    ]])

    # Parse the file template as lines of strings.
    string(REPLACE "\n" ";" lines "${template}")

    # Evaluate each line substituting the variables.
    foreach(line IN LISTS lines)
        string(STRIP "${line}" line)

        # Two layers of eval required.
        cmake_language(EVAL CODE "set(line \"${line}\")")
        cmake_language(EVAL CODE "set(line \"${line}\")")

        set(file "${file}${line}\n")
    endforeach()

    # Remove extra spaces.
    string(REGEX REPLACE "\n\n\n" "\n\n" file "${file}")

    if (NOT DEFINED _OUTPUT_DIR)
        set(_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
    endif ()

    cmake_path(APPEND _OUTPUT_DIR ${header_file_name} OUTPUT_VARIABLE output_file)
    file(WRITE "${output_file}" "${file}")

    cmake_helpers_status("create_header_file" "generated output file")

    if (DEFINED _TARGET AND DEFINED _VISIBILITY)
        cmake_helpers_status("create_header_file" "linking generated file to target ${_TARGET}")
        target_sources(${_TARGET} ${_VISIBILITY} ${output_file})
    endif ()

    set(cmake_helpers_ret ${_OUTPUT_DIR} PARENT_SCOPE)
endfunction()