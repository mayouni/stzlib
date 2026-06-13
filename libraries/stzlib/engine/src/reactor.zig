// Reactor -- cross-platform async I/O backbone on vendored libuv.
//
// Tier 2 foundation. libuv is the industry-standard event loop (Node.js,
// Julia, Neovim): epoll on Linux, kqueue on macOS/BSD, IOCP on Windows,
// behind one proactor API. We vendor it as C source (engine/vendor/libuv,
// like utf8proc/pcre2/sqlite) and build the engine's async surface on top
// of it instead of hand-rolling per-OS reactors.
//
// This first slice only proves the vendor + build + link path is sound:
//   reactor_version()   -> libuv version string (links + headers OK)
//   reactor_selftest()  -> runs a real loop with a one-shot timer and
//                          returns the number of timer callbacks fired
//                          (expected 1) -- proves the loop actually runs.
//
// The full reactor surface (a loop owned by an engine worker thread,
// async TCP/HTTP multiplexing, results drained through the existing
// submit/poll handle pattern so Ring stays synchronous) lands in
// subsequent slices.

const std = @import("std");
const c = @cImport({
    @cInclude("uv.h");
});

/// libuv version string, e.g. "1.52.1".
pub fn reactor_version() callconv(.c) [*c]const u8 {
    return c.uv_version_string();
}

/// Numeric libuv version (UV_VERSION_HEX-style: major<<16 | minor<<8 | patch).
pub fn reactor_version_hex() callconv(.c) u32 {
    return @intCast(c.uv_version());
}

// Self-test: spin up a private loop, arm a 1ms one-shot timer, run the
// loop to completion, and report how many times the timer fired. A
// healthy build returns 1.
var selftest_fired: i32 = 0;

fn onSelftestTimer(handle: [*c]c.uv_timer_t) callconv(.c) void {
    selftest_fired += 1;
    _ = c.uv_timer_stop(handle);
}

pub fn reactor_selftest() callconv(.c) i32 {
    selftest_fired = 0;
    var loop: c.uv_loop_t = undefined;
    if (c.uv_loop_init(&loop) != 0) return -1;
    var timer: c.uv_timer_t = undefined;
    if (c.uv_timer_init(&loop, &timer) != 0) {
        _ = c.uv_loop_close(&loop);
        return -2;
    }
    if (c.uv_timer_start(&timer, onSelftestTimer, 1, 0) != 0) {
        _ = c.uv_loop_close(&loop);
        return -3;
    }
    _ = c.uv_run(&loop, c.UV_RUN_DEFAULT);
    _ = c.uv_loop_close(&loop);
    return selftest_fired;
}

// Tests here need libuv's headers + objects, so they are not part of the
// default `zig build test` sweep (reactor is not imported by engine.zig).
// They run via the engine build's stz_reactor DLL + a Ring smoke, and
// can also be run with:
//   zig test src/reactor.zig -I vendor/libuv/include -I vendor/libuv/src \
//     vendor/libuv/src/*.c vendor/libuv/src/win/*.c -lc <win libs>
test "reactor: version is non-empty" {
    const v = reactor_version();
    try std.testing.expect(v != null);
    try std.testing.expect(std.mem.span(v).len > 0);
}

test "reactor: self-test fires exactly one timer" {
    try std.testing.expectEqual(@as(i32, 1), reactor_selftest());
}
