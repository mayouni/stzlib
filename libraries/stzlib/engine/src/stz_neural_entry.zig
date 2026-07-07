pub const neural = @import("neural.zig");
pub const neural_embed = @import("neural_embed.zig");
pub const ring_bridge = @import("ring_bridge_neural.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

// C++ static initializers are NOT run in this (gnu-ABI) Zig DLL on Windows --
// neither namespace-scope global ctors NOR function-local-static (Meyers) guards.
// The two "clean" fixes are both blocked/fragile: (1) msvc ABI so ctors land in
// .CRT$XCU -> Zig 0.15.2 libc++abi won't compile for msvc; (2) walk the mingw
// `.ctors` list -> no linked crtend terminator, unsafe to bound. WORKING FIX:
// make each ggml C++ static ctor-INDEPENDENT (switch / constant-initialized
// primitive / short-circuit when the feature is unused). This carried the full
// BERT embedding forward pass -- see vendor/ggml/NOTICE for the patch set and
// memory reference_neural_tier for the story.

test {
    _ = neural;
    _ = neural_embed;
}
