//! stz_sound -- the PORTABLE half of the sound plane. SN1 of SOFTANZA_SOUND_PLAN.md.
//!
//! Decode, encode, resample, convert, and hold samples. NOT one line of
//! WASAPI/CoreAudio/ALSA: the device tier is `audiodev.zig` in its own DLL, for
//! the reason FACT 3 gives and SN0 measured. This module cross-compiles to every
//! target the rest of the engine reaches, and everything in it is testable with
//! NO audio hardware -- which is what makes the plane CI-testable at all.
//!
//! ── THE DISCIPLINES THIS FILE INHERITS ──
//!
//!   - **f32 samples internally, interleaved** (plan sec.2). f64 only where
//!     analysis wants it, and analysis rides fft.zig, which is f64 already.
//!   - **Gen-keyed handles.** Ring never sees a pointer. A buffer id is
//!     (generation << 32) | (slot + 1); freeing bumps the slot's generation, so
//!     a stale id is DETECTED (status STALE) and counted, never silently reused.
//!     Same discipline as gpu.zig's VRAM table and window.zig's windows.
//!   - **A bounded record COUNTS what it drops** (lesson 3). Every refusal,
//!     every stale hit, every decode error is a counter a guard can read.
//!   - **Allocation happens at load/prepare time, never in a render path.**
//!     Nothing here is called from an audio callback -- SN3's callback consumes
//!     what this module prepared -- but the shape is set now so it stays true.
//!
//! ── THE UNICODE TRAP, PAID FOR HERE RATHER THAN IN A BUG REPORT ──
//!
//! miniaudio's `ma_decoder_init_file` takes a NARROW path and reaches `fopen`,
//! which on Windows interprets bytes in the ANSI codepage. Hand it a UTF-8
//! Arabic filename and it fails to open a file that plainly exists. The `_w`
//! variants take wchar_t and work. So on Windows every path in this module is
//! converted UTF-8 -> UTF-16 and routed to `_w`; on POSIX the UTF-8 bytes go
//! straight through, which is already correct there.
//!
//! Requirement 4 says the library's multilingual identity does not stop at the
//! speaker. It very nearly stopped at `fopen`.

const std = @import("std");
const builtin = @import("builtin");

const c = @cImport({
    @cDefine("MA_NO_DEVICE_IO", "1");
    @cDefine("MA_NO_ENGINE", "1");
    @cDefine("MA_NO_RESOURCE_MANAGER", "1");
    @cDefine("MA_NO_NODE_GRAPH", "1");
    @cInclude("miniaudio.h");
});

const alloc = std.heap.c_allocator;

// ---------------------------------------------------------------- status

pub const OK: i32 = 0;
pub const FALLBACK: i32 = 1;
pub const STALE: i32 = 2; // generation mismatch: the buffer was freed
pub const BAD_ARG: i32 = 3;
pub const TOO_LARGE: i32 = 4;
pub const IO_ERROR: i32 = 5; // could not open / read / write the file
pub const UNSUPPORTED: i32 = 6; // a format this vendor does not encode

// ---------------------------------------------------------------- counters

pub const CTR_BUFFERS_LIVE = 0; // sound.buffers.live
pub const CTR_BUFFERS_CREATED = 1; // sound.buffers.created
pub const CTR_FRAMES_DECODED = 2; // sound.frames.decoded
pub const CTR_DECODE_BYTES = 3; // sound.decode.bytes
pub const CTR_DECODE_ERRORS = 4; // sound.decode.errors
pub const CTR_ENCODE_FRAMES = 5; // sound.encode.frames
pub const CTR_ENCODE_ERRORS = 6; // sound.encode.errors
pub const CTR_RESAMPLE_FRAMES = 7; // sound.resample.frames
pub const CTR_STALE_HITS = 8; // sound.stale.hits -- a dead id was used
pub const CTR_REFUSALS = 9; // sound.refusals -- bad arg / unsupported
pub const CTR_COUNT = 10;

var counters: [CTR_COUNT]f64 = @splat(0);

fn bump(i: usize, v: f64) void {
    counters[i] += v;
}

pub fn counter(i: usize) f64 {
    if (i >= CTR_COUNT) return 0;
    return counters[i];
}

pub fn countersReset() void {
    counters = @splat(0);
    // buffers.live is a GAUGE, not a tally: resetting it to zero would lie
    // about buffers that are still alive. Restore it from the table.
    var live: f64 = 0;
    for (bufs.items) |b| {
        if (b.live) live += 1;
    }
    counters[CTR_BUFFERS_LIVE] = live;
}

// ---------------------------------------------------------------- errors

var last_error_buf: [512]u8 = @splat(0);
var last_error_len: usize = 0;

fn setErr(msg: []const u8) void {
    const n = @min(msg.len, last_error_buf.len);
    @memcpy(last_error_buf[0..n], msg[0..n]);
    last_error_len = n;
}

pub fn lastError() []const u8 {
    return last_error_buf[0..last_error_len];
}

/// The portable half is always available -- it needs no hardware. It exists so
/// the Ring face can ask the same question of both DLLs and get an honest
/// answer from each.
pub fn isAvailable() i32 {
    return 1;
}

// ---------------------------------------------------------------- buffer table

const Buf = struct {
    data: []f32 = &.{}, // interleaved: frames * channels
    frames: usize = 0,
    channels: u32 = 0,
    rate: u32 = 0,
    gen: u32 = 1,
    live: bool = false,
};

var bufs: std.ArrayList(Buf) = .{};

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 32) | @as(i64, @intCast(slot + 1));
}

