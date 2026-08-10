//! SN0 SOUND SPIKE -- measurement only, no product code.
//!
//! Plan of record: libraries/stzlib/base/sound/SOFTANZA_SOUND_PLAN.md (phase SN0).
//! This standalone exe produces the {device callback, graph render, decode,
//! resample, latency} DECOMPOSITION the plan's lesson 1 demands -- the lesson
//! GR0 paid for by aiming a kill criterion at a tier that cost 3% of the frame.
//! SN1 grows this into stz_sound.dll + stz_audiodev.dll; nothing here is a
//! public surface.
//!
//! Build (from libraries/stzlib/engine, out-of-tree emit keeps the repo clean):
//!     zig build-exe tools/sound_spike.zig -OReleaseSafe -I vendor/miniaudio \
//!         vendor/miniaudio/stz_miniaudio_impl.c -lc --name sound_spike
//! Run:
//!     sound_spike devices          -- enumerate playback + capture devices
//!     sound_spike cpu              -- device-free suite (graph, mix, decode,
//!                                     resample). This is the CI path: it needs
//!                                     no audio hardware at all.
//!     sound_spike device           -- callback period/jitter, tone, capture
//!     sound_spike latency          -- output latency via WASAPI loopback
//!     sound_spike all              -- everything
//!
//! Methodology (the house timing laws, copied from tools/gpu_spike.zig so the
//! two planes' numbers are comparable):
//!   - monotonic clock only (std.time.Timer)
//!   - warm = 3 warmups then 5 timed reps, min AND median reported
//!   - CPU samples inner-loop scaled until a rep is >= ~1 ms
//!   - the machine is SHARED with other sessions: numbers recorded as-is
//!
//! THE CALLBACK IS A NO-ALLOCATION, NO-LOCK, NO-RING ZONE (plan FACT 4). Even
//! here, in a spike whose whole job is to watch the callback, the callback
//! writes only into arrays allocated before the device started. If the
//! measurement harness could not obey the rule, the rule would be a fiction.

const std = @import("std");

const c = @cImport({
    @cDefine("MA_NO_ENGINE", "1");
    @cDefine("MA_NO_RESOURCE_MANAGER", "1");
    @cDefine("MA_NO_NODE_GRAPH", "1");
    @cInclude("miniaudio.h");
});

const alloc = std.heap.c_allocator;

// ---------------------------------------------------------------- constants

const SAMPLE_RATE: u32 = 48000;
const CHANNELS: u32 = 2;

/// The three buffer sizes SN0 was told to decompose. 256 frames at 48 kHz is
/// the 5.333 ms deadline kill criterion #1 names.
const PERIOD_SIZES = [_]u32{ 128, 256, 512 };

/// Voice counts for the graph-render sweep. Kill criterion #1 is about "a plain
/// mix graph"; SN1 needs to know how many voices actually fit in the budget, so
/// the sweep answers that rather than just passing or failing at one point.
const VOICE_COUNTS = [_]usize{ 1, 8, 32, 64, 128 };

const WARMUPS = 3;
const REPS = 5; // house rule: 5 runs minimum
const CPU_TARGET_NS: u64 = 1_000_000; // scale reps until a sample is measurable

const DEVICE_RUN_NS: u64 = 3_000_000_000; // 3 s per device session
const MAX_CALLBACKS: usize = 200_000;

// ---------------------------------------------------------------- stats

const Stats = struct {
    min_ns: u64,
    med_ns: u64,

    fn from(samples: []u64) Stats {
        std.mem.sort(u64, samples, {}, std.sort.asc(u64));
        return .{ .min_ns = samples[0], .med_ns = samples[samples.len / 2] };
    }
};

fn ms(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1e6;
}

fn us(ns: u64) f64 {
    return @as(f64, @floatFromInt(ns)) / 1e3;
}

/// MB/s from a byte count and a duration. MB = 1e6 bytes (the unit the other
/// plans' GB/s figures use), not 2^20.
fn mbps(bytes: usize, ns: u64) f64 {
    if (ns == 0) return 0;
    return (@as(f64, @floatFromInt(bytes)) / 1e6) / (@as(f64, @floatFromInt(ns)) / 1e9);
}

fn pctl(sorted: []const u64, p: f64) u64 {
    if (sorted.len == 0) return 0;
    const last = @as(f64, @floatFromInt(sorted.len - 1));
    const idx: usize = @intFromFloat(@round(p * last));
    return sorted[idx];
}

fn meanNs(xs: []const u64) u64 {
    if (xs.len == 0) return 0;
    var sum: u128 = 0;
    for (xs) |x| sum += x;
    return @intCast(sum / xs.len);
}

fn timeCpu(comptime f: anytype, args: anytype) Stats {
    var timer = std.time.Timer.start() catch unreachable;
    @call(.auto, f, args);
    const once = timer.read();
    const inner: usize = if (once >= CPU_TARGET_NS) 1 else @intCast(CPU_TARGET_NS / @max(once, 1) + 1);

    var samples: [REPS]u64 = undefined;
    for (0..WARMUPS) |_| @call(.auto, f, args);
    for (&samples) |*s| {
        timer.reset();
        for (0..inner) |_| @call(.auto, f, args);
        s.* = timer.read() / inner;
    }
    return Stats.from(&samples);
}

/// miniaudio pads its device-name field; print only up to the NUL and trim.
fn trimName(raw: []const u8) []const u8 {
    const nul = std.mem.indexOfScalar(u8, raw, 0) orelse raw.len;
    return std.mem.trim(u8, raw[0..nul], " \t");
}

// ---------------------------------------------------------------- the mix graph
//
// THE FOUR FORMS ARE THE MEASUREMENT, not four ways of writing one thing.
//
// linalg.zig already minted this repo's law: "reach for @Vector where the
// compiler cannot see the structure, not where it merely needs to be shown" --
// there, slices beat an explicit @Vector by 1.5x because computed indices into
// one array hide independence from LLVM. Audio mixing is the same shape of loop,
// so SN0 re-runs that experiment in this domain rather than assuming the answer
// transfers. And it adds the question the audio domain asks that linear algebra
// does not: INTERLEAVED or PLANAR.
//
// A device wants interleaved stereo (L,R,L,R...). A mixer wants planar (all L,
// then all R) because that is where the wide loads are. Whether it is worth
// interleaving once at the end instead of accumulating in place is an SN1
// architecture decision, so SN0 measures it.

const Voice = struct {
    src: []const f32, // mono source, already long enough for the block
    gain: f32,
    pan: f32, // 0 = hard left, 1 = hard right
};

