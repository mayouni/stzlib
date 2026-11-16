//! whisper.zig -- hearing: Whisper's speech recognition on ggml (CLUSTERBENCH-02, the hearing cluster, 2026-11-16).
//!
//! The model is read from whisper.cpp's own file (`ggml-small.bin` and its sizes): hyperparameters, the 80 mel filters,
//! the vocabulary's bytes, then every tensor by name -- one file carries everything a transcription needs. The graph is
//! built here by hand on the engine's vendored ggml, as OpenAI's whisper/model.py defines the model (whisper.cpp read as
//! reference, not vendored), and its parity is with a numpy implementation reading the same file
//! (base/test/clusterbench/_rig/whisper_reference.py):
//!
//!   - the log-mel as whisper/audio.py makes it: 30 s of samples (zeros after the recording), a 400-sample periodic Hann
//!     window every 160 samples on the start-reflected signal, the power spectrum through the file's mel filters,
//!     log10 clamped at 1e-10, floored 8 below its maximum, then (x + 4) / 4
//!   - the encoder: two convolutions (the second of stride 2) with exact GELU, the file's positions, pre-LayerNorm
//!     blocks (eps 1e-5), the key projection without a bias, a last LayerNorm
//!   - the decoder: token and learned positions, causal self-attention, cross-attention over the encoder's 1500 rows,
//!     an MLP, a last LayerNorm, the token embedding as the output projection
//!
//! The cross-attention's keys and values are computed ONCE per recording, in the encoder's graph, and kept; each
//! decoding step then recomputes the decoder over its few tokens (a recording of a sentence is tens of tokens).
//!
//! The model loads only with its recorded SHA-256 (model_digest.zig) and only when every tensor the graphs read is there
//! and shaped to the file's own sizes; every size read from the file is bounded before it is used.

const std = @import("std");
const og = @import("ocr_graph.zig");
const digest = @import("model_digest.zig");
const c = og.c;

const gpa = std.heap.c_allocator;

pub const EOT: i32 = 50257;
pub const SOT: i32 = 50258;
pub const TRANSCRIBE: i32 = 50359;
pub const NO_TIMESTAMPS: i32 = 50363;
pub const SOT_PREV: i32 = 50361; // <|startofprev|>: the text before it is context the model reads, not words it says
const N_SAMPLES = 480000;
const N_FFT = 400;
const HOP = 160;
const N_FRAMES = 3000;
const N_BINS = N_FFT / 2 + 1;

/// the languages in the order of their tokens, the first at SOT + 1
pub const LANGUAGES = [_][]const u8{ "en", "zh", "de", "es", "ru", "ko", "fr", "ja", "pt", "tr", "pl", "ca", "nl", "ar", "sv", "it", "id", "hi", "fi", "vi", "he", "uk", "el", "ms", "cs", "ro", "da", "hu", "ta", "no", "th", "ur", "hr", "bg", "lt", "la", "mi", "ml", "cy", "sk", "te", "fa", "lv", "bn", "sr", "az", "sl", "kn", "et", "mk", "br", "eu", "is", "hy", "ne", "mn", "bs", "kk", "sq", "sw", "gl", "mr", "pa", "si", "km", "sn", "yo", "so", "af", "oc", "ka", "be", "tg", "sd", "gu", "am", "yi", "lo", "uz", "fo", "ht", "ps", "tk", "nn", "mt", "sa", "lb", "my", "bo", "tl", "mg", "as", "tt", "haw", "ln", "ha", "ba", "jw", "su" };

pub const HParams = struct {
    n_vocab: usize,
    n_audio_ctx: usize,
    n_audio_state: usize,
    n_audio_head: usize,
    n_audio_layer: usize,
    n_text_ctx: usize,
    n_text_state: usize,
    n_text_head: usize,
    n_text_layer: usize,
    n_mels: usize,
};

const Model = struct {
    path: []u8,
    ctx: *c.ggml_context,
    hp: HParams,
    filters: []f32, // n_mels rows of N_BINS
    words: []u8, // the vocabulary's bytes, one after another
    starts: []u32, // word i is words[starts[i]..starts[i + 1]]
};

var g_model: ?Model = null;
var g_err: [300]u8 = undefined;
var g_err_len: usize = 0;

// the last recording: its log-mel, the encoder's rows, the cross-attention's keys and values per decoder layer, and the
// logits of the transcription's first step -- the first three for decoding, all four for a parity check
var g_mel: []f32 = &.{};
var g_enc: []f32 = &.{};
var g_logits0: []f32 = &.{};
var g_cross_ctx: ?*c.ggml_context = null;
var g_kc: [64]*c.ggml_tensor = undefined;
var g_vc: [64]*c.ggml_tensor = undefined;
var g_lang: [8]u8 = undefined;
var g_lang_len: usize = 0;
var g_stats: [4]f64 = .{ 0, 0, 0, 0 }; // ms of the log-mel, of the encoder, of the decoding; tokens made

pub fn lastError() []const u8 {
    return g_err[0..g_err_len];
}
fn setError(comptime fmt: []const u8, args: anytype) void {
    const s = std.fmt.bufPrint(&g_err, fmt, args) catch g_err[0..0];
    g_err_len = s.len;
}
pub fn language() []const u8 {
    return g_lang[0..g_lang_len];
}
pub fn stats() [4]f64 {
    return g_stats;
}
/// "mel", "encoder" or "logits": the last recording's float32 buffer, for a parity check
pub fn dump(which: []const u8) []const f32 {
    if (std.mem.eql(u8, which, "mel")) return g_mel;
    if (std.mem.eql(u8, which, "encoder")) return g_enc;
    if (std.mem.eql(u8, which, "logits")) return g_logits0;
    return &.{};
}

