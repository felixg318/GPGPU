cmake_minimum_required(VERSION 3.21)
project(BlurExample LANGUAGES CXX HIP)

set(CMAKE_HIP_COMPILER hipcc)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(OpenCV REQUIRED)

set(SOURCES
    main.cpp
    kernel.hpp
    gaussian_blur.hip
)

add_executable(BlurExample ${SOURCES})

target_link_libraries(BlurExample PRIVATE ${OpenCV_LIBS})
target_include_directories(BlurExample PRIVATE ${OpenCV_INCLUDE_DIRS})
set_source_files_properties(gaussian_blur.hip PROPERTIES LANGUAGE HIP)

