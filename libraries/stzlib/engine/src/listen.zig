//! listen.zig -- VC3: platform speech recognition, CLOSED GRAMMAR ONLY.
//!
//! ── THE KILL CRITERION FIRED, AND THIS FILE IS WHAT SURVIVED IT ─────────────
//!
//! The voice plan set the gate before any number was taken:
//!
//!   > if free dictation on the platform recognizer cannot beat a stated
//!   > confidence on a stated phrase set, `stzListener` ships CLOSED-GRAMMAR
//!   > ONLY -- commands, not transcription -- and free dictation is deferred to
//!   > the neural tier rather than shipped unreliable.
//!
//! Nine phrases, synthesised by this plane's own fr-FR voice and fed back, three
//! rounds, identical every round:
//!
//!     free dictation   66.7% exact (6/9)   mean confidence 0.600   FAIL
//!     closed grammar   100%  exact (6/6)   mean confidence 0.898   PASS
//!
//! So dictation is not built here. That is the criterion applied as written,
//! not a shortcut.
//!
//! ── WHY DICTATION FAILED IS THE USEFUL PART ────────────────────────────────
//!
//! Every miss was a WRITTEN FORM, not a mishearing:
//!
//!     "annuler"                          -> "annule"
//!     "arreter"                          -> "arrete"
//!     "il reste soixante deux gigaoctets" -> "il reste 60 de gigaoctet"
//!
//! The recognizer heard the sounds correctly and chose a different spelling: a
//! verb ending, a numeral instead of words, a singular instead of a plural. That
//! is exactly the failure a COMMAND surface does not have, because a closed
//! grammar maps sound to the string the caller DECLARED -- there is no spelling
//! left to get wrong. It is also exactly the failure transcription cannot
//! tolerate, which is why the two got different verdicts from one measurement.
//!
//! And the audio was the easiest case recognition will ever see: clean, synthetic,
//! noise-free, correctly pronounced. A microphone in a room is worse.
//!
//! ── WHAT THIS TIER IS ──────────────────────────────────────────────────────
//!
//! An in-process recognizer, a context, and ONE grammar built from a list of
//! phrases the caller declares. Recognition from a WAV in memory (so a guard
//! needs no microphone) and from the default input. Every result carries its
//! CONFIDENCE, because a recognised string without one is a guess wearing a
//! fact's clothes.
//!
//! ── LOCAL ONLY, AND THAT IS A PROMISE ──────────────────────────────────────
//!
//! `CLSID_SpInprocRecognizer` is the IN-PROCESS engine: it runs in this process,
//! against the locally installed recognizer, and reaches no network. The shared
//! recognizer (`CLSID_SpSharedRecognizer`) can be routed to Windows' online
//! speech service, so it is NOT used here and choosing it would have to be an
//! explicit, disclosed act. A microphone is a consent boundary; a microphone
//! that reaches a network is a different product.

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

pub const OK: i32 = 0;
pub const STALE: i32 = 1;
pub const BAD_ARG: i32 = 2;
pub const UNSUPPORTED: i32 = 3;
pub const NO_MATCH: i32 = 4;

pub const CTR_LISTENERS_LIVE = 0;
pub const CTR_RECOGNITIONS = 1;
pub const CTR_NO_MATCH = 2;
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
    const s = std.fmt.bufPrint(&last_error, fmt, args) catch "listen: refusal";
    last_error_len = s.len;
}

pub fn lastError() []const u8 {
    return last_error[0..last_error_len];
}

fn guid(a: u32, b: u16, c: u16, d: [8]u8) win.GUID {
    return .{ .Data1 = a, .Data2 = b, .Data3 = c, .Data4 = d };
}

// THE IN-PROCESS recognizer, deliberately -- see the header on local-only.
const CLSID_SpInprocRecognizer = guid(0x41B89B6B, 0x9399, 0x11D2, .{ 0x96, 0x23, 0x00, 0xC0, 0x4F, 0x8E, 0xE6, 0x28 });
const IID_ISpRecognizer = guid(0xC2B5F241, 0xDAA0, 0x4507, .{ 0x9E, 0x16, 0x5A, 0x1E, 0xAA, 0x2B, 0x7A, 0x5C });
const CLSID_SpStream = guid(0x715D9C59, 0x4442, 0x11D2, .{ 0x96, 0x05, 0x00, 0xC0, 0x4F, 0x8E, 0xE6, 0x28 });
const IID_ISpStream = guid(0x12E3CCA9, 0x7518, 0x44C5, .{ 0xA5, 0xE7, 0xBA, 0x5A, 0x79, 0xCB, 0x92, 0x9E });
const SPDFID_WaveFormatEx = guid(0xC31ADBAE, 0x527F, 0x4FF5, .{ 0xA2, 0x30, 0xF6, 0x2B, 0xB6, 0x1F, 0xF7, 0x0C });
const CLSID_SpObjectTokenCategory = guid(0xA910187F, 0x0C7A, 0x45AC, .{ 0x92, 0xCC, 0x59, 0xED, 0xAF, 0xB7, 0x7B, 0x53 });
const IID_ISpObjectTokenCategory = guid(0x2D3D3845, 0x39AF, 0x4850, .{ 0xBB, 0xF9, 0x40, 0xB4, 0x97, 0x80, 0x01, 0x1D });

