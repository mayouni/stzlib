//! THE SOUND STUDIO -- the sound plane's listening bench, in a browser.
//!
//! ONE FILE TO RUN. Launch it and it opens your browser on itself; there is no
//! port to pick, no page to point it at, no server to start separately. The
//! page is EMBEDDED in the exe (@embedFile), so the binary is the whole tool.
//!
//! Built by `zig build` alongside every engine DLL, which is the point: a
//! studio that can drift from the engine it measures is worse than no studio.
//! Rebuild the engine and you have rebuilt the studio.
//!
//!     zig build              -- builds it into zig-out/bin/
//!     zig build studio       -- builds it AND runs it
//!     stz_sound_studio       -- run it directly; it finds a port and opens
//!                               the browser itself
//!     stz_sound_studio --html tools/studio.html   -- serve the page from disk
//!                               instead of the embedded copy, for editing it
//!
//! Audio is rendered by the REAL engine (soundgraph.zig + sound.zig) and handed
//! to the page as a WAV. Nothing is synthesised in JavaScript, so what you hear
//! in the browser is what the plane does. "Play on speakers" additionally
//! drives the live SN3 path: producer thread, ring buffer, device callback.
//!
//! AND IT IS MEASURED BY THE REAL ANALYSIS (soundanalysis.zig): every sample
//! you play also draws its spectrogram and its spectrum, with its LUFS and its
//! loudest partial underneath. The server measures and sends NUMBERS; the page
//! draws them. That is the sound plane's own law -- an analysis returns a grid,
//! and drawing it is a separate step -- and the browser is simply another
//! drawing surface, exactly as stzCanvas is.
//!
//! WHY THIS OWNS ITS SOCKET LOOP rather than using stz_tcp: tcp_recv could not
//! read from an accepted socket on Windows (Stream.read -> ReadFile fails
//! there; src/tcp.zig now uses std.posix.recv, as testserver.zig always did).
//! A listening bench should not wait on another plane's fix to land.
//!
//! One connection at a time, on purpose: a serial loop cannot race the
//! engine's global handle tables.

const std = @import("std");
const builtin = @import("builtin");
const gph = @import("gph");
const snd = gph.snd; // ONE module -- see the note at the top of soundgraph.zig

const alloc = std.heap.c_allocator;
const RATE: u32 = 48000;

/// The page ships INSIDE the binary. No install step, no working directory to
/// be in, nothing to lose track of.
const EMBEDDED_HTML = @embedFile("studio.html");

var html_override: ?[]const u8 = null; // --html <path>, for editing the page
var wav_path: []u8 = undefined; // a real file in the system temp dir
/// Where the narrated guards live. Resolved from the exe's own location, so
/// running zig-out/bin/stz_sound_studio finds them with no argument.
var guards_dir: []const u8 = "";
var have_device = false;
var device_name: []const u8 = "none";

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var want_port: ?u16 = null;
    var no_open = false;
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--html") and i + 1 < args.len) {
            i += 1;
            html_override = args[i];
        } else if (std.mem.eql(u8, args[i], "--guards") and i + 1 < args.len) {
            i += 1;
            guards_dir = args[i];
        } else if (std.mem.eql(u8, args[i], "--no-open")) {
            no_open = true;
        } else if (std.fmt.parseInt(u16, args[i], 10)) |p| {
            want_port = p;
        } else |_| {}
    }

    // The rendered WAV goes to the system temp dir. Nothing to create, nothing
    // to clean up, and no assumption about which directory you launched from.
    const tmp = std.process.getEnvVarOwned(alloc, "TEMP") catch
        (std.process.getEnvVarOwned(alloc, "TMPDIR") catch try alloc.dupe(u8, "."));
    defer alloc.free(tmp);
    wav_path = try std.fmt.allocPrint(alloc, "{s}/stz_studio_patch.wav", .{tmp});

    // zig-out/bin/ -> zig-out -> engine -> stzlib, then base/test/sound
    if (guards_dir.len == 0) {
        const exe_dir = std.fs.selfExeDirPathAlloc(alloc) catch "";
        guards_dir = std.fmt.allocPrint(alloc, "{s}/../../../base/test/sound", .{exe_dir}) catch "";
    }

    have_device = gph.dev.isAvailable() == 1;
    if (have_device) device_name = gph.dev.backendName();

    // FIND A FREE PORT rather than fail on a busy one. "Port 8730 is in use"
    // is not information the person who wants to hear a sound can act on.
    var server: std.net.Server = undefined;
    var port: u16 = 0;
    const first: u16 = want_port orelse 8730;
    var tries: u16 = 0;
    while (tries < 20) : (tries += 1) {
        const p = first + tries;
        const addr = std.net.Address.parseIp("127.0.0.1", p) catch continue;
        server = addr.listen(.{ .reuse_address = true }) catch continue;
        port = p;
        break;
    }
    if (port == 0) {
        std.debug.print("could not bind any port in {d}..{d}\n", .{ first, first + 19 });
        return;
    }
    defer server.deinit();

    const url = try std.fmt.allocPrint(alloc, "http://127.0.0.1:{d}", .{port});
    defer alloc.free(url);

    std.debug.print("\n  ===============================================\n", .{});
    std.debug.print("   THE SOFTANZA SOUND STUDIO\n", .{});
    std.debug.print("  ===============================================\n", .{});
    std.debug.print("   device : {s}\n", .{device_name});
    std.debug.print("   page   : {s}\n", .{if (html_override) |h| h else "embedded in this binary"});
    std.debug.print("\n   {s}\n", .{url});
    std.debug.print("   Ctrl+C to stop\n\n", .{});

    if (!no_open) openBrowser(url);

    while (true) {
        const conn = server.accept() catch continue;
        handle(conn.stream) catch {};
        conn.stream.close();
    }
}

