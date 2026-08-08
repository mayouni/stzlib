//! Texture atlas -- GR2b of SOFTANZA_GRAPHICS_PLAN.md.
//!
//! This is a TEXTURE atlas, not a font atlas -- the §3b door taken
//! deliberately. Glyphs are its FIRST TENANT; sprites and tilesets are the
//! same shape (a rect of RGBA8 packed into a shared texture, addressed by
//! uv), and naming it for fonts would have guaranteed a rewrite when the
//! game plane arrives. Nothing here knows what a glyph is except the one
//! function that rasters one.
//!
//! Mechanics:
//!   - SHELF packing (rows of uniform height, cursor per shelf): the right
//!     packer for many small similar-height items, which is what glyph runs
//!     and sprite sheets both are.
//!   - 1 px PADDING around every entry, so linear filtering at fractional
//!     positions cannot bleed a neighbour's pixels into a glyph's edge.
//!   - The CPU buffer is the truth; the GPU texture is a projection of it,
//!     re-uploaded when dirty (whole-surface writes: GR1's texture_write
//!     contract). Incremental sub-uploads are a later, measured increment.
//!   - Entries are CACHED by (font id, glyph id, quantized size): the same
//!     word laid out twice rasters once. The guard asserts that by counting.
//!
//! Lives CPU-side; a GPU texture only appears when someone asks for one, so
//! the SVG tier and CI never touch a device.

const std = @import("std");
const gpu = @import("gpu.zig");
const gtext = @import("gpu_text.zig");

const alloc = std.heap.c_allocator;

pub const DEFAULT_W: u32 = 1024;
pub const DEFAULT_H: u32 = 1024;
const PAD: u32 = 1;

pub const Entry = struct {
    x: u32,
    y: u32,
    w: u32, // ink size, padding excluded
    h: u32,
    xoff: i32, // ink left relative to the pen
    yoff: i32, // ink top relative to the baseline (negative = above)
};

const Key = struct { font: i64, gid: u32, size_q: u32 };

const Shelf = struct { y: u32, h: u32, cursor: u32 };

const CacheItem = struct { key: Key, entry: Entry };

var width: u32 = DEFAULT_W;
var height: u32 = DEFAULT_H;
var pixels: []u8 = &.{}; // RGBA8, (255,255,255,coverage)
var shelves: std.ArrayList(Shelf) = .{};
var items: std.ArrayList(CacheItem) = .{};
var dirty = false;
var tex_id: i64 = 0;
var upload_count: u64 = 0;

pub fn stats() [4]f64 {
    return .{
        @floatFromInt(width),
        @floatFromInt(height),
        @floatFromInt(items.items.len),
        @floatFromInt(upload_count),
    };
}

fn ensureBuffer() !void {
    if (pixels.len != 0) return;
    pixels = try alloc.alloc(u8, @as(usize, width) * height * 4);
    @memset(pixels, 0);
}

/// Drop everything: CPU buffer, shelves, cache, and the GPU projection.
/// Called on device loss (the texture id dies with the device) and by the
/// face when a caller wants a clean slate.
pub fn reset() void {
    if (pixels.len != 0) alloc.free(pixels);
    pixels = &.{};
    shelves.clearRetainingCapacity();
    items.clearRetainingCapacity();
    if (tex_id != 0) _ = gpu.stz_gpu_texture_free(tex_id);
    tex_id = 0;
    dirty = false;
}

/// The device went away: the texture handle is gone with it, but the CPU
/// truth survives -- the next upload rebuilds the projection.
pub fn forgetTexture() void {
    tex_id = 0;
    dirty = pixels.len != 0;
}

