//! voice_spike.zig -- VC0: can this engine speak, and what does it cost?
//!
//! MEASUREMENT ONLY. No product code, no face, nothing that survives into a
//! DLL. The sound plane's SN0 spike earned its phases by measuring first and
//! deciding second, and the voice plane is not exempt -- especially because the
//! sound plan currently rules speech OUT as "NEURAL-tier work riding ggml",
//! and that sentence is wrong as written. It is true of NEURAL synthesis. It is
//! not true of the synthesiser every desktop OS already ships.
//!
//! WHAT IS BEING DECIDED HERE
//!
//!   1. Can the ENGINE reach a platform voice, in Zig, with no .NET and no
//!      helper process? If it cannot, the whole architecture changes shape --
//!      a face calling PowerShell is not an engine capability, and every other
//!      binding of this library would be left without it.
//!   2. Does a voice render to a BUFFER rather than only to a speaker? This is
//!      the architectural question. A voice that can only reach the speaker is
//!      a dead end bolted to the side of the plane; a voice that renders to
//!      samples IS a stzSound, and every verb the plane already owns -- filter,
//!      echo, mix, spectrogram, loudness, transport -- applies to it for free.
//!      "One world" is either that handoff or it is a slogan.
//!   3. What does it COST? Cold and warm, because a first call that pays for
//!      engine start-up is the same trap SN0 found in `ma_device_start` (500 ms,
//!      and callbacks running ahead of real time during it).
//!   4. What is REFUSED? A language with no installed voice must fail loudly
//!      and countably, not fall back to a language the operator cannot read.
//!
//! HOW TO RUN
//!
//!     zig build voice-spike
//!
//! WINDOWS ONLY, and deliberately: SAPI is the Windows answer. macOS has
//! AVSpeechSynthesizer and `say`; Linux has espeak-ng and festival and often
//! neither. Each is its own measurement, and the per-OS split this implies is
//! already the plane's law -- FACT 3, the same reason stz_audiodev.dll exists
//! apart from stz_sound.dll.

const std = @import("std");
const builtin = @import("builtin");

const win = if (builtin.os.tag == .windows) @cImport({
    @cDefine("_WIN32_WINNT", "0x0601");
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
    @cInclude("objbase.h");
    @cInclude("sapi.h");
}) else struct {};

// The GUIDs are written out rather than linked from sapi.lib: MinGW's import
// libraries do not carry them consistently, and a spike that fails to LINK
// teaches nothing about whether the platform can speak.
fn guid(a: u32, b: u16, c: u16, d: [8]u8) win.GUID {
    return .{ .Data1 = a, .Data2 = b, .Data3 = c, .Data4 = d };
}

const CLSID_SpVoice = guid(0x96749377, 0x3391, 0x11D2, .{ 0x9E, 0xE3, 0x00, 0xC0, 0x4F, 0x79, 0x73, 0x96 });
const IID_ISpVoice = guid(0x6C44DF74, 0x72B9, 0x4992, .{ 0xA1, 0xEC, 0xEF, 0x99, 0x6E, 0x04, 0x22, 0xD4 });
const CLSID_SpStream = guid(0x715D9C59, 0x4442, 0x11D2, .{ 0x96, 0x05, 0x00, 0xC0, 0x4F, 0x8E, 0xE6, 0x28 });
const IID_ISpStream = guid(0x12E3CCA9, 0x7518, 0x44C5, .{ 0xA5, 0xE7, 0xBA, 0x5A, 0x79, 0xCB, 0x92, 0x9E });
const SPDFID_WaveFormatEx = guid(0xC31ADBAE, 0x527F, 0x4FF5, .{ 0xA2, 0x30, 0xF6, 0x2B, 0xB6, 0x1F, 0xF7, 0x0C });

const SPF_DEFAULT: c_uint = 0;
const SPFM_CREATE_ALWAYS: c_uint = 3;

var refusals: u32 = 0;

fn refuse(comptime fmt: []const u8, args: anytype) void {
    refusals += 1;
    std.debug.print("    REFUSED: " ++ fmt ++ "\n", args);
}