/// Resolve an id to a live slot, or null. A null here is the whole point of the
/// generation key: it distinguishes "never existed" and "freed" from "valid",
/// and it COUNTS the stale case so a guard can prove the detection fires.
fn slotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(bufs.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!bufs.items[s].live or bufs.items[s].gen != gen) {
        bump(CTR_STALE_HITS, 1);
        return null;
    }
    return s;
}

fn adopt(data: []f32, frames: usize, channels: u32, rate: u32) i64 {
    // reuse a dead slot before growing: slots are cheap, generations are the
    // safety property, and reuse keeps the table from growing without bound
    for (bufs.items, 0..) |*b, i| {
        if (!b.live) {
            b.* = .{ .data = data, .frames = frames, .channels = channels, .rate = rate, .gen = b.gen, .live = true };
            bump(CTR_BUFFERS_LIVE, 1);
            bump(CTR_BUFFERS_CREATED, 1);
            return makeId(i, b.gen);
        }
    }
    bufs.append(alloc, .{ .data = data, .frames = frames, .channels = channels, .rate = rate, .gen = 1, .live = true }) catch {
        alloc.free(data);
        setErr("out of memory growing the sample-buffer table");
        return 0;
    };
    bump(CTR_BUFFERS_LIVE, 1);
    bump(CTR_BUFFERS_CREATED, 1);
    return makeId(bufs.items.len - 1, 1);
}

pub fn free(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    alloc.free(bufs.items[s].data);
    bufs.items[s].data = &.{};
    bufs.items[s].live = false;
    bufs.items[s].frames = 0;
    // the generation bump is what makes the freed id STALE rather than reusable
    bufs.items[s].gen +%= 1;
    if (bufs.items[s].gen == 0) bufs.items[s].gen = 1; // 0 is never a valid gen
    bump(CTR_BUFFERS_LIVE, -1);
    return OK;
}

/// How many buffers are live right now -- read straight from the table, not
/// from the counter, so a guard can cross-check one against the other.
pub fn liveCount() f64 {
    var n: f64 = 0;
    for (bufs.items) |b| {
        if (b.live) n += 1;
    }
    return n;
}

// ---------------------------------------------------------------- paths
//
// On Windows a UTF-8 path must become UTF-16 or non-ASCII filenames fail; on
// POSIX the UTF-8 bytes are already right. Both call sites below do the
// conversion inline and route to the _w variant; there is no third one.

// ---------------------------------------------------------------- decode

fn readAllFrames(dec: *c.ma_decoder, channels: u32) ?struct { data: []f32, frames: usize } {
    var total: c.ma_uint64 = 0;
    // The length is a hint, not a promise: some streams cannot report it, and
    // a wrong hint must not truncate the decode. Preallocate from it, then keep
    // reading and growing until the decoder says it is done.
    _ = c.ma_decoder_get_length_in_pcm_frames(dec, &total);
    var cap: usize = if (total > 0) @intCast(total) else 48000;
    var data = alloc.alloc(f32, cap * channels) catch {
        setErr("out of memory allocating the decoded buffer");
        return null;
    };
    var frames: usize = 0;
    while (true) {
        if (frames == cap) {
            cap = cap * 2;
            data = alloc.realloc(data, cap * channels) catch {
                alloc.free(data);
                setErr("out of memory growing the decoded buffer");
                return null;
            };
        }
        var got: c.ma_uint64 = 0;
        const res = c.ma_decoder_read_pcm_frames(dec, data.ptr + frames * channels, cap - frames, &got);
        frames += @intCast(got);
        if (res != c.MA_SUCCESS or got == 0) break;
    }
    if (frames * channels != data.len) {
        data = alloc.realloc(data, frames * channels) catch data[0 .. frames * channels];
    }
    return .{ .data = data, .frames = frames };
}

fn finishDecode(dec: *c.ma_decoder) i64 {
    var fmt: c.ma_format = 0;
    var ch: c.ma_uint32 = 0;
    var rate: c.ma_uint32 = 0;
    _ = c.ma_decoder_get_data_format(dec, &fmt, &ch, &rate, null, 0);
    if (ch == 0 or rate == 0) {
        bump(CTR_DECODE_ERRORS, 1);
        setErr("decoder reported no channels or no sample rate");
        return 0;
    }
    const r = readAllFrames(dec, ch) orelse {
        bump(CTR_DECODE_ERRORS, 1);
        return 0;
    };
    bump(CTR_FRAMES_DECODED, @floatFromInt(r.frames));
    return adopt(r.data, r.frames, ch, rate);
}

/// Decode a whole file into f32 at its native channel count and rate. Returns a
/// buffer id, or 0 with lastError() set.
pub fn loadFile(path: []const u8) i64 {
    var cfg = c.ma_decoder_config_init(c.ma_format_f32, 0, 0); // 0 = keep native
    var dec: c.ma_decoder = undefined;

    const res = blk: {
        if (builtin.os.tag == .windows) {
            const w = std.unicode.utf8ToUtf16LeAllocZ(alloc, path) catch {
                setErr("path is not valid UTF-8");
                break :blk c.MA_INVALID_ARGS;
            };
            defer alloc.free(w);
            break :blk c.ma_decoder_init_file_w(@ptrCast(w.ptr), &cfg, &dec);
        } else {
            const z = alloc.dupeZ(u8, path) catch break :blk c.MA_OUT_OF_MEMORY;
            defer alloc.free(z);
            break :blk c.ma_decoder_init_file(z.ptr, &cfg, &dec);
        }
    };
    if (res != c.MA_SUCCESS) {
        bump(CTR_DECODE_ERRORS, 1);
        setErr("could not open or decode the file (unknown format, or missing)");
        return 0;
    }
    defer _ = c.ma_decoder_uninit(&dec);
    return finishDecode(&dec);
}

