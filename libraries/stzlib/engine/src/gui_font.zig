//! stz_gui's font half -- G2 of base/gui/SOFTANZA_GUI_PLAN.md.
//!
//! THE SAME gpu_text.zig that stz_gpu.dll carries, compiled a second time
//! into stz_gui.dll, exported over a tiny C ABI for the C++ font engine
//! in stz_rmlui.cpp. Two DLLs, two copies of the pipeline, ZERO cross-DLL
//! calls: RmlUi measures with this copy, the canvas paints with stz_gpu's
//! copy, and because both run the same source on the same font bytes at
//! the same size, widths and pixels agree by construction. A protocol
//! between the DLLs would have to be kept in agreement; identical code
//! cannot disagree.
//!
//! Everything here is CPU-side and device-free, like gpu_text itself.

const std = @import("std");
const gtext = @import("gpu_text.zig");

const c = @cImport({
    @cInclude("stb_truetype.h");
});

/// Load a font from memory. Returns gpu_text's gen-keyed id, 0 on refusal.
pub export fn stz_guifont_load(bytes: [*]const u8, len: i32) callconv(.c) i64 {
    if (len <= 0) return 0;
    return gtext.fontLoad(bytes[0..@intCast(len)]);
}

pub export fn stz_guifont_free(id: i64) callconv(.c) i32 {
    return gtext.fontFree(id);
}

/// Vertical metrics at a pixel size, from the SAME scaled font the widths
/// come from: out6 = [ascender, descender, lineGap, xHeight, 0, 0].
/// Descender is answered POSITIVE (a distance below the baseline).
/// x-height is measured from the lowercase 'x' glyph box -- RmlUi centres
/// inline content with it -- and falls back to size/2 when the face has
/// no 'x' (an icon font, the Arabic-only fixture).
pub export fn stz_guifont_metrics(id: i64, size_px: f64, out6: [*]f64) callconv(.c) i32 {
    // shape one space to borrow textLayout's metrics path (it sets the
    // hb scale and reads hb_font_get_h_extents for us)
    const layout = gtext.textLayout(id, " ", size_px) catch return gtext.BAD_ARG;
    defer layout.deinit();
    out6[0] = layout.ascender;
    out6[1] = layout.descender;
    out6[2] = layout.line_gap;
    out6[3] = size_px * 0.5;
    out6[4] = 0;
    out6[5] = 0;

    // x-height from stbtt's box of 'x', on the same em->px mapping
    if (gtext.stbttInfoOf(id)) |p| {
        const info: *const c.stbtt_fontinfo = @ptrCast(@alignCast(p));
        const scale = c.stbtt_ScaleForMappingEmToPixels(info, @floatCast(size_px));
        var x0: c_int = 0;
        var y0: c_int = 0;
        var x1: c_int = 0;
        var y1: c_int = 0;
        if (c.stbtt_GetCodepointBox(info, 'x', &x0, &y0, &x1, &y1) != 0) {
            out6[3] = @as(f64, @floatCast(scale)) * @as(f64, @floatFromInt(y1));
        }
    }
    return gtext.OK;
}

/// The shaped advance width of a UTF-8 string: SheenBidi reorder +
/// HarfBuzz shaping, exactly what the canvas will paint. THIS is what
/// replaces the stub's codepoints * size / 2.
pub export fn stz_guifont_width(id: i64, utf8: [*]const u8, len: i32, size_px: f64) callconv(.c) f64 {
    if (len <= 0) return 0;
    const layout = gtext.textLayout(id, utf8[0..@intCast(len)], size_px) catch return -1;
    defer layout.deinit();
    return layout.width;
}
