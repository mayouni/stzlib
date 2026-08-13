//! voice.zig -- VC1: platform speech synthesis, into a sample buffer.
//!
//! See `base/sound/SOFTANZA_VOICE_PLAN.md`. VC0 proved the engine can reach a
//! platform voice and that a voice renders to a buffer; this is the tier that
//! makes it usable, and the kill criterion it had to clear was specific:
//!
//!   > if a voice cannot be delivered as an IN-MEMORY buffer without a temporary
//!   > file, the seam is a file path rather than a sample handle, and the plan's
//!   > claim weakens from "a voice IS a stzSound" to "a voice is a file".
//!
//! It cleared it. `CreateStreamOnHGlobal` gives an `IStream` in memory,
//! `ISpStream::SetBaseStream` points SAPI at it, and the samples come back
//! through `GetHGlobalFromStream`. No path, no temporary, nothing to clean up
//! and nothing to fail on a read-only volume.
//!
//! ── WHY THIS IS ITS OWN DLL ─────────────────────────────────────────────────
//!
//! FACT 3 of the sound plan: the portable tier must not link a per-OS service.
//! `stz_sound.dll` cross-compiles everywhere; `stz_audiodev.dll` carries the
//! device backends. A voice is a per-OS service exactly like a device -- SAPI
//! here, AVSpeechSynthesizer on macOS, espeak-ng or nothing on Linux -- so it
//! gets `stz_voice.dll` and the portable tier stays portable.
//!
//! ── HOW A VOICE BECOMES A stzSound, ACROSS A DLL BOUNDARY ───────────────────
//!
//! It cannot hand over a sample handle: the buffer table lives in
//! `stz_sound.dll` and a handle from one DLL is meaningless in another. That is
//! the same constraint SN3 solved for the ring, and the same answer applies --
//! **BYTES cross the boundary, never a handle.**
//!
//! So this tier produces a complete WAV in memory, header and all, and the
//! caller hands those bytes to `stz_sound.dll`'s `loadMemory`. Two consequences
//! worth stating rather than discovering:
//!
//!   * SAPI's `SetBaseStream` writes RAW PCM, with no RIFF header -- unlike
//!     `BindToFile`, which writes a container. So the 44-byte header is built
//!     here. That is not a workaround; it is what makes the buffer
//!     SELF-DESCRIBING, so any consumer can use it without being told the
//!     format out of band.
//!   * The header is written with `fmt ` at SIXTEEN bytes, which is the
//!     canonical layout -- deliberately NOT the 18-byte WAVEFORMATEX form SAPI
//!     itself emits. VC0 lost an afternoon to that: a reader trusting the
//!     textbook offsets read a data length out of the sample stream and
//!     reported 34,611 seconds of speech from an 8-second file. Emitting the
//!     canonical form means every reader is right, including the naive one.
//!
//! ── WHAT IS REFUSED, AND COUNTED ────────────────────────────────────────────
//!
//! A missing language is the important one. Speaking French to an operator who
//! asked for English is worse than saying nothing, so `selectLanguage` refuses
//! and counts rather than falling back. VC0 measured why this matters: this
//! machine has voices for en-US and fr-FR, a recognizer for fr-FR only, and OCR
//! for ar-SA and fr-FR. Capability is per language AND per direction, and a tier
//! that hides that will make an application lie to somebody.

const std = @import("std");
const builtin = @import("builtin");

const is_windows = builtin.os.tag == .windows;

const win = if (is_windows) @cImport({
    @cDefine("_WIN32_WINNT", "0x0601");
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
    @cInclude("objbase.h");
    @cInclude("sapi.h");
}) else struct {};

const alloc = std.heap.c_allocator;

// ---------------------------------------------------------------- status

pub const OK: i32 = 0;
pub const STALE: i32 = 1; // generation mismatch: the voice was freed
pub const BAD_ARG: i32 = 2;
pub const UNSUPPORTED: i32 = 3; // no platform voice tier on this OS
pub const NO_SUCH_LANGUAGE: i32 = 4;
pub const SYNTH_FAILED: i32 = 5;

// ---------------------------------------------------------------- counters

pub const CTR_VOICES_LIVE = 0;
pub const CTR_SYNTHESES = 1;
pub const CTR_FRAMES = 2;
pub const CTR_REFUSALS = 3;
pub const CTR_STALE_HITS = 4;
const CTR_COUNT = 5;

var counters: [CTR_COUNT]f64 = @splat(0);

pub fn counter(i: usize) f64 {
    if (i >= CTR_COUNT) return 0;
    return counters[i];
}

pub fn countersReset() void {
    counters = @splat(0);
}