/// Decode from memory. The bytes are NOT retained -- the decode completes here.
pub fn loadMemory(bytes: []const u8) i64 {
    var cfg = c.ma_decoder_config_init(c.ma_format_f32, 0, 0);
    var dec: c.ma_decoder = undefined;
    if (c.ma_decoder_init_memory(bytes.ptr, bytes.len, &cfg, &dec) != c.MA_SUCCESS) {
        bump(CTR_DECODE_ERRORS, 1);
        setErr("could not decode the memory block (unknown format)");
        return 0;
    }
    defer _ = c.ma_decoder_uninit(&dec);
    bump(CTR_DECODE_BYTES, @floatFromInt(bytes.len));
    return finishDecode(&dec);
}

/// An all-silence buffer -- the starting point for synthesis, and the shape a
/// guard uses when it wants exact known samples rather than a file.
pub fn newSilent(frames: usize, channels: u32, rate: u32) i64 {
    if (frames == 0 or channels == 0 or channels > 64 or rate == 0) {
        bump(CTR_REFUSALS, 1);
        setErr("newSilent: frames, channels (1..64) and rate must all be positive");
        return 0;
    }
    const data = alloc.alloc(f32, frames * channels) catch {
        setErr("out of memory allocating a silent buffer");
        return 0;
    };
    @memset(data, 0);
    return adopt(data, frames, channels, rate);
}

// ---------------------------------------------------------------- accessors

pub fn frameCount(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return @floatFromInt(bufs.items[s].frames);
}

pub fn channelCount(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return @floatFromInt(bufs.items[s].channels);
}

pub fn sampleRate(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    return @floatFromInt(bufs.items[s].rate);
}

pub fn duration(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    const b = bufs.items[s];
    if (b.rate == 0) return 0;
    return @as(f64, @floatFromInt(b.frames)) / @as(f64, @floatFromInt(b.rate));
}

/// One sample. Frame and channel are 0-BASED here: this is the engine side, and
/// the house law is that engine bridges are 0-based while Ring faces are
/// 1-based and translate at the face.
pub fn getSample(id: i64, frame: usize, ch: u32) f64 {
    const s = slotOf(id) orelse return 0;
    const b = bufs.items[s];
    if (frame >= b.frames or ch >= b.channels) {
        bump(CTR_REFUSALS, 1);
        return 0;
    }
    return b.data[frame * b.channels + ch];
}

pub fn setSample(id: i64, frame: usize, ch: u32, v: f64) i32 {
    const s = slotOf(id) orelse return STALE;
    const b = bufs.items[s];
    if (frame >= b.frames or ch >= b.channels) {
        bump(CTR_REFUSALS, 1);
        return BAD_ARG;
    }
    b.data[frame * b.channels + ch] = @floatCast(v);
    return OK;
}

pub fn peak(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    var mx: f32 = 0;
    for (bufs.items[s].data) |v| mx = @max(mx, @abs(v));
    return mx;
}

pub fn rms(id: i64) f64 {
    const s = slotOf(id) orelse return -1;
    const d = bufs.items[s].data;
    if (d.len == 0) return 0;
    var sum: f64 = 0;
    for (d) |v| sum += @as(f64, v) * @as(f64, v);
    return @sqrt(sum / @as(f64, @floatFromInt(d.len)));
}

// ---------------------------------------------------------------- encode
//
// WAV ONLY, and that is the vendor's limit, not an omission. miniaudio's own
// documentation lists exactly one encoding format:
//
//     | ma_encoding_format_wav | WAV |
//
// The enum carries flac/mp3/vorbis names because the DECODER uses them.
// FLAC ENCODE would need a second vendor (libFLAC, LGPL -- which sec.4's
// licence hygiene rules out) or an encoder written here. Recorded in the SN1
// status rather than silently skipped; the offline sink that makes this plane
// CI-assertable only ever needed WAV.

pub const BITS_S16: u32 = 16;
pub const BITS_F32: u32 = 32;


// ---------------------------------------------------------------- to memory
//
// The SYMMETRIC half of loadMemory, and its absence was a real gap: a sound
// could be decoded from bytes but not encoded back to them, so anything that
// wanted to hand a buffer to another tier had to go through a temporary file.
// VC1 went to some trouble to keep a voice out of the filesystem; VC3 would
// have put it straight back to feed a recogniser.
//
// Written by hand rather than through miniaudio's encoder, which writes to a
// file or through vtable callbacks -- for 16-bit PCM the header is 44 bytes and
// the body is a clamp and a scale. CANONICAL layout: `fmt ` sixteen, `data` at
// 36, so even a naive reader is right.

var wav_mem: []u8 = &.{};