fn packRect(w: u32, h: u32) ?struct { x: u32, y: u32 } {
    const need_w = w + PAD * 2;
    const need_h = h + PAD * 2;
    if (need_w > width or need_h > height) return null;
    // an existing shelf, if the item is not wastefully shorter than it
    for (shelves.items) |*s| {
        if (s.h >= need_h and s.h <= need_h * 2 and s.cursor + need_w <= width) {
            const x = s.cursor;
            s.cursor += need_w;
            return .{ .x = x + PAD, .y = s.y + PAD };
        }
    }
    // a new shelf below the last
    var next_y: u32 = 0;
    for (shelves.items) |s| next_y = @max(next_y, s.y + s.h);
    if (next_y + need_h > height) return null; // full
    shelves.append(alloc, .{ .y = next_y, .h = need_h, .cursor = need_w }) catch return null;
    return .{ .x = PAD, .y = next_y + PAD };
}

fn sizeKey(size_px: f64) u32 {
    return @intFromFloat(@round(size_px * 4.0)); // quarter-pixel quantization
}

/// Fetch (or raster and insert) the atlas entry for one glyph. The atlas
/// stores coverage in alpha with white rgb, so a tinted draw is
/// `color.rgb, color.a * sampled.a` -- one atlas serves every text color.
pub fn glyphEntry(font_id: i64, gid: u32, size_px: f64) !Entry {
    const key = Key{ .font = font_id, .gid = gid, .size_q = sizeKey(size_px) };
    for (items.items) |it| {
        if (it.key.font == key.font and it.key.gid == key.gid and it.key.size_q == key.size_q)
            return it.entry;
    }
    try ensureBuffer();

    const bm = try gtext.glyphBitmap(font_id, gid, size_px);
    defer bm.deinit();
    if (bm.w == 0 or bm.h == 0) {
        // an ink-free glyph (space): a real, cacheable, zero-area entry
        const e = Entry{ .x = 0, .y = 0, .w = 0, .h = 0, .xoff = 0, .yoff = 0 };
        try items.append(alloc, .{ .key = key, .entry = e });
        return e;
    }
    const spot = packRect(bm.w, bm.h) orelse return error.AtlasFull;
    for (0..bm.h) |row| {
        const dst = ((spot.y + row) * width + spot.x) * 4;
        for (0..bm.w) |col| {
            const cov = bm.gray[row * bm.w + col];
            pixels[dst + col * 4 + 0] = 255;
            pixels[dst + col * 4 + 1] = 255;
            pixels[dst + col * 4 + 2] = 255;
            pixels[dst + col * 4 + 3] = cov;
        }
    }
    dirty = true;
    const e = Entry{ .x = spot.x, .y = spot.y, .w = bm.w, .h = bm.h, .xoff = bm.xoff, .yoff = bm.yoff };
    try items.append(alloc, .{ .key = key, .entry = e });
    return e;
}

/// The GPU projection: a sampled (linear) texture holding the current CPU
/// buffer. 0 when there is no device or nothing has been packed.
pub fn textureId() i64 {
    if (pixels.len == 0) return 0;
    if (gpu.stz_gpu_is_available() == 0) return 0;
    if (tex_id != 0 and gpu.stz_gpu_texture_width(tex_id) < 0) {
        // evicted by the VRAM budget (gen-keyed id went stale): rebuild
        tex_id = 0;
        dirty = true;
    }
    if (tex_id == 0) {
        tex_id = gpu.stz_gpu_texture_new(@floatFromInt(width), @floatFromInt(height), @floatFromInt(gpu.TEX_LINEAR));
        if (tex_id == 0) return 0;
        dirty = true;
    }
    if (dirty) {
        if (gpu.stz_gpu_texture_write(tex_id, pixels.ptr, @floatFromInt(pixels.len)) != gpu.OK) return 0;
        upload_count += 1;
        dirty = false;
    }
    return tex_id;
}

pub fn atlasWidth() f64 {
    return @floatFromInt(width);
}

pub fn atlasHeight() f64 {
    return @floatFromInt(height);
}

test "shelf packing places entries without overlap and respects padding" {
    reset();
    try ensureBuffer();
    const a = packRect(10, 10).?;
    const b = packRect(10, 10).?;
    try std.testing.expect(a.x != b.x or a.y != b.y);
    try std.testing.expect(b.x >= a.x + 10 + PAD or b.y >= a.y + 10 + PAD);
    reset();
}
