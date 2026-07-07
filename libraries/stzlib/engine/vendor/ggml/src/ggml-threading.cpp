#include "ggml-threading.h"
#include <atomic>

// STZ PATCH: was `std::mutex ggml_critical_section_mutex;` (namespace-scope).
// The Zig-built (mingw/gnu ABI) DLL does not run C++ static initializers -- NOT
// global constructors NOR function-local-static (Meyers) guards -- so neither a
// namespace-scope std::mutex nor a Meyers-singleton mutex initializes; both
// crash on first use. A `std::atomic_flag` with ATOMIC_FLAG_INIT is CONSTANT-
// initialized (no dynamic ctor, no guard variable -> lands zero-init in .bss),
// so it works without any runtime static-init support. Used as a tiny spinlock;
// the critical section is only held briefly during one-time table/registry init.
// See NOTICE + reference_neural_tier memory.
static std::atomic_flag ggml_critical_section_flag = ATOMIC_FLAG_INIT;

void ggml_critical_section_start() {
    while (ggml_critical_section_flag.test_and_set(std::memory_order_acquire)) {
        // spin
    }
}

void ggml_critical_section_end(void) {
    ggml_critical_section_flag.clear(std::memory_order_release);
}
