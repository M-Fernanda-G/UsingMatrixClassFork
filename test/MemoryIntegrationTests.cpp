#include "custom_memory/GlobalNew.hpp"

#include <matrix/Matrix.hpp>

#include <gtest/gtest.h>

#include <cstddef>
#include <cstdint>

namespace {

custom_memory::MemoryError reported_error =
    custom_memory::MemoryError::invalid_pointer;
bool error_reported = false;

void recordError(custom_memory::MemoryError error, const void*) noexcept {
    reported_error = error;
    error_reported = true;
}

TEST(GlobalNew, AllocatesFromTheMappedRegion) {
    int* value = new int(42);

    EXPECT_TRUE(custom_memory::owns(value));
    EXPECT_EQ(*value, 42);

    delete value;
}

TEST(GlobalNew, SupportsOverAlignedObjects) {
    struct alignas(64) AlignedValue {
        int value;
    };

    AlignedValue* value = new AlignedValue{42};

    EXPECT_TRUE(custom_memory::owns(value));
    EXPECT_EQ(reinterpret_cast<std::uintptr_t>(value) % 64, 0U);
    EXPECT_EQ(value->value, 42);

    delete value;
}

TEST(MatrixDependency, UsesTheCallersGlobalNew) {
    const auto before = custom_memory::statistics();
    {
        matrix::Matrix<int> value(2, 3);
        value.set(1, 2, 17);

        const auto during = custom_memory::statistics();
        EXPECT_GE(during.live_allocations, before.live_allocations + 3);
        EXPECT_EQ(value.get(1, 2), 17);
    }

    const auto after = custom_memory::statistics();
    EXPECT_EQ(after.live_allocations, before.live_allocations);
}

TEST(GlobalNew, AllocatorReusesSmallChunks) {
#ifdef CUSTOM_ENABLE_METRICS
    const auto before = custom_memory::metrics();

    for (std::size_t index = 0; index < 256; ++index) {
        auto* value = new std::uint64_t(index);

        ASSERT_TRUE(custom_memory::owns(value));
        ASSERT_EQ(*value, index);

        delete value;
    }

    const auto after = custom_memory::metrics();
    EXPECT_GT(
        after.thread_cache_hits - before.thread_cache_hits,
        0U
    );
#else
    GTEST_SKIP() << "Metrics are disabled in this build.";
#endif
}

TEST(MatrixDependency, MultipliesUsingMappedAllocations) {
    matrix::Matrix<int> left(2, 2);
    matrix::Matrix<int> right(2, 2);

    left.set(0, 0, 1);
    left.set(0, 1, 2);
    left.set(1, 0, 3);
    left.set(1, 1, 4);
    right.set(0, 0, 5);
    right.set(0, 1, 6);
    right.set(1, 0, 7);
    right.set(1, 1, 8);

    const matrix::Matrix<int> result = left * right;

    EXPECT_EQ(result.get(0, 0), 19);
    EXPECT_EQ(result.get(0, 1), 22);
    EXPECT_EQ(result.get(1, 0), 43);
    EXPECT_EQ(result.get(1, 1), 50);
}

TEST(GlobalNew, ReportsRearCanaryCorruption) {
    auto& pool = custom_memory::MemoryPool::instance();
    pool.setErrorHandler(recordError);
    error_reported = false;

    char* values = new char[8];
    volatile char* observable_values = values;
    observable_values[8] = 0;
    delete[] values;

    EXPECT_TRUE(error_reported);
    EXPECT_EQ(
        reported_error,
        custom_memory::MemoryError::rear_canary_corrupted
    );
    pool.setErrorHandler(nullptr);
}

}
