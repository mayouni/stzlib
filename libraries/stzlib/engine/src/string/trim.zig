// Softanza Engine -- String Trim/Pad/Alignment/Normalize (Phase D)
//
// Trim, pad, center, indent, dedent, squeeze, and whitespace
// normalization operations extracted from string.zig.
// All functions use C calling convention.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const setError = core.setError;
const str_new = core.str_new;
const str_from = core.str_from;
const decodeCodepoint = core.decodeCodepoint;
const INDEX_BASE = core.INDEX_BASE;
const toInternal = core.toInternal;
const utf8CodepointCount = core.utf8CodepointCount;

// ─── Local helpers ───

/// Return a copy of the string.
fn str_copy(handle: StzStringHandle) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

/// Check if a codepoint slice is present in a char set (UTF-8 string).
fn isInCharSet(cp_slice: []const u8, char_set: []const u8) bool {
    var off: usize = 0;
    while (off < char_set.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(char_set[off]) catch return false;
        if (off + cp_len > char_set.len) return false;
        if (cp_len == cp_slice.len and mem.eql(u8, char_set[off..][0..cp_len], cp_slice)) return true;
        off += cp_len;
    }
    return false;
}

// ─── Trim ───

/// Trim whitespace from the left (Unicode-aware). Returns a new handle.
/// Handles all Unicode whitespace: U+00A0, U+2003, U+3000, etc.
pub fn str_trim_left(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        var i: usize = 0;
        while (i < src.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(src, i, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) == 0) break;
            i += cp_len;
        }
        return str_from(src[i..].ptr, src.len - i);
    }
    return str_new();
}

/// Trim whitespace from the right (Unicode-aware). Returns a new handle.
/// Handles all Unicode whitespace: U+00A0, U+2003, U+3000, etc.
pub fn str_trim_right(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        var end: usize = src.len;
        while (end > 0) {
            // Walk backwards to find codepoint start
            var back = end - 1;
            while (back > 0 and (src[back] & 0xC0) == 0x80) back -= 1;
            const cp_len = std.unicode.utf8ByteSequenceLength(src[back]) catch 1;
            const cp_val: i32 = decodeCodepoint(src, back, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) == 0) break;
            end = back;
        }
        return str_from(src[0..end].ptr, end);
    }
    return str_new();
}

/// Trim whitespace from both ends. Returns new handle.
pub fn str_trim(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    // Find start
    var start: usize = 0;
    while (start < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[start]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, start, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) break;
        start += cp_len;
    }
    // Find end
    var end: usize = bytes.len;
    while (end > start) {
        // Walk backward to find start of last codepoint
        var back: usize = end - 1;
        while (back > start and (bytes[back] & 0xC0) == 0x80) back -= 1;
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[back]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, back, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) break;
        end = back;
    }
    return str_from(bytes[start..end].ptr, end - start);
}

/// Trim specific characters from both ends of the string.
/// `chars` is a UTF-8 string of characters to trim.
/// Returns new handle.
pub fn str_trim_chars(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);
    if (chars_len == 0) return str_from(src.ptr, @intCast(src.len));

    const trim_set = chars[0..chars_len];

    // Find start (skip leading chars in set)
    var start: usize = 0;
    while (start < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[start]) catch break;
        if (start + cp_len > src.len) break;
        const cp_slice = src[start..][0..cp_len];
        if (!isInCharSet(cp_slice, trim_set)) break;
        start += cp_len;
    }

    // Find end (skip trailing chars in set)
    var end: usize = src.len;
    while (end > start) {
        // Walk backwards to find start of last codepoint
        var back: usize = end - 1;
        while (back > start and (src[back] & 0xC0) == 0x80) back -= 1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[back]) catch break;
        if (back + cp_len != end) break;
        const cp_slice = src[back..][0..cp_len];
        if (!isInCharSet(cp_slice, trim_set)) break;
        end = back;
    }

    return str_from(src[start..].ptr, end - start);
}

// ─── Simplify ───

