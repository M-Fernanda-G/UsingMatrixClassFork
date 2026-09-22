#!/usr/bin/env sh
set -e

echo "removing old build file\n"
rm -rf build-v7.0.0

echo "Building\n"
cmake -S . -B build-v7.0.0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCUSTOM_MEMORY_ALLOCATOR_VERSION=v7.0.0 \
  -DBUILD_TESTING=ON

cmake --build build-v7.0.0 --parallel

echo "\n\nOverload tests:"
echo "\ntime ./build-v7.0.0/overloaded_linked_list 750000"
time ./build-v7.0.0/overloaded_linked_list 750000

echo "\ntime ./build-v7.0.0/overloaded_memory_stress 90"
time ./build-v7.0.0/overloaded_memory_stress 90

echo "\ntime ./build-v7.0.0/overloaded_new 90"
time ./build-v7.0.0/overloaded_new 90

echo "\ntime ./build-v7.0.0/overloaded_uniform_nodes 100 2500"
time ./build-v7.0.0/overloaded_uniform_nodes 100 2500

echo "\n\n Unit Tests:"
ctest --test-dir build-v7.0.0 --output-on-failure