/// Open the page in whatever the OS calls a browser. Failing to is not fatal --
/// the URL is printed above, and a headless box has no browser to open.
fn openBrowser(url: []const u8) void {
    const argv: []const []const u8 = switch (builtin.os.tag) {
        // the empty "" is the window TITLE for `start`; without it, a quoted
        // URL becomes the title and no browser opens
        .windows => &.{ "cmd", "/c", "start", "", url },
        .macos => &.{ "open", url },
        else => &.{ "xdg-open", url },
    };
    var child = std.process.Child.init(argv, alloc);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    _ = child.spawn() catch return;
    _ = child.wait() catch return;
}

// ---------------------------------------------------------------- http

fn readRequest(stream: std.net.Stream, buf: []u8) ?[]u8 {
    var total: usize = 0;
    while (total < buf.len) {
        // std.posix.recv on the raw handle -- see the header note.
        const n = std.posix.recv(stream.handle, buf[total..], 0) catch return null;
        if (n == 0) break;
        total += n;
        if (std.mem.indexOf(u8, buf[0..total], "\r\n\r\n") != null) break;
    }
    if (total == 0) return null;
    return buf[0..total];
}

fn respond(stream: std.net.Stream, status: []const u8, ctype: []const u8, body: []const u8) void {
    var head: [256]u8 = undefined;
    const h = std.fmt.bufPrint(&head, "HTTP/1.1 {s}\r\nContent-Type: {s}\r\nContent-Length: {d}\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n", .{ status, ctype, body.len }) catch return;
    _ = stream.writeAll(h) catch return;
    _ = stream.writeAll(body) catch return;
}

fn handle(stream: std.net.Stream) !void {
    var buf: [8192]u8 = undefined;
    const req = readRequest(stream, &buf) orelse return;

    const line_end = std.mem.indexOf(u8, req, "\r\n") orelse req.len;
    const line = req[0..line_end];
    var it = std.mem.splitScalar(u8, line, ' ');
    _ = it.next() orelse return; // method
    const target = it.next() orelse return;

    var route = target;
    var query: []const u8 = "";
    if (std.mem.indexOfScalar(u8, target, '?')) |q| {
        route = target[0..q];
        query = target[q + 1 ..];
    }
    std.debug.print("   {s}\n", .{route});

    if (std.mem.eql(u8, route, "/")) {
        // the embedded copy unless --html pointed at a file, which is how you
        // edit the page without rebuilding
        if (html_override) |h| {
            const page = std.fs.cwd().readFileAlloc(alloc, h, 4 << 20) catch {
                respond(stream, "500 Internal Server Error", "text/plain", "--html file not found");
                return;
            };
            defer alloc.free(page);
            respond(stream, "200 OK", "text/html; charset=utf-8", page);
        } else {
            respond(stream, "200 OK", "text/html; charset=utf-8", EMBEDDED_HTML);
        }
    } else if (std.mem.eql(u8, route, "/api/status")) {
        var b: [256]u8 = undefined;
        const s = try std.fmt.bufPrint(&b, "{{\"engine\":true,\"device\":{s},\"deviceName\":\"{s}\",\"rate\":{d}}}", .{ if (have_device) "true" else "false", device_name, RATE });
        respond(stream, "200 OK", "application/json", s);
    } else if (std.mem.eql(u8, route, "/api/render")) {
        try apiRender(stream, query);
    } else if (std.mem.eql(u8, route, "/api/play")) {
        try apiPlay(stream, query);
    } else if (std.mem.eql(u8, route, "/api/analysis")) {
        try apiAnalysis(stream, query);
    } else if (std.mem.eql(u8, route, "/api/compose")) {
        try apiCompose(stream);
    } else if (std.mem.eql(u8, route, "/api/guards")) {
        try apiGuardList(stream);
    } else if (std.mem.eql(u8, route, "/api/run")) {
        try apiRun(stream, query);
    } else if (std.mem.eql(u8, route, "/api/guard")) {
        try apiGuard(stream, query);
    } else if (std.mem.eql(u8, route, "/api/wav")) {
        const data = std.fs.cwd().readFileAlloc(alloc, wav_path, 256 << 20) catch {
            respond(stream, "404 Not Found", "text/plain", "no render yet");
            return;
        };
        defer alloc.free(data);
        respond(stream, "200 OK", "audio/wav", data);
    } else {
        respond(stream, "404 Not Found", "text/plain", "no such route");
    }
}