/// Simplify: trim whitespace from both ends, collapse internal whitespace runs to single space.
/// Also replaces tabs, CR, LF with spaces. Returns new handle.
pub fn str_simplify(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;

    // Skip leading whitespace
    var start: usize = 0;
    while (start < bytes.len) {
        const b = bytes[start];
        if (b == ' ' or b == '\t' or b == '\n' or b == '\r') {
            start += 1;
        } else if (b < 128) {
            break;
        } else {
            // Check Unicode whitespace
            const cp_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, start, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                start += cp_len;
            } else break;
        }
    }

    // Find end (skip trailing whitespace)
    var end: usize = bytes.len;
    while (end > start) {
        const b = bytes[end - 1];
        if (b == ' ' or b == '\t' or b == '\n' or b == '\r') {
            end -= 1;
        } else break;
    }

    // Process content: collapse whitespace runs to single space
    var i: usize = start;
    var in_space = false;
    while (i < end) {
        const b = bytes[i];
        const is_ws = (b == ' ' or b == '\t' or b == '\n' or b == '\r');
        if (is_ws) {
            if (!in_space) {
                result.data.appendSlice(gpa, " ") catch break;
                in_space = true;
            }
            i += 1;
        } else if (b >= 128) {
            const cp_len = std.unicode.utf8ByteSequenceLength(b) catch 1;
            const cp_end = @min(i + cp_len, end);
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                if (!in_space) {
                    result.data.appendSlice(gpa, " ") catch break;
                    in_space = true;
                }
            } else {
                result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
                in_space = false;
            }
            i += cp_len;
        } else {
            result.data.appendSlice(gpa, bytes[i .. i + 1]) catch break;
            in_space = false;
            i += 1;
        }
    }
    return result;
}

// ─── Pad ───

/// Pad the string on the left to reach `target_cp_count` codepoints,
/// using `pad_char` (a UTF-8 encoded codepoint) as fill.
pub fn str_pad_left(handle: StzStringHandle, target_cp_count: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const current_cp = utf8CodepointCount(src);
        const target: usize = if (target_cp_count > 0) @intCast(target_cp_count) else 0;
        if (current_cp >= target) {
            return str_from(src.ptr, src.len);
        }
        const pad_needed = target - current_cp;
        const pad_slice = if (pad_char != null and pad_len > 0) pad_char[0..pad_len] else " ";
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len + pad_needed * pad_slice.len) catch {
            setError(.out_of_memory);
        };
        for (0..pad_needed) |_| {
            r.data.appendSlice(gpa, pad_slice) catch {
                setError(.out_of_memory);
            };
        }
        r.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
        };
        return r;
    }
    return str_new();
}

/// Pad the string on the right to reach `target_cp_count` codepoints,
/// using `pad_char` (a UTF-8 encoded codepoint) as fill.
pub fn str_pad_right(handle: StzStringHandle, target_cp_count: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const current_cp = utf8CodepointCount(src);
        const target: usize = if (target_cp_count > 0) @intCast(target_cp_count) else 0;
        if (current_cp >= target) {
            return str_from(src.ptr, src.len);
        }
        const pad_needed = target - current_cp;
        const pad_slice = if (pad_char != null and pad_len > 0) pad_char[0..pad_len] else " ";
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len + pad_needed * pad_slice.len) catch {
            setError(.out_of_memory);
        };
        r.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
        };
        for (0..pad_needed) |_| {
            r.data.appendSlice(gpa, pad_slice) catch {
                setError(.out_of_memory);
            };
        }
        return r;
    }
    return str_new();
}

// ─── Center ───