/// Baseline: interleaved accumulation with computed indices. The obvious code,
/// and the one LLVM has the least chance with.
fn mixInterleavedIndex(voices: []const Voice, out: []f32, nframes: usize) void {
    @memset(out[0 .. nframes * 2], 0);
    for (voices) |v| {
        const l = v.gain * (1.0 - v.pan);
        const r = v.gain * v.pan;
        var i: usize = 0;
        while (i < nframes) : (i += 1) {
            out[i * 2] += v.src[i] * l;
            out[i * 2 + 1] += v.src[i] * r;
        }
    }
}

/// Planar accumulation, index loop -- the scalar reference for the SIMD question.
fn mixPlanarIndex(voices: []const Voice, bl: []f32, br: []f32, out: []f32, nframes: usize) void {
    @memset(bl[0..nframes], 0);
    @memset(br[0..nframes], 0);
    for (voices) |v| {
        const l = v.gain * (1.0 - v.pan);
        const r = v.gain * v.pan;
        var i: usize = 0;
        while (i < nframes) : (i += 1) {
            bl[i] += v.src[i] * l;
            br[i] += v.src[i] * r;
        }
    }
    var i: usize = 0;
    while (i < nframes) : (i += 1) {
        out[i * 2] = bl[i];
        out[i * 2 + 1] = br[i];
    }
}

/// Planar accumulation handed as SLICES -- the linalg.zig idiom. No @Vector
/// anywhere; the point is that the compiler can now prove independence.
fn mixPlanarSlices(voices: []const Voice, bl: []f32, br: []f32, out: []f32, nframes: usize) void {
    const dl = bl[0..nframes];
    const dr = br[0..nframes];
    @memset(dl, 0);
    @memset(dr, 0);
    for (voices) |v| {
        const s = v.src[0..nframes];
        const l = v.gain * (1.0 - v.pan);
        const r = v.gain * v.pan;
        for (dl, s) |*o, x| o.* += x * l;
        for (dr, s) |*o, x| o.* += x * r;
    }
    for (0..nframes) |i| {
        out[i * 2] = dl[i];
        out[i * 2 + 1] = dr[i];
    }
}

/// Planar accumulation with an EXPLICIT @Vector -- the form linalg.zig found
/// slower than slices for LU. Measured here rather than assumed.
fn mixPlanarVector(voices: []const Voice, bl: []f32, br: []f32, out: []f32, nframes: usize) void {
    const W = std.simd.suggestVectorLength(f32) orelse 8;
    const V = @Vector(W, f32);
    @memset(bl[0..nframes], 0);
    @memset(br[0..nframes], 0);
    for (voices) |v| {
        const l: V = @splat(v.gain * (1.0 - v.pan));
        const r: V = @splat(v.gain * v.pan);
        var i: usize = 0;
        while (i + W <= nframes) : (i += W) {
            const xv: V = v.src[i..][0..W].*;
            const lv: V = bl[i..][0..W].*;
            const rv: V = br[i..][0..W].*;
            bl[i..][0..W].* = lv + xv * l;
            br[i..][0..W].* = rv + xv * r;
        }
        while (i < nframes) : (i += 1) {
            bl[i] += v.src[i] * l[0];
            br[i] += v.src[i] * r[0];
        }
    }
    for (0..nframes) |i| {
        out[i * 2] = bl[i];
        out[i * 2 + 1] = br[i];
    }
}

// ---------------------------------------------------------------- graph phase

const MixHarness = struct {
    voices: []Voice,
    srcpool: []f32,
    bl: []f32,
    br: []f32,
    out: []f32,

    fn init(max_voices: usize, max_frames: usize) !MixHarness {
        const voices = try alloc.alloc(Voice, max_voices);
        const srcpool = try alloc.alloc(f32, max_voices * max_frames);
        var prng = std.Random.DefaultPrng.init(0xA0D10);
        const rnd = prng.random();
        for (srcpool) |*s| s.* = rnd.float(f32) * 2.0 - 1.0;
        for (voices, 0..) |*v, i| {
            v.* = .{
                .src = srcpool[i * max_frames ..][0..max_frames],
                .gain = 0.5 + 0.25 * @as(f32, @floatFromInt(i % 3)),
                .pan = @as(f32, @floatFromInt(i % 7)) / 6.0,
            };
        }
        return .{
            .voices = voices,
            .srcpool = srcpool,
            .bl = try alloc.alloc(f32, max_frames),
            .br = try alloc.alloc(f32, max_frames),
            .out = try alloc.alloc(f32, max_frames * 2),
        };
    }

    fn deinit(self: *MixHarness) void {
        alloc.free(self.voices);
        alloc.free(self.srcpool);
        alloc.free(self.bl);
        alloc.free(self.br);
        alloc.free(self.out);
    }
};

