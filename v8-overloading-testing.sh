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

# echo "\n\nUnit Tests:"
# echo "\nBuild-v8-metrics Tests"
# ctest --test-dir build-v8-metrics --output-on-failure
# echo "\nBuild-v8 Tests"
# ctest --test-dir build-v8 --output-on-failure