pub fn str_center(handle: StzStringHandle, target_width: c_int, pad_char: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const tw: usize = if (target_width >= 0) @intCast(target_width) else return null;

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count >= tw) {
        // Already wide enough, return copy
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        result.data.appendSlice(gpa, buf) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        return result;
    }

    const total_pad = tw - cp_count;
    const left_pad_count = total_pad / 2;
    const right_pad_count = total_pad - left_pad_count;

    var pad_bytes: [4]u8 = undefined;
    const pad_cp: u21 = @intCast(pad_char);
    const pad_len = std.unicode.utf8Encode(pad_cp, &pad_bytes) catch return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    // Left padding
    for (0..left_pad_count) |_| {
        result.data.appendSlice(gpa, pad_bytes[0..pad_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    // Content
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    // Right padding
    for (0..right_pad_count) |_| {
        result.data.appendSlice(gpa, pad_bytes[0..pad_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_center_pad(handle: StzStringHandle, width: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const w: usize = if (width > 0) @intCast(width) else return str_from(src.ptr, src.len);

    // Get codepoint count of source
    const cp_count = utf8CodepointCount(src);
    if (cp_count >= w) return str_from(src.ptr, src.len);

    // Get pad codepoint (first codepoint from pad_char)
    if (pad_char == null or pad_len == 0) return str_from(src.ptr, src.len);
    const pad_bytes: []const u8 = pad_char[0..pad_len];

    const total_pad = w - cp_count;
    const left_pad_count = total_pad / 2;
    const right_pad_count = total_pad - left_pad_count;

    const r = str_new() orelse return null;
    r.data.ensureTotalCapacity(gpa, src.len + total_pad * pad_len) catch {
        setError(.out_of_memory);
    };

    // Add left padding
    for (0..left_pad_count) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {
            setError(.out_of_memory);
        };
    }
    // Add source
    r.data.appendSlice(gpa, src) catch {
        setError(.out_of_memory);
    };
    // Add right padding
    for (0..right_pad_count) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {
            setError(.out_of_memory);
        };
    }

    return r;
}

// ─── ZFill ───

pub fn str_zfill(handle: StzStringHandle, width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (width <= 0) return str_copy(handle);
    const w: usize = @intCast(width);

    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_count += 1;
    }

    if (cp_count >= w) return str_copy(handle);

    const pad_count = w - cp_count;
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    for (0..pad_count) |_| {
        result.data.append(gpa, '0') catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── Left/Right Justify ───

pub fn str_ljust(handle: StzStringHandle, width: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    // Left-justify: content on left, padding on right
    const s = handle orelse return str_new();
    const src = s.slice();
    const w: usize = if (width > 0) @intCast(width) else return str_from(src.ptr, src.len);

    const cp_count = utf8CodepointCount(src);
    if (cp_count >= w) return str_from(src.ptr, src.len);

    if (pad_char == null or pad_len == 0) return str_from(src.ptr, src.len);
    const pad_bytes: []const u8 = pad_char[0..pad_len];

    const r = str_new() orelse return null;
    r.data.appendSlice(gpa, src) catch {
        setError(.out_of_memory);
    };
    const needed = w - cp_count;
    for (0..needed) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {
            setError(.out_of_memory);
        };
    }
    return r;
}

pub fn str_rjust(handle: StzStringHandle, width: c_int, pad_char: [*c]const u8, pad_len: usize) callconv(.c) StzStringHandle {
    // Right-justify: padding on left, content on right
    const s = handle orelse return str_new();
    const src = s.slice();
    const w: usize = if (width > 0) @intCast(width) else return str_from(src.ptr, src.len);

    const cp_count = utf8CodepointCount(src);
    if (cp_count >= w) return str_from(src.ptr, src.len);

    if (pad_char == null or pad_len == 0) return str_from(src.ptr, src.len);
    const pad_bytes: []const u8 = pad_char[0..pad_len];

    const r = str_new() orelse return null;
    const needed = w - cp_count;
    for (0..needed) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch {
            setError(.out_of_memory);
        };
    }
    r.data.appendSlice(gpa, src) catch {
        setError(.out_of_memory);
    };
    return r;
}

// ─── Simple left/right pad (pub export) ───

pub export fn str_left_pad(handle: ?*StzString, width: c_int, pad_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const w: usize = if (width < 0) 0 else @intCast(width);
    const result = str_new() orelse return null;
    if (src.len >= w) {
        result.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
        };
        return result;
    }
    const pad_count = w - src.len;
    var i: usize = 0;
    while (i < pad_count) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{pad_char}) catch break;
    }
    result.data.appendSlice(gpa, src) catch {
        setError(.out_of_memory);
    };
    return result;
}