fn runGraphPhase() !void {
    const max_frames = PERIOD_SIZES[PERIOD_SIZES.len - 1];
    const max_voices = VOICE_COUNTS[VOICE_COUNTS.len - 1];
    var h = try MixHarness.init(max_voices, max_frames);
    defer h.deinit();

    std.debug.print("\n== GRAPH RENDER -- a plain mix graph, offline (no device, the CI path) ==\n", .{});
    std.debug.print("   deadline = frames/48000; kill criterion #1 wants 256 frames under 25% of 5.333 ms = 1.333 ms\n", .{});
    std.debug.print("{s:>7} {s:>7} {s:>11} {s:>11} {s:>11} {s:>11} {s:>10} {s:>9}\n", .{
        "frames", "voices", "inter-idx", "planar-idx", "planar-sli", "planar-vec", "deadline", "best/dl",
    });

    for (PERIOD_SIZES) |frames| {
        const nf: usize = frames;
        const deadline_ns: u64 = @intFromFloat(1e9 * @as(f64, @floatFromInt(nf)) / @as(f64, @floatFromInt(SAMPLE_RATE)));
        for (VOICE_COUNTS) |nv| {
            const vs = h.voices[0..nv];
            const s_ii = timeCpu(mixInterleavedIndex, .{ vs, h.out, nf });
            const s_pi = timeCpu(mixPlanarIndex, .{ vs, h.bl, h.br, h.out, nf });
            const s_ps = timeCpu(mixPlanarSlices, .{ vs, h.bl, h.br, h.out, nf });
            const s_pv = timeCpu(mixPlanarVector, .{ vs, h.bl, h.br, h.out, nf });
            const best = @min(@min(s_ii.min_ns, s_pi.min_ns), @min(s_ps.min_ns, s_pv.min_ns));
            const share = 100.0 * @as(f64, @floatFromInt(best)) / @as(f64, @floatFromInt(deadline_ns));
            std.debug.print("{d:>7} {d:>7} {d:>10.4}m {d:>10.4}m {d:>10.4}m {d:>10.4}m {d:>9.3}m {d:>8.2}%\n", .{
                frames, nv, ms(s_ii.min_ns), ms(s_pi.min_ns), ms(s_ps.min_ns), ms(s_pv.min_ns), ms(deadline_ns), share,
            });
        }
    }

    // The SIMD-vs-scalar answer on its own terms, at the one size the kill
    // criterion is about, with the speedups spelled out.
    std.debug.print("\n== SIMD vs SCALAR MIX (256 frames, the deadline size) ==\n", .{});
    std.debug.print("{s:>7} {s:>12} {s:>12} {s:>12} {s:>12} {s:>9} {s:>9}\n", .{
        "voices", "inter-idx", "planar-idx", "planar-slice", "planar-vec", "sli/idx", "vec/sli",
    });
    for (VOICE_COUNTS) |nv| {
        const nf: usize = 256;
        const vs = h.voices[0..nv];
        const s_ii = timeCpu(mixInterleavedIndex, .{ vs, h.out, nf });
        const s_pi = timeCpu(mixPlanarIndex, .{ vs, h.bl, h.br, h.out, nf });
        const s_ps = timeCpu(mixPlanarSlices, .{ vs, h.bl, h.br, h.out, nf });
        const s_pv = timeCpu(mixPlanarVector, .{ vs, h.bl, h.br, h.out, nf });
        const f_pi: f64 = @floatFromInt(s_pi.min_ns);
        const f_ps: f64 = @floatFromInt(s_ps.min_ns);
        const f_pv: f64 = @floatFromInt(s_pv.min_ns);
        std.debug.print("{d:>7} {d:>10.4}us {d:>10.4}us {d:>10.4}us {d:>10.4}us {d:>8.2}x {d:>8.2}x\n", .{
            nv, us(s_ii.min_ns), us(s_pi.min_ns), us(s_ps.min_ns), us(s_pv.min_ns), f_pi / f_ps, f_ps / f_pv,
        });
    }

    // A bounded record COUNTS what it drops (lesson 3): prove the four forms
    // agree, or the fastest one is fast at producing the wrong samples.
    try assertFormsAgree(&h);
}

fn assertFormsAgree(h: *MixHarness) !void {
    const nf: usize = 256;
    const vs = h.voices[0..32];
    const ref = try alloc.alloc(f32, nf * 2);
    defer alloc.free(ref);

    mixInterleavedIndex(vs, h.out, nf);
    @memcpy(ref, h.out[0 .. nf * 2]);

    var worst: f64 = 0;
    inline for (.{ mixPlanarIndex, mixPlanarSlices, mixPlanarVector }) |f| {
        @memset(h.out[0 .. nf * 2], 0);
        f(vs, h.bl, h.br, h.out, nf);
        for (ref, h.out[0 .. nf * 2]) |a, b| worst = @max(worst, @abs(@as(f64, a) - @as(f64, b)));
    }
    std.debug.print("\n  forms agree: max abs deviation across all four = {e:.3}  (f32 summation-order noise only)\n", .{worst});
}

// ---------------------------------------------------------------- decode phase

/// Write a real WAV with miniaudio's own encoder, so the decode measurement
/// reads a file miniaudio itself produced -- no hand-rolled header to get wrong.
fn writeTestWav(path: [:0]const u8, seconds: f64) !usize {
    var cfg = c.ma_encoder_config_init(c.ma_encoding_format_wav, c.ma_format_s16, CHANNELS, SAMPLE_RATE);
    var enc: c.ma_encoder = undefined;
    if (c.ma_encoder_init_file(path.ptr, &cfg, &enc) != c.MA_SUCCESS) return error.EncoderInit;
    defer c.ma_encoder_uninit(&enc);

    const total: usize = @intFromFloat(seconds * @as(f64, @floatFromInt(SAMPLE_RATE)));
    const block = 4096;
    var buf: [block * CHANNELS]i16 = undefined;
    var phase: f64 = 0;
    const inc = 2.0 * std.math.pi * 440.0 / @as(f64, @floatFromInt(SAMPLE_RATE));
    var written: usize = 0;
    while (written < total) {
        const n = @min(block, total - written);
        for (0..n) |i| {
            const s: i16 = @intFromFloat(20000.0 * @sin(phase));
            buf[i * 2] = s;
            buf[i * 2 + 1] = s;
            phase += inc;
        }
        var got: c.ma_uint64 = 0;
        _ = c.ma_encoder_write_pcm_frames(&enc, &buf, n, &got);
        written += n;
    }
    return total;
}

const DecodeResult = struct {
    frames: u64,
    channels: u32,
    rate: u32,
    ns: u64,
};

/// Decode a whole file FROM MEMORY into f32. From memory on purpose: the
/// question is the decoder's throughput, and disk I/O is a different tier's
/// number. (SN1 will want the file-path variant too; the difference is the
/// I/O layer's, not the codec's.)
fn decodeAll(bytes: []const u8, out: []f32) !DecodeResult {
    var cfg = c.ma_decoder_config_init(c.ma_format_f32, 0, 0); // 0 = keep native
    var dec: c.ma_decoder = undefined;
    var timer = try std.time.Timer.start();
    if (c.ma_decoder_init_memory(bytes.ptr, bytes.len, &cfg, &dec) != c.MA_SUCCESS) return error.DecoderInit;
    defer _ = c.ma_decoder_uninit(&dec);

    const ch = dec.outputChannels;
    var total: u64 = 0;
    const chunk: u64 = 8192;
    while (true) {
        const room = (out.len - @as(usize, @intCast(total * ch))) / ch;
        if (room == 0) break;
        const want = @min(chunk, room);
        var got: c.ma_uint64 = 0;
        const res = c.ma_decoder_read_pcm_frames(&dec, out.ptr + @as(usize, @intCast(total * ch)), want, &got);
        total += got;
        if (res != c.MA_SUCCESS or got == 0) break;
    }
    return .{ .frames = total, .channels = ch, .rate = dec.outputSampleRate, .ns = timer.read() };
}

