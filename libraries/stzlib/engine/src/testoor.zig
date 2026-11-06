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
pub const graph = @import("testoor_graph.zig");
pub const routes = @import("testoor_routes.zig");
pub const counters = @import("testoor_counters.zig");
pub const walk = @import("testoor_walk.zig");
pub const runner = @import("testoor_runner.zig");

test {
    _ = clock;
    _ = graph;
    _ = routes;
    _ = counters;
    _ = walk;
    _ = runner;
    _ = text;
    _ = json;
    _ = promises;
    _ = verdict;
    _ = logbook;
    _ = api;
    _ = @import("testoor_golden_test.zig");
}