fn qnum(query: []const u8, key: []const u8, dflt: f64) f64 {
    var it = std.mem.splitScalar(u8, query, '&');
    while (it.next()) |pair| {
        const eq = std.mem.indexOfScalar(u8, pair, '=') orelse continue;
        if (std.mem.eql(u8, pair[0..eq], key)) {
            return std.fmt.parseFloat(f64, pair[eq + 1 ..]) catch dflt;
        }
    }
    return dflt;
}

// ---------------------------------------------------------------- the patch
//
//   oscillator -> [filter] -> [envelope] -> [delay] -> pan -> gain
//
// The page's controls map onto exactly this, and apiGuard prints exactly this
// back out as Ring source -- which is the point of the whole studio: dial a
// sound, take it away as a test.

fn buildPatch(query: []const u8) struct { g: i64, secs: f64 } {
    const wave: u32 = @intFromFloat(qnum(query, "wave", 0));
    const g = gph.graphNew(2, RATE, 512);
    var n = gph.addOsc(g, wave, qnum(query, "hz", 440), qnum(query, "amp", 0.35));
    if (qnum(query, "useFilter", 0) == 1) {
        n = gph.addFilter(g, n, @intFromFloat(qnum(query, "fkind", 0)), qnum(query, "fcut", 8000), qnum(query, "fq", 0.707));
    }
    if (qnum(query, "useEnv", 0) == 1) {
        n = gph.addEnvelope(g, n, qnum(query, "att", 0.01), qnum(query, "dec", 0.2), qnum(query, "sus", 0.6), qnum(query, "rel", 0.3), qnum(query, "gate", 1.0));
    }
    if (qnum(query, "useDelay", 0) == 1) {
        n = gph.addDelay(g, n, qnum(query, "dtime", 0.25), qnum(query, "dfb", 0.4), qnum(query, "dwet", 0.4));
    }
    n = gph.addPan(g, n, qnum(query, "pan", 0.5));
    n = gph.addGain(g, n, 1.0);
    _ = gph.setOutput(g, n);
    return .{ .g = g, .secs = qnum(query, "secs", 2.0) };
}

fn renderAndReply(stream: std.net.Stream, g: i64, secs: f64) !void {
    if (gph.prepare(g) != gph.OK) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"prepare failed\"}");
        _ = gph.graphFree(g);
        return;
    }
    const frames: usize = @intFromFloat(secs * @as(f64, @floatFromInt(RATE)));
    var timer = try std.time.Timer.start();
    const buf = gph.renderToBuffer(g, frames);
    const ms = @as(f64, @floatFromInt(timer.read())) / 1e6;
    if (buf == 0) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"render failed\"}");
        _ = gph.graphFree(g);
        return;
    }
    _ = snd.saveWav(buf, wav_path, 16);
    const peak = snd.peak(buf);
    const rms = snd.rms(buf);
    const nodes = gph.nodeCount(g);
    _ = snd.free(buf);
    _ = gph.graphFree(g);

    var b: [512]u8 = undefined;
    const s = try std.fmt.bufPrint(&b, "{{\"ok\":true,\"peak\":{d:.6},\"rms\":{d:.6},\"seconds\":{d:.3},\"renderMs\":{d:.2},\"nodes\":{d:.0},\"frames\":{d}}}", .{ peak, rms, secs, ms, nodes, frames });
    respond(stream, "200 OK", "application/json", s);
}

fn apiRender(stream: std.net.Stream, query: []const u8) !void {
    const p = buildPatch(query);
    try renderAndReply(stream, p.g, p.secs);
}