// ---------------------------------------------------------------- the file

const Reader = struct {
    b: []const u8,
    at: usize = 0,
    fn int(r: *Reader) !i32 {
        if (r.b.len - r.at < 4) return error.Truncated;
        const v = std.mem.readInt(i32, r.b[r.at..][0..4], .little);
        r.at += 4;
        return v;
    }
    fn size(r: *Reader, max: usize) !usize {
        const v = try r.int();
        if (v < 0 or @as(usize, @intCast(v)) > max) return error.BadSize;
        return @intCast(v);
    }
    fn bytes(r: *Reader, n: usize) ![]const u8 {
        if (r.b.len - r.at < n) return error.Truncated;
        const s = r.b[r.at .. r.at + n];
        r.at += n;
        return s;
    }
};

pub fn free() void {
    freeRecording();
    if (g_model) |*m| {
        c.ggml_free(m.ctx);
        gpa.free(m.path);
        gpa.free(m.filters);
        gpa.free(m.words);
        gpa.free(m.starts);
    }
    g_model = null;
}

fn freeRecording() void {
    if (g_cross_ctx) |cx| c.ggml_free(cx);
    g_cross_ctx = null;
    if (g_mel.len > 0) gpa.free(g_mel);
    if (g_enc.len > 0) gpa.free(g_enc);
    if (g_logits0.len > 0) gpa.free(g_logits0);
    g_mel = &.{};
    g_enc = &.{};
    g_logits0 = &.{};
}

/// The model at `path`, loaded once and kept while the same path is asked for; null with the error set.
pub fn load(path: []const u8) ?*Model {
    if (g_model) |*m| {
        if (std.mem.eql(u8, m.path, path)) return m;
    }
    free();
    const pz = gpa.dupeZ(u8, path) catch return null;
    defer gpa.free(pz);
    const vd = digest.verify(pz.ptr);
    if (vd != digest.OK) {
        setError("whisper: the model {s} was refused before parsing ({s})", .{ path, if (vd == digest.ERR_MISMATCH) "its sha256 is not the recorded one" else if (vd == digest.ERR_UNKNOWN) "no recorded sha256: no SHA256SUMS line beside it" else "unreadable" });
        return null;
    }
    const data = std.fs.cwd().readFileAlloc(gpa, path, 1 << 32) catch {
        setError("whisper: cannot read the model {s}", .{path});
        return null;
    };
    defer gpa.free(data);
    const m = parse(data) catch |e| {
        setError("whisper: the model {s} is not a whisper.cpp file this engine reads ({s})", .{ path, @errorName(e) });
        return null;
    };
    g_model = m;
    g_model.?.path = gpa.dupe(u8, path) catch {
        free();
        return null;
    };
    if (!contract(&g_model.?)) {
        setError("whisper: the model {s} has a weight missing or shaped against its own sizes", .{path});
        free();
        return null;
    }
    return &g_model.?;
}

fn parse(data: []const u8) !Model {
    var r = Reader{ .b = data };
    if (try r.int() != 0x67676D6C) return error.NotWhisper;
    const big = 1 << 20;
    var hp: HParams = undefined;
    hp.n_vocab = try r.size(big);
    hp.n_audio_ctx = try r.size(big);
    hp.n_audio_state = try r.size(1 << 14);
    hp.n_audio_head = try r.size(1024);
    hp.n_audio_layer = try r.size(64);
    hp.n_text_ctx = try r.size(big);
    hp.n_text_state = try r.size(1 << 14);
    hp.n_text_head = try r.size(1024);
    hp.n_text_layer = try r.size(64);
    hp.n_mels = try r.size(512);
    _ = try r.int(); // ftype: each tensor says its own type
    if (hp.n_audio_ctx * 2 != N_FRAMES or hp.n_vocab <= NO_TIMESTAMPS or hp.n_audio_head == 0 or hp.n_text_head == 0 or
        hp.n_audio_state % hp.n_audio_head != 0 or hp.n_text_state % hp.n_text_head != 0 or hp.n_text_state != hp.n_audio_state or
        hp.n_text_ctx < 8) return error.BadSizes;

    const n_mel = try r.size(512);
    const n_fft = try r.size(4096);
    if (n_mel != hp.n_mels or n_fft != N_BINS) return error.BadFilters;
    const fb = try r.bytes(n_mel * n_fft * 4);
    const filters = try gpa.alloc(f32, n_mel * n_fft);
    errdefer gpa.free(filters);
    for (filters, 0..) |*f, i| f.* = @bitCast(std.mem.readInt(u32, fb[i * 4 ..][0..4], .little));

    const n_words = try r.size(hp.n_vocab);
    const starts = try gpa.alloc(u32, n_words + 1);
    errdefer gpa.free(starts);
    var words: std.ArrayList(u8) = .{};
    errdefer words.deinit(gpa);
    for (0..n_words) |i| {
        starts[i] = @intCast(words.items.len);
        const n = try r.size(1024);
        try words.appendSlice(gpa, try r.bytes(n));
    }
    starts[n_words] = @intCast(words.items.len);

    // the tensors: a first pass sizes the context, a second fills it
    const first = r.at;
    var count: usize = 0;
    var total: usize = 0;
    while (r.at < data.len) {
        const t = try tensorHeader(&r);
        total += t.nbytes;
        _ = try r.bytes(t.nbytes);
        count += 1;
        if (count > 4096) return error.TooManyTensors;
    }
    const ctx = c.ggml_init(.{ .mem_size = total + count * (c.ggml_tensor_overhead() + 64) + (1 << 20), .mem_buffer = null, .no_alloc = false }) orelse return error.OutOfMemory;
    errdefer c.ggml_free(ctx);
    r.at = first;
    while (r.at < data.len) {
        const h = try tensorHeader(&r);
        const t = c.ggml_new_tensor(ctx, h.ty, @intCast(h.n_dims), &h.ne) orelse return error.OutOfMemory;
        if (c.ggml_nbytes(t) != h.nbytes) return error.BadTensor;
        _ = c.ggml_set_name(t, &h.name);
        @memcpy(@as([*]u8, @ptrCast(t.*.data))[0..h.nbytes], try r.bytes(h.nbytes));
    }
    return .{ .path = &.{}, .ctx = ctx, .hp = hp, .filters = filters, .words = try words.toOwnedSlice(gpa), .starts = starts };
}