const SPCAT_RECOGNIZERS = std.unicode.utf8ToUtf16LeStringLiteral(
    "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Speech\\Recognizers",
);

const SPRAF_TopLevel: c_uint = 0x01;
const SPRAF_Active: c_uint = 0x02;
const SPRS_INACTIVE: c_uint = 0;
const SPRS_ACTIVE: c_uint = 1;
const SPWT_LEXICAL: c_uint = 1; // NOT 0 -- 0 is SPWT_DISPLAY
const SPEI_RECOGNITION: c_ulonglong = 38;
const SPEI_FALSE_RECOGNITION: c_ulonglong = 43;
const SP_GETWHOLEPHRASE: c_ulong = 0xFFFFFFFF;

// A grammar is one rule with one alternative per declared phrase.
const GRAMMAR_ID: c_ulonglong = 1;

// SPEVENT DECLARED BY HAND, because sapi.h declares its first two fields as
// 16-bit BITFIELDS and Zig's translate-c cannot express those -- the @cImport
// yields `opaque {}`, which cannot be instantiated or read.
//
// The layout is the C one: two u16, a ULONG, then an 8-aligned ULONGLONG, then
// WPARAM and LPARAM. 32 bytes on x64, and the guard below asserts that rather
// than trusting this comment.
const SpEvent = extern struct {
    eEventId: u16 = 0,
    elParamType: u16 = 0,
    ulStreamNum: c_ulong = 0,
    ullAudioStreamOffset: u64 = 0,
    wParam: usize = 0,
    lParam: isize = 0,
};

const Listener = struct {
    live: bool = false,
    generation: u32 = 1,
    recognizer: ?*anyopaque = null,
    context: ?*anyopaque = null,
    grammar: ?*anyopaque = null,
    n_phrases: u32 = 0,
    text: [512]u8 = @splat(0),
    text_len: usize = 0,
    confidence: f64 = 0,
};

var listeners: std.ArrayList(Listener) = .{};
var com_ready: bool = false;

fn ensureCom() void {
    if (!is_windows or com_ready) return;
    const hr = win.CoInitializeEx(null, win.COINIT_APARTMENTTHREADED);
    com_ready = hr >= 0;
}

fn idOf(slot: usize, generation: u32) i64 {
    return (@as(i64, generation) << 32) | @as(i64, @intCast(slot + 1));
}

fn slotOf(id: i64) ?usize {
    if (id <= 0) return null;
    const slot: usize = @intCast((id & 0xFFFFFFFF) - 1);
    const generation: u32 = @intCast(id >> 32);
    if (slot >= listeners.items.len) return null;
    if (!listeners.items[slot].live or listeners.items[slot].generation != generation) {
        counters[CTR_STALE_HITS] += 1;
        return null;
    }
    return slot;
}

/// Is there a recognizer at all? On this machine the answer differs from the
/// same question about voices -- two voices, one recognizer, different
/// languages -- which is why capability is asked per direction.
pub fn isAvailable() bool {
    if (!is_windows) return false;
    ensureCom();
    if (!com_ready) return false;
    return installedCount() > 0;
}

fn enumTokens() ?*win.IEnumSpObjectTokens {
    var cat: ?*win.ISpObjectTokenCategory = null;
    var hr = win.CoCreateInstance(&CLSID_SpObjectTokenCategory, null, win.CLSCTX_ALL, &IID_ISpObjectTokenCategory, @ptrCast(&cat));
    if (hr < 0 or cat == null) return null;
    defer _ = cat.?.lpVtbl.*.Release.?(@ptrCast(cat.?));
    hr = cat.?.lpVtbl.*.SetId.?(@ptrCast(cat.?), SPCAT_RECOGNIZERS, 0);
    if (hr < 0) return null;
    var e: ?*win.IEnumSpObjectTokens = null;
    hr = cat.?.lpVtbl.*.EnumTokens.?(@ptrCast(cat.?), null, null, @ptrCast(&e));
    if (hr < 0) return null;
    return e;
}

