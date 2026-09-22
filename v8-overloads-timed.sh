echo "\n\nOverload tests:"

echo "\ntime ./build-v8/overloaded_linked_list 750000"
time ./build-v8/overloaded_linked_list 750000

echo "\ntime ./build-v8/overloaded_memory_stress 90"
time ./build-v8/overloaded_memory_stress 90

echo "\ntime ./build-v8/overloaded_new 140"
time ./build-v8/overloaded_new 140

echo "\ntime ./build-v8/overloaded_uniform_nodes 100 2500"
time ./build-v8/overloaded_uniform_nodes 100 2500