const Header = struct {
    n_dims: usize,
    ne: [4]i64,
    ty: c.ggml_type,
    name: [64:0]u8,
    nbytes: usize,
};

fn tensorHeader(r: *Reader) !Header {
    var h: Header = .{ .n_dims = try r.size(4), .ne = .{ 1, 1, 1, 1 }, .ty = c.GGML_TYPE_F32, .name = @splat(0), .nbytes = 0 };
    const n_name = try r.size(63);
    const ty = try r.int();
    if (h.n_dims == 0) return error.BadTensor;
    var n: usize = 1;
    for (0..h.n_dims) |i| {
        const d = try r.size(1 << 20);
        if (d == 0) return error.BadTensor;
        h.ne[i] = @intCast(d);
        n = std.math.mul(usize, n, d) catch return error.BadTensor;
    }
    @memcpy(h.name[0..n_name], try r.bytes(n_name));
    switch (ty) {
        0 => {
            h.ty = c.GGML_TYPE_F32;
            h.nbytes = std.math.mul(usize, n, 4) catch return error.BadTensor;
        },
        1 => {
            h.ty = c.GGML_TYPE_F16;
            h.nbytes = std.math.mul(usize, n, 2) catch return error.BadTensor;
        },
        else => return error.UnreadType,
    }
    return h;
}

fn tensor(m: *const Model, comptime fmt: []const u8, args: anytype) ?*c.ggml_tensor {
    var buf: [96]u8 = undefined;
    const name = std.fmt.bufPrintZ(&buf, fmt, args) catch return null;
    return c.ggml_get_tensor(m.ctx, name.ptr);
}
fn need(m: *const Model, comptime fmt: []const u8, args: anytype) !*c.ggml_tensor {
    return tensor(m, fmt, args) orelse error.MissingTensor;
}
fn shaped(m: *const Model, comptime fmt: []const u8, args: anytype, ne: [4]i64) bool {
    const t = tensor(m, fmt, args) orelse return false;
    return t.*.ne[0] == ne[0] and t.*.ne[1] == ne[1] and t.*.ne[2] == ne[2] and t.*.ne[3] == ne[3];
}
fn vec(m: *const Model, comptime fmt: []const u8, args: anytype, n: i64) bool {
    const t = tensor(m, fmt, args) orelse return false;
    return t.*.type == c.GGML_TYPE_F32 and t.*.ne[0] == n and t.*.ne[1] == 1 and t.*.ne[2] == 1 and t.*.ne[3] == 1;
}

// THE MODEL'S CONTRACT: every weight the graphs read is there and shaped to the file's sizes, every bias and norm a
// vector of f32 (a convolution's bias is the file's [1, D]), so no graph below is handed a shape ggml would assert on
fn contract(m: *const Model) bool {
    const hp = m.hp;
    const D: i64 = @intCast(hp.n_audio_state);
    const M: i64 = @intCast(hp.n_mels);
    const F: i64 = 4 * D;
    if (hp.n_audio_layer > g_kc.len or hp.n_text_layer > g_kc.len) return false;
    if (!shaped(m, "encoder.conv1.weight", .{}, .{ 3, M, D, 1 }) or !shaped(m, "encoder.conv1.bias", .{}, .{ 1, D, 1, 1 })) return false;
    if (!shaped(m, "encoder.conv2.weight", .{}, .{ 3, D, D, 1 }) or !shaped(m, "encoder.conv2.bias", .{}, .{ 1, D, 1, 1 })) return false;
    if (!shaped(m, "encoder.positional_embedding", .{}, .{ D, @intCast(hp.n_audio_ctx), 1, 1 })) return false;
    if ((tensor(m, "encoder.conv1.bias", .{}) orelse return false).*.type != c.GGML_TYPE_F32) return false;
    if ((tensor(m, "encoder.conv2.bias", .{}) orelse return false).*.type != c.GGML_TYPE_F32) return false;
    if ((tensor(m, "encoder.positional_embedding", .{}) orelse return false).*.type != c.GGML_TYPE_F32) return false;
    for (0..hp.n_audio_layer) |L| {
        if (!block(m, "encoder", L, "attn", D, F, false)) return false;
    }
    if (!vec(m, "encoder.ln_post.weight", .{}, D) or !vec(m, "encoder.ln_post.bias", .{}, D)) return false;
    if (!shaped(m, "decoder.token_embedding.weight", .{}, .{ D, @intCast(hp.n_vocab), 1, 1 })) return false;
    if (!shaped(m, "decoder.positional_embedding", .{}, .{ D, @intCast(hp.n_text_ctx), 1, 1 })) return false;
    if ((tensor(m, "decoder.positional_embedding", .{}) orelse return false).*.type != c.GGML_TYPE_F32) return false;
    for (0..hp.n_text_layer) |L| {
        if (!block(m, "decoder", L, "attn", D, F, true) or !block(m, "decoder", L, "cross_attn", D, F, false)) return false;
    }
    return vec(m, "decoder.ln.weight", .{}, D) and vec(m, "decoder.ln.bias", .{}, D);
}