pub export fn str_right_pad(handle: ?*StzString, width: c_int, pad_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const w: usize = if (width < 0) 0 else @intCast(width);
    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src) catch {
        setError(.out_of_memory);
    };
    if (src.len >= w) return result;
    const pad_count = w - src.len;
    var i: usize = 0;
    while (i < pad_count) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{pad_char}) catch break;
    }
    return result;
}

// ─── Indent / Dedent ───

pub fn str_indent(handle: StzStringHandle, spaces: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const n: usize = if (spaces > 0) @intCast(spaces) else return str_from(src.ptr, src.len);

    const r = str_new() orelse return null;
    r.data.ensureTotalCapacity(gpa, src.len + src.len / 10 * n) catch {
        setError(.out_of_memory);
    };

    // Add indent before first line
    for (0..n) |_| {
        r.data.append(gpa, ' ') catch {
            setError(.out_of_memory);
        };
    }

    for (src) |byte| {
        r.data.append(gpa, byte) catch {
            setError(.out_of_memory);
        };
        if (byte == '\n') {
            // Add indent after each newline
            for (0..n) |_| {
                r.data.append(gpa, ' ') catch {
                    setError(.out_of_memory);
                };
            }
        }
    }
    return r;
}

pub fn str_dedent(handle: StzStringHandle) callconv(.c) StzStringHandle {
    // Remove common leading whitespace from all lines
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    // Find minimum indentation across non-empty lines
    var min_indent: usize = std.math.maxInt(usize);
    var line_start: usize = 0;
    var i: usize = 0;
    while (i <= src.len) : (i += 1) {
        if (i == src.len or src[i] == '\n') {
            const line = src[line_start..i];
            if (line.len > 0) {
                var indent: usize = 0;
                for (line) |c| {
                    if (c == ' ' or c == '\t') {
                        indent += 1;
                    } else break;
                }
                if (indent < line.len) { // non-whitespace-only line
                    min_indent = @min(min_indent, indent);
                }
            }
            line_start = i + 1;
        }
    }

    if (min_indent == std.math.maxInt(usize) or min_indent == 0) {
        return str_from(src.ptr, src.len);
    }

    // Rebuild with indentation removed
    const r = str_new() orelse return null;
    line_start = 0;
    i = 0;
    while (i <= src.len) : (i += 1) {
        if (i == src.len or src[i] == '\n') {
            const line = src[line_start..i];
            if (line.len > min_indent) {
                r.data.appendSlice(gpa, line[min_indent..]) catch {
                    setError(.out_of_memory);
                };
            }
            if (i < src.len) {
                r.data.append(gpa, '\n') catch {
                    setError(.out_of_memory);
                };
            }
            line_start = i + 1;
        }
    }
    return r;
}

// ─── Tab Expand ───

