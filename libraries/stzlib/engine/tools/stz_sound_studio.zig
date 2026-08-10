//! THE SOUND WEB STUDIO -- server side. A browser front end for the sound plane.
//!
//! Standalone exe: a tiny HTTP/1.1 server on 127.0.0.1 that renders patches
//! with the REAL engine (soundgraph.zig + sound.zig) and hands the browser a
//! WAV. Nothing is synthesised in JavaScript -- what you hear in the page is
//! what the plane produces.
//!
//! WHY A ZIG TOOL AND NOT A RING SCRIPT: the Ring version worked right up to
//! the point of reading a request. stz_tcp's tcp_recv used Zig's Stream.read,
//! which on Windows goes through ReadFile and does NOT work on a socket from
//! accept() -- writes succeeded, reads failed with "recv failed: Unexpected",
//! so the server could answer but never hear. (src/tcp.zig now uses
//! std.posix.recv, the same call testserver.zig always used -- which is why
//! the HTTP-client suite never caught it.) Rather than make a listening bench
//! depend on that fix landing, the studio owns its own socket loop, starts
//! instantly, and needs no Ring at all.
//!
//! Build (from libraries/stzlib/engine):
//!     zig build-exe -OReleaseSafe -I vendor/miniaudio -lc \
//!         vendor/miniaudio/stz_miniaudio_impl.c \
//!         --dep snd --dep gph -Mroot=tools/sound_studio_server.zig \
//!         -Msnd=src/sound.zig -Mgph=src/soundgraph.zig \
//!         --name sound_studio_server
//! Run:
//!     sound_studio_server [port] [path/to/studio.html]
//!
//! One connection at a time, on purpose: this is a single-listener bench, and
//! a serial loop cannot race the engine's global handle tables.

const std = @import("std");
const gph = @import("gph");
const snd = gph.snd; // ONE module -- see the note at the top of soundgraph.zig

const alloc = std.heap.c_allocator;
const RATE: u32 = 48000;

var html_path: []const u8 = "studio.html";
var wav_path: []const u8 = "studio_patch.wav";
var have_device = false;
var device_name: []const u8 = "none";

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    var port: u16 = 8730;
    if (args.len > 1) port = std.fmt.parseInt(u16, args[1], 10) catch 8730;
    if (args.len > 2) html_path = args[2];
    if (args.len > 3) wav_path = args[3];

    have_device = gph.dev.isAvailable() == 1;
    if (have_device) device_name = gph.dev.backendName();

    const addr = try std.net.Address.parseIp("127.0.0.1", port);
    var server = addr.listen(.{ .reuse_address = true }) catch |e| {
        std.debug.print("cannot listen on {d}: {s}\n", .{ port, @errorName(e) });
        std.debug.print("(already running? try another port: sound_studio_server 8731)\n", .{});
        return;
    };
    defer server.deinit();

    std.debug.print("\n  ===============================================\n", .{});
    std.debug.print("   THE SOFTANZA SOUND WEB STUDIO\n", .{});
    std.debug.print("  ===============================================\n", .{});
    std.debug.print("   page   : {s}\n", .{html_path});
    std.debug.print("   wav    : {s}\n", .{wav_path});
    std.debug.print("\n   OPEN:    http://127.0.0.1:{d}\n\n", .{port});

    while (true) {
        const conn = server.accept() catch continue;
        handle(conn.stream) catch {};
        conn.stream.close();
    }
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
        const page = std.fs.cwd().readFileAlloc(alloc, html_path, 4 << 20) catch {
            respond(stream, "500 Internal Server Error", "text/plain", "studio.html not found next to the server");
            return;
        };
        defer alloc.free(page);
        respond(stream, "200 OK", "text/html; charset=utf-8", page);
    } else if (std.mem.eql(u8, route, "/api/status")) {
        var b: [256]u8 = undefined;
        const s = try std.fmt.bufPrint(&b, "{{\"engine\":true,\"device\":{s},\"deviceName\":\"{s}\",\"rate\":{d}}}", .{ if (have_device) "true" else "false", device_name, RATE });
        respond(stream, "200 OK", "application/json", s);
    } else if (std.mem.eql(u8, route, "/api/render")) {
        try apiRender(stream, query);
    } else if (std.mem.eql(u8, route, "/api/play")) {
        try apiPlay(stream, query);
    } else if (std.mem.eql(u8, route, "/api/compose")) {
        try apiCompose(stream);
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