// one block's attention (query, key without bias, value, out) and its norm; with `mlp`, the MLP pair and its norm too
// (the encoder's blocks always have one: their attention is checked with mlp = false, then the MLP below)
fn block(m: *const Model, comptime side: []const u8, L: usize, comptime att: []const u8, D: i64, F: i64, mlp: bool) bool {
    const p = side ++ ".blocks.{d}.";
    inline for (.{ "query", "value", "out" }) |w| {
        if (!shaped(m, p ++ att ++ "." ++ w ++ ".weight", .{L}, .{ D, D, 1, 1 }) or !vec(m, p ++ att ++ "." ++ w ++ ".bias", .{L}, D)) return false;
    }
    if (!shaped(m, p ++ att ++ ".key.weight", .{L}, .{ D, D, 1, 1 })) return false;
    if (!vec(m, p ++ att ++ "_ln.weight", .{L}, D) or !vec(m, p ++ att ++ "_ln.bias", .{L}, D)) return false;
    if (mlp or std.mem.eql(u8, side, "encoder")) {
        if (!shaped(m, p ++ "mlp.0.weight", .{L}, .{ D, F, 1, 1 }) or !vec(m, p ++ "mlp.0.bias", .{L}, F)) return false;
        if (!shaped(m, p ++ "mlp.2.weight", .{L}, .{ F, D, 1, 1 }) or !vec(m, p ++ "mlp.2.bias", .{L}, D)) return false;
        if (!vec(m, p ++ "mlp_ln.weight", .{L}, D) or !vec(m, p ++ "mlp_ln.bias", .{L}, D)) return false;
    }
    return true;
}

// ---------------------------------------------------------------- the recording

/// 16 kHz mono samples of a WAV file's bytes -- 16-bit PCM or 32-bit IEEE float, plain or extensible -- as floats in [-1, 1); error.UnreadWav for any other form
pub fn wavSamples(bytes: []const u8) ![]f32 {
    if (bytes.len < 12 or !std.mem.eql(u8, bytes[0..4], "RIFF") or !std.mem.eql(u8, bytes[8..12], "WAVE")) return error.UnreadWav;
    var at: usize = 12;
    var fmt_ok = false;
    var float32 = false; // 16-bit integer PCM, or 32-bit IEEE float (as FLEURS and many recorders write it)
    while (bytes.len - at >= 8) {
        const id = bytes[at .. at + 4];
        const n: usize = std.mem.readInt(u32, bytes[at + 4 ..][0..4], .little);
        at += 8;
        if (n > bytes.len - at) return error.UnreadWav;
        const body = bytes[at .. at + n];
        if (std.mem.eql(u8, id, "fmt ")) {
            if (n < 16) return error.UnreadWav;
            var format = std.mem.readInt(u16, body[0..2], .little);
            // WAVE_FORMAT_EXTENSIBLE: the format is the first two bytes of its sub-format's GUID
            if (format == 0xFFFE and n >= 26) format = std.mem.readInt(u16, body[24..26], .little);
            const channels = std.mem.readInt(u16, body[2..4], .little);
            const rate = std.mem.readInt(u32, body[4..8], .little);
            const bits = std.mem.readInt(u16, body[14..16], .little);
            float32 = format == 3 and bits == 32;
            fmt_ok = channels == 1 and rate == 16000 and ((format == 1 and bits == 16) or float32);
            if (!fmt_ok) return error.NotSixteenKhzMono;
        } else if (std.mem.eql(u8, id, "data")) {
            if (!fmt_ok) return error.UnreadWav;
            if (float32) {
                const out = try gpa.alloc(f32, n / 4);
                for (out, 0..) |*s, i| s.* = @bitCast(std.mem.readInt(u32, body[i * 4 ..][0..4], .little));
                return out;
            }
            const out = try gpa.alloc(f32, n / 2);
            for (out, 0..) |*s, i| s.* = @as(f32, @floatFromInt(std.mem.readInt(i16, body[i * 2 ..][0..2], .little))) / 32768.0;
            return out;
        }
        at += n + (n & 1);
    }
    return error.UnreadWav;
}

/// the log-mel of up to 30 s of samples: n_mels rows of N_FRAMES, row-major (the encoder's input as ggml reads it)
fn logMel(m: *const Model, pcm: []const f32, out: []f32) void {
    const n_mels = m.hp.n_mels;
    // the cosine and sine tables of the 400-point transform (1.3 MB: on the heap, never a thread's stack), and the window
    const cosT = gpa.alloc(f64, N_BINS * N_FFT) catch return;
    defer gpa.free(cosT);
    const sinT = gpa.alloc(f64, N_BINS * N_FFT) catch return;
    defer gpa.free(sinT);
    for (0..N_BINS) |k| {
        for (0..N_FFT) |n| {
            const a = 2.0 * std.math.pi * @as(f64, @floatFromInt((k * n) % N_FFT)) / N_FFT;
            cosT[k * N_FFT + n] = @cos(a);
            sinT[k * N_FFT + n] = @sin(a);
        }
    }
    var win: [N_FFT]f64 = undefined;
    for (0..N_FFT) |n| win[n] = 0.5 - 0.5 * @cos(2.0 * std.math.pi * @as(f64, @floatFromInt(n)) / N_FFT);
    const used = @min(pcm.len, N_SAMPLES);
    // sample i of the start-reflected signal: the first N_FFT/2 mirror samples 1..200, then the recording, then zeros
    const at = struct {
        fn v(p: []const f32, u: usize, i: usize) f64 {
            const j: usize = if (i < N_FFT / 2) N_FFT / 2 - i else i - N_FFT / 2;
            return if (j < u) p[j] else 0;
        }
    }.v;
    var frame: [N_FFT]f64 = undefined;
    var power: [N_BINS]f64 = undefined;
    var top: f64 = -1e30;
    const tmp = gpa.alloc(f64, n_mels * N_FRAMES) catch return;
    defer gpa.free(tmp);
    for (0..N_FRAMES) |t| {
        var silent = true;
        for (0..N_FFT) |n| {
            frame[n] = at(pcm, used, t * HOP + n) * win[n];
            if (frame[n] != 0) silent = false;
        }
        if (silent) {
            @memset(&power, 0);
        } else {
            for (0..N_BINS) |k| {
                var re: f64 = 0;
                var im: f64 = 0;
                const cs = cosT[k * N_FFT ..][0..N_FFT];
                const sn = sinT[k * N_FFT ..][0..N_FFT];
                for (0..N_FFT) |n| {
                    re += frame[n] * cs[n];
                    im -= frame[n] * sn[n];
                }
                power[k] = re * re + im * im;
            }
        }
        for (0..n_mels) |b| {
            var s: f64 = 0;
            const f = m.filters[b * N_BINS ..][0..N_BINS];
            for (0..N_BINS) |k| s += @as(f64, f[k]) * power[k];
            const lg = std.math.log10(@max(s, 1e-10));
            tmp[b * N_FRAMES + t] = lg;
            top = @max(top, lg);
        }
    }
    for (tmp, 0..) |v, i| out[i] = @floatCast((@max(v, top - 8.0) + 4.0) / 4.0);
}