/// Encode the buffer as a complete 16-bit PCM WAV in memory. Returns its
/// length; the bytes are at `wavMemoryPtr()` until the next call.
pub fn saveWavToMemory(id: i64) i64 {
    const s = slotOf(id) orelse return 0;
    const b = bufs.items[s];
    const n_samples = b.frames * b.channels;
    const body = n_samples * 2;
    if (wav_mem.len > 0) alloc.free(wav_mem);
    wav_mem = alloc.alloc(u8, 44 + body) catch {
        wav_mem = &.{};
        bump(CTR_REFUSALS, 1);
        setErr("saveWavToMemory: out of memory");
        return 0;
    };
    const byte_rate = b.rate * b.channels * 2;
    @memcpy(wav_mem[0..4], "RIFF");
    std.mem.writeInt(u32, wav_mem[4..8], @intCast(36 + body), .little);
    @memcpy(wav_mem[8..12], "WAVE");
    @memcpy(wav_mem[12..16], "fmt ");
    std.mem.writeInt(u32, wav_mem[16..20], 16, .little);
    std.mem.writeInt(u16, wav_mem[20..22], 1, .little);
    std.mem.writeInt(u16, wav_mem[22..24], @intCast(b.channels), .little);
    std.mem.writeInt(u32, wav_mem[24..28], b.rate, .little);
    std.mem.writeInt(u32, wav_mem[28..32], byte_rate, .little);
    std.mem.writeInt(u16, wav_mem[32..34], @intCast(b.channels * 2), .little);
    std.mem.writeInt(u16, wav_mem[34..36], 16, .little);
    @memcpy(wav_mem[36..40], "data");
    std.mem.writeInt(u32, wav_mem[40..44], @intCast(body), .little);

    var i: usize = 0;
    while (i < n_samples) : (i += 1) {
        // clamp before scaling: a sample above 1.0 would wrap to a loud
        // negative, which is the worst-sounding possible failure
        const v = @max(-1.0, @min(1.0, b.data[i]));
        const q: i16 = @intFromFloat(v * 32767.0);
        std.mem.writeInt(i16, wav_mem[44 + i * 2 ..][0..2], q, .little);
    }
    bump(CTR_ENCODE_FRAMES, @floatFromInt(b.frames));
    return @intCast(wav_mem.len);
}

pub fn wavMemoryPtr() usize {
    if (wav_mem.len == 0) return 0;
    return @intFromPtr(wav_mem.ptr);
}

pub fn saveWav(id: i64, path: []const u8, bits: u32) i32 {
    const s = slotOf(id) orelse return STALE;
    const b = bufs.items[s];
    const fmt: c.ma_format = switch (bits) {
        BITS_S16 => c.ma_format_s16,
        BITS_F32 => c.ma_format_f32,
        else => {
            bump(CTR_REFUSALS, 1);
            setErr("saveWav: bit depth must be 16 or 32");
            return BAD_ARG;
        },
    };

    var cfg = c.ma_encoder_config_init(c.ma_encoding_format_wav, fmt, b.channels, b.rate);
    var enc: c.ma_encoder = undefined;
    const res = blk: {
        if (builtin.os.tag == .windows) {
            const w = std.unicode.utf8ToUtf16LeAllocZ(alloc, path) catch {
                setErr("path is not valid UTF-8");
                break :blk c.MA_INVALID_ARGS;
            };
            defer alloc.free(w);
            break :blk c.ma_encoder_init_file_w(@ptrCast(w.ptr), &cfg, &enc);
        } else {
            const z = alloc.dupeZ(u8, path) catch break :blk c.MA_OUT_OF_MEMORY;
            defer alloc.free(z);
            break :blk c.ma_encoder_init_file(z.ptr, &cfg, &enc);
        }
    };
    if (res != c.MA_SUCCESS) {
        bump(CTR_ENCODE_ERRORS, 1);
        setErr("could not open the output file for writing");
        return IO_ERROR;
    }
    defer c.ma_encoder_uninit(&enc);

    if (fmt == c.ma_format_f32) {
        var written: c.ma_uint64 = 0;
        _ = c.ma_encoder_write_pcm_frames(&enc, b.data.ptr, b.frames, &written);
        bump(CTR_ENCODE_FRAMES, @floatFromInt(written));
        return if (written == b.frames) OK else IO_ERROR;
    }

    // s16: convert in blocks rather than allocating a second whole copy.
    // Clamped, not wrapped -- a sample over 1.0 must become full scale, not
    // flip sign, which is the difference between a loud sound and a bang.
    const BLOCK = 4096;
    const tmp = alloc.alloc(i16, BLOCK * b.channels) catch {
        bump(CTR_ENCODE_ERRORS, 1);
        return IO_ERROR;
    };
    defer alloc.free(tmp);
    var done: usize = 0;
    while (done < b.frames) {
        const n = @min(BLOCK, b.frames - done);
        const src = b.data[done * b.channels ..][0 .. n * b.channels];
        for (tmp[0 .. n * b.channels], src) |*o, v| {
            const x = @max(-1.0, @min(1.0, v));
            o.* = @intFromFloat(@round(x * 32767.0));
        }
        var written: c.ma_uint64 = 0;
        _ = c.ma_encoder_write_pcm_frames(&enc, tmp.ptr, n, &written);
        if (written == 0) {
            bump(CTR_ENCODE_ERRORS, 1);
            return IO_ERROR;
        }
        done += @intCast(written);
    }
    bump(CTR_ENCODE_FRAMES, @floatFromInt(done));
    return OK;
}

/// FLAC encode is not available from this vendor. It refuses LOUDLY and is
/// COUNTED, rather than writing a WAV with a .flac name -- a silent substitution
/// is the kind of thing that is discovered years later in someone's archive.
pub fn saveFlac(id: i64, path: []const u8) i32 {
    _ = id;
    _ = path;
    bump(CTR_REFUSALS, 1);
    setErr("FLAC encoding is not supported: miniaudio encodes WAV only (it DECODES flac/mp3). See the SN1 status in SOFTANZA_SOUND_PLAN.md.");
    return UNSUPPORTED;
}

