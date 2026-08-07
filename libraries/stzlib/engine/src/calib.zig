// Softanza Engine -- the ONE calibration store (M5 of the multicore tier).
//
// WHY THIS FILE EXISTS. By M4 the engine carried SEVEN provisional
// parallel-dispatch thresholds across four files -- matmul's two flops
// gates, LU's min-n, two stats gates, topK's min-work, knnExact's min-n --
// every one a constant measured on ONE machine (Core 5 210H) and labeled
// "provisional until M5". The GPU plane grew its own name->threshold store
// in parallel (gpu.zig, stz_gpu_calib_set/get). Same idea, eight spellings:
// the duplication law, aimed at configuration instead of arithmetic.
//
// THE DESIGN, under the house laws:
//   - Handle tables are per-DLL, and so are statics: this store cannot be
//     shared memory across DLLs. THE FILE IS THE SHARED TRUTH: each DLL
//     lazily loads `stz_calibration.txt` from the working directory, once,
//     and every DLL that reads the same file agrees.
//   - No file -> the compiled defaults, which are the spike-measured
//     values. Behavior without a file is EXACTLY the pre-M5 behavior.
//   - Tests override gates directly (Gate.override), and an override
//     always wins over the file -- a test must never depend on the
//     machine it runs on.
//   - The `gpu.*` key namespace is RESERVED for the GPU plane's store
//     (owned by the GPU session); this module never defines gpu keys, so
//     the two stores can converge on one file without a collision.
//
// The file format is one `key = value` per line, `#` comments:
//
//     # written by tools/calibrate.zig on 2026-08-07
//     cpu.lu.par_min_n = 1024
//     cpu.topk.par_min_work = 8000000
//
// tools/calibrate.zig probes THIS machine and writes the file.

const std = @import("std");

const MAX_ENTRIES = 64;

var entries: [MAX_ENTRIES]struct { hash: u64, value: f64 } = undefined;
var n_entries: usize = 0;
var file_loaded = false;

fn lookup(key: []const u8) ?f64 {
    const h = std.hash.Wyhash.hash(0, key);
    for (entries[0..n_entries]) |e| {
        if (e.hash == h) return e.value;
    }
    return null;
}

/// Parse `key = value` lines into the store. Unknown keys are kept (they
/// hash like any other -- the gpu namespace flows through untouched);
/// malformed lines are skipped, never fatal: a broken calibration file
/// must degrade to defaults, not take the engine down.
pub fn loadFromText(text: []const u8) void {
    var it = std.mem.splitScalar(u8, text, '\n');
    while (it.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0 or line[0] == '#') continue;
        const eq = std.mem.indexOfScalar(u8, line, '=') orelse continue;
        const key = std.mem.trim(u8, line[0..eq], " \t");
        const val_s = std.mem.trim(u8, line[eq + 1 ..], " \t");
        const val = std.fmt.parseFloat(f64, val_s) catch continue;
        if (key.len == 0) continue;
        const h = std.hash.Wyhash.hash(0, key);
        for (entries[0..n_entries]) |*e| {
            if (e.hash == h) {
                e.value = val;
                break;
            }
        } else if (n_entries < MAX_ENTRIES) {
            entries[n_entries] = .{ .hash = h, .value = val };
            n_entries += 1;
        }
    }
}

pub const CALIB_FILE = "stz_calibration.txt";

fn ensureFileLoaded() void {
    if (file_loaded) return;
    file_loaded = true;
    const f = std.fs.cwd().openFile(CALIB_FILE, .{}) catch return;
    defer f.close();
    var buf: [16 * 1024]u8 = undefined;
    const n = f.readAll(&buf) catch return;
    loadFromText(buf[0..n]);
}

/// A dispatch threshold: a key, a spike-measured default, and the
/// resolution order OVERRIDE > FILE > DEFAULT. Declare one per gate:
///
///     pub var lu_gate = calib.Gate.init("cpu.lu.par_min_n", 1024);
///     ... if (n >= lu_gate.valueUsize()) ...
///
/// Tests call .override(x) (wins over everything) and .reset().
pub const Gate = struct {
    key: []const u8,
    def: f64,
    cached: f64 = 0,
    resolved: bool = false,
    locked: bool = false,

    pub fn init(key: []const u8, def: f64) Gate {
        return .{ .key = key, .def = def };
    }

    pub fn value(self: *Gate) f64 {
        if (self.locked) return self.cached;
        if (!self.resolved) {
            ensureFileLoaded();
            self.cached = lookup(self.key) orelse self.def;
            self.resolved = true;
        }
        return self.cached;
    }

    pub fn valueUsize(self: *Gate) usize {
        const v = self.value();
        if (v <= 0) return 0;
        if (v >= @as(f64, @floatFromInt(std.math.maxInt(usize) >> 1))) return std.math.maxInt(usize);
        return @intFromFloat(v);
    }

    pub fn override(self: *Gate, v: f64) void {
        self.cached = v;
        self.locked = true;
    }

    pub fn overrideUsize(self: *Gate, v: usize) void {
        // maxInt(usize) round-trips through f64 badly; clamp to the same
        // "effectively infinite" the valueUsize path uses.
        if (v >= std.math.maxInt(usize) >> 1) {
            self.override(@as(f64, @floatFromInt(std.math.maxInt(u64) >> 1)));
        } else {
            self.override(@as(f64, @floatFromInt(v)));
        }
    }

    pub fn reset(self: *Gate) void {
        self.locked = false;
        self.resolved = false;
    }
};

// ─── Tests ───

test "resolution order: override > file > default" {
    var g = Gate.init("test.some_gate", 1234);
    try std.testing.expectEqual(@as(f64, 1234), g.value()); // default

    loadFromText("# comment\n test.some_gate = 777 \njunk line\nbad = notanumber\n");
    var g2 = Gate.init("test.some_gate", 1234);
    try std.testing.expectEqual(@as(f64, 777), g2.value()); // file wins

    g2.override(42);
    try std.testing.expectEqual(@as(f64, 42), g2.value()); // override wins
    g2.reset();
    try std.testing.expectEqual(@as(f64, 777), g2.value()); // back to file
}

test "malformed lines never poison the store" {
    loadFromText("=\n = 5\nkey =\nkey = nan?x\n#a=1\n   \n");
    // nothing to assert beyond "did not crash and did not add junk keys
    // that collide" -- lookups of untouched keys still miss:
    try std.testing.expectEqual(@as(?f64, null), lookup("never.defined"));
}

test "usize round trip including the huge sentinel" {
    var g = Gate.init("test.usize_gate", 4096);
    try std.testing.expectEqual(@as(usize, 4096), g.valueUsize());
    g.overrideUsize(std.math.maxInt(usize)); // the force-serial idiom
    try std.testing.expect(g.valueUsize() > (1 << 60));
    g.overrideUsize(16);
    try std.testing.expectEqual(@as(usize, 16), g.valueUsize());
}