pub fn main() !void {
    if (builtin.os.tag != .windows) {
        std.debug.print("voice_spike: Windows only -- SAPI is the Windows answer.\n", .{});
        std.debug.print("macOS (AVSpeechSynthesizer) and Linux (espeak-ng) are their own spikes.\n", .{});
        return;
    }
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    std.debug.print("\n=== VC0: THE VOICE SPIKE ===\n", .{});
    std.debug.print("Measurement only. Windows / SAPI, reached from the ENGINE.\n\n", .{});

    var hr = win.CoInitializeEx(null, win.COINIT_APARTMENTTHREADED);
    if (hr < 0) {
        std.debug.print("  CoInitializeEx failed: 0x{x}\n", .{@as(u32, @bitCast(hr))});
        return;
    }
    defer win.CoUninitialize();

    // ---- 1. can the engine reach a voice at all? --------------------------
    std.debug.print("-- 1. reaching a platform voice from Zig --\n", .{});
    var voice: ?*win.ISpVoice = null;
    hr = win.CoCreateInstance(
        &CLSID_SpVoice,
        null,
        win.CLSCTX_ALL,
        &IID_ISpVoice,
        @ptrCast(&voice),
    );
    if (hr < 0 or voice == null) {
        refuse("CoCreateInstance(SpVoice) -> 0x{x}. No platform voice.", .{@as(u32, @bitCast(hr))});
        std.debug.print("\n  VERDICT: the engine CANNOT reach a voice. The architecture\n", .{});
        std.debug.print("  would have to change shape -- see the spike's header.\n", .{});
        return;
    }
    const v = voice.?;
    defer _ = v.*.lpVtbl.*.Release.?(@ptrCast(v));
    std.debug.print("  ISpVoice obtained. No .NET, no helper process, no PowerShell.\n\n", .{});

    // ---- 2. does a voice render to a BUFFER? -----------------------------
    std.debug.print("-- 2. rendering to a FILE, not to a speaker --\n", .{});
    std.debug.print("   This is the architectural question: a voice that reaches only\n", .{});
    std.debug.print("   the speaker is bolted on; a voice that renders to samples IS a\n", .{});
    std.debug.print("   stzSound, and the whole plane applies to it.\n", .{});

    const tmp = try std.fs.cwd().realpathAlloc(alloc, ".");
    defer alloc.free(tmp);
    const out_path = try std.fmt.allocPrint(alloc, "{s}\\temp_voice_spike.wav", .{tmp});
    defer alloc.free(out_path);

    const phrase = "Softanza speaks. A voice is a sound buffer, so every verb this plane owns applies to it.";

    var timer = try std.time.Timer.start();
    const cold_ok = speakToFile(alloc, v, phrase, out_path);
    const cold_ns = timer.read();

    if (!cold_ok) {
        std.debug.print("\n  VERDICT: speaking to a file FAILED. A voice reaching only the\n", .{});
        std.debug.print("  speaker cannot join the plane -- that is the finding.\n", .{});
        return;
    }

    const f = std.fs.cwd().openFile(out_path, .{}) catch null;
    var bytes: u64 = 0;
    if (f) |file| {
        defer file.close();
        bytes = (file.stat() catch return).size;
    }
    std.debug.print("  wrote {d} bytes in {d:.1} ms (COLD -- includes engine start-up)\n", .{ bytes, @as(f64, @floatFromInt(cold_ns)) / 1e6 });

    // Read the WAV header the plane will have to accept -- BY WALKING THE
    // CHUNKS, not by trusting the textbook 44-byte layout.
    //
    // A FINDING, and it cost a nonsense number before it was found: SAPI writes
    // `fmt ` with size EIGHTEEN, not sixteen, because a WAVEFORMATEX carries a
    // cbSize field. So `data` begins at offset 38 and its length is at 42. Read
    // at the canonical offset 40 and you get part of the sample stream as a
    // length -- which reported "34611 seconds of speech" and "526293x
    // realtime" here, from an eight-second file.
    if (bytes > 64) {
        const file = try std.fs.cwd().openFile(out_path, .{});
        defer file.close();
        const raw = try file.readToEndAlloc(alloc, 4 << 20);
        defer alloc.free(raw);

        var channels: u16 = 0;
        var rate: u32 = 0;
        var bits: u16 = 0;
        var data_len: u32 = 0;
        var p: usize = 12; // past "RIFF" + size + "WAVE"
        while (p + 8 <= raw.len) {
            const id = raw[p..][0..4];
            const sz = std.mem.readInt(u32, raw[p + 4 ..][0..4], .little);
            if (std.mem.eql(u8, id, "fmt ")) {
                channels = std.mem.readInt(u16, raw[p + 10 ..][0..2], .little);
                rate = std.mem.readInt(u32, raw[p + 12 ..][0..4], .little);
                bits = std.mem.readInt(u16, raw[p + 22 ..][0..2], .little);
                std.debug.print("  the 'fmt ' chunk is {d} bytes, not 16 -- so 'data' is NOT at 36\n", .{sz});
            } else if (std.mem.eql(u8, id, "data")) {
                data_len = sz;
                std.debug.print("  the 'data' chunk starts at {d}, its length is at {d}\n", .{ p + 8, p + 4 });
                break;
            }
            p += 8 + sz + (sz % 2);
        }
        const secs = @as(f64, @floatFromInt(data_len)) /
            (@as(f64, @floatFromInt(rate)) * @as(f64, @floatFromInt(channels)) * (@as(f64, @floatFromInt(bits)) / 8.0));
        std.debug.print("  format: {d} Hz, {d} channel, {d}-bit -> {d:.2} s of speech\n", .{ rate, channels, bits, secs });
        std.debug.print("  NOTE: {d} Hz, not 48000. The plane resamples; BS.1770 loudness\n", .{rate});
        std.debug.print("        REFUSES a non-48k buffer, so a voice must be resampled\n", .{});
        std.debug.print("        before it can be measured. Recorded, not discovered later.\n", .{});
        // x realtime -- the number that decides whether speech can be live
        const xrt = secs / (@as(f64, @floatFromInt(cold_ns)) / 1e9);
        std.debug.print("  cold: {d:.1}x realtime\n", .{xrt});
    }

    // ---- 3. WARM cost, measured separately -------------------------------
    std.debug.print("\n-- 3. cold against warm, because the first call lies --\n", .{});
    var warm_total: u64 = 0;
    const runs: usize = 5;
    var i: usize = 0;
    var warm_min: u64 = std.math.maxInt(u64);
    while (i < runs) : (i += 1) {
        timer.reset();
        _ = speakToFile(alloc, v, phrase, out_path);
        const ns = timer.read();
        warm_total += ns;
        warm_min = @min(warm_min, ns);
    }
    const warm_avg = @as(f64, @floatFromInt(warm_total / runs)) / 1e6;
    std.debug.print("  warm: {d:.1} ms avg over {d} runs, {d:.1} ms best\n", .{ warm_avg, runs, @as(f64, @floatFromInt(warm_min)) / 1e6 });
    std.debug.print("  the COLD call cost {d:.1}x the warm one\n", .{(@as(f64, @floatFromInt(cold_ns)) / 1e6) / warm_avg});
    std.debug.print("  LESSON, same as SN0's ma_device_start: a voice plane must warm\n", .{});
    std.debug.print("  up out of band, or its first word is late by whatever this is.\n", .{});

    // ---- 4. a short phrase, for the latency budget ------------------------
    std.debug.print("\n-- 4. how soon can a voice say something SHORT? --\n", .{});
    std.debug.print("   Rule 18 allows 100 ms. Synthesis happens BEFORE a sample exists,\n", .{});
    std.debug.print("   so this cost lands on top of the plane's output latency.\n", .{});
    for ([_][]const u8{ "yes", "disk full", "the deployment finished successfully" }) |p| {
        timer.reset();
        _ = speakToFile(alloc, v, p, out_path);
        const ms = @as(f64, @floatFromInt(timer.read())) / 1e6;
        std.debug.print("  \"{s}\" -> {d:.1} ms to synthesise\n", .{ p, ms });
    }

    // ---- 5. what is REFUSED --------------------------------------------
    std.debug.print("\n-- 5. the refusals, which a plane must count rather than paper over --\n", .{});
    // an empty phrase
    if (speakToFile(alloc, v, "", out_path)) {
        std.debug.print("  an empty phrase was ACCEPTED (wrote a file). Worth deciding:\n", .{});
        std.debug.print("  silence is a legitimate rendering, per the semantic layer.\n", .{});
    } else {
        std.debug.print("  an empty phrase was refused by the platform.\n", .{});
    }
    // an unwritable path
    if (!speakToFile(alloc, v, "test", "Z:\\nonexistent\\path\\x.wav")) {
        std.debug.print("  an unwritable path was refused, and the refusal was VISIBLE.\n", .{});
    } else {
        std.debug.print("  an unwritable path was ACCEPTED -- which would be a silent lie.\n", .{});
    }

    std.debug.print("\n=== WHAT THIS SPIKE DECIDES ===\n", .{});
    std.debug.print("  1. The ENGINE can reach a platform voice in Zig. GO.\n", .{});
    std.debug.print("  2. A voice renders to a BUFFER. GO -- and it is the whole\n", .{});
    std.debug.print("     architecture: a voice becomes a stzSound.\n", .{});
    std.debug.print("  3. Cold start is real and must be warmed out of band.\n", .{});
    std.debug.print("  4. Synthesis time lands ON TOP of output latency, so speech can\n", .{});
    std.debug.print("     never be a Rule 18 acknowledgement. It is always a report.\n", .{});
    std.debug.print("  refusals counted: {d}\n", .{refusals});
    std.debug.print("\n  NOT measured here, and needing its own spike: RECOGNITION.\n", .{});
    std.debug.print("  ISpRecognizer needs a recognizer, a context, a grammar and an\n", .{});
    std.debug.print("  event loop -- an order more surface than ISpVoice. The platform's\n", .{});
    std.debug.print("  own capability is proven (a fr-FR round trip returned 'Bonjour le\n", .{});
    std.debug.print("  monde' at 0.585 confidence), but reaching it from the engine is\n", .{});
    std.debug.print("  a separate measurement and is stated as such.\n\n", .{});

    std.fs.cwd().deleteFile(out_path) catch {};
}

