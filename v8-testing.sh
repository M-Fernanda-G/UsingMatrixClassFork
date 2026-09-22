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
ctest --test-dir build-v8-metrics --output-on-failure -V

echo "\nBuilding v8 Release\n"
cmake -S . -B build-v8 \
   -DCMAKE_BUILD_TYPE=Release \
   -DCUSTOM_ENABLE_METRICS=OFF \
   -DBUILD_TESTING=ON \
   -DCUSTOM_MEMORY_ALLOCATOR_LOCAL_SOURCE="$PWD/CustomMemoryAllocator_v8/"

cmake --build build-v8 --parallel
ctest --test-dir build-v8 --output-on-failure

echo "\n\nOverload tests:"
echo "\n\n./build-v8-metrics/overloaded_linked_list 750000"
./build-v8-metrics/overloaded_linked_list 750000

echo "\ntime ./build-v8/overloaded_linked_list 750000"
time ./build-v8/overloaded_linked_list 750000

echo "\n\n./build-v8-metrics/overloaded_memory_stress 90"
./build-v8-metrics/overloaded_memory_stress 90

echo "\ntime ./build-v8/overloaded_memory_stress 90"
time ./build-v8/overloaded_memory_stress 90

echo "\n\n./build-v8-metrics/overloaded_new 140"
./build-v8-metrics/overloaded_new 140

echo "\ntime ./build-v8/overloaded_new 140"
time ./build-v8/overloaded_new 140

echo "\n\n./build-v8-metrics/overloaded_uniform_nodes 100 2500"
./build-v8-metrics/overloaded_uniform_nodes 100 2500

echo "\ntime ./build-v8/overloaded_uniform_nodes 100 2500"
time ./build-v8/overloaded_uniform_nodes 100 2500

echo "\n\nUnit Tests:"
echo "\nBuild-v8-metrics Tests"
ctest --test-dir build-v8-metrics --output-on-failure
echo "\nBuild-v8 Tests"
ctest --test-dir build-v8 -V --output-on-failure
