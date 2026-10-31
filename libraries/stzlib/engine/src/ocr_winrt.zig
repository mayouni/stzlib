// Softanza Engine -- the :ocr floor called in process: Windows.Media.Ocr through WinRT (O5)
//
// The floor used to be a PowerShell script started once per page: measured 2026-10-31, the process and its WinRT type
// loading cost 480 ms on every page (1,000 ms a French page against 520 ms of recognition, 1,400 against 920 for an
// Arabic one) -- a third to a half of every platform read, paid once per page. Here the same engine is called from the
// engine's own process through its WinRT interfaces: combase.dll is opened at run time (no import library, and a
// machine without WinRT simply answers "unavailable" and the caller falls back to the script), each interface is a
// COM vtable called by index, and the indices and interface ids come from the system's own metadata
// (System32\WinMetadata, read by reflection: get_MaxImageDimension is IOcrEngineStatics' first method, after
// IInspectable's six). The page is the script's, step for step: read as it stands; when a quarter of its words stand
// under the target height, read again enlarged to reach it (at most 4x, inside the engine's largest image); a run of
// small words set beside large ones read again on its own; each line's box in the image's pixels with the median of
// its words' tops and bottoms.

const std = @import("std");
const builtin = @import("builtin");
const ocrp = @import("ocr_pipeline.zig");

const gpa = std.heap.c_allocator;
const HRESULT = i32;
const HSTRING = ?*anyopaque;

pub const Guid = extern struct { a: u32, b: u16, c: u16, d: [8]u8 };

fn guid(comptime s: []const u8) Guid {
    @setEvalBranchQuota(10000);
    const hex = struct {
        fn v(comptime t: []const u8) u64 {
            return std.fmt.parseInt(u64, t, 16) catch unreachable;
        }
    }.v;
    var d: [8]u8 = undefined;
    d[0] = @intCast(hex(s[19..21]));
    d[1] = @intCast(hex(s[21..23]));
    for (0..6) |i| d[2 + i] = @intCast(hex(s[24 + 2 * i .. 26 + 2 * i]));
    return .{ .a = @intCast(hex(s[0..8])), .b = @intCast(hex(s[9..13])), .c = @intCast(hex(s[14..18])), .d = d };
}

const IID_IOcrEngineStatics = guid("5bffa85a-3384-3540-9940-699120d428a8");
const IID_ILanguageFactory = guid("9b0252ac-0c27-44f8-b792-9793fb66c63e");
const IID_ISoftwareBitmapFactory = guid("c99feb69-2d62-4d47-a6b3-4fdb6a07fdf8");
const IID_IBufferFactory = guid("71af914d-c10f-484b-bc50-14bc623b3a27");
const IID_IBufferByteAccess = guid("905a0fef-bc53-11df-8c49-001e4fc686da");
const IID_IAsyncInfo = guid("00000036-0000-0000-c000-000000000046");

// the IInspectable methods take the first six slots of every WinRT vtable; an interface's own methods follow in
// metadata order
const SLOT = 6;

const Combase = struct {
    RoInitialize: *const fn (u32) callconv(.winapi) HRESULT,
    RoGetActivationFactory: *const fn (HSTRING, *const Guid, *?*anyopaque) callconv(.winapi) HRESULT,
    WindowsCreateString: *const fn ([*]const u16, u32, *HSTRING) callconv(.winapi) HRESULT,
    WindowsDeleteString: *const fn (HSTRING) callconv(.winapi) HRESULT,
    WindowsGetStringRawBuffer: *const fn (HSTRING, ?*u32) callconv(.winapi) ?[*]const u16,
};
var g_combase: ?Combase = null;
var g_lib: ?std.DynLib = null;

fn combase() ?Combase {
    if (builtin.os.tag != .windows) return null;
    if (g_combase) |c| return c;
    var lib = std.DynLib.open("combase.dll") catch return null;
    const c = Combase{
        .RoInitialize = lib.lookup(@FieldType(Combase, "RoInitialize"), "RoInitialize") orelse return null,
        .RoGetActivationFactory = lib.lookup(@FieldType(Combase, "RoGetActivationFactory"), "RoGetActivationFactory") orelse return null,
        .WindowsCreateString = lib.lookup(@FieldType(Combase, "WindowsCreateString"), "WindowsCreateString") orelse return null,
        .WindowsDeleteString = lib.lookup(@FieldType(Combase, "WindowsDeleteString"), "WindowsDeleteString") orelse return null,
        .WindowsGetStringRawBuffer = lib.lookup(@FieldType(Combase, "WindowsGetStringRawBuffer"), "WindowsGetStringRawBuffer") orelse return null,
    };
    g_lib = lib;
    g_combase = c;
    // a thread already initialised for COM answers RPC_E_CHANGED_MODE and stays as it is: WinRT works either way
    _ = c.RoInitialize(1);
    return c;
}

