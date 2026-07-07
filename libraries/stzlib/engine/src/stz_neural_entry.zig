pub const neural = @import("neural.zig");
pub const neural_embed = @import("neural_embed.zig");
pub const ring_bridge = @import("ring_bridge_neural.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

// C++ global constructors are NOT auto-invoked in this (gnu-ABI) Zig DLL, and the
// two clean fixes are both blocked/fragile here: (1) msvc ABI so ctors land in
// .CRT$XCU -> Zig 0.15.2 libc++abi won't compile for msvc; (2) walk the mingw
// `.ctors` list -> no linked crtend terminator, unsafe to bound. So ggml's
// namespace-scope statics are initialised via ctor-independent per-global patches
// (see vendor/ggml/src/gguf.cpp). See memory reference_neural_tier for the plan.

test {
    _ = neural;
    _ = neural_embed;
}
