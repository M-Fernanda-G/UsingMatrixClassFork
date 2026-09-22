#include "NestedMatrixStress.hpp"

#include <custom_memory/GlobalNew.hpp>

#include <cstddef>

namespace {

bool initializeMemory(std::size_t bytes) noexcept {
    return custom_memory::initialize(bytes);
}

bool shutdownMemory() noexcept {
#ifdef CUSTOM_ENABLE_METRICS
    const custom_memory::AllocatorMetrics metrics =
        custom_memory::metrics();

    std::printf(
        "allocator metrics: \n"
        "cache_hits=%zu \tcache_misses=%zu \n"
        "central_searches=%zu \tsearched_nodes=%zu \n"
        "cache_refills=%zu \tcache_flushes=%zu \n"
        "target_flush_events=%zu \tbyte_limit_flush_events=%zu \n"
        "coalesce_on_allocation=%zu\n",
        metrics.thread_cache_hits,
        metrics.thread_cache_misses,
        metrics.central_pool_searches,
        metrics.searched_free_list_nodes,
        metrics.cache_refills,
        metrics.cache_flushes,
        metrics.cache_target_flush_events,
        metrics.cache_byte_limit_flush_events,
        metrics.coalesce_on_allocation_events
    );
#endif

    return custom_memory::shutdown();
}

}

int main(int argument_count, char** arguments) {
    return nested_matrix_stress::run(
        argument_count,
        arguments,
        "overloaded new",
        initializeMemory,
        shutdownMemory
    );
}