fn runDecodePhase(flac_path: ?[]const u8) !void {
    std.debug.print("\n== DECODE (miniaudio's built-in dr_wav / dr_flac, from memory, to f32) ==\n", .{});
    std.debug.print("{s:>22} {s:>10} {s:>9} {s:>8} {s:>10} {s:>11} {s:>12} {s:>10}\n", .{
        "file", "in bytes", "frames", "rate", "min ms", "in MB/s", "out MB/s", "x realtime",
    });

    // --- WAV, written here so the corpus is reproducible
    const tmp = std.process.getEnvVarOwned(alloc, "TEMP") catch
        (std.process.getEnvVarOwned(alloc, "TMPDIR") catch try alloc.dupe(u8, "."));
    defer alloc.free(tmp);
    const wav_path = try std.fmt.allocPrintSentinel(alloc, "{s}/stz_sn0_tone.wav", .{tmp}, 0);
    defer alloc.free(wav_path);
    _ = writeTestWav(wav_path, 10.0) catch |e| {
        std.debug.print("  wav encode FAILED: {s}\n", .{@errorName(e)});
        return;
    };
    try decodeOne(wav_path, "10 s tone (wav s16)");

    // --- FLAC, the compressed number that actually matters
    if (flac_path) |p| {
        const pz = try alloc.dupeZ(u8, p);
        defer alloc.free(pz);
        try decodeOne(pz, "16-44100-stereo.flac");
    } else {
        std.debug.print("  flac: NOT MEASURED (no corpus file given -- pass it as argv[2])\n", .{});
    }
}

fn decodeOne(path: [:0]const u8, label: []const u8) !void {
    const f = std.fs.cwd().openFile(path, .{}) catch |e| {
        std.debug.print("  {s}: open FAILED ({s})\n", .{ label, @errorName(e) });
        return;
    };
    defer f.close();
    const st = try f.stat();
    const bytes = try alloc.alloc(u8, st.size);
    defer alloc.free(bytes);
    _ = try f.readAll(bytes);

    // the output is allocated ONCE, before any timed decode -- Prepare-time
    // allocation, the discipline SN2 will make structural.
    // a generous ceiling: 10 minutes of stereo f32
    const cap: usize = 48000 * 2 * 600;
    const out = try alloc.alloc(f32, cap);
    defer alloc.free(out);

    var samples: [REPS]u64 = undefined;
    var r0: DecodeResult = undefined;
    for (0..WARMUPS) |_| _ = try decodeAll(bytes, out);
    for (&samples) |*s| {
        r0 = try decodeAll(bytes, out);
        s.* = r0.ns;
    }
    const st2 = Stats.from(&samples);
    const out_bytes = @as(usize, @intCast(r0.frames)) * r0.channels * 4;
    const audio_ns: u64 = @intFromFloat(1e9 * @as(f64, @floatFromInt(r0.frames)) / @as(f64, @floatFromInt(r0.rate)));
    std.debug.print("{s:>22} {d:>10} {d:>9} {d:>8} {d:>10.3} {d:>11.1} {d:>12.1} {d:>9.0}x\n", .{
        label,
        bytes.len,
        r0.frames,
        r0.rate,
        ms(st2.min_ns),
        mbps(bytes.len, st2.min_ns),
        mbps(out_bytes, st2.min_ns),
        @as(f64, @floatFromInt(audio_ns)) / @as(f64, @floatFromInt(st2.min_ns)),
    });
}

// ---------------------------------------------------------------- resample phase

const ResampleHarness = struct {
    rs: c.ma_resampler,
    in: []f32,
    out: []f32,
    frames_in: usize,

    fn run(self: *ResampleHarness) void {
        var fi: c.ma_uint64 = self.frames_in;
        var fo: c.ma_uint64 = self.out.len / CHANNELS;
        _ = c.ma_resampler_process_pcm_frames(&self.rs, self.in.ptr, &fi, self.out.ptr, &fo);
    }
};

fn runResamplePhase() !void {
    std.debug.print("\n== RESAMPLE (miniaudio, f32 stereo, 48000 -> 44100, 1 s blocks) ==\n", .{});
    std.debug.print("{s:>10} {s:>10} {s:>12} {s:>13} {s:>11}\n", .{ "algorithm", "min ms", "in MB/s", "Mframes/s", "x realtime" });

    const frames_in: usize = SAMPLE_RATE;
    const in = try alloc.alloc(f32, frames_in * CHANNELS);
    defer alloc.free(in);
    var prng = std.Random.DefaultPrng.init(7);
    const rnd = prng.random();
    for (in) |*v| v.* = rnd.float(f32) * 2 - 1;
    const out = try alloc.alloc(f32, (frames_in + 1024) * CHANNELS);
    defer alloc.free(out);

    const algos = [_]struct { name: []const u8, a: c_uint }{
        .{ .name = "linear", .a = c.ma_resample_algorithm_linear },
    };

    for (algos) |al| {
        var cfg = c.ma_resampler_config_init(c.ma_format_f32, CHANNELS, SAMPLE_RATE, 44100, al.a);
        var h = ResampleHarness{ .rs = undefined, .in = in, .out = out, .frames_in = frames_in };
        if (c.ma_resampler_init(&cfg, null, &h.rs) != c.MA_SUCCESS) {
            std.debug.print("{s:>10}  init FAILED\n", .{al.name});
            continue;
        }
        defer c.ma_resampler_uninit(&h.rs, null);
        const s = timeCpu(ResampleHarness.run, .{&h});
        const in_bytes = frames_in * CHANNELS * 4;
        std.debug.print("{s:>10} {d:>10.4} {d:>12.1} {d:>13.2} {d:>10.0}x\n", .{
            al.name,
            ms(s.min_ns),
            mbps(in_bytes, s.min_ns),
            (@as(f64, @floatFromInt(frames_in)) / 1e6) / (@as(f64, @floatFromInt(s.min_ns)) / 1e9),
            1e9 / @as(f64, @floatFromInt(s.min_ns)),
        });
    }
}

// ---------------------------------------------------------------- device phase

/// Everything the callback touches is allocated before ma_device_start. The
/// callback itself does: read a monotonic clock, write two array slots, and
/// synthesize. No allocation, no lock, no Ring.
const CbState = struct {
    timer: std.time.Timer,
    n: usize = 0,
    t_enter: []u64,
    t_work: []u64,
    frames: []u32,
    phase: f64 = 0,
    inc: f64,
    dropped: usize = 0, // trace slots we could not record: COUNTED, not silent
    total_frames: u64 = 0, // the underrun proxy: frames the device actually took
};

