#!/usr/bin/env sh
set -e

echo "removing old build file\n"
rm -rf build-v8
rm -rf build-v8-metrics
rm -rf build-v8-allocation-tests

echo "Building Allocator Tests:\n"
cmake -S CustomMemoryAllocator_v8/ -B build-v8-allocator-tests \
  -DCMAKE_BUILD_TYPE=Debug \
  -DBUILD_TESTING=ON \
  -DCUSTOM_ENABLE_METRICS=ON

cmake --build build-v8-allocator-tests --parallel
echo "\n\nRunning Integration Tests:"
ctest --test-dir build-v8-allocator-tests --output-on-failure -V

echo "\nBuilding v8 Metrics\n"
cmake -S . -B build-v8-metrics \
   -DCMAKE_BUILD_TYPE=Release \
   -DBUILD_TESTING=ON \
   -DCUSTOM_ENABLE_METRICS=ON \
   -DCUSTOM_MEMORY_ALLOCATOR_LOCAL_SOURCE="$PWD/CustomMemoryAllocator_v8/"

cmake --build build-v8-metrics --parallel
ctest --test-dir build-v8-metrics --output-on-failure

echo "\nBuilding v8 Release\n"
cmake -S . -B build-v8 \
   -DCMAKE_BUILD_TYPE=Release \
   -DCUSTOM_ENABLE_METRICS=OFF \
   -DBUILD_TESTING=ON \
   -DCUSTOM_MEMORY_ALLOCATOR_LOCAL_SOURCE="$PWD/CustomMemoryAllocator_v8/"

cmake --build build-v8 --parallel
ctest --test-dir build-v8 --output-on-failure