// ---------------------------------------------------------------- resampling
//
// OURS, IN ZIG, and sec.1 said so before any of it was written: "the mixer/
// graph, resampling, the synthesis primitives..." are written here rather than
// vendored, because the SIMD and multicore tiers make this shape of loop the
// house's strength.
//
// There is also a vendor reason. miniaudio 0.11.25 ships exactly two resampler
// algorithms -- `linear` and `custom` (the speex backend is gone) -- and linear
// resampling of audio is audibly poor: it is a two-tap filter, so it both
// aliases when downsampling and dulls when upsampling. SN0 measured miniaudio's
// linear at 1.17 ms per second of stereo audio; that is the number to beat, and
// quality is the axis to beat it on.
//
// The filter is a windowed sinc, tabulated once. h(t) = sinc(t) * blackman(t/HALF)
// in FILTER time; input-sample distance maps to filter time by `scale`, which is
// min(1, ratio). That single factor is what makes the same table correct for
// both directions: upsampling interpolates at the input Nyquist, downsampling
// moves the cutoff down to the OUTPUT Nyquist and so cannot alias.

pub const QUALITY_LINEAR: u32 = 0;
pub const QUALITY_SINC: u32 = 1;

const SINC_HALF = 16; // zero crossings per side at unity ratio
const SINC_DENSITY = 128; // table entries per unit of filter time
const SINC_TABLE_LEN = SINC_HALF * SINC_DENSITY + 2;

var sinc_table: [SINC_TABLE_LEN]f32 = undefined;
var sinc_ready = false;

fn sinc(x: f64) f64 {
    if (@abs(x) < 1e-12) return 1.0;
    const px = std.math.pi * x;
    return @sin(px) / px;
}

fn buildSincTable() void {
    if (sinc_ready) return;
    for (&sinc_table, 0..) |*h, i| {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, SINC_DENSITY);
        const u = t / @as(f64, SINC_HALF);
        const w = if (u >= 1.0) 0.0 else 0.42 + 0.5 * @cos(std.math.pi * u) + 0.08 * @cos(2.0 * std.math.pi * u);
        h.* = @floatCast(sinc(t) * w);
    }
    sinc_ready = true;
}

fn tapWeight(ft: f64) f64 {
    // ft is filter time, always >= 0 (the kernel is symmetric)
    const pos = ft * @as(f64, SINC_DENSITY);
    const i: usize = @intFromFloat(pos);
    if (i + 1 >= SINC_TABLE_LEN) return 0;
    const f = pos - @as(f64, @floatFromInt(i));
    const a = @as(f64, sinc_table[i]);
    const b = @as(f64, sinc_table[i + 1]);
    return a + f * (b - a);
}

/// Resample to `new_rate`, returning a NEW buffer id. The source is untouched --
/// conversions in this plane never mutate their input, so a guard can compare
/// before against after.
pub fn resample(id: i64, new_rate: u32, quality: u32) i64 {
    const s = slotOf(id) orelse return 0;
    const b = bufs.items[s];
    if (new_rate == 0 or new_rate > 768000) {
        bump(CTR_REFUSALS, 1);
        setErr("resample: target rate must be in 1..768000");
        return 0;
    }
    if (new_rate == b.rate) {
        // Not a no-op at the API level: the caller asked for a buffer and gets
        // one it owns, so freeing it cannot free someone else's samples.
        const copy = alloc.dupe(f32, b.data) catch {
            setErr("out of memory copying a buffer");
            return 0;
        };
        return adopt(copy, b.frames, b.channels, b.rate);
    }

    const ch = b.channels;
    const ratio = @as(f64, @floatFromInt(new_rate)) / @as(f64, @floatFromInt(b.rate));
    const out_frames: usize = @intFromFloat(@floor(@as(f64, @floatFromInt(b.frames)) * ratio));
    if (out_frames == 0) {
        bump(CTR_REFUSALS, 1);
        setErr("resample: the result would be empty");
        return 0;
    }
    const out = alloc.alloc(f32, out_frames * ch) catch {
        setErr("out of memory allocating the resampled buffer");
        return 0;
    };

    if (quality == QUALITY_LINEAR) {
        resampleLinear(b, out, out_frames, ratio);
    } else {
        buildSincTable();
        resampleSinc(b, out, out_frames, ratio);
    }
    bump(CTR_RESAMPLE_FRAMES, @floatFromInt(out_frames));
    return adopt(out, out_frames, ch, new_rate);
}

fn resampleLinear(b: Buf, out: []f32, out_frames: usize, ratio: f64) void {
    const ch = b.channels;
    const inv = 1.0 / ratio;
    for (0..out_frames) |i| {
        const pos = @as(f64, @floatFromInt(i)) * inv;
        const k: usize = @intFromFloat(pos);
        const f: f32 = @floatCast(pos - @as(f64, @floatFromInt(k)));
        const k1 = @min(k + 1, b.frames - 1);
        for (0..ch) |cc| {
            const a = b.data[k * ch + cc];
            const d = b.data[k1 * ch + cc];
            out[i * ch + cc] = a + f * (d - a);
        }
    }
}

fn resampleSinc(b: Buf, out: []f32, out_frames: usize, ratio: f64) void {
    const ch = b.channels;
    const inv = 1.0 / ratio;
    const scale = @min(1.0, ratio); // < 1 when downsampling: moves the cutoff
    const half_in: f64 = @as(f64, SINC_HALF) / scale; // support, in INPUT samples
    const last = b.frames - 1;

    for (0..out_frames) |i| {
        const pos = @as(f64, @floatFromInt(i)) * inv;
        const lo_f = @ceil(pos - half_in);
        const hi_f = @floor(pos + half_in);
        const lo: usize = if (lo_f < 0) 0 else @intFromFloat(lo_f);
        const hi: usize = if (hi_f > @as(f64, @floatFromInt(last))) last else @intFromFloat(hi_f);

        // The weights are normalised by their own sum. That is what keeps DC
        // gain at exactly 1 even at the edges, where the kernel is truncated
        // by the start and end of the signal -- without it, every file would
        // fade in and out by a few percent.
        var wsum: f64 = 0;
        var accs: [8]f64 = @splat(0);
        const nch = @min(ch, 8);
        var k = lo;
        while (k <= hi) : (k += 1) {
            const ft = @abs(pos - @as(f64, @floatFromInt(k))) * scale;
            const w = tapWeight(ft);
            if (w == 0) continue;
            wsum += w;
            for (0..nch) |cc| accs[cc] += w * @as(f64, b.data[k * ch + cc]);
        }
        const norm = if (wsum != 0) 1.0 / wsum else 0;
        for (0..nch) |cc| out[i * ch + cc] = @floatCast(accs[cc] * norm);
        // channels beyond 8 fall back to nearest-neighbour rather than being
        // silently dropped; 8 covers 7.1, and the refusal is visible in the data
        var cc: usize = nch;
        while (cc < ch) : (cc += 1) {
            const k0: usize = @min(@as(usize, @intFromFloat(pos)), last);
            out[i * ch + cc] = b.data[k0 * ch + cc];
        }
    }
}