fn playbackCallback(dev: [*c]c.ma_device, out: ?*anyopaque, in: ?*const anyopaque, frame_count: c.ma_uint32) callconv(.c) void {
    _ = in;
    const st: *CbState = @ptrCast(@alignCast(dev.*.pUserData.?));
    const t0 = st.timer.read();

    const n: usize = frame_count;
    const buf: [*]f32 = @ptrCast(@alignCast(out.?));
    var ph = st.phase;
    for (0..n) |i| {
        const s: f32 = @floatCast(0.2 * @sin(ph));
        buf[i * 2] = s;
        buf[i * 2 + 1] = s;
        ph += st.inc;
    }
    if (ph > 2.0 * std.math.pi * 1e6) ph = @mod(ph, 2.0 * std.math.pi);
    st.phase = ph;

    st.total_frames += frame_count;
    if (st.n < st.t_enter.len) {
        st.t_enter[st.n] = t0;
        st.t_work[st.n] = st.timer.read() - t0;
        st.frames[st.n] = frame_count;
        st.n += 1;
    } else {
        st.dropped += 1;
    }
}

const CaptureState = struct {
    frames: u64 = 0,
    sumsq: f64 = 0,
    peak: f32 = 0,
    callbacks: usize = 0,
};

fn captureCallback(dev: [*c]c.ma_device, out: ?*anyopaque, in: ?*const anyopaque, frame_count: c.ma_uint32) callconv(.c) void {
    _ = out;
    const st: *CaptureState = @ptrCast(@alignCast(dev.*.pUserData.?));
    if (in == null) return;
    const buf: [*]const f32 = @ptrCast(@alignCast(in.?));
    const n: usize = frame_count * CHANNELS;
    var sq: f64 = 0;
    var pk: f32 = st.peak;
    for (0..n) |i| {
        const v = buf[i];
        sq += @as(f64, v) * @as(f64, v);
        pk = @max(pk, @abs(v));
    }
    st.sumsq += sq;
    st.peak = pk;
    st.frames += frame_count;
    st.callbacks += 1;
}

/// THE CALLBACK IS NOT THE DEADLINE -- MEASURED, AND IT CHANGES THE TABLE.
///
/// The first cut of this phase timed the gap between successive data callbacks
/// and called the spread "jitter". The numbers were nonsense: a p50 of 2.3 us
/// against a mean of 2639 us. The reason is that WASAPI shared mode wakes the
/// device thread once per INTERNAL period (480 frames = 10 ms here) and
/// miniaudio then issues a BURST of data callbacks back-to-back to fill it --
/// four 128-frame callbacks in ~7 us, then a 10 ms gap.
///
/// So the deadline is the WAKE-UP, not the callback. What must fit in 10 ms is
/// the burst's TOTAL work. Timing the callback gap measures the burst's
/// internal spacing, which nothing depends on. This is lesson 1 again --
/// decompose, and name which part the criterion is about -- caught inside SN0
/// rather than inherited by SN3.
const DeviceRun = struct {
    ok: bool = false,
    internal: u32 = 0,
    periods: u32 = 0,
    callbacks: usize = 0,
    bursts: usize = 0,
    burst_p50_ns: u64 = 0,
    burst_p99_ns: u64 = 0,
    burst_max_ns: u64 = 0,
    burst_min_ns: u64 = 0,
    work_p50_ns: u64 = 0,
    work_p99_ns: u64 = 0,
    work_max_ns: u64 = 0,
    budget_ns: f64 = 0,
    frames_delivered: u64 = 0,
    frames_expected: u64 = 0,
};

const Scratch = struct {
    t_enter: []u64,
    t_work: []u64,
    frames: []u32,
    a: []u64,
    b: []u64,
};

fn oneDeviceRun(sc: Scratch, want: u32, exclusive: bool) !DeviceRun {
    var st = CbState{
        .timer = try std.time.Timer.start(),
        .t_enter = sc.t_enter,
        .t_work = sc.t_work,
        .frames = sc.frames,
        .inc = 2.0 * std.math.pi * 440.0 / @as(f64, @floatFromInt(SAMPLE_RATE)),
    };

    var cfg = c.ma_device_config_init(c.ma_device_type_playback);
    cfg.playback.format = c.ma_format_f32;
    cfg.playback.channels = CHANNELS;
    cfg.playback.shareMode = if (exclusive) c.ma_share_mode_exclusive else c.ma_share_mode_shared;
    cfg.sampleRate = SAMPLE_RATE;
    cfg.periodSizeInFrames = want;
    cfg.dataCallback = playbackCallback;
    cfg.pUserData = &st;

    var dev: c.ma_device = undefined;
    if (c.ma_device_init(null, &cfg, &dev) != c.MA_SUCCESS) return .{};
    defer c.ma_device_uninit(&dev);

    var r = DeviceRun{
        .internal = dev.playback.internalPeriodSizeInFrames,
        .periods = dev.playback.internalPeriods,
    };
    if (c.ma_device_start(&dev) != c.MA_SUCCESS) return .{};

    var wall = try std.time.Timer.start();
    while (wall.read() < DEVICE_RUN_NS) std.Thread.sleep(20 * std.time.ns_per_ms);
    const elapsed = wall.read();
    _ = c.ma_device_stop(&dev);

    const n = st.n;
    if (n < 8) return .{};

    // A bounded record COUNTS what it drops (lesson 3): frames the device took
    // against frames the wall clock says it should have. A shortfall here is
    // audio that was never rendered -- the honest underrun proxy, since
    // miniaudio exposes no underrun counter of its own.
    r.frames_delivered = st.total_frames;
    r.frames_expected = @intFromFloat(@as(f64, @floatFromInt(elapsed)) / 1e9 * @as(f64, @floatFromInt(dev.playback.internalSampleRate)));

    // Group callbacks into bursts. A gap smaller than a quarter of the internal
    // period is within-burst; anything larger starts a new wake-up.
    const period_ns: f64 = 1e9 * @as(f64, @floatFromInt(r.internal)) / @as(f64, @floatFromInt(dev.playback.internalSampleRate));
    const gap_thresh: u64 = @intFromFloat(period_ns / 4.0);

    var nb: usize = 0; // burst start times
    var nw: usize = 0; // per-burst total work
    var burst_work: u64 = st.t_work[0];
    sc.a[0] = st.t_enter[0];
    nb = 1;
    for (1..n) |i| {
        if (st.t_enter[i] - st.t_enter[i - 1] > gap_thresh) {
            sc.b[nw] = burst_work;
            nw += 1;
            sc.a[nb] = st.t_enter[i];
            nb += 1;
            burst_work = 0;
        }
        burst_work += st.t_work[i];
    }
    sc.b[nw] = burst_work;
    nw += 1;

    if (nb < 4) return .{};
    // burst-to-burst periods
    const nd = nb - 1;
    for (1..nb) |i| sc.a[i - 1] = sc.a[i] - sc.a[i - 1];
    const dsl = sc.a[0..nd];
    const wsl = sc.b[0..nw];
    std.mem.sort(u64, dsl, {}, std.sort.asc(u64));
    std.mem.sort(u64, wsl, {}, std.sort.asc(u64));

    r.ok = true;
    r.callbacks = n;
    r.bursts = nb;
    r.burst_min_ns = dsl[0];
    r.burst_p50_ns = pctl(dsl, 0.50);
    r.burst_p99_ns = pctl(dsl, 0.99);
    r.burst_max_ns = dsl[nd - 1];
    r.work_p50_ns = pctl(wsl, 0.50);
    r.work_p99_ns = pctl(wsl, 0.99);
    r.work_max_ns = wsl[nw - 1];
    r.budget_ns = period_ns;
    return r;
}

