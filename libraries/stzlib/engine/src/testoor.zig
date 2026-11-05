//! Testoor core (roadmap P3, TESTOOR_ZIG_CORE.md): the judge, the promises, the logbook.
//! Nothing here imports Ring; `zig test` runs it with no virtual machine. The Ring face
//! reaches it through ring_bridge_testoor.zig.

pub const text = @import("testoor_text.zig");
pub const json = @import("testoor_json.zig");
pub const promises = @import("testoor_promises.zig");
pub const verdict = @import("testoor_verdict.zig");
pub const logbook = @import("testoor_logbook.zig");
pub const api = @import("testoor_api.zig");
pub const clock = @import("testoor_clock.zig");

test {
    _ = clock;
    _ = text;
    _ = json;
    _ = promises;
    _ = verdict;
    _ = logbook;
    _ = api;
    _ = @import("testoor_golden_test.zig");
}