fn layerNorm(ctx: *c.ggml_context, x: *c.ggml_tensor, w: *c.ggml_tensor, b: *c.ggml_tensor) *c.ggml_tensor {
    return c.ggml_add(ctx, c.ggml_mul(ctx, c.ggml_norm(ctx, x, 1e-5), w), b).?;
}

// attention of `n_q` query rows over keys K [hd, n_k, H] and values Vt [n_k, hd, H] already split by head
fn attend(ctx: *c.ggml_context, q: *c.ggml_tensor, K: *c.ggml_tensor, Vt: *c.ggml_tensor, D: usize, H: usize, n_q: usize, causal: bool) *c.ggml_tensor {
    const hd = D / H;
    const Q = c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, q, @intCast(hd), @intCast(H), @intCast(n_q)), 0, 2, 1, 3)).?;
    var kq = c.ggml_mul_mat(ctx, K, Q).?; // [n_k, n_q, H]
    if (causal) kq = c.ggml_diag_mask_inf(ctx, kq, 0).?;
    kq = c.ggml_soft_max_ext(ctx, kq, null, 1.0 / @sqrt(@as(f32, @floatFromInt(hd))), 0.0).?;
    var kqv = c.ggml_mul_mat(ctx, Vt, kq).?; // [hd, n_q, H]
    kqv = c.ggml_cont(ctx, c.ggml_permute(ctx, kqv, 0, 2, 1, 3)).?;
    return c.ggml_reshape_2d(ctx, kqv, @intCast(D), @intCast(n_q)).?;
}

fn splitKeys(ctx: *c.ggml_context, k: *c.ggml_tensor, D: usize, H: usize, n: usize) *c.ggml_tensor {
    return c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, k, @intCast(D / H), @intCast(H), @intCast(n)), 0, 2, 1, 3)).?;
}
fn splitValues(ctx: *c.ggml_context, v: *c.ggml_tensor, D: usize, H: usize, n: usize) *c.ggml_tensor {
    return c.ggml_cont(ctx, c.ggml_permute(ctx, c.ggml_reshape_3d(ctx, v, @intCast(D / H), @intCast(H), @intCast(n)), 1, 2, 0, 3)).?;
}

fn compute(graph: *c.ggml_cgraph, n_threads: c_int) !*c.ggml_gallocr {
    const galloc = c.ggml_gallocr_new(c.ggml_backend_cpu_buffer_type()) orelse return error.OutOfMemory;
    errdefer c.ggml_gallocr_free(galloc);
    if (!c.ggml_gallocr_alloc_graph(galloc, graph)) return error.OutOfMemory;
    var plan = c.ggml_graph_plan(graph, n_threads, null);
    var wbuf: ?[]u8 = null;
    defer if (wbuf) |w| gpa.free(w);
    if (plan.work_size > 0) {
        wbuf = try gpa.alloc(u8, plan.work_size);
        plan.work_data = wbuf.?.ptr;
    }
    if (c.ggml_graph_compute(graph, &plan) != c.GGML_STATUS_SUCCESS) return error.ComputeFailed;
    return galloc;
}