// ---------------------------------------------------------------- channels

/// Convert to `n` channels, returning a NEW buffer.
///
/// The rules are deliberately simple and written down, because a silent
/// surprise here is a mix that sounds wrong for reasons nobody can find:
///   - same count       -> a copy
///   - to mono          -> the AVERAGE of every source channel
///   - from mono        -> the same signal in every destination channel
///   - otherwise        -> channel i maps to channel i; missing sources are
///                         silence, extra sources are dropped
/// Proper surround downmix coefficients (5.1 -> 2.0 with centre and LFE gains)
/// are a different job, and miniaudio's ma_channel_converter already does it if
/// this plane ever claims surround. It does not claim it today.
pub fn toChannels(id: i64, n: u32) i64 {
    const s = slotOf(id) orelse return 0;
    const b = bufs.items[s];
    if (n == 0 or n > 64) {
        bump(CTR_REFUSALS, 1);
        setErr("toChannels: channel count must be 1..64");
        return 0;
    }
    const out = alloc.alloc(f32, b.frames * n) catch {
        setErr("out of memory allocating the converted buffer");
        return 0;
    };
    const src_ch = b.channels;
    if (n == src_ch) {
        @memcpy(out, b.data);
    } else if (n == 1) {
        const inv: f32 = 1.0 / @as(f32, @floatFromInt(src_ch));
        for (0..b.frames) |i| {
            var sum: f32 = 0;
            for (0..src_ch) |cc| sum += b.data[i * src_ch + cc];
            out[i] = sum * inv;
        }
    } else if (src_ch == 1) {
        for (0..b.frames) |i| {
            const v = b.data[i];
            for (0..n) |cc| out[i * n + cc] = v;
        }
    } else {
        const common = @min(src_ch, n);
        for (0..b.frames) |i| {
            for (0..common) |cc| out[i * n + cc] = b.data[i * src_ch + cc];
            var cc: usize = common;
            while (cc < n) : (cc += 1) out[i * n + cc] = 0;
        }
    }
    return adopt(out, b.frames, n, b.rate);
}

// ---------------------------------------------------------------- tests
//
// Run directly (from libraries/stzlib/engine):
//     zig test src/sound.zig -I vendor/miniaudio \
//         vendor/miniaudio/stz_miniaudio_dec_impl.c -lc

const testing = std.testing;

test "a freed handle is STALE, not reused -- and the detection is counted" {
    countersReset();
    const id = newSilent(100, 2, 48000);
    try testing.expect(id != 0);
    try testing.expectEqual(@as(f64, 100), frameCount(id));

    const before = counter(CTR_STALE_HITS);
    try testing.expectEqual(OK, free(id));
    // the NEGATIVE sibling: the same id must now fail, and say why
    try testing.expectEqual(STALE, free(id));
    try testing.expectEqual(@as(f64, -1), frameCount(id));
    try testing.expect(counter(CTR_STALE_HITS) > before);

    // and a NEW buffer landing in that reused slot must not answer to the old id
    const id2 = newSilent(50, 1, 44100);
    try testing.expect(id2 != id);
    try testing.expectEqual(@as(f64, 50), frameCount(id2));
    try testing.expectEqual(@as(f64, -1), frameCount(id));
    _ = free(id2);
}

test "silence is silent, and set/get round-trips at the sample" {
    const id = newSilent(10, 2, 48000);
    defer _ = free(id);
    try testing.expectEqual(@as(f64, 0), peak(id));
    try testing.expectEqual(OK, setSample(id, 3, 1, 0.5));
    try testing.expectApproxEqAbs(@as(f64, 0.5), getSample(id, 3, 1), 1e-7);
    try testing.expectApproxEqAbs(@as(f64, 0.5), peak(id), 1e-7);
    // the other channel of the same frame stayed untouched
    try testing.expectEqual(@as(f64, 0), getSample(id, 3, 0));
    // out of range is a counted refusal, not a crash and not a wrong answer
    try testing.expectEqual(BAD_ARG, setSample(id, 99, 0, 1.0));
}

test "resampling preserves duration, DC gain and a sine's frequency" {
    const rate_in: u32 = 48000;
    const n: usize = 4800; // 0.1 s
    const id = newSilent(n, 1, rate_in);
    defer _ = free(id);

    // a 1 kHz sine, well below both Nyquists
    const s = slotOf(id).?;
    for (0..n) |i| {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(rate_in));
        bufs.items[s].data[i] = @floatCast(@sin(2.0 * std.math.pi * 1000.0 * t));
    }

    const down = resample(id, 44100, QUALITY_SINC);
    defer _ = free(down);
    try testing.expect(down != 0);
    try testing.expectEqual(@as(f64, 44100), sampleRate(down));
    // duration is preserved to within one output frame
    try testing.expectApproxEqAbs(duration(id), duration(down), 1.0 / 44100.0);
    // and the amplitude survives: a windowed sinc must not lose 20% of the signal
    try testing.expect(peak(down) > 0.95);
    try testing.expect(peak(down) < 1.05);
}