pub fn str_tab_expand(handle: StzStringHandle, tab_width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (tab_width <= 0) return str_copy(handle);
    const tw: usize = @intCast(tab_width);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    for (buf) |byte| {
        if (byte == '\t') {
            for (0..tw) |_| {
                result.data.append(gpa, ' ') catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
            }
        } else {
            result.data.append(gpa, byte) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
    }
    return result;
}

pub export fn str_expand_tabs(handle: ?*StzString, tab_size: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const ts: usize = if (tab_size < 1) 4 else @intCast(tab_size);
    const result = str_new() orelse return null;
    for (src) |c| {
        if (c == '\t') {
            var j: usize = 0;
            while (j < ts) : (j += 1) {
                result.data.appendSlice(gpa, " ") catch break;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// ─── Collapse / Normalize Spaces ───

/// Collapse multiple consecutive spaces/whitespace to a single space.
/// Also trims leading/trailing whitespace. Returns new handle.
pub fn str_collapse_spaces(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var off: usize = 0;
    var prev_was_space = true; // treat start as space to trim leading

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        const is_space = unicode.stz_unicode_is_space(cp_val) != 0;

        if (is_space) {
            if (!prev_was_space) {
                result.data.appendSlice(gpa, " ") catch break;
            }
            prev_was_space = true;
        } else {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
            prev_was_space = false;
        }
        off += cp_len;
    }

    // Trim trailing space
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == ' ') {
        _ = result.data.pop();
    }
    return result;
}

pub export fn str_normalize_spaces(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var prev_space = true; // treat start as space to trim leading
    for (src) |c| {
        if (c == ' ' or c == '\t') {
            if (!prev_space) {
                result.data.appendSlice(gpa, &[_]u8{' '}) catch break;
                prev_space = true;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_space = false;
        }
    }
    // Remove trailing space
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == ' ') {
        _ = result.data.pop();
    }
    return result;
}

// ─── Squeeze ───

/// Reduce all runs of consecutive identical codepoints to a single codepoint.
pub fn str_squeeze(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const r = str_new() orelse return null;
    var prev_cp: u32 = 0;
    var off: usize = 0;
    var first = true;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (first or cp != prev_cp) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {
                setError(.out_of_memory);
            };
            prev_cp = cp;
            first = false;
        }
        off += cp_len;
    }
    return r;
}

pub fn str_squeeze_char(handle: StzStringHandle, cp: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var prev_was_target = false;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == cp) {
            if (!prev_was_target) {
                result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
                prev_was_target = true;
            }
        } else {
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
            prev_was_target = false;
        }
        off += cp_len;
    }
    return result;
}

// ─── Tests ───

const testing = std.testing;
const str_free = core.str_free;

fn h(comptime s: []const u8) StzStringHandle {
    return str_from(s.ptr, s.len);
}

fn expectStr(handle: StzStringHandle, expected: []const u8) !void {
    const s = handle orelse return error.TestUnexpectedResult;
    defer str_free(s);
    try testing.expectEqualSlices(u8, expected, s.slice());
}

test "str_trim_left: removes leading whitespace" {
    const s = h("   hello");
    defer str_free(s);
    try expectStr(str_trim_left(s), "hello");
}

test "str_trim_left: no leading whitespace unchanged" {
    const s = h("hello   ");
    defer str_free(s);
    try expectStr(str_trim_left(s), "hello   ");
}

test "str_trim_right: removes trailing whitespace" {
    const s = h("hello   ");
    defer str_free(s);
    try expectStr(str_trim_right(s), "hello");
}

test "str_trim_right: no trailing whitespace unchanged" {
    const s = h("   hello");
    defer str_free(s);
    try expectStr(str_trim_right(s), "   hello");
}

test "str_trim: removes both ends" {
    const s = h("  hello  ");
    defer str_free(s);
    try expectStr(str_trim(s), "hello");
}

test "str_trim: tabs and newlines" {
    const s = h("\t\nhello\n\t");
    defer str_free(s);
    try expectStr(str_trim(s), "hello");
}

test "str_trim: all whitespace returns empty" {
    const s = h("   \t\n  ");
    defer str_free(s);
    try expectStr(str_trim(s), "");
}

test "str_trim: null handle returns null" {
    const r = str_trim(null);
    try testing.expectEqual(@as(StzStringHandle, null), r);
}

test "str_trim_chars: custom characters" {
    const s = h("***hello***");
    defer str_free(s);
    try expectStr(str_trim_chars(s, "*", 1), "hello");
}

test "str_trim_chars: multi-char set" {
    const s = h("+-hello-+");
    defer str_free(s);
    try expectStr(str_trim_chars(s, "+-", 2), "hello");
}

test "str_trim_chars: empty set unchanged" {
    const s = h("hello");
    defer str_free(s);
    try expectStr(str_trim_chars(s, "", 0), "hello");
}

test "str_simplify: collapse internal whitespace" {
    const s = h("  hello   world  ");
    defer str_free(s);
    try expectStr(str_simplify(s), "hello world");
}