/// The recording through the encoder: keeps its log-mel, the encoder's rows and each decoder layer's cross-attention
/// keys and values, for the decoding steps that follow.
pub fn encode(m: *const Model, pcm: []const f32, n_threads: c_int) !void {
    freeRecording();
    const hp = m.hp;
    const D = hp.n_audio_state;
    const T = hp.n_audio_ctx;
    var t0 = std.time.nanoTimestamp();
    g_mel = try gpa.alloc(f32, hp.n_mels * N_FRAMES);
    logMel(m, pcm, g_mel);
    g_stats[0] = msSince(t0);
    t0 = std.time.nanoTimestamp();

    const MAX_NODES = 8192;
    const meta = c.ggml_init(.{ .mem_size = c.ggml_tensor_overhead() * MAX_NODES + c.ggml_graph_overhead_custom(MAX_NODES, false) + (1 << 20), .mem_buffer = null, .no_alloc = true }) orelse return error.OutOfMemory;
    defer c.ggml_free(meta);
    const dctx = c.ggml_init(.{ .mem_size = g_mel.len * 4 + c.ggml_tensor_overhead() * 2 + 4096, .mem_buffer = null, .no_alloc = false }) orelse return error.OutOfMemory;
    defer c.ggml_free(dctx);
    const mel = c.ggml_new_tensor_2d(dctx, c.GGML_TYPE_F32, N_FRAMES, @intCast(hp.n_mels)) orelse return error.OutOfMemory;
    @memcpy(@as([*]f32, @ptrCast(@alignCast(mel.*.data)))[0..g_mel.len], g_mel);
    const ctx = meta;

    var x = c.ggml_conv_1d(ctx, try need(m, "encoder.conv1.weight", .{}), mel, 1, 1, 1).?; // [3000, D]
    x = c.ggml_gelu_erf(ctx, c.ggml_add(ctx, x, try need(m, "encoder.conv1.bias", .{}))).?;
    x = c.ggml_conv_1d(ctx, try need(m, "encoder.conv2.weight", .{}), x, 2, 1, 1).?; // [1500, D]
    x = c.ggml_gelu_erf(ctx, c.ggml_add(ctx, x, try need(m, "encoder.conv2.bias", .{}))).?;
    x = c.ggml_cont(ctx, c.ggml_transpose(ctx, x)).?; // [D, 1500]
    x = c.ggml_add(ctx, x, try need(m, "encoder.positional_embedding", .{})).?;
    const H = hp.n_audio_head;
    for (0..hp.n_audio_layer) |L| {
        const res = x;
        const h = layerNorm(ctx, x, try need(m, "encoder.blocks.{d}.attn_ln.weight", .{L}), try need(m, "encoder.blocks.{d}.attn_ln.bias", .{L}));
        const q = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "encoder.blocks.{d}.attn.query.weight", .{L}), h), try need(m, "encoder.blocks.{d}.attn.query.bias", .{L})).?;
        const k = c.ggml_mul_mat(ctx, try need(m, "encoder.blocks.{d}.attn.key.weight", .{L}), h).?;
        const v = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "encoder.blocks.{d}.attn.value.weight", .{L}), h), try need(m, "encoder.blocks.{d}.attn.value.bias", .{L})).?;
        const a = attend(ctx, q, splitKeys(ctx, k, D, H, T), splitValues(ctx, v, D, H, T), D, H, T, false);
        x = c.ggml_add(ctx, c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "encoder.blocks.{d}.attn.out.weight", .{L}), a), try need(m, "encoder.blocks.{d}.attn.out.bias", .{L})), res).?;
        x = c.ggml_add(ctx, try mlpOf(ctx, m, "encoder", L, x), x).?;
    }
    x = layerNorm(ctx, x, try need(m, "encoder.ln_post.weight", .{}), try need(m, "encoder.ln_post.bias", .{}));
    c.ggml_set_output(x);

    const graph = c.ggml_new_graph_custom(ctx, MAX_NODES, false) orelse return error.OutOfMemory;
    c.ggml_build_forward_expand(graph, x);
    const HT = hp.n_text_head;
    var kc: [64]*c.ggml_tensor = undefined;
    var vc: [64]*c.ggml_tensor = undefined;
    for (0..hp.n_text_layer) |L| {
        const k = c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.cross_attn.key.weight", .{L}), x).?;
        const v = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.cross_attn.value.weight", .{L}), x), try need(m, "decoder.blocks.{d}.cross_attn.value.bias", .{L})).?;
        kc[L] = splitKeys(ctx, k, D, HT, T);
        vc[L] = splitValues(ctx, v, D, HT, T);
        c.ggml_set_output(kc[L]);
        c.ggml_set_output(vc[L]);
        c.ggml_build_forward_expand(graph, kc[L]);
        c.ggml_build_forward_expand(graph, vc[L]);
    }
    const galloc = try compute(graph, n_threads);
    defer c.ggml_gallocr_free(galloc);

    g_enc = try gpa.alloc(f32, D * T);
    @memcpy(g_enc, @as([*]const f32, @ptrCast(@alignCast(x.*.data)))[0 .. D * T]);
    // the keys and values kept, in a context of their own
    const per = D * T * 4;
    const cx = c.ggml_init(.{ .mem_size = 2 * hp.n_text_layer * (per + c.ggml_tensor_overhead() + 64) + 4096, .mem_buffer = null, .no_alloc = false }) orelse return error.OutOfMemory;
    g_cross_ctx = cx;
    for (0..hp.n_text_layer) |L| {
        g_kc[L] = c.ggml_dup_tensor(cx, kc[L]).?;
        g_vc[L] = c.ggml_dup_tensor(cx, vc[L]).?;
        @memcpy(@as([*]u8, @ptrCast(g_kc[L].*.data))[0..per], @as([*]const u8, @ptrCast(kc[L].*.data))[0..per]);
        @memcpy(@as([*]u8, @ptrCast(g_vc[L].*.data))[0..per], @as([*]const u8, @ptrCast(vc[L].*.data))[0..per]);
    }
    g_stats[1] = msSince(t0);
}

fn mlpOf(ctx: *c.ggml_context, m: *const Model, comptime side: []const u8, L: usize, x: *c.ggml_tensor) !*c.ggml_tensor {
    const p = side ++ ".blocks.{d}.";
    const h = layerNorm(ctx, x, try need(m, p ++ "mlp_ln.weight", .{L}), try need(m, p ++ "mlp_ln.bias", .{L}));
    const u = c.ggml_gelu_erf(ctx, c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, p ++ "mlp.0.weight", .{L}), h), try need(m, p ++ "mlp.0.bias", .{L}))).?;
    return c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, p ++ "mlp.2.weight", .{L}), u), try need(m, p ++ "mlp.2.bias", .{L})).?;
}