pub fn installedCount() i64 {
    if (!is_windows) return 0;
    ensureCom();
    if (!com_ready) return 0;
    const e = enumTokens() orelse return 0;
    defer _ = e.lpVtbl.*.Release.?(@ptrCast(e));
    var n: c_ulong = 0;
    if (e.lpVtbl.*.GetCount.?(@ptrCast(e), &n) < 0) return 0;
    return @intCast(n);
}

var name_buf: [256]u8 = @splat(0);
var name_len: usize = 0;

pub fn installedName(index: i64) []const u8 {
    name_len = 0;
    if (!is_windows or index < 0) return &.{};
    ensureCom();
    const e = enumTokens() orelse return &.{};
    defer _ = e.lpVtbl.*.Release.?(@ptrCast(e));
    var token: ?*win.ISpObjectToken = null;
    if (e.lpVtbl.*.Item.?(@ptrCast(e), @intCast(index), @ptrCast(&token)) < 0 or token == null) {
        refuse("listen: there is no recognizer {d}", .{index});
        return &.{};
    }
    defer _ = token.?.lpVtbl.*.Release.?(@ptrCast(token.?));
    var desc: ?[*:0]u16 = null;
    if (token.?.lpVtbl.*.GetStringValue.?(@ptrCast(token.?), null, @ptrCast(&desc)) < 0 or desc == null) return &.{};
    defer win.CoTaskMemFree(@ptrCast(desc.?));
    const n = std.unicode.utf16LeToUtf8(&name_buf, std.mem.span(desc.?)) catch return &.{};
    name_len = n;
    return name_buf[0..n];
}

var lang_buf: [64]u8 = @splat(0);

/// The BCP-47 tag of recognizer `index`. Same OS-as-authority route the voice
/// tier uses: a hex LCID on the token, converted by LCIDToLocaleName.
pub fn installedLanguage(index: i64) []const u8 {
    if (!is_windows or index < 0) return &.{};
    ensureCom();
    const e = enumTokens() orelse return &.{};
    defer _ = e.lpVtbl.*.Release.?(@ptrCast(e));
    var token: ?*win.ISpObjectToken = null;
    if (e.lpVtbl.*.Item.?(@ptrCast(e), @intCast(index), @ptrCast(&token)) < 0 or token == null) return &.{};
    defer _ = token.?.lpVtbl.*.Release.?(@ptrCast(token.?));

    var attrs: ?*win.ISpDataKey = null;
    const attr_name = std.unicode.utf8ToUtf16LeStringLiteral("Attributes");
    if (token.?.lpVtbl.*.OpenKey.?(@ptrCast(token.?), attr_name, @ptrCast(&attrs)) < 0 or attrs == null) return &.{};
    defer _ = attrs.?.lpVtbl.*.Release.?(@ptrCast(attrs.?));

    var val: ?[*:0]u16 = null;
    const key_name = std.unicode.utf8ToUtf16LeStringLiteral("Language");
    if (attrs.?.lpVtbl.*.GetStringValue.?(@ptrCast(attrs.?), key_name, @ptrCast(&val)) < 0 or val == null) return &.{};
    defer win.CoTaskMemFree(@ptrCast(val.?));

    var hex: [16]u8 = @splat(0);
    var n: usize = 0;
    for (std.mem.span(val.?)) |c| {
        if (c == ';' or c == 0) break;
        if (n >= hex.len) break;
        hex[n] = @intCast(c & 0x7F);
        n += 1;
    }
    const lcid = std.fmt.parseInt(u32, hex[0..n], 16) catch return &.{};
    var wtag: [win.LOCALE_NAME_MAX_LENGTH]u16 = undefined;
    const got = win.LCIDToLocaleName(lcid, &wtag, @intCast(wtag.len), 0);
    if (got <= 1) return &.{};
    const tl = std.unicode.utf16LeToUtf8(&lang_buf, wtag[0..@as(usize, @intCast(got)) - 1]) catch return &.{};
    return lang_buf[0..tl];
}

