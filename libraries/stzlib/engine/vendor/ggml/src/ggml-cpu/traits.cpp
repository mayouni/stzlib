#include "traits.h"

#include "ggml-backend-impl.h"
#include "ggml-backend.h"

namespace ggml::cpu {
tensor_traits::~tensor_traits() {}

extra_buffer_type::~extra_buffer_type() {}
}  // namespace ggml::cpu

// STZ PATCH (GPU routing, 2026-08-07): big MUL_MAT nodes may be claimed by
// the wgpu path compiled into the SAME DLL (neural_gpu.zig in stz_neural;
// stz_matrix links a return-0 stub). The callee's verdict is shape-
// deterministic so every worker thread agrees; thread 0 computes, the rest
// are held by ggml's per-node barrier. See vendor/ggml/NOTICE.
extern "C" int stz_neural_gpu_try_mul_mat(int ith, struct ggml_tensor * op);

bool ggml_cpu_extra_compute_forward(struct ggml_compute_params * params, struct ggml_tensor * op) {
    if (op->op == GGML_OP_MUL_MAT && stz_neural_gpu_try_mul_mat(params->ith, op)) {
        return true;
    }
    // STZ PATCH: short-circuit -- no extra buffer types are compiled in (no
    // GGML_USE_CPU_REPACK/AMX/KLEIDIAI). Avoids the function-local-static
    // std::vector init (Meyers) that crashes without C++ static-init support.
    return false;
    for (auto extra : ggml_backend_cpu_get_extra_buffer_types()) {
        if (extra && extra->context) {
            auto buf_extra     = (ggml::cpu::extra_buffer_type *) extra->context;
            auto tensor_traits = buf_extra->get_tensor_traits(op);
            if (tensor_traits && tensor_traits->compute_forward(params, op)) {
                return true;
            }
        }
    }
    return false;
}

bool ggml_cpu_extra_work_size(int n_threads, const struct ggml_tensor * op, size_t * size) {
    // STZ PROBE: short-circuit -- we build without GGML_USE_CPU_REPACK / AMX /
    // KLEIDIAI, so there are never any extra buffer types. Testing whether the
    // function-local-static std::vector init is what crashes here.
    return false;
    for (auto extra : ggml_backend_cpu_get_extra_buffer_types()) {
        if (extra && extra->context) {
            auto buf_extra     = (ggml::cpu::extra_buffer_type *) extra->context;
            auto tensor_traits = buf_extra->get_tensor_traits(op);
            if (tensor_traits && tensor_traits->work_size(n_threads, op, *size)) {
                return true;
            }
        }
    }
    return false;
}