var last_error: [512]u8 = @splat(0);
var last_error_len: usize = 0;

fn refuse(comptime fmt: []const u8, args: anytype) void {
    counters[CTR_REFUSALS] += 1;
    const s = std.fmt.bufPrint(&last_error, fmt, args) catch "voice: refusal (message too long)";
    last_error_len = s.len;
}

pub fn lastError() []const u8 {
    return last_error[0..last_error_len];
}

// ---------------------------------------------------------------- the GUIDs
//
// Written out rather than linked from sapi.lib: MinGW's import libraries do not
// carry them consistently, and a DLL that fails to LINK is worse than one that
// refuses at runtime with a message.

fn guid(a: u32, b: u16, c: u16, d: [8]u8) win.GUID {
    return .{ .Data1 = a, .Data2 = b, .Data3 = c, .Data4 = d };
}

const CLSID_SpVoice = guid(0x96749377, 0x3391, 0x11D2, .{ 0x9E, 0xE3, 0x00, 0xC0, 0x4F, 0x79, 0x73, 0x96 });
const IID_ISpVoice = guid(0x6C44DF74, 0x72B9, 0x4992, .{ 0xA1, 0xEC, 0xEF, 0x99, 0x6E, 0x04, 0x22, 0xD4 });
const CLSID_SpStream = guid(0x715D9C59, 0x4442, 0x11D2, .{ 0x96, 0x05, 0x00, 0xC0, 0x4F, 0x8E, 0xE6, 0x28 });
const IID_ISpStream = guid(0x12E3CCA9, 0x7518, 0x44C5, .{ 0xA5, 0xE7, 0xBA, 0x5A, 0x79, 0xCB, 0x92, 0x9E });
const SPDFID_WaveFormatEx = guid(0xC31ADBAE, 0x527F, 0x4FF5, .{ 0xA2, 0x30, 0xF6, 0x2B, 0xB6, 0x1F, 0xF7, 0x0C });
const CLSID_SpObjectTokenCategory = guid(0xA910187F, 0x0C7A, 0x45AC, .{ 0x92, 0xCC, 0x59, 0xED, 0xAF, 0xB7, 0x7B, 0x53 });
const IID_ISpObjectTokenCategory = guid(0x2D3D3845, 0x39AF, 0x4850, .{ 0xBB, 0xF9, 0x40, 0xB4, 0x97, 0x80, 0x01, 0x1D });

const SPF_DEFAULT: c_uint = 0;
const SPF_IS_XML: c_uint = 8; // what makes SpeakSsml unnecessary as a separate call

const SPCAT_VOICES = std.unicode.utf8ToUtf16LeStringLiteral(
    "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Speech\\Voices",
);

// The native format of SAPI's desktop voices. Asking for 48000 would make SAPI
// resample, and SN1 measured this plane's resampler as the better one -- so the
// voice arrives native and the caller resamples if it wants to measure loudness
// (BS.1770 refuses anything but 48 kHz).
const VOICE_RATE: u32 = 22050;
const VOICE_CHANNELS: u16 = 1;
const VOICE_BITS: u16 = 16;

// ---------------------------------------------------------------- the table
//
// Gen-keyed handles, the same discipline as sound.zig: the id carries a
// generation, freeing bumps it, and a stale id is DETECTED and COUNTED rather
// than silently addressing whatever now occupies the slot.

const Voice = struct {
    live: bool = false,
    generation: u32 = 1,
    // ISpVoice, as an opaque pointer so the struct is the same shape on every OS
    handle: ?*anyopaque = null,
    // the last synthesis, kept so the caller can read it without a second call
    pcm: []u8 = &.{},
};

var voices: std.ArrayList(Voice) = .{};
var com_ready: bool = false;