// the function in slot i of an interface's vtable
fn slot(comptime F: type, obj: *anyopaque, i: usize) F {
    const vt: *const [*]const ?*const anyopaque = @ptrCast(@alignCast(obj));
    return @ptrCast(vt.*[i].?);
}

fn release(obj: ?*anyopaque) void {
    const o = obj orelse return;
    _ = slot(*const fn (*anyopaque) callconv(.winapi) u32, o, 2)(o);
}

fn query(obj: *anyopaque, iid: *const Guid) ?*anyopaque {
    var out: ?*anyopaque = null;
    if (slot(*const fn (*anyopaque, *const Guid, *?*anyopaque) callconv(.winapi) HRESULT, obj, 0)(obj, iid, &out) < 0) return null;
    return out;
}

fn hstring(c: Combase, s: []const u8) !HSTRING {
    const w = try std.unicode.utf8ToUtf16LeAlloc(gpa, s);
    defer gpa.free(w);
    var h: HSTRING = null;
    if (c.WindowsCreateString(w.ptr, @intCast(w.len), &h) < 0) return error.WinRT;
    return h;
}

fn utf8Of(c: Combase, a: std.mem.Allocator, h: HSTRING) ![]u8 {
    if (h == null) return a.dupe(u8, "");
    var n: u32 = 0;
    const p = c.WindowsGetStringRawBuffer(h, &n) orelse return a.dupe(u8, "");
    return std.unicode.utf16LeToUtf8Alloc(a, p[0..n]);
}

fn factory(c: Combase, class: []const u8, iid: *const Guid) !*anyopaque {
    const h = try hstring(c, class);
    defer _ = c.WindowsDeleteString(h);
    var f: ?*anyopaque = null;
    if (c.RoGetActivationFactory(h, iid, &f) < 0 or f == null) return error.WinRT;
    return f.?;
}

const Word = struct { text: []u8, x: f32, y: f32, w: f32, h: f32 };
const RLine = struct { words: []Word };

const Engine = struct {
    c: Combase,
    engine: *anyopaque,
    bitmaps: *anyopaque,
    buffers: *anyopaque,
    max_dim: f32,
};