/// Play the patch on the machine's own speakers -- the LIVE SN3 path, not a
/// file: producer thread -> ring buffer -> device callback. The browser's
/// <audio> element plays a rendered WAV; this button proves the real-time tier
/// still works, and reports what it cost.
fn apiPlay(stream: std.net.Stream, query: []const u8) !void {
    if (gph.dev.isAvailable() == 0) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"no audio device on this machine\"}");
        return;
    }
    const p = buildPatch(query);
    if (gph.prepare(p.g) != gph.OK) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"prepare failed\"}");
        _ = gph.graphFree(p.g);
        return;
    }
    const sid = gph.streamStart(p.g, 16384);
    if (sid == 0) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"stream would not start\"}");
        _ = gph.graphFree(p.g);
        return;
    }
    std.Thread.sleep(120 * std.time.ns_per_ms); // let the producer get ahead
    const did = gph.dev.playbackOpen(gph.streamRingPtr(sid), 256);
    if (did == 0) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"device would not open\"}");
        _ = gph.streamStop(sid);
        _ = gph.graphFree(p.g);
        return;
    }
    _ = gph.dev.playbackStart(did);
    std.Thread.sleep(@intFromFloat(p.secs * @as(f64, std.time.ns_per_s)));
    _ = gph.dev.playbackStop(did);
    const frames = gph.dev.playbackFramesOut(did);
    const worst = gph.dev.playbackWorstUs(did);
    const under = gph.streamUnderruns(sid);
    _ = gph.dev.playbackClose(did); // consumer first, ALWAYS
    _ = gph.streamStop(sid); // then the producer frees the ring
    _ = gph.graphFree(p.g);

    var b: [256]u8 = undefined;
    const s = try std.fmt.bufPrint(&b, "{{\"ok\":true,\"framesOut\":{d:.0},\"worstUs\":{d:.2},\"underruns\":{d:.0}}}", .{ frames, worst, under });
    respond(stream, "200 OK", "application/json", s);
}

// ── LOOKING AT WHAT YOU JUST HEARD ──────────────────────────────────────────
//
// The same patch, rendered and then MEASURED: a spectrum, a spectrogram, and
// the numbers a level meter cannot show you (LUFS, the dominant partial).
//
// THE SERVER SENDS DATA, THE PAGE DRAWS IT. That is the sound plane's own law
// -- every analysis returns a grid, and drawing is a separate step -- and the
// browser is just another drawing surface, exactly as stzCanvas is. It also
// happens to be the only arrangement that is fast enough to tune with: an SVG
// of a spectrogram is one rectangle per cell and weighs 100 KB, while the same
// picture as bytes is 38 KB and the canvas paints it in a frame.
//
// DOWNSAMPLED HERE, NOT THERE. A 2-second spectrogram is ~190 rows x 1025 bins
// = 195,000 numbers, and JSON would make that two megabytes of text per slider
// nudge. The server reduces it to the cells the canvas actually has, taking
// the LOUDEST value under each -- a peak that survives is a peak that was
// there, where an average would hide a brief bright partial -- and quantises
// to one byte of dB. What crosses the wire is what gets drawn.

const PLOT_W: usize = 260; // spectrogram cells across
const PLOT_H: usize = 150; // and up
const PLOT_RANGE_DB: f64 = 70;
const PLOT_BOTTOM_HZ: f64 = 40; // below this there is no note, only rumble
const PLOT_TOP_HZ: f64 = 16000;

fn apiAnalysis(stream: std.net.Stream, query: []const u8) !void {
    const p = buildPatch(query);
    if (gph.prepare(p.g) != gph.OK) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"prepare failed\"}");
        _ = gph.graphFree(p.g);
        return;
    }
    const frames: usize = @intFromFloat(p.secs * @as(f64, @floatFromInt(RATE)));
    const buf = gph.renderToBuffer(p.g, frames);
    _ = gph.graphFree(p.g);
    if (buf == 0) {
        respond(stream, "200 OK", "application/json", "{\"ok\":false,\"error\":\"render failed\"}");
        return;
    }
    defer _ = snd.free(buf);

    var timer = try std.time.Timer.start();
    const sg = gph.ana.spectrogram(buf, 0, 2048, 512, 4);
    const sp = gph.ana.spectrum(buf, 0, 0, 4096);
    const lufs = gph.ana.loudness(buf);
    const dom = gph.ana.dominantFrequency(buf, 0, 8192);
    const ms = @as(f64, @floatFromInt(timer.read())) / 1e6;
    defer _ = gph.ana.gridFree(sg);
    defer _ = gph.ana.gridFree(sp);

    var out: std.ArrayList(u8) = .{};
    defer out.deinit(alloc);
    const w = out.writer(alloc);

    try w.print("{{\"ok\":true,\"analysisMs\":{d:.2},\"seconds\":{d:.3},\"rate\":{d}", .{ ms, p.secs, RATE });
    try w.print(",\"loudnessLufs\":{d:.2},\"dominantHz\":{d:.1}", .{ lufs, dom });
    try w.print(",\"peak\":{d:.6},\"rms\":{d:.6}", .{ snd.peak(buf), snd.rms(buf) });
    try w.print(",\"rangeDb\":{d:.0},\"plotW\":{d},\"plotH\":{d}", .{ PLOT_RANGE_DB, PLOT_W, PLOT_H });

    try writeSpectrum(w, sp);
    try writeSpectrogram(w, sg);
    try w.print("}}", .{});
    respond(stream, "200 OK", "application/json", out.items);
}