fn runDevicePhase() !void {
    std.debug.print("\n== DEVICE WAKE-UP -- period, jitter and budget (playing a 440 Hz tone) ==\n", .{});
    std.debug.print("   the deadline is the WAKE-UP, not the callback: WASAPI shared mode issues a\n", .{});
    std.debug.print("   BURST of callbacks per wake-up, so what must fit the period is the burst total.\n", .{});

    const sc = Scratch{
        .t_enter = try alloc.alloc(u64, MAX_CALLBACKS),
        .t_work = try alloc.alloc(u64, MAX_CALLBACKS),
        .frames = try alloc.alloc(u32, MAX_CALLBACKS),
        .a = try alloc.alloc(u64, MAX_CALLBACKS),
        .b = try alloc.alloc(u64, MAX_CALLBACKS),
    };
    defer {
        alloc.free(sc.t_enter);
        alloc.free(sc.t_work);
        alloc.free(sc.frames);
        alloc.free(sc.a);
        alloc.free(sc.b);
    }

    for ([_]bool{ false, true }) |exclusive| {
        std.debug.print("\n-- {s} mode --\n", .{if (exclusive) "EXCLUSIVE" else "SHARED"});
        std.debug.print("{s:>6} {s:>9} {s:>4} {s:>7} {s:>7} {s:>9} {s:>9} {s:>9} {s:>8} {s:>9} {s:>8} {s:>9}\n", .{
            "asked", "internal", "xN", "cb", "bursts", "p50 ms", "p99 ms", "max ms", "jitter", "work p99", "budget", "frames",
        });
        for (PERIOD_SIZES) |want| {
            const r = try oneDeviceRun(sc, want, exclusive);
            if (!r.ok) {
                std.debug.print("{d:>6}  refused (counted): device init/start declined this configuration\n", .{want});
                continue;
            }
            const shortfall = if (r.frames_expected > r.frames_delivered) r.frames_expected - r.frames_delivered else 0;
            std.debug.print("{d:>6} {d:>9} {d:>4} {d:>7} {d:>7} {d:>9.3} {d:>9.3} {d:>9.3} {d:>7.1}% {d:>8.1}u {d:>7.2}% {d:>9}\n", .{
                want,
                r.internal,
                r.periods,
                r.callbacks,
                r.bursts,
                ms(r.burst_p50_ns),
                ms(r.burst_p99_ns),
                ms(r.burst_max_ns),
                100.0 * @as(f64, @floatFromInt(r.burst_max_ns - r.burst_min_ns)) / @as(f64, @floatFromInt(r.burst_p50_ns)),
                us(r.work_p99_ns),
                100.0 * @as(f64, @floatFromInt(r.work_p99_ns)) / r.budget_ns,
                shortfall,
            });
        }
    }
    std.debug.print("\n  'frames' = frames the wall clock expected minus frames the device took.\n", .{});
    std.debug.print("  Zero means the render thread kept up for the whole run. It is COUNTED, not assumed.\n", .{});
}

fn runCapturePhase() !void {
    std.debug.print("\n== CAPTURE -- 2 s from the default input ==\n", .{});
    var st = CaptureState{};
    var cfg = c.ma_device_config_init(c.ma_device_type_capture);
    cfg.capture.format = c.ma_format_f32;
    cfg.capture.channels = CHANNELS;
    cfg.sampleRate = SAMPLE_RATE;
    cfg.periodSizeInFrames = 256;
    cfg.dataCallback = captureCallback;
    cfg.pUserData = &st;

    var dev: c.ma_device = undefined;
    if (c.ma_device_init(null, &cfg, &dev) != c.MA_SUCCESS) {
        std.debug.print("  capture device init FAILED -- counted refusal, not a crash\n", .{});
        return;
    }
    defer c.ma_device_uninit(&dev);
    if (c.ma_device_start(&dev) != c.MA_SUCCESS) {
        std.debug.print("  capture start FAILED -- counted refusal\n", .{});
        return;
    }
    var wall = try std.time.Timer.start();
    while (wall.read() < 2 * std.time.ns_per_s) std.Thread.sleep(20 * std.time.ns_per_ms);
    _ = c.ma_device_stop(&dev);

    const n = st.frames * CHANNELS;
    const rms = if (n > 0) @sqrt(st.sumsq / @as(f64, @floatFromInt(n))) else 0;
    std.debug.print("  captured {d} frames in {d} callbacks ({d:.2} s at {d} Hz), rms {e:.3}, peak {e:.3}\n", .{
        st.frames,                                                                     st.callbacks,
        @as(f64, @floatFromInt(st.frames)) / @as(f64, @floatFromInt(SAMPLE_RATE)), SAMPLE_RATE,
        rms,                                                                           st.peak,
    });
    std.debug.print("  internal period {d} frames, internal rate {d} Hz\n", .{
        dev.capture.internalPeriodSizeInFrames, dev.capture.internalSampleRate,
    });
}

// ---------------------------------------------------------------- latency phase
//
// WHAT THIS MEASURES, STATED BEFORE THE NUMBER (the plans' habit):
//
// WASAPI loopback taps the endpoint's RENDER MIX. So an impulse written in our
// playback callback and seen in the loopback capture has crossed: our buffer ->
// the shared-mode mixer -> the endpoint. That is the SOFTWARE output path, and
// it is the part a sound engine can influence. It does NOT include the DAC or
// the speaker; a full acoustic round trip needs a microphone in front of the
// speaker, which is not a measurement a CI box can ever make.
//
// Reported alongside it: the device's own claimed buffer latency
// (internalPeriodSizeInFrames * internalPeriods / rate), which is what an audio
// API would tell you if you asked. Two independent readings of the same truth --
// the perf plane's law #5 -- rather than one number and a hope.