// One recognition of an RGB image: its lines and their words, in the image's pixels
fn recognise(e: Engine, a: std.mem.Allocator, im: *const ocrp.Image) ![]RLine {
    const c = e.c;
    var bmp: ?*anyopaque = null;
    // ISoftwareBitmapFactory.Create(Bgra8 = 87, width, height)
    if (slot(*const fn (*anyopaque, i32, i32, i32, *?*anyopaque) callconv(.winapi) HRESULT, e.bitmaps, SLOT)(e.bitmaps, 87, @intCast(im.w), @intCast(im.h), &bmp) < 0 or bmp == null) return error.WinRT;
    defer release(bmp);
    const n: u32 = @intCast(im.w * im.h * 4);
    var buf: ?*anyopaque = null;
    if (slot(*const fn (*anyopaque, u32, *?*anyopaque) callconv(.winapi) HRESULT, e.buffers, SLOT)(e.buffers, n, &buf) < 0 or buf == null) return error.WinRT;
    defer release(buf);
    // IBuffer.put_Length (slot 2 of its own), then the bytes through IBufferByteAccess.Buffer (an IUnknown: slot 3)
    _ = slot(*const fn (*anyopaque, u32) callconv(.winapi) HRESULT, buf.?, SLOT + 2)(buf.?, n);
    const acc = query(buf.?, &IID_IBufferByteAccess) orelse return error.WinRT;
    defer release(acc);
    var bytes: ?[*]u8 = null;
    if (slot(*const fn (*anyopaque, *?[*]u8) callconv(.winapi) HRESULT, acc, 3)(acc, &bytes) < 0 or bytes == null) return error.WinRT;
    const dst = bytes.?;
    for (0..im.w * im.h) |i| {
        dst[i * 4] = im.px[i * 3 + 2];
        dst[i * 4 + 1] = im.px[i * 3 + 1];
        dst[i * 4 + 2] = im.px[i * 3];
        dst[i * 4 + 3] = 255;
    }
    // ISoftwareBitmap.CopyFromBuffer: its twelfth method
    if (slot(*const fn (*anyopaque, *anyopaque) callconv(.winapi) HRESULT, bmp.?, SLOT + 11)(bmp.?, buf.?) < 0) return error.WinRT;
    // IOcrEngine.RecognizeAsync, waited on through IAsyncInfo.get_Status (0 started, 1 completed)
    var op: ?*anyopaque = null;
    if (slot(*const fn (*anyopaque, *anyopaque, *?*anyopaque) callconv(.winapi) HRESULT, e.engine, SLOT)(e.engine, bmp.?, &op) < 0 or op == null) return error.WinRT;
    defer release(op);
    const info = query(op.?, &IID_IAsyncInfo) orelse return error.WinRT;
    defer release(info);
    var status: i32 = 0;
    while (true) {
        if (slot(*const fn (*anyopaque, *i32) callconv(.winapi) HRESULT, info, SLOT + 1)(info, &status) < 0) return error.WinRT;
        if (status != 0) break;
        std.Thread.sleep(1 * std.time.ns_per_ms);
    }
    if (status != 1) return error.WinRT;
    var res: ?*anyopaque = null;
    // IAsyncOperation<OcrResult>.GetResults: after put_Completed and get_Completed
    if (slot(*const fn (*anyopaque, *?*anyopaque) callconv(.winapi) HRESULT, op.?, SLOT + 2)(op.?, &res) < 0 or res == null) return error.WinRT;
    defer release(res);
    var lines_v: ?*anyopaque = null;
    if (slot(*const fn (*anyopaque, *?*anyopaque) callconv(.winapi) HRESULT, res.?, SLOT)(res.?, &lines_v) < 0 or lines_v == null) return error.WinRT;
    defer release(lines_v);
    var out: std.ArrayList(RLine) = .empty;
    var nl: u32 = 0;
    _ = slot(*const fn (*anyopaque, *u32) callconv(.winapi) HRESULT, lines_v.?, SLOT + 1)(lines_v.?, &nl);
    for (0..nl) |li| {
        var line: ?*anyopaque = null;
        if (slot(*const fn (*anyopaque, u32, *?*anyopaque) callconv(.winapi) HRESULT, lines_v.?, SLOT)(lines_v.?, @intCast(li), &line) < 0 or line == null) continue;
        defer release(line);
        var words_v: ?*anyopaque = null;
        if (slot(*const fn (*anyopaque, *?*anyopaque) callconv(.winapi) HRESULT, line.?, SLOT)(line.?, &words_v) < 0 or words_v == null) continue;
        defer release(words_v);
        var nw: u32 = 0;
        _ = slot(*const fn (*anyopaque, *u32) callconv(.winapi) HRESULT, words_v.?, SLOT + 1)(words_v.?, &nw);
        var words: std.ArrayList(Word) = .empty;
        for (0..nw) |wi| {
            var word: ?*anyopaque = null;
            if (slot(*const fn (*anyopaque, u32, *?*anyopaque) callconv(.winapi) HRESULT, words_v.?, SLOT)(words_v.?, @intCast(wi), &word) < 0 or word == null) continue;
            defer release(word);
            var rect: [4]f32 = .{ 0, 0, 0, 0 };
            _ = slot(*const fn (*anyopaque, *[4]f32) callconv(.winapi) HRESULT, word.?, SLOT)(word.?, &rect);
            var ht: HSTRING = null;
            _ = slot(*const fn (*anyopaque, *HSTRING) callconv(.winapi) HRESULT, word.?, SLOT + 1)(word.?, &ht);
            const t = try utf8Of(c, a, ht);
            _ = c.WindowsDeleteString(ht);
            try words.append(a, .{ .text = t, .x = rect[0], .y = rect[1], .w = rect[2], .h = rect[3] });
        }
        try out.append(a, .{ .words = try words.toOwnedSlice(a) });
    }
    return out.toOwnedSlice(a);
}

pub const Line = struct { text: []const u8, box: [4]f32, mid: [2]f32 };

pub const Read = struct {
    arena: std.heap.ArenaAllocator,
    summary: []const u8,
    lines: []Line,
    pub fn free(self: *Read) void {
        self.arena.deinit();
    }
};

// An image enlarged by k, bilinear (the pipeline's own resize). The script this replaces enlarged with WIC's cubic
// mode; measured on the 21 degraded twins, neither filter reads better -- bilinear 378 blocks of the right kind, 2,208
// words and 509 numbers right, a cubic convolution here 376, 2,208 and 506, the script 379, 2,211 and 508 -- each
// moving a few words either way (Carnot as "Camot" on one photo, "لا" found on four pages), and cubic costs 70 ms more.
fn scaled(im: *const ocrp.Image, k: f32) !ocrp.Image {
    const w: usize = @intFromFloat(@round(@as(f32, @floatFromInt(im.w)) * k));
    const h: usize = @intFromFloat(@round(@as(f32, @floatFromInt(im.h)) * k));
    return ocrp.resize(im, @max(1, w), @max(1, h));
}