/// the decoder over `tokens`: the logits of the token after the last one, n_vocab floats into `out`
fn decodeLogits(m: *const Model, tokens: []const i32, n_threads: c_int, out: []f32) !void {
    if (g_cross_ctx == null) return error.NotEncoded;
    const hp = m.hp;
    const D = hp.n_text_state;
    const H = hp.n_text_head;
    const n = tokens.len;
    if (n == 0 or n > hp.n_text_ctx or out.len != hp.n_vocab) return error.SizeMismatch;
    const MAX_NODES = 4096;
    const meta = c.ggml_init(.{ .mem_size = c.ggml_tensor_overhead() * MAX_NODES + c.ggml_graph_overhead_custom(MAX_NODES, false) + (1 << 20), .mem_buffer = null, .no_alloc = true }) orelse return error.OutOfMemory;
    defer c.ggml_free(meta);
    const dctx = c.ggml_init(.{ .mem_size = n * 4 + c.ggml_tensor_overhead() * 2 + 4096, .mem_buffer = null, .no_alloc = false }) orelse return error.OutOfMemory;
    defer c.ggml_free(dctx);
    const tok = c.ggml_new_tensor_1d(dctx, c.GGML_TYPE_I32, @intCast(n)) orelse return error.OutOfMemory;
    @memcpy(@as([*]i32, @ptrCast(@alignCast(tok.*.data)))[0..n], tokens);
    const ctx = meta;
    const emb = try need(m, "decoder.token_embedding.weight", .{});
    const pos = try need(m, "decoder.positional_embedding", .{});
    var x = c.ggml_add(ctx, c.ggml_get_rows(ctx, emb, tok), c.ggml_view_2d(ctx, pos, @intCast(D), @intCast(n), pos.*.nb[1], 0)).?;
    for (0..hp.n_text_layer) |L| {
        var res = x;
        var h = layerNorm(ctx, x, try need(m, "decoder.blocks.{d}.attn_ln.weight", .{L}), try need(m, "decoder.blocks.{d}.attn_ln.bias", .{L}));
        var q = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.attn.query.weight", .{L}), h), try need(m, "decoder.blocks.{d}.attn.query.bias", .{L})).?;
        const k = c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.attn.key.weight", .{L}), h).?;
        const v = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.attn.value.weight", .{L}), h), try need(m, "decoder.blocks.{d}.attn.value.bias", .{L})).?;
        var a = attend(ctx, q, splitKeys(ctx, k, D, H, n), splitValues(ctx, v, D, H, n), D, H, n, true);
        x = c.ggml_add(ctx, c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.attn.out.weight", .{L}), a), try need(m, "decoder.blocks.{d}.attn.out.bias", .{L})), res).?;
        res = x;
        h = layerNorm(ctx, x, try need(m, "decoder.blocks.{d}.cross_attn_ln.weight", .{L}), try need(m, "decoder.blocks.{d}.cross_attn_ln.bias", .{L}));
        q = c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.cross_attn.query.weight", .{L}), h), try need(m, "decoder.blocks.{d}.cross_attn.query.bias", .{L})).?;
        a = attend(ctx, q, g_kc[L], g_vc[L], D, H, n, false);
        x = c.ggml_add(ctx, c.ggml_add(ctx, c.ggml_mul_mat(ctx, try need(m, "decoder.blocks.{d}.cross_attn.out.weight", .{L}), a), try need(m, "decoder.blocks.{d}.cross_attn.out.bias", .{L})), res).?;
        x = c.ggml_add(ctx, try mlpOf(ctx, m, "decoder", L, x), x).?;
    }
    x = layerNorm(ctx, x, try need(m, "decoder.ln.weight", .{}), try need(m, "decoder.ln.bias", .{}));
    const last = c.ggml_view_2d(ctx, x, @intCast(D), 1, x.*.nb[1], (n - 1) * x.*.nb[1]).?;
    const logits = c.ggml_mul_mat(ctx, emb, last).?; // [n_vocab, 1]
    const graph = c.ggml_new_graph_custom(ctx, MAX_NODES, false) orelse return error.OutOfMemory;
    c.ggml_build_forward_expand(graph, logits);
    const galloc = try compute(graph, n_threads);
    defer c.ggml_gallocr_free(galloc);
    @memcpy(out, @as([*]const f32, @ptrCast(@alignCast(logits.*.data)))[0..out.len]);
}

fn argmax(v: []const f32) usize {
    var best: usize = 0;
    for (v, 0..) |x, i| {
        if (x > v[best]) best = i;
    }
    return best;
}

/// A prompt's tokens: at each place, the longest word of the vocabulary's text tokens that starts there (whisper.cpp's
/// greedy reading), a byte no word starts with skipped. At most `limit` tokens, the LAST ones kept, as Whisper keeps
/// the end of its previous text.
pub fn promptTokens(m: *const Model, text: []const u8, limit: usize) ![]i32 {
    var index = std.StringHashMap(i32).init(gpa);
    defer index.deinit();
    var longest: usize = 1;
    var w: usize = 0;
    while (w < @as(usize, @intCast(EOT)) and w + 1 < m.starts.len) : (w += 1) {
        const word = m.words[m.starts[w]..m.starts[w + 1]];
        if (word.len == 0) continue;
        const got = try index.getOrPut(word);
        if (!got.found_existing) got.value_ptr.* = @intCast(w);
        longest = @max(longest, word.len);
    }
    var out: std.ArrayList(i32) = .{};
    errdefer out.deinit(gpa);
    var at: usize = 0;
    while (at < text.len) {
        var n = @min(longest, text.len - at);
        while (n > 0) : (n -= 1) {
            if (index.get(text[at .. at + n])) |id| {
                try out.append(gpa, id);
                break;
            }
        }
        at += if (n == 0) 1 else n;
    }
    if (out.items.len > limit) {
        const drop = out.items.len - limit;
        std.mem.copyForwards(i32, out.items[0..limit], out.items[drop..]);
        out.shrinkRetainingCapacity(limit);
    }
    return out.toOwnedSlice(gpa);
}

/// The recording's words: `lang` is a language code, or "auto" for the one the model hears; greedy, at most
/// `max_tokens` tokens. The caller owns the text. language() then gives the language used.
pub fn transcribe(m: *const Model, pcm: []const f32, lang: []const u8, max_tokens: usize, n_threads: c_int) ![]u8 {
    return transcribePrompted(m, pcm, lang, "", max_tokens, n_threads);
}

/// transcribe(), with `prompt` -- words the recording is expected to hold (names, places, terms of the setting) -- read
/// by the decoder first, behind <|startofprev|>, so a word it hears is spelled as the prompt spells it. The language
/// is heard with no prompt, so a prompt never changes it. "" is no prompt.
pub fn transcribePrompted(m: *const Model, pcm: []const f32, lang: []const u8, prompt: []const u8, max_tokens: usize, n_threads: c_int) ![]u8 {
    g_err_len = 0;
    try encode(m, pcm, n_threads);
    const t0 = std.time.nanoTimestamp();
    const logits = try gpa.alloc(f32, m.hp.n_vocab);
    defer gpa.free(logits);
    var li: usize = LANGUAGES.len;
    if (std.mem.eql(u8, lang, "auto")) {
        try decodeLogits(m, &.{SOT}, n_threads, logits);
        li = argmax(logits[@intCast(SOT + 1)..][0..LANGUAGES.len]);
    } else {
        for (LANGUAGES, 0..) |code, i| {
            if (std.mem.eql(u8, code, lang)) li = i;
        }
        if (li == LANGUAGES.len) {
            setError("whisper: '{s}' is not a language code Whisper knows", .{lang});
            return error.UnknownLanguage;
        }
    }
    g_lang_len = LANGUAGES[li].len;
    @memcpy(g_lang[0..g_lang_len], LANGUAGES[li]);

    var tokens: std.ArrayList(i32) = .{};
    defer tokens.deinit(gpa);
    if (prompt.len > 0) {
        // Whisper's own bound: half the text context, less the <|startofprev|> token
        const pt = try promptTokens(m, prompt, m.hp.n_text_ctx / 2 - 1);
        defer gpa.free(pt);
        try tokens.append(gpa, SOT_PREV);
        try tokens.appendSlice(gpa, pt);
    }
    try tokens.appendSlice(gpa, &.{ SOT, SOT + 1 + @as(i32, @intCast(li)), TRANSCRIBE, NO_TIMESTAMPS });
    var text: std.ArrayList(u8) = .{};
    errdefer text.deinit(gpa);
    var made: usize = 0;
    while (made < max_tokens and tokens.items.len < m.hp.n_text_ctx) : (made += 1) {
        try decodeLogits(m, tokens.items, n_threads, logits);
        if (made == 0) g_logits0 = try gpa.dupe(f32, logits);
        // text tokens and the end only: no special token is chosen
        const next: i32 = @intCast(argmax(logits[0..@intCast(EOT + 1)]));
        if (next == EOT) break;
        try tokens.append(gpa, next);
        const w: usize = @intCast(next);
        if (w + 1 < m.starts.len) try text.appendSlice(gpa, m.words[m.starts[w]..m.starts[w + 1]]);
    }
    g_stats[2] = msSince(t0);
    g_stats[3] = @floatFromInt(made);
    return text.toOwnedSlice(gpa);
}

fn msSince(t: i128) f64 {
    return @as(f64, @floatFromInt(std.time.nanoTimestamp() - t)) / 1e6;
}

test "a WAV that is not 16 kHz mono 16-bit or float is refused, and one that is reads its samples" {
    var good = [_]u8{ 'R', 'I', 'F', 'F', 0, 0, 0, 0, 'W', 'A', 'V', 'E', 'f', 'm', 't', ' ', 16, 0, 0, 0, 1, 0, 1, 0, 0x80, 0x3E, 0, 0, 0, 0x7D, 0, 0, 2, 0, 16, 0, 'd', 'a', 't', 'a', 4, 0, 0, 0, 0, 0x40, 0, 0xC0 };
    const s = try wavSamples(&good);
    defer gpa.free(s);
    try std.testing.expectEqual(@as(usize, 2), s.len);
    try std.testing.expectApproxEqAbs(@as(f32, 0.5), s[0], 1e-6);
    try std.testing.expectApproxEqAbs(@as(f32, -0.5), s[1], 1e-6);
    // the same samples as 32-bit IEEE float (format 3)
    var flt = [_]u8{ 'R', 'I', 'F', 'F', 0, 0, 0, 0, 'W', 'A', 'V', 'E', 'f', 'm', 't', ' ', 16, 0, 0, 0, 3, 0, 1, 0, 0x80, 0x3E, 0, 0, 0, 0xFA, 0, 0, 4, 0, 32, 0, 'd', 'a', 't', 'a', 8, 0, 0, 0, 0, 0, 0, 0x3F, 0, 0, 0, 0xBF };
    const f = try wavSamples(&flt);
    defer gpa.free(f);
    try std.testing.expectEqual(@as(usize, 2), f.len);
    try std.testing.expectEqual(@as(f32, 0.5), f[0]);
    try std.testing.expectEqual(@as(f32, -0.5), f[1]);
    good[24] = 0x44; // 44100 Hz
    try std.testing.expectError(error.NotSixteenKhzMono, wavSamples(&good));
    try std.testing.expectError(error.UnreadWav, wavSamples("RIFF"));
}