fn idOf(slot: usize, generation: u32) i64 {
    return (@as(i64, generation) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    if (id <= 0) return null;
    const slot: usize = @intCast((id & 0xFFFFFFFF) - 1);
    const generation: u32 = @intCast(id >> 32);
    if (slot >= voices.items.len) return null;
    if (!voices.items[slot].live or voices.items[slot].generation != generation) {
        counters[CTR_STALE_HITS] += 1;
        return null;
    }
    return slot;
}

/// Is there a platform voice tier at all on this OS? Answered honestly so a
/// caller can degrade rather than discover it in a refusal.
pub fn isAvailable() bool {
    if (!is_windows) return false;
    ensureCom();
    return com_ready;
}

fn ensureCom() void {
    if (!is_windows or com_ready) return;
    const hr = win.CoInitializeEx(null, win.COINIT_APARTMENTTHREADED);
    // S_FALSE means "already initialised on this thread", which is success here
    com_ready = hr >= 0;
    if (!com_ready) refuse("CoInitializeEx failed: 0x{x}", .{@as(u32, @bitCast(hr))});
}

// ---------------------------------------------------------------- open / free

pub fn open() i64 {
    if (!is_windows) {
        refuse("voice: no platform speech tier on this OS", .{});
        return 0;
    }
    ensureCom();
    if (!com_ready) return 0;

    var v: ?*win.ISpVoice = null;
    const hr = win.CoCreateInstance(&CLSID_SpVoice, null, win.CLSCTX_ALL, &IID_ISpVoice, @ptrCast(&v));
    if (hr < 0 or v == null) {
        refuse("voice: CoCreateInstance(SpVoice) -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }

    // reuse a dead slot before growing, so a program that opens and frees in a
    // loop does not grow the table without bound
    for (voices.items, 0..) |*slot, i| {
        if (!slot.live) {
            slot.live = true;
            slot.handle = @ptrCast(v);
            slot.pcm = &.{};
            counters[CTR_VOICES_LIVE] += 1;
            return idOf(i, slot.generation);
        }
    }
    voices.append(alloc, .{ .live = true, .generation = 1, .handle = @ptrCast(v) }) catch {
        _ = v.?.lpVtbl.*.Release.?(@ptrCast(v.?));
        refuse("voice: out of memory growing the voice table", .{});
        return 0;
    };
    counters[CTR_VOICES_LIVE] += 1;
    return idOf(voices.items.len - 1, 1);
}

pub fn free(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const v = &voices.items[s];
    if (is_windows) {
        if (v.handle) |h| {
            const iv: *win.ISpVoice = @ptrCast(@alignCast(h));
            _ = iv.lpVtbl.*.Release.?(@ptrCast(iv));
        }
    }
    if (v.pcm.len > 0) alloc.free(v.pcm);
    v.pcm = &.{};
    v.handle = null;
    v.live = false;
    // BUMP THE GENERATION so the id that just worked never works again
    v.generation +%= 1;
    if (v.generation == 0) v.generation = 1;
    counters[CTR_VOICES_LIVE] -= 1;
    return OK;
}

pub fn liveCount() i64 {
    var n: i64 = 0;
    for (voices.items) |v| {
        if (v.live) n += 1;
    }
    return n;
}

// ---------------------------------------------------------------- speaking

/// Synthesise `text` into an in-memory WAV, kept on the voice until the next
/// call. Returns the byte length, or 0 on refusal. `is_ssml` routes the same
/// path with SPF_IS_XML, so prosody costs no extra surface.
pub fn speak(id: i64, text: []const u8, is_ssml: bool) i64 {
    if (!is_windows) {
        refuse("voice: no platform speech tier on this OS", .{});
        return 0;
    }
    const s = slotOf(id) orelse return 0;
    const v = &voices.items[s];
    const iv: *win.ISpVoice = @ptrCast(@alignCast(v.handle orelse return 0));

    // an empty phrase is LEGITIMATE -- the semantic layer's :Muted renders to
    // silence, and a tier that refused it would force a caller to special-case
    // the one value the law says has no sound
    if (text.len == 0) {
        if (v.pcm.len > 0) alloc.free(v.pcm);
        v.pcm = buildWav(&.{}) catch return 0;
        return @intCast(v.pcm.len);
    }

    // ── the in-memory stream: the kill criterion, in four calls ────────────
    var base: ?*win.IStream = null;
    var hr = win.CreateStreamOnHGlobal(null, win.TRUE, @ptrCast(&base));
    if (hr < 0 or base == null) {
        refuse("voice: CreateStreamOnHGlobal -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }
    defer _ = base.?.lpVtbl.*.Release.?(@ptrCast(base.?));

    var stream: ?*win.ISpStream = null;
    hr = win.CoCreateInstance(&CLSID_SpStream, null, win.CLSCTX_ALL, &IID_ISpStream, @ptrCast(&stream));
    if (hr < 0 or stream == null) {
        refuse("voice: CoCreateInstance(SpStream) -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }
    const st = stream.?;
    defer _ = st.lpVtbl.*.Release.?(@ptrCast(st));

    var wfx = std.mem.zeroes(win.WAVEFORMATEX);
    wfx.wFormatTag = 1; // WAVE_FORMAT_PCM
    wfx.nChannels = VOICE_CHANNELS;
    wfx.nSamplesPerSec = VOICE_RATE;
    wfx.wBitsPerSample = VOICE_BITS;
    wfx.nBlockAlign = @intCast(VOICE_CHANNELS * VOICE_BITS / 8);
    wfx.nAvgBytesPerSec = VOICE_RATE * wfx.nBlockAlign;
    wfx.cbSize = 0;

    hr = st.lpVtbl.*.SetBaseStream.?(@ptrCast(st), @ptrCast(base.?), &SPDFID_WaveFormatEx, &wfx);
    if (hr < 0) {
        refuse("voice: SetBaseStream -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }

    hr = iv.lpVtbl.*.SetOutput.?(@ptrCast(iv), @ptrCast(st), 0);
    if (hr < 0) {
        refuse("voice: SetOutput -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }

    const wtext = std.unicode.utf8ToUtf16LeAllocZ(alloc, text) catch {
        refuse("voice: the text is not valid UTF-8", .{});
        return 0;
    };
    defer alloc.free(wtext);

    // THE PLATFORM DOES NOT VALIDATE SSML, and this is measured rather than
    // assumed. Given `<speak><prosody rate='fast'>unclosed` SAPI produced
    // BYTE-FOR-BYTE the same audio as the bare word "unclosed": it neither
    // refused nor read the markup aloud -- it silently discarded it. Mercifully
    // it does not speak the tags; unhelpfully, a typo in an attribute means the
    // prosody simply does not happen and the caller is never told.
    //
    // That is the same failure this file already refuses to tolerate for an
    // out-of-range rate: a setting that silently does nothing is worse than one
    // that is visibly limited. So the markup is checked here, minimally, and a
    // failure is a COUNTED refusal with the reason attached.
    if (is_ssml and !looksWellFormed(text)) {
        refuse("voice: the SSML is not well formed ({s}) -- SAPI would have discarded it silently", .{ssml_fault});
        return 0;
    }
    const flags: c_uint = if (is_ssml) SPF_IS_XML else SPF_DEFAULT;
    hr = iv.lpVtbl.*.Speak.?(@ptrCast(iv), wtext.ptr, flags, null);
    if (hr < 0) {
        refuse("voice: Speak -> 0x{x}{s}", .{
            @as(u32, @bitCast(hr)),
            if (is_ssml) " (SSML: check the markup is well-formed)" else "",
        });
        return 0;
    }

    // SAPI is synchronous with SPF_DEFAULT, so the stream is complete here.
    // Detach the voice from it before reading, or the stream stays busy.
    _ = iv.lpVtbl.*.SetOutput.?(@ptrCast(iv), null, 0);

    var hg: win.HGLOBAL = undefined;
    hr = win.GetHGlobalFromStream(@ptrCast(base.?), &hg);
    if (hr < 0) {
        refuse("voice: GetHGlobalFromStream -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }
    const pcm_len = win.GlobalSize(hg);
    const locked = win.GlobalLock(hg);
    if (locked == null) {
        refuse("voice: GlobalLock returned null", .{});
        return 0;
    }
    defer _ = win.GlobalUnlock(hg);

    const raw: []const u8 = @as([*]const u8, @ptrCast(locked.?))[0..pcm_len];

    if (v.pcm.len > 0) alloc.free(v.pcm);
    v.pcm = buildWav(raw) catch {
        refuse("voice: out of memory building the WAV", .{});
        return 0;
    };

    counters[CTR_SYNTHESES] += 1;
    counters[CTR_FRAMES] += @floatFromInt(raw.len / (VOICE_BITS / 8) / VOICE_CHANNELS);
    return @intCast(v.pcm.len);
}

/// A pointer to the last synthesis, for a caller that copies it across the DLL
/// boundary. Valid until the next `speak` or `free` on the same voice.
pub fn lastBytesPtr(id: i64) usize {
    const s = slotOf(id) orelse return 0;
    const v = &voices.items[s];
    if (v.pcm.len == 0) return 0;
    return @intFromPtr(v.pcm.ptr);
}

pub fn lastBytesLen(id: i64) i64 {
    const s = slotOf(id) orelse return 0;
    return @intCast(voices.items[s].pcm.len);
}

// A MINIMAL well-formedness check, and it is minimal on purpose: it is not an
// XML parser and does not pretend to be one. It catches the error that actually
// happens -- unbalanced or unclosed tags -- and errs toward ACCEPTING anything
// it cannot be sure about, because refusing valid markup would be a worse
// failure than passing questionable markup to a lenient platform.
//
// Known simplification, stated rather than hidden: an attribute value
// containing '>' would confuse it. SSML in practice does not contain one.
var ssml_fault: []const u8 = "";

fn looksWellFormed(text: []const u8) bool {
    ssml_fault = "";
    if (std.mem.indexOf(u8, text, "<speak") == null) {
        ssml_fault = "no <speak> root";
        return false;
    }
    var stack: [32][]const u8 = undefined;
    var depth: usize = 0;
    var i: usize = 0;
    while (i < text.len) {
        if (text[i] != '<') {
            i += 1;
            continue;
        }
        const close = std.mem.indexOfScalarPos(u8, text, i, '>') orelse {
            ssml_fault = "a '<' with no matching '>'";
            return false;
        };
        const inner = text[i + 1 .. close];
        i = close + 1;
        if (inner.len == 0) continue;
        // declarations and comments carry no nesting
        if (inner[0] == '!' or inner[0] == '?') continue;
        if (inner[0] == '/') {
            const name = tagName(inner[1..]);
            if (depth == 0) {
                ssml_fault = "a closing tag with nothing open";
                return false;
            }
            depth -= 1;
            if (!std.mem.eql(u8, stack[depth], name)) {
                ssml_fault = "a closing tag that does not match the tag it closes";
                return false;
            }
            continue;
        }
        if (inner[inner.len - 1] == '/') continue; // self-closing, e.g. <break/>
        if (depth >= stack.len) {
            ssml_fault = "nested deeper than 32 tags";
            return false;
        }
        stack[depth] = tagName(inner);
        depth += 1;
    }
    if (depth != 0) {
        ssml_fault = "a tag was left unclosed";
        return false;
    }
    return true;
}

fn tagName(inner: []const u8) []const u8 {
    var n: usize = 0;
    while (n < inner.len and !std.ascii.isWhitespace(inner[n]) and inner[n] != '/') : (n += 1) {}
    return inner[0..n];
}

/// The canonical 44-byte RIFF/WAVE header, then the samples.
///
/// `fmt ` is written at SIXTEEN bytes on purpose. SAPI's own files use the
/// 18-byte WAVEFORMATEX form, which pushes `data` from offset 36 to 46 and its
/// length from 40 to 42 -- and VC0 proved what that costs a reader who trusts
/// the textbook offsets: a data length read out of the sample stream, reported
/// as 34,611 seconds of speech from an 8-second file. Emitting the canonical
/// form makes every reader right, including the naive one.
fn buildWav(pcm: []const u8) ![]u8 {
    const byte_rate = VOICE_RATE * VOICE_CHANNELS * (VOICE_BITS / 8);
    const block_align: u16 = VOICE_CHANNELS * (VOICE_BITS / 8);
    var out = try alloc.alloc(u8, 44 + pcm.len);
    @memcpy(out[0..4], "RIFF");
    std.mem.writeInt(u32, out[4..8], @intCast(36 + pcm.len), .little);
    @memcpy(out[8..12], "WAVE");
    @memcpy(out[12..16], "fmt ");
    std.mem.writeInt(u32, out[16..20], 16, .little); // SIXTEEN -- see above
    std.mem.writeInt(u16, out[20..22], 1, .little); // PCM
    std.mem.writeInt(u16, out[22..24], VOICE_CHANNELS, .little);
    std.mem.writeInt(u32, out[24..28], VOICE_RATE, .little);
    std.mem.writeInt(u32, out[28..32], byte_rate, .little);
    std.mem.writeInt(u16, out[32..34], block_align, .little);
    std.mem.writeInt(u16, out[34..36], VOICE_BITS, .little);
    @memcpy(out[36..40], "data");
    std.mem.writeInt(u32, out[40..44], @intCast(pcm.len), .little);
    if (pcm.len > 0) @memcpy(out[44..], pcm);
    return out;
}

// ---------------------------------------------------------------- the voices

/// How many installed voices the platform reports.
pub fn installedCount() i64 {
    if (!is_windows) return 0;
    ensureCom();
    if (!com_ready) return 0;
    const enumerator = enumTokens() orelse return 0;
    defer _ = enumerator.lpVtbl.*.Release.?(@ptrCast(enumerator));
    var n: c_ulong = 0;
    if (enumerator.lpVtbl.*.GetCount.?(@ptrCast(enumerator), &n) < 0) return 0;
    return @intCast(n);
}

fn enumTokens() ?*win.IEnumSpObjectTokens {
    var cat: ?*win.ISpObjectTokenCategory = null;
    var hr = win.CoCreateInstance(
        &CLSID_SpObjectTokenCategory,
        null,
        win.CLSCTX_ALL,
        &IID_ISpObjectTokenCategory,
        @ptrCast(&cat),
    );
    if (hr < 0 or cat == null) {
        refuse("voice: no voice token category -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return null;
    }
    defer _ = cat.?.lpVtbl.*.Release.?(@ptrCast(cat.?));

    hr = cat.?.lpVtbl.*.SetId.?(@ptrCast(cat.?), SPCAT_VOICES, 0);
    if (hr < 0) {
        refuse("voice: SetId(SPCAT_VOICES) -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return null;
    }
    var e: ?*win.IEnumSpObjectTokens = null;
    hr = cat.?.lpVtbl.*.EnumTokens.?(@ptrCast(cat.?), null, null, @ptrCast(&e));
    if (hr < 0 or e == null) {
        refuse("voice: EnumTokens -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return null;
    }
    return e;
}

var name_buf: [256]u8 = @splat(0);
var name_len: usize = 0;

/// The display name of installed voice `index`, 0-based. Held in a static
/// buffer until the next call -- the engine convention for a string crossing
/// the FFI.
pub fn installedName(index: i64) []const u8 {
    name_len = 0;
    if (!is_windows or index < 0) return &.{};
    ensureCom();
    if (!com_ready) return &.{};
    const enumerator = enumTokens() orelse return &.{};
    defer _ = enumerator.lpVtbl.*.Release.?(@ptrCast(enumerator));

    var token: ?*win.ISpObjectToken = null;
    if (enumerator.lpVtbl.*.Item.?(@ptrCast(enumerator), @intCast(index), @ptrCast(&token)) < 0 or token == null) {
        refuse("voice: there is no installed voice {d}", .{index});
        return &.{};
    }
    defer _ = token.?.lpVtbl.*.Release.?(@ptrCast(token.?));

    var desc: ?[*:0]u16 = null;
    if (token.?.lpVtbl.*.GetStringValue.?(@ptrCast(token.?), null, @ptrCast(&desc)) < 0 or desc == null) {
        refuse("voice: voice {d} has no description", .{index});
        return &.{};
    }
    defer win.CoTaskMemFree(@ptrCast(desc.?));

    const wide = std.mem.span(desc.?);
    const n = std.unicode.utf16LeToUtf8(&name_buf, wide) catch return &.{};
    name_len = n;
    return name_buf[0..n];
}

/// Choose a voice by its index. A caller that wants a LANGUAGE should ask for
/// one by name via the face; this tier deals in what the platform reports.
pub fn selectVoice(id: i64, index: i64) i32 {
    if (!is_windows) return UNSUPPORTED;
    const s = slotOf(id) orelse return STALE;
    const v = &voices.items[s];
    const iv: *win.ISpVoice = @ptrCast(@alignCast(v.handle orelse return BAD_ARG));

    const enumerator = enumTokens() orelse return NO_SUCH_LANGUAGE;
    defer _ = enumerator.lpVtbl.*.Release.?(@ptrCast(enumerator));
    var token: ?*win.ISpObjectToken = null;
    if (enumerator.lpVtbl.*.Item.?(@ptrCast(enumerator), @intCast(index), @ptrCast(&token)) < 0 or token == null) {
        refuse("voice: cannot select voice {d} -- there is no such voice", .{index});
        return BAD_ARG;
    }
    defer _ = token.?.lpVtbl.*.Release.?(@ptrCast(token.?));

    const hr = iv.lpVtbl.*.SetVoice.?(@ptrCast(iv), @ptrCast(token.?));
    if (hr < 0) {
        refuse("voice: SetVoice -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return BAD_ARG;
    }
    return OK;
}

// ---------------------------------------------------------------- prosody
//
// SAPI's rate and volume are integers, not the continuous factors a caller
// would expect: rate is -10..10 where 0 is normal, volume is 0..100. They are
// CLAMPED here rather than passed through, because SAPI accepts out-of-range
// values by ignoring them, and a setting that silently does nothing is worse
// than one that is visibly limited.

pub fn setRate(id: i64, rate: i64) i32 {
    if (!is_windows) return UNSUPPORTED;
    const s = slotOf(id) orelse return STALE;
    const iv: *win.ISpVoice = @ptrCast(@alignCast(voices.items[s].handle orelse return BAD_ARG));
    const clamped: c_long = @intCast(@max(-10, @min(10, rate)));
    if (clamped != rate) refuse("voice: rate {d} clamped to {d} (SAPI takes -10..10)", .{ rate, clamped });
    return if (iv.lpVtbl.*.SetRate.?(@ptrCast(iv), clamped) >= 0) OK else BAD_ARG;
}

pub fn setVolume(id: i64, volume: i64) i32 {
    if (!is_windows) return UNSUPPORTED;
    const s = slotOf(id) orelse return STALE;
    const iv: *win.ISpVoice = @ptrCast(@alignCast(voices.items[s].handle orelse return BAD_ARG));
    const clamped: c_ushort = @intCast(@max(0, @min(100, volume)));
    if (clamped != volume) refuse("voice: volume {d} clamped to {d} (SAPI takes 0..100)", .{ volume, clamped });
    return if (iv.lpVtbl.*.SetVolume.?(@ptrCast(iv), clamped) >= 0) OK else BAD_ARG;
}

/// The format the voice produces, so a caller never has to guess and never has
/// to parse the header it was just handed.
pub fn sampleRate() i64 {
    return VOICE_RATE;
}
pub fn channelCount() i64 {
    return VOICE_CHANNELS;
}
pub fn bitsPerSample() i64 {
    return VOICE_BITS;
}

// ---------------------------------------------------------------- tests

const testing = std.testing;

test "the tier reports honestly whether it exists at all" {
    // On a non-Windows target this must be a clean FALSE and a counted refusal,
    // not a crash -- CI has no SAPI and neither does a Linux build.
    if (!is_windows) {
        try testing.expect(!isAvailable());
        countersReset();
        try testing.expectEqual(@as(i64, 0), open());
        try testing.expect(counter(CTR_REFUSALS) > 0);
        return;
    }
    try testing.expect(isAvailable());
}

test "VC1's KILL CRITERION: a voice arrives in memory, with no temporary file" {
    if (!is_windows) return error.SkipZigTest;
    countersReset();
    const id = open();
    try testing.expect(id > 0);
    defer _ = free(id);

    const n = speak(id, "Softanza speaks from memory.", false);
    try testing.expect(n > 44); // a header plus samples

    const ptr = lastBytesPtr(id);
    try testing.expect(ptr != 0);
    try testing.expectEqual(n, lastBytesLen(id));

    const bytes = @as([*]const u8, @ptrFromInt(ptr))[0..@intCast(n)];

    // it is a WAV, and it is the CANONICAL layout -- fmt at 16, data at 36
    try testing.expectEqualSlices(u8, "RIFF", bytes[0..4]);
    try testing.expectEqualSlices(u8, "WAVE", bytes[8..12]);
    try testing.expectEqualSlices(u8, "fmt ", bytes[12..16]);
    try testing.expectEqual(@as(u32, 16), std.mem.readInt(u32, bytes[16..20], .little));
    try testing.expectEqualSlices(u8, "data", bytes[36..40]);

    // the header's own numbers agree with what the tier reports
    try testing.expectEqual(@as(u16, VOICE_CHANNELS), std.mem.readInt(u16, bytes[22..24], .little));
    try testing.expectEqual(@as(u32, VOICE_RATE), std.mem.readInt(u32, bytes[24..28], .little));
    try testing.expectEqual(@as(u16, VOICE_BITS), std.mem.readInt(u16, bytes[34..36], .little));

    // and the declared data length IS the remaining bytes -- the check that
    // would have caught VC0's 34,611-second reading
    const data_len = std.mem.readInt(u32, bytes[40..44], .little);
    try testing.expectEqual(@as(usize, data_len), bytes.len - 44);

    // the samples are not silence: a voice that returned a valid empty WAV
    // would pass every assertion above
    var peak: i16 = 0;
    var i: usize = 44;
    while (i + 1 < bytes.len) : (i += 2) {
        const smp = std.mem.readInt(i16, bytes[i..][0..2], .little);
        peak = @max(peak, if (smp < 0) -%smp else smp);
    }
    try testing.expect(peak > 1000);

    try testing.expect(counter(CTR_SYNTHESES) == 1);
    try testing.expect(counter(CTR_FRAMES) > 0);
}

test "an empty phrase is LEGITIMATE -- :Muted renders to silence" {
    if (!is_windows) return error.SkipZigTest;
    const id = open();
    defer _ = free(id);
    const n = speak(id, "", false);
    // a valid, empty WAV: header only
    try testing.expectEqual(@as(i64, 44), n);
    const bytes = @as([*]const u8, @ptrFromInt(lastBytesPtr(id)))[0..44];
    try testing.expectEqual(@as(u32, 0), std.mem.readInt(u32, bytes[40..44], .little));
}

test "a freed voice is STALE, and the stale hit is COUNTED" {
    if (!is_windows) return error.SkipZigTest;
    countersReset();
    const id = open();
    try testing.expect(speak(id, "before", false) > 44);
    try testing.expectEqual(OK, free(id));
    // every entry point must refuse the dead id
    try testing.expectEqual(@as(i64, 0), speak(id, "after", false));
    try testing.expectEqual(@as(usize, 0), lastBytesPtr(id));
    try testing.expectEqual(STALE, free(id));
    try testing.expectEqual(STALE, setRate(id, 0));
    try testing.expect(counter(CTR_STALE_HITS) >= 4);
    // and the negative sibling: a LIVE id is not counted stale
    const before = counter(CTR_STALE_HITS);
    const id2 = open();
    defer _ = free(id2);
    _ = speak(id2, "alive", false);
    try testing.expectEqual(before, counter(CTR_STALE_HITS));
}

test "installed voices are enumerable, and a name comes back" {
    if (!is_windows) return error.SkipZigTest;
    const n = installedCount();
    std.debug.print("\n  installed voices: {d}\n", .{n});
    try testing.expect(n > 0);
    var i: i64 = 0;
    while (i < n) : (i += 1) {
        const name = installedName(i);
        std.debug.print("    [{d}] {s}\n", .{ i, name });
        try testing.expect(name.len > 0);
    }
    // the negative sibling: an index past the end refuses and counts
    countersReset();
    try testing.expectEqual(@as(usize, 0), installedName(n + 5).len);
    try testing.expect(counter(CTR_REFUSALS) > 0);
}

test "selecting a voice changes the samples that come out" {
    if (!is_windows) return error.SkipZigTest;
    if (installedCount() < 2) return error.SkipZigTest; // needs two to compare
    const id = open();
    defer _ = free(id);

    try testing.expectEqual(OK, selectVoice(id, 0));
    const n0 = speak(id, "one two three", false);
    const first = try alloc.dupe(u8, @as([*]const u8, @ptrFromInt(lastBytesPtr(id)))[0..@intCast(n0)]);
    defer alloc.free(first);

    try testing.expectEqual(OK, selectVoice(id, 1));
    const n1 = speak(id, "one two three", false);
    const second = @as([*]const u8, @ptrFromInt(lastBytesPtr(id)))[0..@intCast(n1)];

    // two different voices saying the same words must not produce the same
    // bytes -- if they did, SetVoice did nothing and the refusal was silent
    try testing.expect(!std.mem.eql(u8, first, second));
    std.debug.print("  two voices, same words: {d} vs {d} bytes\n", .{ n0, n1 });
}

test "prosody: SSML is accepted, and out-of-range settings are CLAMPED loudly" {
    if (!is_windows) return error.SkipZigTest;
    const id = open();
    defer _ = free(id);

    const plain = speak(id, "slow down", false);
    const ssml = speak(id,
        \\<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US"><prosody rate="-40%">slow down</prosody></speak>
    , true);
    try testing.expect(plain > 44);
    try testing.expect(ssml > 44);
    // a rate change must lengthen the audio, or the markup was ignored
    std.debug.print("  plain {d} bytes, SSML at -40% rate {d} bytes\n", .{ plain, ssml });
    try testing.expect(ssml > plain);

    // clamping is REPORTED, not silent
    countersReset();
    try testing.expectEqual(OK, setRate(id, 99));
    try testing.expect(counter(CTR_REFUSALS) > 0);
    // and an in-range value is not reported
    countersReset();
    try testing.expectEqual(OK, setRate(id, 3));
    try testing.expectEqual(@as(f64, 0), counter(CTR_REFUSALS));
}

test "malformed SSML is refused HERE, because the platform will not refuse it" {
    if (!is_windows) return error.SkipZigTest;
    const id = open();
    defer _ = free(id);

    // MEASURED FIRST, and it is the only reason this check exists: handed
    // `<speak><prosody rate='fast'>unclosed`, SAPI produced BYTE-FOR-BYTE the
    // same audio as the bare word "unclosed" -- silently discarding the markup
    // rather than refusing it. It does not read the tags aloud, which is a
    // mercy; it also never says the prosody did nothing, which is the defect.
    countersReset();
    try testing.expectEqual(@as(i64, 0), speak(id, "<speak><prosody rate='fast'>unclosed", true));
    try testing.expect(counter(CTR_REFUSALS) > 0);
    std.debug.print("\n  unclosed tag -> {s}\n", .{lastError()});

    countersReset();
    try testing.expectEqual(@as(i64, 0), speak(id, "<speak><a></b></speak>", true));
    std.debug.print("  mismatched   -> {s}\n", .{lastError()});

    countersReset();
    try testing.expectEqual(@as(i64, 0), speak(id, "just prose, no root", true));
    std.debug.print("  no root      -> {s}\n", .{lastError()});

    // THE NEGATIVE SIBLING, and the one that matters most here: the check must
    // not refuse markup that is FINE. A validator that rejects valid input is a
    // worse defect than the leniency it was written to cover -- so this asserts
    // a real document, with attributes, a namespace and a self-closing break.
    countersReset();
    const good = speak(id,
        \\<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US"><prosody rate="-20%">fine</prosody><break time="200ms"/>and fine</speak>
    , true);
    try testing.expect(good > 44);
    try testing.expectEqual(@as(f64, 0), counter(CTR_REFUSALS));
    std.debug.print("  well-formed, with a self-closing break: {d} bytes, no refusal\n", .{good});
}