/// One row of dB values, already reduced to the points the page will draw,
/// already in dB, and already spaced LOGARITHMICALLY.
///
/// Log, because the ear is. On a linear axis a 440 Hz fundamental sits at 3%
/// of the width and everything a person came to look at is crushed against the
/// left edge -- the first version drew exactly that, and a pure sine looked
/// like an empty chart with a smudge on it. An octave is a doubling, and equal
/// octaves deserve equal space.
fn writeSpectrum(w: anytype, sp: i64) !void {
    const cols: usize = @intFromFloat(@max(0, gph.ana.gridCols(sp)));
    const hz_per: f64 = gph.ana.gridYStep(sp);
    const mx: f64 = gph.ana.gridMax(sp);
    const top = @min(PLOT_TOP_HZ, @as(f64, @floatFromInt(cols)) * hz_per);
    try w.print(",\"spectrumFromHz\":{d:.1},\"spectrumToHz\":{d:.1},\"spectrum\":[", .{ PLOT_BOTTOM_HZ, top });
    if (cols == 0 or mx <= 0 or hz_per <= 0) {
        try w.print("]", .{});
        return;
    }
    const n: usize = 420;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const lo = logHzAt(i, n, PLOT_BOTTOM_HZ, top);
        const hi = logHzAt(i + 1, n, PLOT_BOTTOM_HZ, top);
        var c0: usize = @intFromFloat(@max(1.0, lo / hz_per));
        const c1 = @max(c0 + 1, @as(usize, @intFromFloat(hi / hz_per)));
        // peak-hold across whatever bins fall under this point: a harmonic
        // that survives is a harmonic that was there, where an average would
        // wash a narrow spike into the noise beside it
        var v: f64 = 0;
        while (c0 < c1 and c0 < cols) : (c0 += 1) v = @max(v, gph.ana.gridAt(sp, 0, c0));
        const db = if (v > 0) 20 * @log10(v / mx) else -PLOT_RANGE_DB;
        if (i > 0) try w.print(",", .{});
        try w.print("{d:.1}", .{@max(-PLOT_RANGE_DB, db)});
    }
    try w.print("]", .{});
}

/// The i-th of n edges on a log scale from lo to hi.
fn logHzAt(i: usize, n: usize, lo: f64, hi: f64) f64 {
    const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(n));
    return lo * std.math.pow(f64, hi / lo, t);
}

