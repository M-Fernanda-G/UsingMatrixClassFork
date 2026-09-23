#include "custom_memory/MemoryPool.hpp"

#include <cassert>
#include <cstddef>

int main() {
    auto& pool = custom_memory::MemoryPool::instance();
    assert(pool.initialize(1024 * 1024));

    void* initial = pool.allocate(32);
    pool.deallocate(initial);

    const auto before = pool.metrics();

    void* reused = pool.allocate(32);
    const auto after = pool.metrics();

    assert(
        after.thread_cache_hits ==
        before.thread_cache_hits + 1
    );
    assert(
        after.thread_cache_misses ==
        before.thread_cache_misses
    );
    assert(
        after.central_pool_searches ==
        before.central_pool_searches
    );
    assert(
        after.central_mutex_acquisitions ==
        before.central_mutex_acquisitions
    );
    assert(
        after.thread_cache_scanned_nodes ==
        before.thread_cache_scanned_nodes
    );

    pool.deallocate(reused);
    assert(pool.shutdown());
}