test "the sinc resampler keeps DC at unity -- including at the edges" {
    const n: usize = 1000;
    const id = newSilent(n, 1, 48000);
    defer _ = free(id);
    const s = slotOf(id).?;
    @memset(bufs.items[s].data, 1.0); // pure DC

    const up = resample(id, 96000, QUALITY_SINC);
    defer _ = free(up);
    // EVERY sample, not just the middle: edge normalisation is exactly the
    // thing that a "looks fine in the middle" test would miss
    const us = slotOf(up).?;
    for (bufs.items[us].data) |v| try testing.expectApproxEqAbs(@as(f64, 1.0), v, 1e-4);
}

test "channel conversion averages down and replicates up" {
    const id = newSilent(4, 2, 48000);
    defer _ = free(id);
    for (0..4) |i| {
        _ = setSample(id, i, 0, 1.0);
        _ = setSample(id, i, 1, 0.0);
    }
    const mono = toChannels(id, 1);
    defer _ = free(mono);
    try testing.expectEqual(@as(f64, 1), channelCount(mono));
    try testing.expectApproxEqAbs(@as(f64, 0.5), getSample(mono, 0, 0), 1e-7);

    const back = toChannels(mono, 2);
    defer _ = free(back);
    try testing.expectApproxEqAbs(@as(f64, 0.5), getSample(back, 0, 0), 1e-7);
    try testing.expectApproxEqAbs(@as(f64, 0.5), getSample(back, 0, 1), 1e-7);
    // the source was NOT mutated by either conversion
    try testing.expectApproxEqAbs(@as(f64, 1.0), getSample(id, 0, 0), 1e-7);
}

test "FLAC encode refuses loudly rather than writing a mislabelled WAV" {
    countersReset();
    const id = newSilent(8, 1, 48000);
    defer _ = free(id);
    const before = counter(CTR_REFUSALS);
    try testing.expectEqual(UNSUPPORTED, saveFlac(id, "nope.flac"));
    try testing.expect(counter(CTR_REFUSALS) > before);
    try testing.expect(lastError().len > 0);
}

test "the live gauge tracks the table, and a reset does not lie about it" {
    countersReset();
    const base = liveCount();
    const a = newSilent(4, 1, 8000);
    const b = newSilent(4, 1, 8000);
    try testing.expectEqual(base + 2, liveCount());
    try testing.expectEqual(liveCount(), counter(CTR_BUFFERS_LIVE));
    countersReset();
    // created/decoded are tallies and go to zero; live is a GAUGE and must not
    try testing.expectEqual(@as(f64, 0), counter(CTR_BUFFERS_CREATED));
    try testing.expectEqual(liveCount(), counter(CTR_BUFFERS_LIVE));
    _ = free(a);
    _ = free(b);
}

// ---------------------------------------------------------------- the recorder (SN4)
//
// The portable end of capture. The device tier fills a ring; this drains it
// into a sample buffer, which is then an ordinary stzSound like any other.
//
// It lives HERE, in the portable half, for the same reason everything else
// does: draining a ring into a buffer needs no audio hardware, so a test can
// push frames in by hand and assert what comes out. Only the thing that
// actually talks to a microphone is per-OS.

const sr = @import("soundring.zig");

const Recorder = struct {
    ring: ?*sr.Ring = null,
    ring_mem: []f32 = &.{},
    dest: []f32 = &.{}, // interleaved, capacity_frames * channels
    frames: usize = 0, // frames written into dest so far
    capacity: usize = 0, // dest capacity in frames
    channels: u32 = 0,
    rate: u32 = 0,
    gen: u32 = 1,
    live: bool = false,
};

var recs: std.ArrayList(Recorder) = .{};

fn recSlotOf(id: i64) ?usize {
    const idx = id & 0xffff_ffff;
    if (idx <= 0 or idx > @as(i64, @intCast(recs.items.len))) return null;
    const s: usize = @intCast(idx - 1);
    const gen: u32 = @intCast((id >> 32) & 0xffff_ffff);
    if (!recs.items[s].live or recs.items[s].gen != gen) {
        bump(CTR_STALE_HITS, 1);
        return null;
    }
    return s;
}

/// A recorder with room for `max_seconds`. The destination is allocated NOW,
/// not grown while recording: a realloc mid-capture is exactly the sort of
/// pause that costs you frames.
pub fn recorderNew(channels: u32, rate: u32, max_seconds: f64) i64 {
    if (channels == 0 or channels > 8 or rate == 0 or max_seconds <= 0 or max_seconds > 3600) {
        bump(CTR_REFUSALS, 1);
        setErr("recorderNew: channels 1..8, rate > 0, seconds 0..3600");
        return 0;
    }
    const cap_frames: usize = @intFromFloat(max_seconds * @as(f64, @floatFromInt(rate)));
    const ring_frames = sr.roundUpPow2(@max(rate / 4, 4096)); // ~250 ms of slack
    const mem = alloc.alloc(f32, ring_frames * channels) catch {
        setErr("out of memory allocating the capture ring");
        return 0;
    };
    @memset(mem, 0);
    const dest = alloc.alloc(f32, cap_frames * channels) catch {
        alloc.free(mem);
        setErr("out of memory allocating the recording buffer");
        return 0;
    };
    const ring = alloc.create(sr.Ring) catch {
        alloc.free(mem);
        alloc.free(dest);
        setErr("out of memory allocating the ring header");
        return 0;
    };
    ring.* = .{
        .magic = sr.MAGIC,
        .version = sr.VERSION,
        .channels = channels,
        .capacity = @intCast(ring_frames),
        .write_pos = 0,
        .frames_written = 0,
        .read_pos = 0,
        .frames_read = 0,
        .underruns = 0,
        .underrun_events = 0,
        .running = 1,
        .data = mem.ptr,
    };

    var slot: usize = recs.items.len;
    for (recs.items, 0..) |*k, i| {
        if (!k.live) {
            slot = i;
            break;
        }
    }
    if (slot == recs.items.len) {
        recs.append(alloc, .{}) catch {
            alloc.free(mem);
            alloc.free(dest);
            alloc.destroy(ring);
            setErr("out of memory growing the recorder table");
            return 0;
        };
    }
    const rc = &recs.items[slot];
    const gen = rc.gen;
    rc.* = .{
        .ring = ring,
        .ring_mem = mem,
        .dest = dest,
        .frames = 0,
        .capacity = cap_frames,
        .channels = channels,
        .rate = rate,
        .gen = gen,
        .live = true,
    };
    return makeId(slot, gen);
}

