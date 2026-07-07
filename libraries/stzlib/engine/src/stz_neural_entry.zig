pub const neural = @import("neural.zig");
pub const neural_embed = @import("neural_embed.zig");
pub const ring_bridge = @import("ring_bridge_neural.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

// NOTE: C++ global constructors are NOT auto-invoked in this Zig-built DLL
// (mingw/gnu COFF ABI -> ctors in `.ctors`, not run at load). So ggml's
// namespace-scope statics (std::map type tables, backend registries) stay
// empty. We currently neutralise this per-global with ctor-independent patches
// (e.g. vendor/ggml/src/gguf.cpp gguf_type_size -> switch). The proper fix
// (run the ctors at load, or force the msvc ABI so they land in .CRT$XCU) is
// pending -- see memory reference_neural_tier.

test {
    _ = neural;
    _ = neural_embed;
}
