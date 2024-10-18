cmake_minimum_required(VERSION 3.29)
project(FractalGPU CXX CUDA)

find_package(SDL2 REQUIRED)
find_package(CUDAToolkit)

set(CMAKE_CXX_STANDARD 20)

add_executable(FractalGPU main.cpp fractal.cu)

set_target_properties(FractalGPU PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
target_link_libraries(FractalGPU PRIVATE SDL2::SDL2)