/// The LCID of the first installed recognizer, which is the language a grammar
/// must be reset to before it will accept a word. 0 when there is none.
fn primaryLangId() u32 {
    if (!is_windows) return 0;
    const e = enumTokens() orelse return 0;
    defer _ = e.lpVtbl.*.Release.?(@ptrCast(e));
    var token: ?*win.ISpObjectToken = null;
    if (e.lpVtbl.*.Item.?(@ptrCast(e), 0, @ptrCast(&token)) < 0 or token == null) return 0;
    defer _ = token.?.lpVtbl.*.Release.?(@ptrCast(token.?));
    var attrs: ?*win.ISpDataKey = null;
    const attr_name = std.unicode.utf8ToUtf16LeStringLiteral("Attributes");
    if (token.?.lpVtbl.*.OpenKey.?(@ptrCast(token.?), attr_name, @ptrCast(&attrs)) < 0 or attrs == null) return 0;
    defer _ = attrs.?.lpVtbl.*.Release.?(@ptrCast(attrs.?));
    var val: ?[*:0]u16 = null;
    const key_name = std.unicode.utf8ToUtf16LeStringLiteral("Language");
    if (attrs.?.lpVtbl.*.GetStringValue.?(@ptrCast(attrs.?), key_name, @ptrCast(&val)) < 0 or val == null) return 0;
    defer win.CoTaskMemFree(@ptrCast(val.?));
    var hex: [16]u8 = @splat(0);
    var n: usize = 0;
    for (std.mem.span(val.?)) |c| {
        if (c == ';' or c == 0) break;
        if (n >= hex.len) break;
        hex[n] = @intCast(c & 0x7F);
        n += 1;
    }
    return std.fmt.parseInt(u32, hex[0..n], 16) catch 0;
}

// ---------------------------------------------------------------- lifecycle