// Bind an ISpStream to a WAV file, point the voice at it, speak, close.
// SAPI's own C++ helpers (sphelper.h's SPBindToFile, CSpStreamFormat) are
// C++-only, so the WAVEFORMATEX and the bind are done by hand here.
fn speakToFile(alloc: std.mem.Allocator, v: *win.ISpVoice, text: []const u8, path: []const u8) bool {
    var stream: ?*win.ISpStream = null;
    var hr = win.CoCreateInstance(&CLSID_SpStream, null, win.CLSCTX_ALL, &IID_ISpStream, @ptrCast(&stream));
    if (hr < 0 or stream == null) {
        refuse("CoCreateInstance(SpStream) -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return false;
    }
    const s = stream.?;
    defer _ = s.*.lpVtbl.*.Release.?(@ptrCast(s));

    // 22.05 kHz, 16-bit, mono -- what SAPI's desktop voices produce natively.
    // Asking for 48000 here would make SAPI resample, and the plane has a
    // better resampler than a speech engine does (SN1 measured it).
    var wfx = std.mem.zeroes(win.WAVEFORMATEX);
    wfx.wFormatTag = 1; // WAVE_FORMAT_PCM
    wfx.nChannels = 1;
    wfx.nSamplesPerSec = 22050;
    wfx.wBitsPerSample = 16;
    wfx.nBlockAlign = 2;
    wfx.nAvgBytesPerSec = 22050 * 2;
    wfx.cbSize = 0;

    const wpath = std.unicode.utf8ToUtf16LeAllocZ(alloc, path) catch return false;
    defer alloc.free(wpath);

    hr = s.*.lpVtbl.*.BindToFile.?(
        @ptrCast(s),
        wpath.ptr,
        SPFM_CREATE_ALWAYS,
        &SPDFID_WaveFormatEx,
        &wfx,
        0,
    );
    if (hr < 0) {
        refuse("BindToFile('{s}') -> 0x{x}", .{ path, @as(u32, @bitCast(hr)) });
        return false;
    }

    hr = v.*.lpVtbl.*.SetOutput.?(@ptrCast(v), @ptrCast(s), 0);
    if (hr < 0) {
        refuse("SetOutput -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return false;
    }

    const wtext = std.unicode.utf8ToUtf16LeAllocZ(alloc, text) catch return false;
    defer alloc.free(wtext);

    // SPF_DEFAULT is synchronous: Speak returns when the stream is written,
    // which is exactly what a measurement wants.
    hr = v.*.lpVtbl.*.Speak.?(@ptrCast(v), wtext.ptr, SPF_DEFAULT, null);
    const spoke = hr >= 0;
    if (!spoke) refuse("Speak -> 0x{x}", .{@as(u32, @bitCast(hr))});

    _ = s.*.lpVtbl.*.Close.?(@ptrCast(s));
    return spoke;
}