test "str_simplify: tabs and newlines become spaces" {
    const s = h("hello\t\tworld\n\nfoo");
    defer str_free(s);
    try expectStr(str_simplify(s), "hello world foo");
}

test "str_pad_left: zero-padded number" {
    const s = h("42");
    defer str_free(s);
    try expectStr(str_pad_left(s, 5, "0", 1), "00042");
}

test "str_pad_left: already wide enough" {
    const s = h("hello");
    defer str_free(s);
    try expectStr(str_pad_left(s, 3, " ", 1), "hello");
}

test "str_pad_right: space padding" {
    const s = h("hi");
    defer str_free(s);
    try expectStr(str_pad_right(s, 5, ".", 1), "hi...");
}

test "str_center_pad: center with dots" {
    const s = h("hi");
    defer str_free(s);
    try expectStr(str_center_pad(s, 6, ".", 1), "..hi..");
}

test "str_center_pad: odd padding favors right" {
    const s = h("x");
    defer str_free(s);
    try expectStr(str_center_pad(s, 4, "-", 1), "-x--");
}

test "str_zfill: zero-fill" {
    const s = h("7");
    defer str_free(s);
    try expectStr(str_zfill(s, 4), "0007");
}

test "str_zfill: already long enough" {
    const s = h("12345");
    defer str_free(s);
    try expectStr(str_zfill(s, 3), "12345");
}

test "str_ljust: left justify" {
    const s = h("hi");
    defer str_free(s);
    try expectStr(str_ljust(s, 5, " ", 1), "hi   ");
}

test "str_rjust: right justify" {
    const s = h("hi");
    defer str_free(s);
    try expectStr(str_rjust(s, 5, " ", 1), "   hi");
}

test "str_left_pad: byte-level padding" {
    const s = h("42");
    defer str_free(s);
    try expectStr(str_left_pad(s, 5, '0'), "00042");
}

test "str_right_pad: byte-level padding" {
    const s = h("hi");
    defer str_free(s);
    try expectStr(str_right_pad(s, 5, '.'), "hi...");
}

test "str_indent: add indentation" {
    const s = h("line1\nline2");
    defer str_free(s);
    try expectStr(str_indent(s, 4), "    line1\n    line2");
}

test "str_dedent: remove common indentation" {
    const s = h("    line1\n    line2\n    line3");
    defer str_free(s);
    try expectStr(str_dedent(s), "line1\nline2\nline3");
}

test "str_dedent: mixed indentation" {
    const s = h("    deep\n  shallow\n      deeper");
    defer str_free(s);
    try expectStr(str_dedent(s), "  deep\nshallow\n    deeper");
}

test "str_tab_expand: tabs to spaces" {
    const s = h("a\tb\tc");
    defer str_free(s);
    try expectStr(str_tab_expand(s, 4), "a    b    c");
}

test "str_expand_tabs: export variant" {
    const s = h("x\ty");
    defer str_free(s);
    try expectStr(str_expand_tabs(s, 2), "x  y");
}

test "str_collapse_spaces: multiple spaces to one" {
    const s = h("  hello    world  ");
    defer str_free(s);
    try expectStr(str_collapse_spaces(s), "hello world");
}

test "str_normalize_spaces: tabs collapse" {
    const s = h("  hello\t\tworld  ");
    defer str_free(s);
    try expectStr(str_normalize_spaces(s), "hello world");
}

test "str_squeeze: collapse all runs" {
    const s = h("aaabbbccc");
    defer str_free(s);
    try expectStr(str_squeeze(s), "abc");
}

test "str_squeeze: mixed content" {
    const s = h("aabbcc  dd");
    defer str_free(s);
    try expectStr(str_squeeze(s), "abc d");
}

test "str_squeeze_char: specific character" {
    const s = h("aaabbbccc");
    defer str_free(s);
    try expectStr(str_squeeze_char(s, 'a'), "abbbccc");
}

test "str_squeeze_char: spaces only" {
    const s = h("hello   world");
    defer str_free(s);
    try expectStr(str_squeeze_char(s, ' '), "hello world");
}