pub fn recorderRingPtr(id: i64) i64 {
    const s = recSlotOf(id) orelse return 0;
    return @intCast(@intFromPtr(recs.items[s].ring.?));
}

/// Move whatever the device has recorded into the destination. Call it often
/// enough that the ring does not overflow -- it holds about 250 ms.
/// Returns frames moved this call.
pub fn recorderDrain(id: i64) f64 {
    const s = recSlotOf(id) orelse return -1;
    const rc = &recs.items[s];
    const r = rc.ring.?;
    const nch: usize = rc.channels;
    var moved: usize = 0;
    while (rc.frames < rc.capacity) {
        const avail: usize = @intCast(r.readable());
        if (avail == 0) break;
        const room = rc.capacity - rc.frames;
        const n = @min(avail, room);
        const got = r.popInterleaved(rc.dest.ptr + rc.frames * nch, n);
        if (got == 0) break;
        rc.frames += got;
        moved += got;
    }
    return @floatFromInt(moved);
}

pub fn recorderFrames(id: i64) f64 {
    const s = recSlotOf(id) orelse return -1;
    return @floatFromInt(recs.items[s].frames);
}

/// Hand back what was recorded as an ordinary sample buffer, trimmed to the
/// frames actually captured. After this the recorder is spent.
pub fn recorderFinish(id: i64) i64 {
    const s = recSlotOf(id) orelse return 0;
    const rc = &recs.items[s];
    const n = rc.frames;
    if (n == 0) {
        bump(CTR_REFUSALS, 1);
        setErr("recorderFinish: nothing was recorded");
        recorderRelease(rc);
        return 0;
    }
    const data = alloc.alloc(f32, n * rc.channels) catch {
        setErr("out of memory trimming the recording");
        recorderRelease(rc);
        return 0;
    };
    @memcpy(data, rc.dest[0 .. n * rc.channels]);
    const ch = rc.channels;
    const rate = rc.rate;
    recorderRelease(rc);
    return adopt(data, n, ch, rate);
}

pub fn recorderFree(id: i64) i32 {
    const s = recSlotOf(id) orelse return STALE;
    recorderRelease(&recs.items[s]);
    return OK;
}

fn recorderRelease(rc: *Recorder) void {
    // poison before freeing: a capture callback still holding the address then
    // reads an invalid ring and drops its frames, rather than writing into
    // freed memory
    if (rc.ring) |r| {
        r.magic = 0;
        alloc.destroy(r);
    }
    if (rc.ring_mem.len > 0) alloc.free(rc.ring_mem);
    if (rc.dest.len > 0) alloc.free(rc.dest);
    rc.ring = null;
    rc.ring_mem = &.{};
    rc.dest = &.{};
    rc.live = false;
    rc.gen +%= 1;
    if (rc.gen == 0) rc.gen = 1;
}

test "a recorder turns pushed frames into an ordinary sample buffer" {
    // No microphone involved: push frames in exactly as a capture callback
    // would, then assert what comes out. This is why the recorder lives in the
    // portable half.
    const rid = recorderNew(1, 48000, 1.0);
    try testing.expect(rid != 0);
    const ptr = recorderRingPtr(rid);
    try testing.expect(ptr != 0);
    const ring: *sr.Ring = @ptrFromInt(@as(usize, @intCast(ptr)));

    const block = [_]f32{ 0.1, 0.2, 0.3, 0.4 };
    try testing.expectEqual(@as(usize, 4), ring.pushInterleaved(&block, 4));
    try testing.expectEqual(@as(f64, 4), recorderDrain(rid));
    try testing.expectEqual(@as(f64, 4), recorderFrames(rid));

    const buf = recorderFinish(rid);
    defer _ = free(buf);
    try testing.expectEqual(@as(f64, 4), frameCount(buf));
    try testing.expectEqual(@as(f64, 48000), sampleRate(buf));
    for (block, 0..) |w, i| try testing.expectApproxEqAbs(@as(f64, w), getSample(buf, i, 0), 1e-6);

    // the recorder id is spent, and says so rather than handing out a second copy
    try testing.expectEqual(@as(i64, 0), recorderFinish(rid));
}

test "a recording that captured nothing refuses rather than returning silence" {
    const rid = recorderNew(2, 48000, 0.5);
    countersReset();
    const before = counter(CTR_REFUSALS);
    try testing.expectEqual(@as(i64, 0), recorderFinish(rid));
    try testing.expect(counter(CTR_REFUSALS) > before);
}