/// The spectrogram as ONE BYTE PER CELL: 0 is the floor, 255 is the loudest
/// cell in the picture. Row-major, low frequencies first; the page flips it,
/// because every spectrogram ever drawn puts low at the bottom.
///
/// Log on the frequency axis, for the reason above -- and it matters more
/// here, because a harmonic stack drawn linearly is a bright smear at the
/// bottom of an empty rectangle.
fn writeSpectrogram(w: anytype, sg: i64) !void {
    const rows: usize = @intFromFloat(@max(0, gph.ana.gridRows(sg)));
    const cols: usize = @intFromFloat(@max(0, gph.ana.gridCols(sg)));
    const mx: f64 = gph.ana.gridMax(sg);
    const secs_per_row: f64 = gph.ana.gridXStep(sg);
    const hz_per_col: f64 = gph.ana.gridYStep(sg);
    const top = @min(PLOT_TOP_HZ, @as(f64, @floatFromInt(cols)) * hz_per_col);

    try w.print(",\"sgBottomHz\":{d:.1},\"sgTopHz\":{d:.1},\"sgSeconds\":{d:.4},\"sg\":\"", .{
        PLOT_BOTTOM_HZ, top,
        @as(f64, @floatFromInt(rows)) * secs_per_row,
    });
    if (rows == 0 or cols == 0 or mx <= 0 or hz_per_col <= 0) {
        try w.print("\"", .{});
        return;
    }

    // base64, because a JSON array of 39,000 numbers is 150 KB of commas
    const raw = try alloc.alloc(u8, PLOT_W * PLOT_H);
    defer alloc.free(raw);
    var x: usize = 0;
    while (x < PLOT_W) : (x += 1) {
        const r0 = x * rows / PLOT_W;
        const r1 = @max(r0 + 1, (x + 1) * rows / PLOT_W);
        var y: usize = 0;
        while (y < PLOT_H) : (y += 1) {
            const lo = logHzAt(y, PLOT_H, PLOT_BOTTOM_HZ, top);
            const hi = logHzAt(y + 1, PLOT_H, PLOT_BOTTOM_HZ, top);
            const c0: usize = @intFromFloat(@max(1.0, lo / hz_per_col));
            const c1 = @max(c0 + 1, @as(usize, @intFromFloat(hi / hz_per_col)));
            var v: f64 = 0;
            var r = r0;
            while (r < r1 and r < rows) : (r += 1) {
                var c = c0;
                while (c < c1 and c < cols) : (c += 1) v = @max(v, gph.ana.gridAt(sg, r, c));
            }
            const db = if (v > 0) 20 * @log10(v / mx) else -PLOT_RANGE_DB - 1;
            const t = @max(0.0, (db + PLOT_RANGE_DB) / PLOT_RANGE_DB);
            raw[y * PLOT_W + x] = @intFromFloat(@min(255.0, t * 255.0));
        }
    }
    const enc = std.base64.standard.Encoder;
    const b64 = try alloc.alloc(u8, enc.calcSize(raw.len));
    defer alloc.free(b64);
    _ = enc.encode(b64, raw);
    try w.print("{s}\"", .{b64});
}

fn apiCompose(stream: std.net.Stream) !void {
    const c = buildComposition();
    try renderAndReply(stream, c.g, c.secs);
}

fn apiGuard(stream: std.net.Stream, query: []const u8) !void {
    const waves = [_][]const u8{ "StzSoundWaveSine()", "StzSoundWaveSquare()", "StzSoundWaveSaw()", "StzSoundWaveTriangle()" };
    const kinds = [_][]const u8{ "StzSoundFilterLowPass()", "StzSoundFilterHighPass()", "StzSoundFilterBandPass()" };
    const wi: usize = @intFromFloat(@min(3, @max(0, qnum(query, "wave", 0))));
    const ki: usize = @intFromFloat(@min(2, @max(0, qnum(query, "fkind", 0))));
    const secs = qnum(query, "secs", 2);

    var out: std.ArrayList(u8) = .{};
    defer out.deinit(alloc);
    const w = out.writer(alloc);

    try w.print("# --- patch dialled in the web studio ---\n", .{});
    try w.print("nG = StzEngineSoundGraphNew(2, 48000, 512)\n", .{});
    try w.print("nN = StzEngineSoundGraphAddOsc(nG, {s}, {d:.2}, {d:.3})\n", .{ waves[wi], qnum(query, "hz", 440), qnum(query, "amp", 0.35) });
    if (qnum(query, "useFilter", 0) == 1)
        try w.print("nN = StzEngineSoundGraphAddFilter(nG, nN, {s}, {d:.1}, {d:.3})\n", .{ kinds[ki], qnum(query, "fcut", 8000), qnum(query, "fq", 0.707) });
    if (qnum(query, "useEnv", 0) == 1)
        try w.print("nN = StzEngineSoundGraphAddEnvelope(nG, nN, {d:.4}, {d:.4}, {d:.3}, {d:.4}, {d:.3})\n", .{ qnum(query, "att", 0.01), qnum(query, "dec", 0.2), qnum(query, "sus", 0.6), qnum(query, "rel", 0.3), qnum(query, "gate", 1.0) });
    if (qnum(query, "useDelay", 0) == 1)
        try w.print("nN = StzEngineSoundGraphAddDelay(nG, nN, {d:.4}, {d:.3}, {d:.3})\n", .{ qnum(query, "dtime", 0.25), qnum(query, "dfb", 0.4), qnum(query, "dwet", 0.4) });
    try w.print("nN = StzEngineSoundGraphAddPan(nG, nN, {d:.3})\n", .{qnum(query, "pan", 0.5)});
    try w.print("StzEngineSoundGraphSetOutput(nG, nN)\n", .{});
    try w.print("StzEngineSoundGraphPrepare(nG)\n", .{});
    try w.print("nBuf = StzEngineSoundGraphToBuffer(nG, {d})\n\n", .{@as(usize, @intFromFloat(secs * 48000))});
    try w.print("# assert what you just heard, so it stays true:\n", .{});
    try w.print("Chk(\"the patch renders\", nBuf != 0)\n", .{});
    try w.print("Chk(\"it is {d:.2} seconds\", fabs(StzEngineSoundDuration(nBuf) - {d:.2}) < 0.01)\n", .{ secs, secs });
    try w.print("Chk(\"it is not silent\", StzEngineSoundPeak(nBuf) > 0.01)\n", .{});
    try w.print("Chk(\"and it does not clip\", StzEngineSoundPeak(nBuf) < 1.0)\n\n", .{});
    try w.print("StzEngineSoundFree(nBuf)\n", .{});
    try w.print("StzEngineSoundGraphFree(nG)\n", .{});

    respond(stream, "200 OK", "text/plain; charset=utf-8", out.items);
}

