pub const crypto = @import("crypto.zig");
pub const webauthn = @import("webauthn.zig");
pub const xmldsig = @import("xmldsig.zig");
pub const ring_bridge = @import("ring_bridge_crypto.zig");

comptime {
    @export(&ringlib_init, .{ .name = "ringlib_init" });
}

fn ringlib_init(pState: ?*anyopaque) callconv(.c) void {
    if (pState) |s| ring_bridge.registerAll(s);
}

test {
    _ = crypto;
    _ = webauthn;
    _ = xmldsig;
}
