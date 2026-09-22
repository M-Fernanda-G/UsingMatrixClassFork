#include "custom_memory/MemoryPool.hpp"

#include <array>
#include <cassert>
#include <cstddef>

int main() {
    auto& pool = custom_memory::MemoryPool::instance();
    assert(pool.initialize(256 * 1024));

    std::array<void*, 128> burst{};
    for (void*& pointer : burst) {
        pointer = pool.allocate(16);
    }
    for (void* pointer : burst) {
        pool.deallocate(pointer);
    }

    // Generate several low-demand policy epochs after the burst.
    for (std::size_t index = 0; index < 256; ++index) {
        void* pointer = pool.allocate(16);
        pool.deallocate(pointer);
    }

    const auto metrics = pool.metrics();
    assert(metrics.cache_policy_tunes > 0);
    assert(metrics.cache_target_increases > 0);
    assert(metrics.cache_target_decreases > 0);

    assert(pool.shutdown());
}