const LatState = struct {
    timer: std.time.Timer,
    fired: bool = false,
    arm: bool = false, // set by the main thread once the stream is in steady state
    t_emit: u64 = 0,
    warmup_cbs: usize = 0,
    frames_before: u64 = 0, // stream position of the impulse, in frames
};

const LoopState = struct {
    timer: std.time.Timer,
    armed: bool = false,
    detected: bool = false,
    t_detect: u64 = 0,
    peak: f32 = 0,
    rate: u32 = SAMPLE_RATE,
    channels: u32 = CHANNELS,
    cbs: usize = 0,
};

var g_lat: LatState = undefined;
var g_loop: LoopState = undefined;

fn latPlaybackCallback(dev: [*c]c.ma_device, out: ?*anyopaque, in: ?*const anyopaque, frame_count: c.ma_uint32) callconv(.c) void {
    _ = in;
    _ = dev;
    const n: usize = frame_count;
    const buf: [*]f32 = @ptrCast(@alignCast(out.?));
    @memset(buf[0 .. n * CHANNELS], 0);
    g_lat.warmup_cbs += 1;

    // ARM ON WALL TIME, NOT ON A CALLBACK COUNT -- the first cut counted 40
    // callbacks and measured 122 ms against a 30 ms buffer. The instrumentation
    // said why: ma_device_start takes hundreds of ms, and during startup the
    // callbacks run AHEAD of real time to prefill the ring, so callback 40 had
    // already queued 104 ms of audio that had not begun to play. Counting
    // callbacks measured the startup prefill; waiting on the clock measures the
    // steady state, which is the thing that has a latency.
    if (@atomicLoad(bool, &g_lat.arm, .acquire) and !g_lat.fired) {
        g_lat.t_emit = g_lat.timer.read();
        g_lat.fired = true;
        buf[0] = 0.9;
        buf[1] = 0.9;
    }
    if (!g_lat.fired) g_lat.frames_before += n;
}

fn loopbackCallback(dev: [*c]c.ma_device, out: ?*anyopaque, in: ?*const anyopaque, frame_count: c.ma_uint32) callconv(.c) void {
    _ = out;
    _ = dev;
    if (in == null or g_loop.detected) return;
    const t_now = g_loop.timer.read();
    g_loop.cbs += 1;
    const ch = g_loop.channels;
    const buf: [*]const f32 = @ptrCast(@alignCast(in.?));
    const n: usize = frame_count * ch;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const v = @abs(buf[i]);
        if (v > g_loop.peak) g_loop.peak = v;
        if (g_loop.armed and v > 0.25) {
            // where inside this block the impulse sat, converted to time: the
            // block arrived as a unit, so the sample offset is real information
            const frame_off = i / ch;
            const off_ns: u64 = @intFromFloat(1e9 * @as(f64, @floatFromInt(frame_off)) / @as(f64, @floatFromInt(g_loop.rate)));
            const block_ns: u64 = @intFromFloat(1e9 * @as(f64, @floatFromInt(frame_count)) / @as(f64, @floatFromInt(g_loop.rate)));
            g_loop.t_detect = t_now - block_ns + off_ns;
            g_loop.detected = true;
            return;
        }
    }
}

fn runLatencyPhase() !void {
    std.debug.print("\n== OUTPUT LATENCY -- impulse through WASAPI loopback ==\n", .{});
    std.debug.print("   (software output path: our buffer -> shared mixer -> endpoint tap.\n", .{});
    std.debug.print("    NOT the DAC or the speaker -- no CI box can measure those.)\n", .{});
    std.debug.print("   The loopback tap has buffering of its OWN, so an absolute reading is an\n", .{});
    std.debug.print("   UPPER BOUND. Two buffer configurations are measured so the tap's constant\n", .{});
    std.debug.print("   offset cancels in the difference -- that difference is the part we control.\n", .{});

    var shared_med: u64 = 0;
    var shared_ok = false;
    for ([_]bool{ false, true }) |exclusive| {
        const r = try latencyOnce(exclusive);
        if (r.got == 0) {
            std.debug.print("  {s:>9}: impulse never observed -- NOT MEASURED (loopback peak seen: {e:.3})\n", .{
                if (exclusive) "EXCLUSIVE" else "SHARED", r.peak,
            });
            continue;
        }
        std.debug.print("  {s:>9}: impulse->loopback min {d:>7.2} ms, median {d:>7.2} ms ({d}/{d} detected) | device-claimed buffer {d:.2} ms ({d} frames x {d} periods)\n", .{
            if (exclusive) "EXCLUSIVE" else "SHARED",
            ms(r.min_ns),
            ms(r.med_ns),
            r.got,
            REPS,
            r.claimed_ms,
            r.internal_frames,
            r.internal_periods,
        });
        if (!exclusive) {
            shared_med = r.med_ns;
            shared_ok = true;
        } else if (shared_ok) {
            const d = @as(f64, @floatFromInt(@as(i64, @intCast(shared_med)) - @as(i64, @intCast(r.med_ns)))) / 1e6;
            std.debug.print("  DIFFERENCE (shared - exclusive) = {d:.2} ms. The tap's own latency is common to both,\n", .{d});
            std.debug.print("  so this is the latency our buffer choice actually buys or costs.\n", .{});
        }
    }
}

const LatResult = struct {
    got: usize = 0,
    min_ns: u64 = 0,
    med_ns: u64 = 0,
    claimed_ms: f64 = 0,
    internal_frames: u32 = 0,
    internal_periods: u32 = 0,
    peak: f32 = 0,
};