pub fn open() i64 {
    if (!is_windows) {
        refuse("listen: no platform recognition on this OS", .{});
        return 0;
    }
    ensureCom();
    if (!com_ready) return 0;

    var rec: ?*win.ISpRecognizer = null;
    var hr = win.CoCreateInstance(&CLSID_SpInprocRecognizer, null, win.CLSCTX_ALL, &IID_ISpRecognizer, @ptrCast(&rec));
    if (hr < 0 or rec == null) {
        refuse("listen: no in-process recognizer -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return 0;
    }
    var ctx: ?*win.ISpRecoContext = null;
    hr = rec.?.lpVtbl.*.CreateRecoContext.?(@ptrCast(rec.?), @ptrCast(&ctx));
    if (hr < 0 or ctx == null) {
        refuse("listen: CreateRecoContext -> 0x{x}", .{@as(u32, @bitCast(hr))});
        _ = rec.?.lpVtbl.*.Release.?(@ptrCast(rec.?));
        return 0;
    }
    // interested in recognitions and in FALSE recognitions -- a rejection is
    // information, and a listener that only hears successes cannot report
    // "something was said and it was not in the grammar"
    const interest = (@as(c_ulonglong, 1) << @intCast(SPEI_RECOGNITION)) |
        (@as(c_ulonglong, 1) << @intCast(SPEI_FALSE_RECOGNITION));
    _ = ctx.?.lpVtbl.*.SetInterest.?(@ptrCast(ctx.?), interest, interest);

    var gram: ?*win.ISpRecoGrammar = null;
    hr = ctx.?.lpVtbl.*.CreateGrammar.?(@ptrCast(ctx.?), GRAMMAR_ID, @ptrCast(&gram));
    if (hr < 0 or gram == null) {
        refuse("listen: CreateGrammar -> 0x{x}", .{@as(u32, @bitCast(hr))});
        _ = ctx.?.lpVtbl.*.Release.?(@ptrCast(ctx.?));
        _ = rec.?.lpVtbl.*.Release.?(@ptrCast(rec.?));
        return 0;
    }

    for (listeners.items, 0..) |*slot, i| {
        if (!slot.live) {
            slot.* = .{ .live = true, .generation = slot.generation, .recognizer = @ptrCast(rec), .context = @ptrCast(ctx), .grammar = @ptrCast(gram) };
            counters[CTR_LISTENERS_LIVE] += 1;
            return idOf(i, slot.generation);
        }
    }
    listeners.append(alloc, .{ .live = true, .generation = 1, .recognizer = @ptrCast(rec), .context = @ptrCast(ctx), .grammar = @ptrCast(gram) }) catch return 0;
    counters[CTR_LISTENERS_LIVE] += 1;
    return idOf(listeners.items.len - 1, 1);
}

pub fn free(id: i64) i32 {
    const s = slotOf(id) orelse return STALE;
    const l = &listeners.items[s];
    if (is_windows) {
        if (l.grammar) |g| {
            const p: *win.ISpRecoGrammar = @ptrCast(@alignCast(g));
            _ = p.lpVtbl.*.Release.?(@ptrCast(p));
        }
        if (l.context) |c| {
            const p: *win.ISpRecoContext = @ptrCast(@alignCast(c));
            _ = p.lpVtbl.*.Release.?(@ptrCast(p));
        }
        if (l.recognizer) |r| {
            const p: *win.ISpRecognizer = @ptrCast(@alignCast(r));
            _ = p.lpVtbl.*.Release.?(@ptrCast(p));
        }
    }
    l.grammar = null;
    l.context = null;
    l.recognizer = null;
    l.live = false;
    l.generation +%= 1;
    if (l.generation == 0) l.generation = 1;
    counters[CTR_LISTENERS_LIVE] -= 1;
    return OK;
}

pub fn liveCount() i64 {
    var n: i64 = 0;
    for (listeners.items) |l| {
        if (l.live) n += 1;
    }
    return n;
}

// ---------------------------------------------------------------- the grammar

/// Declare the phrases this listener will accept. THE WHOLE POINT: a closed
/// grammar maps sound to the string the caller wrote, so there is no spelling
/// left to get wrong -- which is exactly the failure free dictation had.
///
/// Call it with a newline-separated list. Replaces any previous grammar.
pub fn setPhrases(id: i64, phrases: []const u8) i32 {
    if (!is_windows) return UNSUPPORTED;
    const s = slotOf(id) orelse return STALE;
    const l = &listeners.items[s];
    const gram: *win.ISpRecoGrammar = @ptrCast(@alignCast(l.grammar orelse return BAD_ARG));

    // THE GRAMMAR NEEDS A LANGUAGE BEFORE IT WILL TAKE A WORD, and this was
    // not obvious: without it, AddWordTransition returns E_INVALIDARG
    // (0x80070057) for every phrase, including a single ordinary word. SAPI
    // validates each word against a LEXICON, and with no language there is no
    // lexicon to validate against -- so the error is about the grammar's state
    // rather than about the argument it names.
    const langid: u16 = @intCast(primaryLangId() & 0xFFFF);
    if (gram.lpVtbl.*.ResetGrammar.?(@ptrCast(gram), langid) < 0) {
        refuse("listen: ResetGrammar(0x{x}) failed -- no lexicon for that language", .{langid});
        return BAD_ARG;
    }

    var hstate: win.SPSTATEHANDLE = undefined;
    const rule_name = std.unicode.utf8ToUtf16LeStringLiteral("stzcommands");
    // GET THE RULE FIRST. An earlier cut called ClearRule with `hstate` still
    // `undefined` -- clearing a handle that had never been filled, which is
    // undefined behaviour dressed as tidiness. GetRule creates it (the 1), and
    // only then is there something to clear.
    var hr = gram.lpVtbl.*.GetRule.?(@ptrCast(gram), rule_name, 0, SPRAF_TopLevel | SPRAF_Active, 1, &hstate);
    if (hr < 0) {
        refuse("listen: GetRule -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return BAD_ARG;
    }
    _ = gram.lpVtbl.*.ClearRule.?(@ptrCast(gram), hstate);

    var n: u32 = 0;
    var it = std.mem.splitScalar(u8, phrases, '\n');
    while (it.next()) |raw| {
        const phrase = std.mem.trim(u8, raw, " \t\r");
        if (phrase.len == 0) continue;
        const w = std.unicode.utf8ToUtf16LeAllocZ(alloc, phrase) catch continue;
        defer alloc.free(w);
        // NULL destination state = this transition ends the rule, so each
        // phrase is one complete alternative
        hr = gram.lpVtbl.*.AddWordTransition.?(@ptrCast(gram), hstate, null, w.ptr, std.unicode.utf8ToUtf16LeStringLiteral(" "), SPWT_LEXICAL, 1.0, null);
        if (hr < 0) {
            refuse("listen: AddWordTransition('{s}') -> 0x{x}", .{ phrase, @as(u32, @bitCast(hr)) });
            return BAD_ARG;
        }
        n += 1;
    }
    if (n == 0) {
        refuse("listen: no usable phrases in the grammar", .{});
        return BAD_ARG;
    }
    hr = gram.lpVtbl.*.Commit.?(@ptrCast(gram), 0);
    if (hr < 0) {
        refuse("listen: Commit -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return BAD_ARG;
    }
    hr = gram.lpVtbl.*.SetRuleState.?(@ptrCast(gram), rule_name, null, SPRS_ACTIVE);
    if (hr < 0) {
        refuse("listen: SetRuleState -> 0x{x}", .{@as(u32, @bitCast(hr))});
        return BAD_ARG;
    }
    l.n_phrases = n;
    return OK;
}

pub fn phraseCount(id: i64) i64 {
    const s = slotOf(id) orelse return 0;
    return listeners.items[s].n_phrases;
}

// ---------------------------------------------------------------- listening

/// Recognise a WAV held in memory. Returns OK, NO_MATCH, or a refusal code.
/// The text and confidence are read with `lastText` / `lastConfidence`.
///
/// Takes a WHOLE WAV rather than raw samples so the buffer is self-describing --
/// the same reason the voice tier emits one.
pub fn listenToWav(id: i64, wav: []const u8) i32 {
    if (!is_windows) return UNSUPPORTED;
    const s = slotOf(id) orelse return STALE;
    const l = &listeners.items[s];
    l.text_len = 0;
    l.confidence = 0;
    if (l.n_phrases == 0) {
        refuse("listen: declare the phrases before listening", .{});
        return BAD_ARG;
    }

    var fmt: win.WAVEFORMATEX = undefined;
    const pcm = parseWav(wav, &fmt) orelse {
        refuse("listen: that is not a WAV this tier can read", .{});
        return BAD_ARG;
    };

    var base: ?*win.IStream = null;
    if (win.CreateStreamOnHGlobal(null, win.TRUE, @ptrCast(&base)) < 0 or base == null) return BAD_ARG;
    defer _ = base.?.lpVtbl.*.Release.?(@ptrCast(base.?));
    var written: c_ulong = 0;
    _ = base.?.lpVtbl.*.Write.?(@ptrCast(base.?), pcm.ptr, @intCast(pcm.len), &written);
    const zero = std.mem.zeroes(win.LARGE_INTEGER);
    _ = base.?.lpVtbl.*.Seek.?(@ptrCast(base.?), zero, 0, null);

    var stream: ?*win.ISpStream = null;
    if (win.CoCreateInstance(&CLSID_SpStream, null, win.CLSCTX_ALL, &IID_ISpStream, @ptrCast(&stream)) < 0 or stream == null) return BAD_ARG;
    const st = stream.?;
    defer _ = st.lpVtbl.*.Release.?(@ptrCast(st));
    if (st.lpVtbl.*.SetBaseStream.?(@ptrCast(st), @ptrCast(base.?), &SPDFID_WaveFormatEx, &fmt) < 0) {
        refuse("listen: SetBaseStream failed -- the WAV format may be unsupported", .{});
        return BAD_ARG;
    }

    const rec: *win.ISpRecognizer = @ptrCast(@alignCast(l.recognizer orelse return BAD_ARG));
    if (rec.lpVtbl.*.SetInput.?(@ptrCast(rec), @ptrCast(st), 1) < 0) {
        refuse("listen: SetInput failed", .{});
        return BAD_ARG;
    }
    return pump(l, 4000);
}

/// Recognise from the DEFAULT AUDIO INPUT -- a microphone.
///
/// This is the consent boundary of the whole library. It opens an input device
/// and listens until it hears something in the grammar or the timeout expires.
/// It is local-only (see the header); nothing is sent anywhere.
pub fn listenToMicrophone(id: i64, timeout_ms: i64) i32 {
    if (!is_windows) return UNSUPPORTED;
    const s = slotOf(id) orelse return STALE;
    const l = &listeners.items[s];
    l.text_len = 0;
    l.confidence = 0;
    if (l.n_phrases == 0) {
        refuse("listen: declare the phrases before listening", .{});
        return BAD_ARG;
    }
    const rec: *win.ISpRecognizer = @ptrCast(@alignCast(l.recognizer orelse return BAD_ARG));
    // NULL input token = the system default input
    if (rec.lpVtbl.*.SetInput.?(@ptrCast(rec), null, 1) < 0) {
        refuse("listen: no audio input available", .{});
        return BAD_ARG;
    }
    return pump(l, timeout_ms);
}

fn pump(l: *Listener, timeout_ms: i64) i32 {
    const ctx: *win.ISpRecoContext = @ptrCast(@alignCast(l.context orelse return BAD_ARG));
    const deadline = std.time.milliTimestamp() + timeout_ms;
    while (std.time.milliTimestamp() < deadline) {
        const remain: c_ulong = @intCast(@max(0, deadline - std.time.milliTimestamp()));
        const hr = ctx.lpVtbl.*.WaitForNotifyEvent.?(@ptrCast(ctx), remain);
        if (hr < 0) break;
        var ev = SpEvent{};
        var fetched: c_ulong = 0;
        while (ctx.lpVtbl.*.GetEvents.?(@ptrCast(ctx), 1, @ptrCast(&ev), &fetched) >= 0 and fetched == 1) {
            if (ev.eEventId == @as(u16, @intCast(SPEI_RECOGNITION))) {
                const res: *win.ISpRecoResult = @ptrFromInt(@as(usize, @intCast(ev.lParam)));
                defer _ = res.lpVtbl.*.Release.?(@ptrCast(res));
                var text: ?[*:0]u16 = null;
                if (res.lpVtbl.*.GetText.?(@ptrCast(res), SP_GETWHOLEPHRASE, SP_GETWHOLEPHRASE, 1, @ptrCast(&text), null) >= 0 and text != null) {
                    defer win.CoTaskMemFree(@ptrCast(text.?));
                    const n = std.unicode.utf16LeToUtf8(&l.text, std.mem.span(text.?)) catch 0;
                    l.text_len = n;
                }
                // CONFIDENCE TRAVELS WITH THE TEXT, always. A recognised string
                // without one is a guess wearing a fact's clothes.
                var phrase: ?*win.SPPHRASE = null;
                if (res.lpVtbl.*.GetPhrase.?(@ptrCast(res), @ptrCast(&phrase)) >= 0 and phrase != null) {
                    l.confidence = phrase.?.Rule.SREngineConfidence;
                    win.CoTaskMemFree(@ptrCast(phrase.?));
                }
                counters[CTR_RECOGNITIONS] += 1;
                return OK;
            } else if (ev.eEventId == @as(u16, @intCast(SPEI_FALSE_RECOGNITION))) {
                counters[CTR_NO_MATCH] += 1;
                return NO_MATCH;
            }
            fetched = 0;
        }
    }
    counters[CTR_NO_MATCH] += 1;
    return NO_MATCH;
}

pub fn lastText(id: i64) []const u8 {
    const s = slotOf(id) orelse return &.{};
    return listeners.items[s].text[0..listeners.items[s].text_len];
}

pub fn lastConfidence(id: i64) f64 {
    const s = slotOf(id) orelse return 0;
    return listeners.items[s].confidence;
}

// A minimal WAV reader that WALKS THE CHUNKS. It does not trust offset 36 for
// `data`, because SAPI's own files put it at 46 -- and VC0 reported 34,611
// seconds of speech from an 8-second file by trusting the textbook.
fn parseWav(wav: []const u8, fmt: *win.WAVEFORMATEX) ?[]const u8 {
    if (wav.len < 44) return null;
    if (!std.mem.eql(u8, wav[0..4], "RIFF") or !std.mem.eql(u8, wav[8..12], "WAVE")) return null;
    var have_fmt = false;
    var p: usize = 12;
    while (p + 8 <= wav.len) {
        const id = wav[p..][0..4];
        const sz = std.mem.readInt(u32, wav[p + 4 ..][0..4], .little);
        const body = p + 8;
        if (std.mem.eql(u8, id, "fmt ") and body + 16 <= wav.len) {
            fmt.* = std.mem.zeroes(win.WAVEFORMATEX);
            fmt.wFormatTag = std.mem.readInt(u16, wav[body..][0..2], .little);
            fmt.nChannels = std.mem.readInt(u16, wav[body + 2 ..][0..2], .little);
            fmt.nSamplesPerSec = std.mem.readInt(u32, wav[body + 4 ..][0..4], .little);
            fmt.nAvgBytesPerSec = std.mem.readInt(u32, wav[body + 8 ..][0..4], .little);
            fmt.nBlockAlign = std.mem.readInt(u16, wav[body + 12 ..][0..2], .little);
            fmt.wBitsPerSample = std.mem.readInt(u16, wav[body + 14 ..][0..2], .little);
            fmt.cbSize = 0;
            have_fmt = true;
        } else if (std.mem.eql(u8, id, "data")) {
            if (!have_fmt) return null;
            const end = @min(wav.len, body + sz);
            return wav[body..end];
        }
        p = body + sz + (sz % 2);
    }
    return null;
}

// ---------------------------------------------------------------- tests

const testing = std.testing;

test "the hand-declared SPEVENT matches the layout SAPI expects" {
    // If this is wrong, GetEvents writes past the struct or the event id is
    // read from the wrong offset -- and the failure would look like "nothing is
    // ever recognised" rather than like a layout bug.
    try testing.expectEqual(@as(usize, 32), @sizeOf(SpEvent));
    try testing.expectEqual(@as(usize, 0), @offsetOf(SpEvent, "eEventId"));
    try testing.expectEqual(@as(usize, 2), @offsetOf(SpEvent, "elParamType"));
    try testing.expectEqual(@as(usize, 8), @offsetOf(SpEvent, "ullAudioStreamOffset"));
    try testing.expectEqual(@as(usize, 16), @offsetOf(SpEvent, "wParam"));
    try testing.expectEqual(@as(usize, 24), @offsetOf(SpEvent, "lParam"));
}

test "the recognition tier reports its own absence honestly" {
    if (!is_windows) {
        try testing.expect(!isAvailable());
        return;
    }
    // On Windows it may still be absent -- a machine can have voices and no
    // recognizer, which is exactly this machine's shape for English.
    const n = installedCount();
    std.debug.print("\n  installed recognizers: {d}\n", .{n});
    var i: i64 = 0;
    while (i < n) : (i += 1) {
        std.debug.print("    [{d}] {s}  lang={s}\n", .{ i, installedName(i), installedLanguage(i) });
    }
}

test "a listener opens, takes a grammar, and refuses to listen without one" {
    if (!is_windows or !isAvailable()) return error.SkipZigTest;
    countersReset();
    const id = open();
    try testing.expect(id > 0);
    defer _ = free(id);

    // listening before declaring a grammar is refused, not attempted
    try testing.expectEqual(BAD_ARG, listenToWav(id, "not a wav"));
    try testing.expect(counter(CTR_REFUSALS) > 0);

    const rc = setPhrases(id, "ouvrir le fichier\nenregistrer\nannuler");
    if (rc != OK) std.debug.print("\n  setPhrases refused: {s}\n", .{lastError()});
    try testing.expectEqual(OK, rc);
    try testing.expectEqual(@as(i64, 3), phraseCount(id));

    // an empty grammar is refused
    try testing.expectEqual(BAD_ARG, setPhrases(id, "   \n  \n"));
}

test "a freed listener is STALE, and counted" {
    if (!is_windows or !isAvailable()) return error.SkipZigTest;
    const id = open();
    _ = setPhrases(id, "annuler");
    try testing.expectEqual(OK, free(id));
    countersReset();
    try testing.expectEqual(STALE, listenToWav(id, "x"));
    try testing.expectEqual(STALE, free(id));
    try testing.expectEqual(@as(i64, 0), phraseCount(id));
    try testing.expect(counter(CTR_STALE_HITS) >= 3);
}

test "the WAV reader WALKS the chunks rather than trusting offset 36" {
    // an 18-byte fmt chunk, which is what SAPI itself writes -- data lands at
    // 46, not 36, and a reader that assumes otherwise reads samples as a length
    var buf: [64]u8 = @splat(0);
    @memcpy(buf[0..4], "RIFF");
    std.mem.writeInt(u32, buf[4..8], 56, .little);
    @memcpy(buf[8..12], "WAVE");
    @memcpy(buf[12..16], "fmt ");
    std.mem.writeInt(u32, buf[16..20], 18, .little); // EIGHTEEN
    std.mem.writeInt(u16, buf[20..22], 1, .little);
    std.mem.writeInt(u16, buf[22..24], 1, .little);
    std.mem.writeInt(u32, buf[24..28], 16000, .little);
    std.mem.writeInt(u32, buf[28..32], 32000, .little);
    std.mem.writeInt(u16, buf[32..34], 2, .little);
    std.mem.writeInt(u16, buf[34..36], 16, .little);
    std.mem.writeInt(u16, buf[36..38], 0, .little); // cbSize
    @memcpy(buf[38..42], "data");
    std.mem.writeInt(u32, buf[42..46], 8, .little);

    var fmt: win.WAVEFORMATEX = undefined;
    const pcm = parseWav(&buf, &fmt);
    try testing.expect(pcm != null);
    try testing.expectEqual(@as(usize, 8), pcm.?.len);
    try testing.expectEqual(@as(u32, 16000), fmt.nSamplesPerSec);
    try testing.expectEqual(@as(u16, 1), fmt.nChannels);

    // the negative sibling: rubbish is refused rather than half-read
    try testing.expect(parseWav("not a wav at all", &fmt) == null);
    try testing.expect(parseWav(buf[0..10], &fmt) == null);
}