// ---------------------------------------------------------------- the guards
//
// RUNNING THE TESTS FROM THE SAME PAGE THAT MAKES THEM. The studio's whole
// argument is that dialling a sound and asserting it should not be two
// different activities in two different windows: hear it, take the guard code,
// paste it in, run the suite, all without leaving the page.
//
// The guards are Ring scripts, so this shells out to `ring`. That is the one
// place the studio needs anything outside itself -- and if `ring` is not on
// PATH the panel says so rather than silently showing nothing.

fn apiGuardList(stream: std.net.Stream) !void {
    var out: std.ArrayList(u8) = .{};
    defer out.deinit(alloc);
    const w = out.writer(alloc);
    try w.print("[", .{});

    var dir = std.fs.cwd().openDir(guards_dir, .{ .iterate = true }) catch {
        try w.print("]", .{});
        respond(stream, "200 OK", "application/json", out.items);
        return;
    };
    defer dir.close();
    var it = dir.iterate();
    var first = true;
    while (it.next() catch null) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, "_narrated.ring")) continue;
        if (!first) try w.print(",", .{});
        first = false;
        try w.print("\"{s}\"", .{entry.name});
    }
    try w.print("]", .{});
    respond(stream, "200 OK", "application/json", out.items);
}

fn apiRun(stream: std.net.Stream, query: []const u8) !void {
    var name_buf: [256]u8 = undefined;
    const name = qstr(query, "file", &name_buf) orelse {
        respond(stream, "200 OK", "text/plain", "no file given");
        return;
    };
    // Only a guard in the guards directory, and no path tricks. This server
    // binds to loopback, but "it is only local" is how a lot of things start.
    if (!std.mem.endsWith(u8, name, "_narrated.ring") or
        std.mem.indexOfScalar(u8, name, '/') != null or
        std.mem.indexOfScalar(u8, name, '\\') != null or
        std.mem.indexOf(u8, name, "..") != null)
    {
        respond(stream, "200 OK", "text/plain", "refused: not a guard filename");
        return;
    }

    const res = std.process.Child.run(.{
        .allocator = alloc,
        .argv = &.{ "ring", name },
        .cwd = guards_dir,
        .max_output_bytes = 1 << 20,
    }) catch |e| {
        var b: [256]u8 = undefined;
        const msg = std.fmt.bufPrint(&b, "could not run `ring {s}`: {s}\n(is ring on your PATH?)", .{ name, @errorName(e) }) catch "could not run ring";
        respond(stream, "200 OK", "text/plain; charset=utf-8", msg);
        return;
    };
    defer alloc.free(res.stdout);
    defer alloc.free(res.stderr);
    const body = if (res.stdout.len > 0) res.stdout else res.stderr;
    respond(stream, "200 OK", "text/plain; charset=utf-8", body);
}

fn qstr(query: []const u8, key: []const u8, buf: []u8) ?[]const u8 {
    var it = std.mem.splitScalar(u8, query, '&');
    while (it.next()) |pair| {
        const eq = std.mem.indexOfScalar(u8, pair, '=') orelse continue;
        if (std.mem.eql(u8, pair[0..eq], key)) {
            const v = pair[eq + 1 ..];
            if (v.len > buf.len) return null;
            @memcpy(buf[0..v.len], v);
            return buf[0..v.len];
        }
    }
    return null;
}

// ---------------------------------------------------------------- the piece

fn addVoice(g: i64, wave: u32, hz: f64, amp: f64, start: f64, gate: f64, a: f64, d: f64, s: f64, r: f64, pan: f64) i64 {
    const o = gph.addOsc(g, wave, hz, amp);
    const e = gph.addEnvelopeAt(g, o, a, d, s, r, gate, start);
    return gph.addPan(g, e, pan);
}