fn cropped(im: *const ocrp.Image, x0: usize, y0: usize, x1: usize, y1: usize) !ocrp.Image {
    const w = x1 - x0;
    const h = y1 - y0;
    var out = try ocrp.newImage(w, h);
    for (0..h) |y| @memcpy(out.px[y * w * 3 .. (y + 1) * w * 3], im.px[((y0 + y) * im.w + x0) * 3 .. ((y0 + y) * im.w + x1) * 3]);
    return out;
}

/// Reads one image with the platform's engine for a language ("" for the user's own languages), the way the floor's
/// script does. The summary says "NO ENGINE for <lang>" when the machine has no pack for it (no lines then);
/// error.Unavailable when WinRT cannot be reached at all.
pub fn read(image_path: []const u8, lang: []const u8, target: f32) !Read {
    var res = Read{ .arena = std.heap.ArenaAllocator.init(gpa), .summary = "", .lines = &.{} };
    errdefer res.arena.deinit();
    const a = res.arena.allocator();
    const c = combase() orelse return error.Unavailable;
    const statics = factory(c, "Windows.Media.Ocr.OcrEngine", &IID_IOcrEngineStatics) catch return error.Unavailable;
    defer release(statics);
    var engine: ?*anyopaque = null;
    if (lang.len == 0) {
        _ = slot(*const fn (*anyopaque, *?*anyopaque) callconv(.winapi) HRESULT, statics, SLOT + 4)(statics, &engine);
    } else {
        const lf = factory(c, "Windows.Globalization.Language", &IID_ILanguageFactory) catch return error.Unavailable;
        defer release(lf);
        const ht = try hstring(c, lang);
        defer _ = c.WindowsDeleteString(ht);
        var language: ?*anyopaque = null;
        if (slot(*const fn (*anyopaque, HSTRING, *?*anyopaque) callconv(.winapi) HRESULT, lf, SLOT)(lf, ht, &language) >= 0 and language != null) {
            defer release(language);
            _ = slot(*const fn (*anyopaque, *anyopaque, *?*anyopaque) callconv(.winapi) HRESULT, statics, SLOT + 3)(statics, language.?, &engine);
        }
    }
    if (engine == null) {
        res.summary = try std.fmt.allocPrint(a, "NO ENGINE for {s}", .{lang});
        return res;
    }
    defer release(engine);
    var max_dim: u32 = 0;
    _ = slot(*const fn (*anyopaque, *u32) callconv(.winapi) HRESULT, statics, SLOT)(statics, &max_dim);
    const bitmaps = factory(c, "Windows.Graphics.Imaging.SoftwareBitmap", &IID_ISoftwareBitmapFactory) catch return error.Unavailable;
    defer release(bitmaps);
    const buffers = factory(c, "Windows.Storage.Streams.Buffer", &IID_IBufferFactory) catch return error.Unavailable;
    defer release(buffers);
    const e = Engine{ .c = c, .engine = engine.?, .bitmaps = bitmaps, .buffers = buffers, .max_dim = @floatFromInt(max_dim) };

    var im = ocrp.loadImage(image_path) catch {
        res.summary = try std.fmt.allocPrint(a, "NO IMAGE at {s}", .{image_path});
        return res;
    };
    defer im.free();
    const W: f32 = @floatFromInt(im.w);
    const H: f32 = @floatFromInt(im.h);
    const fit = e.max_dim / @max(W, H);
    var timer = try std.time.Timer.start();

    // pass 1 as the image stands; small text read again enlarged
    var k: f32 = 1;
    var lines = try recognise(e, a, &im);
    var hs: std.ArrayList(f32) = .empty;
    for (lines) |l| for (l.words) |w| try hs.append(a, w.h);
    if (hs.items.len > 0) {
        std.sort.pdq(f32, hs.items, {}, std.sort.asc(f32));
        const q = hs.items[@intFromFloat(@floor(@as(f32, @floatFromInt(hs.items.len - 1)) * 0.25))];
        k = @min(@min(4.0, target / @max(1.0, q)), fit);
        if (k < 1.2) k = 1 else {
            var big = try scaled(&im, k);
            defer big.free();
            lines = try recognise(e, a, &big);
        }
    }
    var out: std.ArrayList(Line) = .empty;
    var n_words: usize = 0;
    var n_reread: usize = 0;
    for (lines) |l| {
        const ws = l.words;
        if (ws.len == 0) continue;
        n_words += ws.len;
        var texts: std.ArrayList([]const u8) = .empty;
        for (ws) |w| try texts.append(a, w.text);
        // a run of small words set beside large ones is read again on its own
        if (ws.len >= 2) {
            const hh = try a.alloc(f32, ws.len);
            for (ws, 0..) |w, i| hh[i] = w.h;
            std.sort.pdq(f32, hh, {}, std.sort.asc(f32));
            var cut: f32 = -1;
            var best: f32 = 1.7;
            for (0..hh.len - 1) |i| {
                const r = hh[i + 1] / @max(1.0, hh[i]);
                if (r >= best) {
                    best = r;
                    cut = hh[i];
                }
            }
            if (cut > 0) {
                var small: std.ArrayList(usize) = .empty;
                for (ws, 0..) |w, i| if (w.h <= cut) try small.append(a, i);
                const sm = small.items;
                if (sm.len >= 2 and sm.len < ws.len and sm[sm.len - 1] - sm[0] + 1 == sm.len) {
                    var x0: f32 = 1e9;
                    var y0: f32 = 1e9;
                    var x1: f32 = 0;
                    var y1: f32 = 0;
                    for (sm) |i| {
                        x0 = @min(x0, ws[i].x);
                        y0 = @min(y0, ws[i].y);
                        x1 = @max(x1, ws[i].x + ws[i].w);
                        y1 = @max(y1, ws[i].y + ws[i].h);
                    }
                    const h0 = (y1 - y0) / k;
                    const ks = @min(@max(k, @min(4.0, target / @max(1.0, h0))), fit);
                    const p = 0.6 * h0;
                    const ox0: usize = @intFromFloat(@max(0, x0 / k - p));
                    const oy0: usize = @intFromFloat(@max(0, y0 / k - p));
                    const ox1: usize = @intFromFloat(@min(W, x1 / k + p));
                    const oy1: usize = @intFromFloat(@min(H, y1 / k + p));
                    if (ox1 > ox0 + 2 and oy1 > oy0 + 2) {
                        var piece = try cropped(&im, ox0, oy0, ox1, oy1);
                        defer piece.free();
                        var big = try scaled(&piece, ks);
                        defer big.free();
                        const again = try recognise(e, a, &big);
                        if (again.len == 1) {
                            var t2: std.ArrayList(u8) = .empty;
                            for (again[0].words, 0..) |w, i| {
                                if (i > 0) try t2.append(a, ' ');
                                try t2.appendSlice(a, w.text);
                            }
                            var nt: std.ArrayList([]const u8) = .empty;
                            for (ws, 0..) |_, i| {
                                if (i == sm[0]) try nt.append(a, t2.items) else if (std.mem.indexOfScalar(usize, sm, i) == null) try nt.append(a, texts.items[i]);
                            }
                            texts = nt;
                            n_reread += 1;
                        }
                    }
                }
            }
        }
        const text = try std.mem.join(a, " ", texts.items);
        var bx0: f32 = 1e9;
        var by0: f32 = 1e9;
        var bx1: f32 = 0;
        var by1: f32 = 0;
        const tops = try a.alloc(f32, ws.len);
        const bots = try a.alloc(f32, ws.len);
        for (ws, 0..) |w, i| {
            bx0 = @min(bx0, w.x);
            by0 = @min(by0, w.y);
            bx1 = @max(bx1, w.x + w.w);
            by1 = @max(by1, w.y + w.h);
            tops[i] = w.y;
            bots[i] = w.y + w.h;
        }
        std.sort.pdq(f32, tops, {}, std.sort.asc(f32));
        std.sort.pdq(f32, bots, {}, std.sort.asc(f32));
        const lo = (ws.len - 1) / 2;
        const hi = ws.len / 2;
        try out.append(a, .{
            .text = text,
            .box = .{ @round(bx0 / k), @round(by0 / k), @round(bx1 / k), @round(by1 / k) },
            .mid = .{ @round((tops[lo] + tops[hi]) / 2 / k * 10) / 10, @round((bots[lo] + bots[hi]) / 2 / k * 10) / 10 },
        });
    }
    const ms = timer.read() / std.time.ns_per_ms;
    res.lines = try out.toOwnedSlice(a);
    res.summary = try std.fmt.allocPrint(a, "lang {s}  image {d}x{d}  lines {d}  words {d}  angle 0  ms {d}  scale {d:.2}  reread {d}  in process", .{ lang, im.w, im.h, res.lines.len, n_words, ms, k, n_reread });
    return res;
}
