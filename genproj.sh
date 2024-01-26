#!/bin/bash

# "$#": Expands into a number indicating the number of positional parameters that are available.
if [ "$#" -ne 1 ]; then
    echo -e "\\nPlease provide one \"project_name\" as argument.\\n"
    exit -1
fi

project_name="$(basename "$1" | tr -st ' ' '_')"
# PROJECT_PATH="$(dirname "$1")"

mkdir -p "$project_name/src" "$project_name/include" "$project_name/test"

more > "$project_name/.gitignore" <<//HERE_DOCUMENT//
build
.vscode
//HERE_DOCUMENT//

more > "$project_name/src/main.cpp" <<//HERE_DOCUMENT//
#include <iostream>

int main() {
    return 0;
}
//HERE_DOCUMENT//


PROJECT_NAME='${PROJECT_NAME}'
Boost_INCLUDE_DIRS='${Boost_INCLUDE_DIRS}'
Boost_LIBRARIES='${Boost_LIBRARIES}'
CMAKE_SOURCE_DIR='${CMAKE_SOURCE_DIR}'
CMAKE_CURRENT_SOURCE_DIR='${CMAKE_CURRENT_SOURCE_DIR}'
CMAKE_CURRENT_BINARY_DIR='${CMAKE_CURRENT_BINARY_DIR}'
module='${module}'

more > "$project_name/CMakeLists.txt" <<//HERE_DOCUMENT//
cmake_minimum_required(VERSION 3.25)
project($project_name VERSION 0.1.0)
set(CMAKE_CXX_STANDARD 20)

find_package(Threads REQUIRED)

add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Threads::Threads
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/include
)

add_subdirectory(test)
//HERE_DOCUMENT//

more > "$project_name/test/CMakeLists.txt" <<//HERE_DOCUMENT//
set (Boost_USE_STATIC_LIBS OFF)
find_package (Boost 1.83 CONFIG REQUIRED COMPONENTS unit_test_framework)

enable_testing()

foreach(module
        Main
)
    add_executable (${PROJECT_NAME}Tests${module} test_${module}.cpp)
    
    target_link_libraries(${PROJECT_NAME}Tests${module} PUBLIC
        Threads::Threads
        ${Boost_LIBRARIES}
)

    target_include_directories(${PROJECT_NAME}Tests${module} PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${Boost_INCLUDE_DIRS}
)

add_test(NAME ${PROJECT_NAME}Tests${module} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Tests${module})
endforeach()
//HERE_DOCUMENT//

more > "$project_name/test/test_Main.cpp" <<//HERE_DOCUMENT//
#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMacroInspection"

#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MAIN  // in only one cpp file
#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_SUITE(Main)

    BOOST_AUTO_TEST_CASE(first_test) {
    }

BOOST_AUTO_TEST_SUITE_END()

#pragma clang diagnostic pop
//HERE_DOCUMENT//