fn mixOf(g: i64, voices: []const i64) i64 {
    const m = gph.addMix(g);
    for (voices) |v| _ = gph.mixAdd(g, m, v);
    return m;
}

fn buildComposition() struct { g: i64, secs: f64 } {
    const beat: f64 = 0.6;
    const barlen = beat * 4;
    const chords = [4][4]f64{
        .{ 220.00, 261.63, 329.63, 110.00 },
        .{ 174.61, 220.00, 261.63, 87.31 },
        .{ 261.63, 329.63, 392.00, 130.81 },
        .{ 196.00, 246.94, 293.66, 98.00 },
    };
    const tune = [8]f64{ 659.25, 523.25, 587.33, 493.88, 523.25, 440.00, 493.88, 440.00 };

    const g = gph.graphNew(2, RATE, 512);
    var pad: [24]i64 = undefined;
    var np: usize = 0;
    var bass: [16]i64 = undefined;
    var nb: usize = 0;
    var arp1: [16]i64 = undefined;
    var na1: usize = 0;
    var arp2: [16]i64 = undefined;
    var na2: usize = 0;
    var bell: [4]i64 = undefined;
    var nbe: usize = 0;

    for (0..8) |bi| {
        const ch = chords[bi % 4];
        const t0 = @as(f64, @floatFromInt(bi)) * barlen;
        const sw: f64 = if (bi >= 4) 0.75 else 0.55;

        pad[np] = addVoice(g, gph.WAVE_TRIANGLE, ch[0], 0.13 * sw, t0, barlen * 0.9, 0.35, 0.4, 0.75, 0.7, 0.18);
        np += 1;
        pad[np] = addVoice(g, gph.WAVE_TRIANGLE, ch[1], 0.11 * sw, t0, barlen * 0.9, 0.40, 0.4, 0.75, 0.7, 0.50);
        np += 1;
        pad[np] = addVoice(g, gph.WAVE_TRIANGLE, ch[2], 0.11 * sw, t0, barlen * 0.9, 0.45, 0.4, 0.75, 0.7, 0.82);
        np += 1;

        for (0..2) |hit| {
            const o = gph.addOsc(g, gph.WAVE_SAW, ch[3], 0.34);
            const f = gph.addFilter(g, o, gph.FILTER_LOWPASS, 420, 1.1);
            const e = gph.addEnvelopeAt(g, f, 0.008, 0.22, 0.35, 0.25, beat * 0.9, t0 + @as(f64, @floatFromInt(hit)) * beat * 2);
            bass[nb] = gph.addPan(g, e, 0.5);
            nb += 1;
        }

        for (0..4) |n| {
            var hz = ch[n % 3];
            if (n == 3) hz *= 2;
            const v = addVoice(g, gph.WAVE_TRIANGLE, hz, 0.16, t0 + @as(f64, @floatFromInt(n)) * beat, 0.18, 0.004, 0.22, 0.0, 0.08, 0.25 + (@as(f64, @floatFromInt(n)) / 3.0) * 0.5);
            if (bi < 4) {
                arp1[na1] = v;
                na1 += 1;
            } else {
                arp2[na2] = v;
                na2 += 1;
            }
        }

        if (bi >= 4) {
            bell[nbe] = addVoice(g, gph.WAVE_SINE, tune[bi], 0.26, t0 + beat, barlen * 0.5, 0.006, 1.1, 0.0, 0.5, 0.45);
            nbe += 1;
        }
    }

    // MIXES AFTER VOICES: a mix may only take inputs that already exist, which
    // is what makes a cycle impossible to express. Building them first is how
    // the first version of the Ring composition rendered 21.7 s of silence.
    const m_pad = mixOf(g, pad[0..np]);
    const m_bass = mixOf(g, bass[0..nb]);
    const m_bell = mixOf(g, bell[0..nbe]);
    const bell_echo = gph.addDelay(g, m_bell, beat * 0.75, 0.42, 0.42);
    const a1 = mixOf(g, arp1[0..na1]);
    const a2 = mixOf(g, arp2[0..na2]);
    const arp_both = mixOf(g, &[_]i64{ a1, a2 });
    const arp_echo = gph.addDelay(g, arp_both, beat * 0.5, 0.30, 0.28);
    const master = mixOf(g, &[_]i64{ m_pad, m_bass, arp_echo, bell_echo });
    const warm = gph.addFilter(g, master, gph.FILTER_LOWPASS, 7000, 0.7);
    const out = gph.addGain(g, warm, 1.9);
    _ = gph.setOutput(g, out);
    return .{ .g = g, .secs = barlen * 8 + 2.5 };
}