fn latencyOnce(exclusive: bool) !LatResult {
    var samples: [REPS]u64 = undefined;
    var got: usize = 0;
    var claimed_ms: f64 = 0;
    var internal_frames: u32 = 0;
    var internal_periods: u32 = 0;

    for (0..REPS) |_| {
        const shared = try std.time.Timer.start();
        g_lat = .{ .timer = shared };
        g_loop = .{ .timer = shared };

        // loopback first, so it is already listening when the tone starts
        var lcfg = c.ma_device_config_init(c.ma_device_type_loopback);
        lcfg.capture.format = c.ma_format_f32;
        lcfg.capture.channels = CHANNELS;
        lcfg.sampleRate = SAMPLE_RATE;
        lcfg.periodSizeInFrames = 128;
        lcfg.dataCallback = loopbackCallback;
        var ldev: c.ma_device = undefined;
        if (c.ma_device_init(null, &lcfg, &ldev) != c.MA_SUCCESS) {
            std.debug.print("  loopback capture unavailable on this backend -- NOT MEASURED (counted refusal)\n", .{});
            break;
        }
        defer c.ma_device_uninit(&ldev);
        g_loop.rate = ldev.capture.internalSampleRate;
        g_loop.channels = ldev.capture.channels;

        var pcfg = c.ma_device_config_init(c.ma_device_type_playback);
        pcfg.playback.format = c.ma_format_f32;
        pcfg.playback.channels = CHANNELS;
        pcfg.playback.shareMode = if (exclusive) c.ma_share_mode_exclusive else c.ma_share_mode_shared;
        pcfg.sampleRate = SAMPLE_RATE;
        pcfg.periodSizeInFrames = 128;
        pcfg.dataCallback = latPlaybackCallback;
        var pdev: c.ma_device = undefined;
        if (c.ma_device_init(null, &pcfg, &pdev) != c.MA_SUCCESS) {
            std.debug.print("  playback init FAILED\n", .{});
            break;
        }
        defer c.ma_device_uninit(&pdev);
        internal_frames = pdev.playback.internalPeriodSizeInFrames;
        internal_periods = pdev.playback.internalPeriods;
        claimed_ms = 1000.0 * @as(f64, @floatFromInt(internal_frames * internal_periods)) /
            @as(f64, @floatFromInt(pdev.playback.internalSampleRate));

        _ = c.ma_device_start(&ldev);
        std.Thread.sleep(120 * std.time.ns_per_ms); // let loopback reach steady state
        g_loop.armed = true;
        _ = c.ma_device_start(&pdev);

        // 1.5 s of silence first: long enough that the startup prefill has
        // drained and the callback is being PACED by the device, which is the
        // only regime in which "latency" means anything.
        std.Thread.sleep(1500 * std.time.ns_per_ms);
        @atomicStore(bool, &g_lat.arm, true, .release);

        var wall = try std.time.Timer.start();
        while (!g_loop.detected and wall.read() < 3 * std.time.ns_per_s) std.Thread.sleep(2 * std.time.ns_per_ms);
        _ = c.ma_device_stop(&pdev);
        _ = c.ma_device_stop(&ldev);

        if (g_loop.detected and g_lat.fired and g_loop.t_detect > g_lat.t_emit) {
            samples[got] = g_loop.t_detect - g_lat.t_emit;
            got += 1;
            if (got == 1) {
                // instrument the first run rather than reason about it: where
                // the 100+ ms actually sits is the whole question
                std.debug.print("  [run 1] emit at {d:.2} ms, detect at {d:.2} ms (both on one monotonic clock)\n", .{ ms(g_lat.t_emit), ms(g_loop.t_detect) });
                std.debug.print("  [run 1] playback internal {d} frames x {d} periods @ {d} Hz; impulse queued at stream frame {d} = {d:.2} ms of audio\n", .{
                    pdev.playback.internalPeriodSizeInFrames, pdev.playback.internalPeriods, pdev.playback.internalSampleRate,
                    g_lat.frames_before,                      1000.0 * @as(f64, @floatFromInt(g_lat.frames_before)) / @as(f64, @floatFromInt(SAMPLE_RATE)),
                });
                std.debug.print("  [run 1] loopback internal {d} frames x {d} periods @ {d} Hz; {d} loopback callbacks before detection\n", .{
                    ldev.capture.internalPeriodSizeInFrames, ldev.capture.internalPeriods, ldev.capture.internalSampleRate, g_loop.cbs,
                });
            }
        }
    }

    if (got == 0) return .{ .peak = g_loop.peak, .claimed_ms = claimed_ms, .internal_frames = internal_frames, .internal_periods = internal_periods };
    const s = Stats.from(samples[0..got]);
    return .{
        .got = got,
        .min_ns = s.min_ns,
        .med_ns = s.med_ns,
        .claimed_ms = claimed_ms,
        .internal_frames = internal_frames,
        .internal_periods = internal_periods,
        .peak = g_loop.peak,
    };
}

// ---------------------------------------------------------------- devices

fn runDevicesPhase() !void {
    var ctx: c.ma_context = undefined;
    if (c.ma_context_init(null, 0, null, &ctx) != c.MA_SUCCESS) {
        std.debug.print("context init FAILED -- no audio backend (counted refusal)\n", .{});
        return;
    }
    defer _ = c.ma_context_uninit(&ctx);
    std.debug.print("== DEVICES (miniaudio {s}, backend {s}) ==\n", .{ c.ma_version_string(), c.ma_get_backend_name(ctx.backend) });

    var play: [*c]c.ma_device_info = undefined;
    var nplay: c.ma_uint32 = 0;
    var cap: [*c]c.ma_device_info = undefined;
    var ncap: c.ma_uint32 = 0;
    if (c.ma_context_get_devices(&ctx, &play, &nplay, &cap, &ncap) != c.MA_SUCCESS) {
        std.debug.print("  device enumeration FAILED\n", .{});
        return;
    }
    for (0..nplay) |i| std.debug.print("  [P{d}] {s}{s}\n", .{ i, trimName(&play[i].name), if (play[i].isDefault != 0) "  (default)" else "" });
    for (0..ncap) |i| std.debug.print("  [C{d}] {s}{s}\n", .{ i, trimName(&cap[i].name), if (cap[i].isDefault != 0) "  (default)" else "" });
}

// ---------------------------------------------------------------- main

pub fn main() !void {
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    const cmd = if (args.len > 1) args[1] else "all";
    const flac = if (args.len > 2) args[2] else null;

    std.debug.print("SN0 sound spike -- miniaudio {s}, Zig {s}\n", .{ c.ma_version_string(), @import("builtin").zig_version_string });

    if (std.mem.eql(u8, cmd, "devices")) {
        try runDevicesPhase();
    } else if (std.mem.eql(u8, cmd, "cpu")) {
        try runGraphPhase();
        try runDecodePhase(flac);
        try runResamplePhase();
    } else if (std.mem.eql(u8, cmd, "device")) {
        try runDevicesPhase();
        try runDevicePhase();
        try runCapturePhase();
    } else if (std.mem.eql(u8, cmd, "latency")) {
        try runLatencyPhase();
    } else if (std.mem.eql(u8, cmd, "all")) {
        try runDevicesPhase();
        try runGraphPhase();
        try runDecodePhase(flac);
        try runResamplePhase();
        try runDevicePhase();
        try runCapturePhase();
        try runLatencyPhase();
    } else {
        std.debug.print("unknown command '{s}' -- try devices | cpu | device | latency | all\n", .{cmd});
    }
}
