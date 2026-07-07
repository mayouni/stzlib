// Softanza Engine -- String Format/Structure Operations
//
// Structural transforms, formatting/presentation, and word-level
// operations. Extracted from string.zig as part of Phase D module
// separation.
//
// Categories:
//   Structural transforms: reverse, repeat, concat, copy, sort,
//     rotate, swap, mirror, repeat_each_char, repeat_to_length.
//   Formatting/presentation: spacify, bytes_per_char, frequency,
//     truncate, wrap, ensure prefix/suffix, filter, interleave,
//     surround, mask, slug, camel_to_words, initials, title_smart,
//     strip_tags, deduplicate_lines, number_lines, hide, chop,
//     scan_int, to_ordinal, abbreviate, wrap_with, char_frequency_top.
//   Word-level: reverse_words, sort_words, unique_words,
//     run_length_encode/decode, truncate_words, reverse_each_word.

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
const toExternal = core.toExternal;
const utf8CodepointCount = core.utf8CodepointCount;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const isVowelAscii = core.isVowelAscii;
const formatUsize = core.formatUsize;
const ciMatch = core.ciMatch;
const casefoldAlloc = core.casefoldAlloc;

// ─── Structural Transforms ─────────────────────────────────────

/// Reverse the codepoints in the string. Returns a new handle.
pub fn str_reverse(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return str_new();

        // Count codepoints to allocate offset array
        const cp_count = utf8CodepointCount(src);
        const offsets = gpa.alloc(usize, cp_count + 1) catch return str_new();
        defer gpa.free(offsets);

        // Fill offset array with byte positions of each codepoint
        var i: usize = 0;
        var idx: usize = 0;
        while (i < src.len) {
            offsets[idx] = i;
            idx += 1;
            const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch 1;
            i += cp_len;
        }
        offsets[idx] = src.len;

        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len) catch { setError(.out_of_memory); };

        // Walk codepoints in reverse order
        var k: usize = cp_count;
        while (k > 0) {
            k -= 1;
            const start = offsets[k];
            const end = offsets[k + 1];
            r.data.appendSlice(gpa, src[start..end]) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

/// Repeat the string `count` times. Returns a new handle.
pub fn str_repeat(handle: StzStringHandle, count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0 or count <= 0) return str_new();
        const n: usize = @intCast(count);
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * n) catch { setError(.out_of_memory); };
        for (0..n) |_| {
            r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

/// Concatenate two strings, returning a new handle.
pub fn str_concat(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (h1) |s1| result.data.appendSlice(gpa, s1.slice()) catch return null;
    if (h2) |s2| result.data.appendSlice(gpa, s2.slice()) catch return null;
    return result;
}

/// Copy a string. Returns a new handle.
pub fn str_copy(handle: StzStringHandle) callconv(.c) StzStringHandle {
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

pub fn str_sort_chars_asc(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    // Collect codepoints
    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        cps.append(gpa, cp_val) catch return null;
        off += cp_len;
    }

    // Sort ascending
    std.mem.sort(u21, cps.items, {}, std.sort.asc(u21));

    // Rebuild UTF-8
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var enc_buf: [4]u8 = undefined;
    for (cps.items) |cp| {
        const enc_len = std.unicode.utf8Encode(cp, &enc_buf) catch continue;
        result.data.appendSlice(gpa, enc_buf[0..enc_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_sort_chars_desc(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        cps.append(gpa, cp_val) catch return null;
        off += cp_len;
    }

    // Sort descending
    std.mem.sort(u21, cps.items, {}, std.sort.desc(u21));

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var enc_buf: [4]u8 = undefined;
    for (cps.items) |cp| {
        const enc_len = std.unicode.utf8Encode(cp, &enc_buf) catch continue;
        result.data.appendSlice(gpa, enc_buf[0..enc_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_repeat_char(cp: u32, count: c_int) callconv(.c) StzStringHandle {
    if (count <= 0) return str_new();

    var char_bytes: [4]u8 = undefined;
    const cp21: u21 = @intCast(cp);
    const char_len = std.unicode.utf8Encode(cp21, &char_bytes) catch return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const n: usize = @intCast(count);
    result.data.ensureTotalCapacity(gpa, n * char_len) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    for (0..n) |_| {
        result.data.appendSlice(gpa, char_bytes[0..char_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

/// Rotate codepoints left by `n` positions. Negative n rotates right.
/// Returns new handle with rotated string.
pub fn str_rotate(handle: StzStringHandle, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, src.len);

    // Count codepoints
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch break;
        if (i + cp_len > src.len) break;
        cp_count += 1;
        i += cp_len;
    }
    if (cp_count == 0) return str_from(src.ptr, src.len);

    // Normalize rotation amount
    const cpi: i64 = @intCast(cp_count);
    var rot: i64 = @rem(@as(i64, n), cpi);
    if (rot < 0) rot += cpi;
    if (rot == 0) return str_from(src.ptr, src.len);

    // Find byte offset of rotation point
    var off: usize = 0;
    var cp_idx: usize = 0;
    while (cp_idx < @as(usize, @intCast(rot)) and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        cp_idx += 1;
    }

    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src[off..]) catch {
        core.str_free(result);
        return null;
    };
    result.data.appendSlice(gpa, src[0..off]) catch {
        core.str_free(result);
        return null;
    };
    return result;
}

/// Repeat string to fill exactly `target_len` codepoints.
/// Returns new handle.
pub fn str_repeat_to_length(handle: StzStringHandle, target_len: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or target_len <= 0) return str_new();

    const target: usize = @intCast(target_len);

    // Count codepoints in source
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }
    if (cp_count == 0) return str_new();

    const result = str_new() orelse return null;
    var written: usize = 0;
    while (written < target) {
        const remaining = target - written;
        if (remaining >= cp_count) {
            // Append full copy
            result.data.appendSlice(gpa, src) catch break;
            written += cp_count;
        } else {
            // Append partial: walk `remaining` codepoints
            var poff: usize = 0;
            var pidx: usize = 0;
            while (pidx < remaining and poff < src.len) {
                const plen = std.unicode.utf8ByteSequenceLength(src[poff]) catch break;
                if (poff + plen > src.len) break;
                poff += plen;
                pidx += 1;
            }
            result.data.appendSlice(gpa, src[0..poff]) catch break;
            written += remaining;
        }
    }
    return result;
}

/// Swap characters at two codepoint positions (1-based from host, converted to 0-based internally). Returns new handle.
pub fn str_swap_chars(handle: StzStringHandle, pos1: c_int, pos2: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or pos1 < INDEX_BASE or pos2 < INDEX_BASE or pos1 == pos2) return str_from(src.ptr, src.len);

    const p1: usize = toInternal(@intCast(pos1));
    const p2: usize = toInternal(@intCast(pos2));

    // Build array of byte-offset ranges for each codepoint
    var offsets: [32768]struct { start: usize, len: usize } = undefined;
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len and cp_count < 32768) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        offsets[cp_count] = .{ .start = off, .len = cp_len };
        cp_count += 1;
        off += cp_len;
    }

    if (p1 >= cp_count or p2 >= cp_count) return str_from(src.ptr, src.len);

    const result = str_new() orelse return null;
    var idx: usize = 0;
    while (idx < cp_count) {
        const actual = if (idx == p1) p2 else if (idx == p2) p1 else idx;
        const o = offsets[actual];
        result.data.appendSlice(gpa, src[o.start..][0..o.len]) catch break;
        idx += 1;
    }
    return result;
}

/// Mirror/reflect: "abc" -> "abccba"
pub export fn str_mirror(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Append original
    result.data.appendSlice(gpa, src) catch return result;
    // Append reversed
    var off: usize = src.len;
    while (off > 0) {
        // Walk backwards to find start of previous codepoint
        off -= 1;
        while (off > 0 and (src[off] & 0xC0) == 0x80) {
            off -= 1;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        result.data.appendSlice(gpa, src[off .. off + cp_len]) catch break;
        if (off == 0) break;
    }
    return result;
}

/// Repeat each character n times: "abc", 2 -> "aabbcc"
pub export fn str_repeat_each_char(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (n <= 0) return result;
    const count: usize = @intCast(n);

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const ch = src[off .. off + cp_len];
        for (0..count) |_| {
            result.data.appendSlice(gpa, ch) catch break;
        }
        off += cp_len;
    }
    return result;
}

// ─── Formatting / Presentation ─────────────────────────────────

pub fn str_spacify(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (!first) {
            result.data.append(gpa, ' ') catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        first = false;
        off += cp_len;
    }
    return result;
}

pub fn str_bytes_per_char(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var first = true;
    var num_buf: [4]u8 = undefined;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (!first) {
            result.data.append(gpa, ' ') catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        // cp_len is 1..4, write as ASCII digit
        num_buf[0] = '0' + @as(u8, @intCast(cp_len));
        result.data.append(gpa, num_buf[0]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        first = false;
        off += cp_len;
    }
    return result;
}

/// Returns "char:count" pairs separated by newlines, e.g. "a:3\nb:2\n"
pub fn str_char_frequency(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    // Collect codepoints and count them
    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var counts: std.ArrayList(usize) = .{};
    defer counts.deinit(gpa);

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        off += cp_len;

        // Find if already tracked
        var found = false;
        for (cps.items, 0..) |existing, i| {
            if (existing == cp_val) {
                counts.items[i] += 1;
                found = true;
                break;
            }
        }
        if (!found) {
            cps.append(gpa, cp_val) catch break;
            counts.append(gpa, 1) catch break;
        }
    }

    // Build result string
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    for (cps.items, 0..) |cp_val, i| {
        var cp_bytes: [4]u8 = undefined;
        const cp_byte_len = std.unicode.utf8Encode(cp_val, &cp_bytes) catch continue;
        result.data.appendSlice(gpa, cp_bytes[0..cp_byte_len]) catch break;
        result.data.append(gpa, ':') catch break;

        // Number to string
        var num_buf2: [20]u8 = undefined;
        const num_str = std.fmt.bufPrint(&num_buf2, "{d}", .{counts.items[i]}) catch break;
        result.data.appendSlice(gpa, num_str) catch break;
        result.data.append(gpa, '\n') catch break;
    }
    return result;
}

pub fn str_truncate(handle: StzStringHandle, max_cp: c_int, ellipsis: [*c]const u8, ell_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (max_cp <= 0) return str_new();

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    var cut_off: usize = 0;
    const max: usize = @intCast(max_cp);
    while (off < buf.len) {
        if (cp_count == max) {
            cut_off = off;
            break;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_count += 1;
    }

    // If string fits, return copy
    if (cp_count <= max and off >= buf.len) return str_copy(handle);

    // Need truncation
    if (cut_off == 0) cut_off = off;
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[0..cut_off]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    if (ellipsis != null and ell_len > 0) {
        result.data.appendSlice(gpa, ellipsis[0..ell_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_wrap_at(handle: StzStringHandle, width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (width <= 0) return str_copy(handle);
    const w: usize = @intCast(width);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var line_cp: usize = 0;
    var last_space_result_pos: ?usize = null;
    var off: usize = 0;

    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;

        if (cp_val == '\n') {
            result.data.append(gpa, '\n') catch break;
            off += cp_len;
            line_cp = 0;
            last_space_result_pos = null;
            continue;
        }

        if (cp_val == ' ') {
            last_space_result_pos = result.data.items.len;
        }

        result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
        off += cp_len;
        line_cp += 1;

        if (line_cp >= w and last_space_result_pos != null) {
            // Replace last space with newline
            result.data.items[last_space_result_pos.?] = '\n';
            line_cp = result.data.items.len - last_space_result_pos.? - 1;
            last_space_result_pos = null;
        }
    }
    return result;
}

pub fn str_ensure_prefix_cs(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, case: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0) return str_copy(handle);
    const pfx: []const u8 = prefix[0..prefix_len];

    const has_prefix = if (case == 0) blk: {
        if (buf.len < pfx.len) break :blk false;
        break :blk core.ciMatch(buf[0..pfx.len], pfx);
    } else mem.startsWith(u8, buf, pfx);

    if (has_prefix) return str_copy(handle);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, pfx) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

pub fn str_ensure_prefix(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) StzStringHandle {
    return str_ensure_prefix_cs(handle, prefix, prefix_len, 1);
}

pub fn str_ensure_suffix_cs(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize, case: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0) return str_copy(handle);
    const sfx: []const u8 = suffix[0..suffix_len];

    const has_suffix = if (case == 0) blk: {
        if (buf.len < sfx.len) break :blk false;
        break :blk core.ciMatch(buf[buf.len - sfx.len ..], sfx);
    } else mem.endsWith(u8, buf, sfx);

    if (has_suffix) return str_copy(handle);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    result.data.appendSlice(gpa, sfx) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

pub fn str_ensure_suffix(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    return str_ensure_suffix_cs(handle, suffix, suffix_len, 1);
}

pub fn str_only_letters(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_letter(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

pub fn str_only_digits(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_digit(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

/// Interleave: place separator between each codepoint. "abc" with "," => "a,b,c"
pub fn str_interleave(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const separator = if (sep_len > 0) sep[0..sep_len] else return str_from(src.ptr, src.len);
    const r = str_new() orelse return null;
    var first = true;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (!first) {
            r.data.appendSlice(gpa, separator) catch { setError(.out_of_memory); };
        }
        r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        first = false;
        off += cp_len;
    }
    return r;
}

/// Wrap string with prefix and suffix: surround("hello", "[", "]") => "[hello]"
pub fn str_surround(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();

    const r = str_new() orelse return null;
    if (prefix_len > 0) r.data.appendSlice(gpa, prefix[0..prefix_len]) catch { setError(.out_of_memory); };
    r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    if (suffix_len > 0) r.data.appendSlice(gpa, suffix[0..suffix_len]) catch { setError(.out_of_memory); };
    return r;
}

/// Mask the string: replace middle characters with mask_char, keeping `keep` chars visible
/// at start and end. E.g. mask("hello@mail.com", '*', 2) -> "he*********om"
/// Returns new handle.
pub fn str_mask(handle: StzStringHandle, mask_char: [*c]const u8, mask_len: usize, keep: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or mask_len == 0) return str_from(src.ptr, src.len);

    const keep_n: usize = if (keep >= 0) @intCast(keep) else 0;
    const mask_s = mask_char[0..mask_len];

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count <= keep_n * 2) return str_from(src.ptr, src.len);

    const result = str_new() orelse return null;
    off = 0;
    var idx: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (idx < keep_n or idx >= cp_count - keep_n) {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        } else {
            result.data.appendSlice(gpa, mask_s) catch break;
        }
        idx += 1;
        off += cp_len;
    }
    return result;
}

/// Keep only ASCII vowels (a,e,i,o,u both cases). Returns new handle.
pub fn str_only_vowels(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            }
        }
        off += cp_len;
    }
    return result;
}

/// Convert to URL-friendly slug: lowercase, spaces/underscores to hyphens,
/// remove non-alphanumeric (except hyphens), collapse consecutive hyphens.
/// Returns new handle.
pub fn str_slug(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var prev_hyphen = true; // suppress leading hyphen
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                prev_hyphen = false;
            } else if ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9')) {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                prev_hyphen = false;
            } else if (c == ' ' or c == '_' or c == '-' or c == '\t') {
                if (!prev_hyphen) {
                    result.data.appendSlice(gpa, "-") catch break;
                    prev_hyphen = true;
                }
            }
            // else: skip non-alnum
        }
        // skip multi-byte codepoints for slug
        off += cp_len;
    }
    // Remove trailing hyphen
    const rsl = result.slice();
    if (rsl.len > 0 and rsl[rsl.len - 1] == '-') {
        _ = result.data.pop();
    }
    return result;
}

/// Split camelCase/PascalCase into space-separated words.
/// E.g. "camelCaseString" -> "camel Case String"
/// Returns new handle.
pub fn str_camel_to_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var i: usize = 0;
    while (i < src.len) {
        const c = src[i];
        // Insert space before uppercase that follows lowercase
        if (i > 0 and c >= 'A' and c <= 'Z') {
            const prev = src[i - 1];
            if (prev >= 'a' and prev <= 'z') {
                result.data.appendSlice(gpa, " ") catch break;
            } else if (prev >= 'A' and prev <= 'Z' and i + 1 < src.len and src[i + 1] >= 'a' and src[i + 1] <= 'z') {
                // ABCdef -> AB Cdef
                result.data.appendSlice(gpa, " ") catch break;
            }
        }
        result.data.appendSlice(gpa, src[i..][0..1]) catch break;
        i += 1;
    }
    return result;
}

/// Extract initials (first letter of each word). Words separated by spaces.
/// E.g. "Hello World" -> "HW", "united states of america" -> "usoa"
/// Returns new handle.
pub fn str_initials(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var in_word = false;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1 and (src[off] == ' ' or src[off] == '\t' or src[off] == '\n' or src[off] == '\r')) {
            in_word = false;
        } else {
            if (!in_word) {
                result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
                in_word = true;
            }
        }
        off += cp_len;
    }
    return result;
}

/// Smart titlecase: capitalize words except small words (the, a, an, of, in, on, at, to, for, and, but, or, is).
/// First word is always capitalized. Returns new handle.
pub fn str_title_smart(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const small_words = [_][]const u8{ "the", "a", "an", "of", "in", "on", "at", "to", "for", "and", "but", "or", "is" };

    const result = str_new() orelse return null;
    var off: usize = 0;
    var first_word = true;

    while (off < src.len) {
        // Skip spaces
        while (off < src.len and (src[off] == ' ' or src[off] == '\t')) {
            result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            off += 1;
        }
        if (off >= src.len) break;

        // Find word end
        const word_start = off;
        while (off < src.len and src[off] != ' ' and src[off] != '\t') off += 1;
        const word = src[word_start..off];

        if (first_word or !isSmallWord(word, &small_words)) {
            // Capitalize first letter
            if (word.len > 0 and word[0] >= 'a' and word[0] <= 'z') {
                result.data.appendSlice(gpa, &[_]u8{word[0] - 32}) catch break;
                if (word.len > 1) result.data.appendSlice(gpa, word[1..]) catch break;
            } else {
                result.data.appendSlice(gpa, word) catch break;
            }
        } else {
            result.data.appendSlice(gpa, word) catch break;
        }
        first_word = false;
    }
    return result;
}

fn isSmallWord(word: []const u8, small_words: []const []const u8) bool {
    // Compare lowercase
    var buf: [16]u8 = undefined;
    if (word.len > 16) return false;
    for (word, 0..) |c, i| {
        buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    const lower = buf[0..word.len];
    for (small_words) |sw| {
        if (mem.eql(u8, lower, sw)) return true;
    }
    return false;
}

/// Return the most frequent character as a single-char string. Ties: first in byte order.
pub export fn str_char_frequency_top(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;

    var freq: [256]u32 = [_]u32{0} ** 256;
    for (src) |c| {
        freq[c] += 1;
    }

    var max_idx: u8 = 0;
    var max_count: u32 = 0;
    for (0..256) |idx| {
        if (freq[idx] > max_count) {
            max_count = freq[idx];
            max_idx = @intCast(idx);
        }
    }
    result.data.appendSlice(gpa, &[_]u8{max_idx}) catch { setError(.out_of_memory); };
    return result;
}

/// Wrap string with prefix and suffix: wrap("hello", "[", "]") -> "[hello]"
pub export fn str_wrap_with(handle: ?*StzString, prefix: [*c]const u8, prefix_len: c_int, suffix: [*c]const u8, suffix_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const plen: usize = if (prefix_len >= 0) @intCast(prefix_len) else 0;
    const slen: usize = if (suffix_len >= 0) @intCast(suffix_len) else 0;

    result.data.appendSlice(gpa, prefix[0..plen]) catch { setError(.out_of_memory); };
    result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    result.data.appendSlice(gpa, suffix[0..slen]) catch { setError(.out_of_memory); };
    return result;
}

/// Abbreviate: produce a string of at most max_len total characters.
/// If the string is longer, truncate to (max_len - 3) characters + "...".
/// If max_len <= 3, just return "..." truncated to max_len.
pub export fn str_abbreviate(handle: ?*StzString, max_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const limit: usize = if (max_len >= 0) @intCast(max_len) else return result;

    // Count total codepoints
    const cp_count = utf8CodepointCount(src);

    if (cp_count <= limit) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    } else {
        // Truncate to (limit - 3) codepoints + "..."
        const text_len: usize = if (limit >= 3) limit - 3 else 0;
        var off: usize = 0;
        var cp_idx: usize = 0;
        while (off < src.len and cp_idx < text_len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
            if (off + cp_len > src.len) break;
            off += cp_len;
            cp_idx += 1;
        }
        result.data.appendSlice(gpa, src[0..off]) catch { setError(.out_of_memory); };
        result.data.appendSlice(gpa, "...") catch { setError(.out_of_memory); };
    }
    return result;
}

pub export fn str_strip_tags(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var in_tag = false;
    for (src) |c| {
        if (c == '<') {
            in_tag = true;
        } else if (c == '>') {
            in_tag = false;
        } else if (!in_tag) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

pub export fn str_to_slug(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var prev_was_dash = false;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') {
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_was_dash = false;
        } else if ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9')) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_dash = false;
        } else if (c == ' ' or c == '_' or c == '-' or c == '\t') {
            if (!prev_was_dash) {
                result.data.appendSlice(gpa, &[_]u8{'-'}) catch break;
                prev_was_dash = true;
            }
        }
        // skip other chars
    }
    // Remove trailing dash
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == '-') {
        _ = result.data.pop();
    }
    return result;
}

/// Deduplicate lines. case=1: exact comparison, case=0: casefold comparison.
pub export fn str_deduplicate_lines_cs(handle: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    if (case == 0) {
        // CI dedup using hashmap with casefolded keys
        var seen = std.StringHashMap(void).init(gpa);
        defer {
            var it = seen.keyIterator();
            while (it.next()) |key| gpa.free(key.*);
            seen.deinit();
        }
        var pos: usize = 0;
        var first = true;
        while (pos <= src.len) {
            const start = pos;
            while (pos < src.len and src[pos] != '\n') pos += 1;
            const line = src[start..pos];
            const folded = casefoldAlloc(line) orelse line;
            if (!seen.contains(folded)) {
                const owned = gpa.dupe(u8, folded) catch {
                    gpa.free(folded);
                    break;
                };
                seen.put(owned, {}) catch {
                    gpa.free(owned);
                    gpa.free(folded);
                    break;
                };
                if (!first) result.data.appendSlice(gpa, "\n") catch { setError(.out_of_memory); };
                result.data.appendSlice(gpa, line) catch { setError(.out_of_memory); };
                first = false;
            }
            gpa.free(folded);
            if (pos < src.len) pos += 1 else break;
        }
    } else {
        // CS dedup using O(n^2) scan for correctness
        var line_starts: [1024]usize = undefined;
        var line_ends: [1024]usize = undefined;
        var line_count: usize = 0;
        var pos: usize = 0;
        var first = true;
        while (pos <= src.len and line_count < 1024) {
            const start = pos;
            while (pos < src.len and src[pos] != '\n') pos += 1;
            const end = pos;
            var is_dup = false;
            const line = src[start..end];
            for (0..line_count) |li| {
                const prev = src[line_starts[li]..line_ends[li]];
                if (prev.len == line.len and mem.eql(u8, prev, line)) {
                    is_dup = true;
                    break;
                }
            }
            if (!is_dup) {
                if (!first) result.data.appendSlice(gpa, "\n") catch { setError(.out_of_memory); };
                result.data.appendSlice(gpa, line) catch { setError(.out_of_memory); };
                line_starts[line_count] = start;
                line_ends[line_count] = end;
                line_count += 1;
                first = false;
            }
            if (pos < src.len) pos += 1 else break;
        }
    }
    return result;
}

pub export fn str_deduplicate_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    return str_deduplicate_lines_cs(handle, 1);
}

pub export fn str_number_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var line_num: usize = 1;
    var pos: usize = 0;
    while (pos <= src.len) {
        // Write line number
        var buf: [12]u8 = undefined;
        const num_len = formatUsize(line_num, &buf);
        result.data.appendSlice(gpa, buf[0..num_len]) catch { setError(.out_of_memory); };
        result.data.appendSlice(gpa, ": ") catch { setError(.out_of_memory); };
        // Write line content
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        result.data.appendSlice(gpa, src[start..pos]) catch { setError(.out_of_memory); };
        if (pos < src.len) {
            result.data.appendSlice(gpa, "\n") catch { setError(.out_of_memory); };
            pos += 1;
            line_num += 1;
        } else break;
    }
    return result;
}

pub export fn str_hide(handle: ?*StzString, mask_char: u8, keep_first: c_int, keep_last: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const kf: usize = if (keep_first < 0) 0 else @intCast(keep_first);
    const kl: usize = if (keep_last < 0) 0 else @intCast(keep_last);
    if (kf + kl >= src.len) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        return result;
    }
    result.data.appendSlice(gpa, src[0..kf]) catch { setError(.out_of_memory); };
    var i: usize = kf;
    while (i < src.len - kl) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{mask_char}) catch break;
    }
    result.data.appendSlice(gpa, src[src.len - kl ..]) catch { setError(.out_of_memory); };
    return result;
}

pub export fn str_chop(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len > 0) {
        result.data.appendSlice(gpa, src[0 .. src.len - 1]) catch { setError(.out_of_memory); };
    }
    return result;
}

pub export fn str_scan_int(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var val: c_int = 0;
    var neg = false;
    var started = false;
    for (src) |c| {
        if (!started and c == '-') {
            neg = true;
            started = true;
        } else if (c >= '0' and c <= '9') {
            val = val * 10 + @as(c_int, c - '0');
            started = true;
        } else if (started) break;
    }
    return if (neg) -val else val;
}

// Parse the leading numeric token (optional sign, digits, one '.', optional
// exponent) to an f64; 0 on no number. Engine-backed StzNumber().
pub export fn str_to_number(handle: ?*StzString) callconv(.c) f64 {
    const s = handle orelse return 0;
    const src = s.slice();
    var i: usize = 0;
    while (i < src.len and (src[i] == ' ' or src[i] == '\t' or src[i] == '\n' or src[i] == '\r')) i += 1;
    const start = i;
    if (i < src.len and (src[i] == '-' or src[i] == '+')) i += 1;
    var seen_digit = false;
    var seen_dot = false;
    while (i < src.len) : (i += 1) {
        const c = src[i];
        if (c >= '0' and c <= '9') {
            seen_digit = true;
        } else if (c == '.' and !seen_dot) {
            seen_dot = true;
        } else break;
    }
    if (seen_digit and i < src.len and (src[i] == 'e' or src[i] == 'E')) {
        var j = i + 1;
        if (j < src.len and (src[j] == '-' or src[j] == '+')) j += 1;
        var exp_digit = false;
        while (j < src.len and src[j] >= '0' and src[j] <= '9') : (j += 1) exp_digit = true;
        if (exp_digit) i = j;
    }
    if (!seen_digit) return 0;
    return std.fmt.parseFloat(f64, src[start..i]) catch 0;
}

pub export fn str_to_ordinal(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src) catch return result;
    // Parse the number to determine suffix
    const num = str_scan_int(s);
    const abs_num: u32 = if (num < 0) @intCast(-num) else @intCast(num);
    const last_two = abs_num % 100;
    const last_one = abs_num % 10;
    if (last_two >= 11 and last_two <= 13) {
        result.data.appendSlice(gpa, "th") catch { setError(.out_of_memory); };
    } else if (last_one == 1) {
        result.data.appendSlice(gpa, "st") catch { setError(.out_of_memory); };
    } else if (last_one == 2) {
        result.data.appendSlice(gpa, "nd") catch { setError(.out_of_memory); };
    } else if (last_one == 3) {
        result.data.appendSlice(gpa, "rd") catch { setError(.out_of_memory); };
    } else {
        result.data.appendSlice(gpa, "th") catch { setError(.out_of_memory); };
    }
    return result;
}

// ─── Word-level Operations ─────────────────────────────────────

/// Reverse the order of words in the string. Words are whitespace-delimited.
/// Returns new handle.
pub fn str_reverse_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    // Collect word boundaries (start, end byte offsets)
    var words: [8192]struct { start: usize, end: usize } = undefined;
    var word_count: usize = 0;
    var off: usize = 0;
    var in_word = false;
    var word_start: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        const is_space = unicode.stz_unicode_is_space(cp_val) != 0;

        if (!is_space and !in_word) {
            word_start = off;
            in_word = true;
        } else if (is_space and in_word) {
            if (word_count < 8192) {
                words[word_count] = .{ .start = word_start, .end = off };
                word_count += 1;
            }
            in_word = false;
        }
        off += cp_len;
    }
    if (in_word and word_count < 8192) {
        words[word_count] = .{ .start = word_start, .end = off };
        word_count += 1;
    }

    if (word_count == 0) return str_from(src.ptr, src.len);

    const result = str_new() orelse return null;
    var i: usize = word_count;
    while (i > 0) {
        i -= 1;
        if (i < word_count - 1) {
            result.data.appendSlice(gpa, " ") catch break;
        }
        const w = words[i];
        result.data.appendSlice(gpa, src[w.start..w.end]) catch break;
    }
    return result;
}

/// Sort words alphabetically. case=1: byte order, case=0: casefold order.
pub export fn str_sort_words_cs(handle: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Collect word boundaries
    var words: [256][2]usize = undefined;
    var word_count: usize = 0;
    var i: usize = 0;
    while (i < src.len and word_count < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        const start = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        words[word_count] = .{ start, i };
        word_count += 1;
    }

    if (case == 0) {
        // CI sort: allocate folded keys, build index, sort by folded
        const folded = gpa.alloc([]const u8, word_count) catch return result;
        defer {
            for (folded[0..word_count]) |f| gpa.free(f);
            gpa.free(folded);
        }
        for (0..word_count) |idx| {
            folded[idx] = casefoldAlloc(src[words[idx][0]..words[idx][1]]) orelse src[words[idx][0]..words[idx][1]];
        }
        const indices = gpa.alloc(usize, word_count) catch return result;
        defer gpa.free(indices);
        for (0..word_count) |idx| indices[idx] = idx;

        const Ctx = struct {
            folded_keys: []const []const u8,
            fn lessThan(ctx: @This(), a: usize, b: usize) bool {
                return std.mem.order(u8, ctx.folded_keys[a], ctx.folded_keys[b]) == .lt;
            }
        };
        std.mem.sort(usize, indices, Ctx{ .folded_keys = folded }, Ctx.lessThan);

        for (indices[0..word_count], 0..) |idx, out_i| {
            if (out_i > 0) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, src[words[idx][0]..words[idx][1]]) catch break;
        }
    } else {
        // CS sort: insertion sort by raw byte order
        var j: usize = 1;
        while (j < word_count) : (j += 1) {
            const key = words[j];
            var k: usize = j;
            while (k > 0) {
                const w_k = src[words[k - 1][0]..words[k - 1][1]];
                const w_key = src[key[0]..key[1]];
                if (mem.order(u8, w_k, w_key) == .gt) {
                    words[k] = words[k - 1];
                    k -= 1;
                } else break;
            }
            words[k] = key;
        }

        for (0..word_count) |idx| {
            if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, src[words[idx][0]..words[idx][1]]) catch break;
        }
    }
    return result;
}

pub export fn str_sort_words(handle: ?*StzString) callconv(.c) ?*StzString {
    return str_sort_words_cs(handle, 1);
}

/// Keep only unique words (first occurrence preserved). case=1: exact, case=0: casefold dedup.
pub export fn str_unique_words_cs(handle: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    if (case == 0) {
        // CI dedup using hashmap with casefolded keys
        var seen = std.StringHashMap(void).init(gpa);
        defer {
            var it = seen.keyIterator();
            while (it.next()) |key| gpa.free(key.*);
            seen.deinit();
        }
        var first = true;
        var ii: usize = 0;
        while (ii < src.len) {
            while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
            if (ii >= src.len) break;
            const start = ii;
            while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
            const word = src[start..ii];
            const folded = casefoldAlloc(word) orelse word;
            if (!seen.contains(folded)) {
                const owned = gpa.dupe(u8, folded) catch {
                    gpa.free(folded);
                    break;
                };
                seen.put(owned, {}) catch {
                    gpa.free(owned);
                    gpa.free(folded);
                    break;
                };
                if (!first) result.data.appendSlice(gpa, " ") catch break;
                result.data.appendSlice(gpa, word) catch break;
                first = false;
            }
            gpa.free(folded);
        }
    } else {
        // CS dedup using O(n^2) scan
        var seen_starts: [256]usize = undefined;
        var seen_ends: [256]usize = undefined;
        var seen_count: usize = 0;
        var first = true;
        var ii: usize = 0;
        while (ii < src.len) {
            while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
            if (ii >= src.len) break;
            const start = ii;
            while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
            const word = src[start..ii];

            var found = false;
            for (0..seen_count) |si| {
                if (mem.eql(u8, src[seen_starts[si]..seen_ends[si]], word)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                if (!first) result.data.appendSlice(gpa, " ") catch break;
                result.data.appendSlice(gpa, word) catch break;
                if (seen_count < 256) {
                    seen_starts[seen_count] = start;
                    seen_ends[seen_count] = ii;
                    seen_count += 1;
                }
                first = false;
            }
        }
    }
    return result;
}

pub export fn str_unique_words(handle: ?*StzString) callconv(.c) ?*StzString {
    return str_unique_words_cs(handle, 1);
}

/// Run-length encode: "aaabbc" -> "3a2b1c"
pub export fn str_run_length_encode(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;

    var i: usize = 0;
    while (i < src.len) {
        const ch = src[i];
        var count: usize = 1;
        while (i + count < src.len and src[i + count] == ch) : (count += 1) {}
        // Write count as digits
        var buf: [20]u8 = undefined;
        var digits: usize = 0;
        var n = count;
        while (n > 0) {
            buf[digits] = @intCast('0' + (n % 10));
            digits += 1;
            n /= 10;
        }
        // Reverse digits into result
        var d: usize = digits;
        while (d > 0) {
            d -= 1;
            result.data.appendSlice(gpa, &[_]u8{buf[d]}) catch break;
        }
        result.data.appendSlice(gpa, &[_]u8{ch}) catch break;
        i += count;
    }
    return result;
}

/// Run-length decode: "3a2b1c" -> "aaabbc"
pub export fn str_run_length_decode(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var i: usize = 0;
    while (i < src.len) {
        // Parse number
        var count: usize = 0;
        while (i < src.len and src[i] >= '0' and src[i] <= '9') {
            count = count * 10 + (src[i] - '0');
            i += 1;
        }
        if (count == 0) count = 1;
        if (i >= src.len) break;
        const ch = src[i];
        i += 1;
        for (0..count) |_| {
            result.data.appendSlice(gpa, &[_]u8{ch}) catch break;
        }
    }
    return result;
}

pub export fn str_truncate_words(handle: ?*StzString, max_words: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const max: usize = if (max_words < 1) 0 else @intCast(max_words);
    const result = str_new() orelse return null;
    if (max == 0) return result;
    var word_count: usize = 0;
    var pos: usize = 0;
    var last_end: usize = 0;
    while (pos < src.len) {
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        if (word_count > 0) {
            // include the space before this word
        }
        const word_start = pos;
        _ = word_start;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        word_count += 1;
        last_end = pos;
        if (word_count >= max) break;
    }
    if (last_end > 0) {
        // Find start: skip leading spaces
        var start: usize = 0;
        while (start < src.len and src[start] == ' ') start += 1;
        result.data.appendSlice(gpa, src[start..last_end]) catch { setError(.out_of_memory); };
    }
    return result;
}

pub export fn str_reverse_each_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    while (pos < src.len) {
        if (src[pos] == ' ') {
            result.data.appendSlice(gpa, &[_]u8{' '}) catch break;
            pos += 1;
        } else {
            const start = pos;
            while (pos < src.len and src[pos] != ' ') pos += 1;
            // Reverse the word
            var j: usize = pos;
            while (j > start) {
                j -= 1;
                result.data.appendSlice(gpa, &[_]u8{src[j]}) catch break;
            }
        }
    }
    return result;
}

// ─── Substrings generation ────────────────────────────────────

/// Return all substrings joined by \x00 delimiter. O(n^2) substrings,
/// each generated by codepoint-aware slicing. CS variant (all substrings,
/// including duplicates). Ring splits on \x00 to get the list.
/// Return all substrings joined by \x00 delimiter.
/// case=1: case-sensitive (includes duplicates).
/// case=0: case-insensitive (unique substrings only, deduped by content).
pub export fn str_all_substrings_cs(handle: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_new();

    // Build codepoint offset table
    const cp_count = utf8CodepointCount(src);
    const offsets = gpa.alloc(usize, cp_count + 1) catch return null;
    defer gpa.free(offsets);
    var byte_off: usize = 0;
    var cp_idx: usize = 0;
    while (byte_off < src.len and cp_idx < cp_count) {
        offsets[cp_idx] = byte_off;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_off]) catch 1;
        byte_off += cp_len;
        cp_idx += 1;
    }
    offsets[cp_count] = src.len;

    // For CI mode: hash set for dedup
    var seen: ?std.StringHashMap(void) = if (case == 0)
        std.StringHashMap(void).init(gpa)
    else
        null;
    defer if (seen) |*m| m.deinit();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    // Pre-allocate for CS mode
    if (case == 1) {
        result.data.ensureTotalCapacity(gpa, src.len * cp_count) catch {};
    }

    var first = true;
    for (0..cp_count) |i| {
        for (i + 1..cp_count + 1) |j| {
            const sub = src[offsets[i]..offsets[j]];

            // CI: skip duplicates
            if (seen) |*m| {
                if (m.contains(sub)) continue;
                m.put(sub, {}) catch break;
            }

            if (!first) {
                result.data.append(gpa, 0) catch break;
            }
            result.data.appendSlice(gpa, sub) catch break;
            first = false;
        }
    }
    return result;
}


/// Return unique chars as \x00-delimited string.
/// case=1: case-sensitive (preserves original case).
/// case=0: case-insensitive (folds to lowercase before dedup).
pub export fn str_unique_chars_cs(handle: ?*StzString, case: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_new();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();

    var i: usize = 0;
    var first = true;
    while (i < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch {
            i += 1;
            continue;
        };
        if (i + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, i, cp_len);

        // Key for dedup: fold case when CI
        const key: i32 = if (case == 0 and unicode.stz_unicode_is_upper(cp_val) == 1)
            unicode.stz_unicode_to_lower(cp_val)
        else
            cp_val;

        if (!seen.contains(key)) {
            seen.put(key, {}) catch break;
            if (!first) {
                result.data.append(gpa, 0) catch break;
            }
            if (case == 0) {
                // CI: encode the folded (lowercased) codepoint
                var buf: [4]u8 = undefined;
                const folded_u21: u21 = @intCast(@as(u32, @intCast(key)));
                const enc_len = std.unicode.utf8Encode(folded_u21, &buf) catch {
                    i += cp_len;
                    continue;
                };
                result.data.appendSlice(gpa, buf[0..enc_len]) catch break;
            } else {
                // CS: keep original bytes
                const cp_end = @min(i + cp_len, src.len);
                result.data.appendSlice(gpa, src[i..cp_end]) catch break;
            }
            first = false;
        }
        i += cp_len;
    }
    return result;
}


/// Count of all substrings (n*(n+1)/2 for n codepoints).
pub export fn str_substrings_count(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const n: c_int = @intCast(utf8CodepointCount(src));
    return @divTrunc(n * (n + 1), 2);
}

/// Return all substrings of exactly `n` codepoints, joined by \x00.
/// O(cp_count) sliding window — replaces O(n^2) Ring loop.
pub export fn str_substrings_of_n_chars(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return core.str_from("", 0);
    const src = s.slice();
    if (src.len == 0 or n <= 0) return core.str_from("", 0);

    const cp_count = utf8CodepointCount(src);
    const wanted: usize = @intCast(n);
    if (wanted > cp_count) return core.str_from("", 0);

    // Build codepoint offset table
    var cp_offsets: [16384]usize = undefined;
    const offsets = if (cp_count + 1 <= 16384) cp_offsets[0 .. cp_count + 1] else blk: {
        break :blk gpa.alloc(usize, cp_count + 1) catch return core.str_from("", 0);
    };
    defer if (cp_count + 1 > 16384) gpa.free(offsets);

    var idx: usize = 0;
    var byte_pos: usize = 0;
    while (byte_pos < src.len) : (idx += 1) {
        offsets[idx] = byte_pos;
        const b = src[byte_pos];
        const seq_len: usize = if (b < 0x80) 1 else if (b < 0xE0) 2 else if (b < 0xF0) 3 else 4;
        byte_pos += seq_len;
    }
    offsets[idx] = byte_pos;

    const result_count = cp_count - wanted + 1;

    // Pre-allocate: each substring is up to wanted*4 bytes, plus \x00 delimiter
    const est_size = result_count * (wanted * 4 + 1);
    const out = gpa.alloc(u8, est_size) catch return core.str_from("", 0);
    defer gpa.free(out);

    var write_pos: usize = 0;
    for (0..result_count) |i| {
        if (i > 0) {
            out[write_pos] = 0;
            write_pos += 1;
        }
        const start = offsets[i];
        const end = offsets[i + wanted];
        const chunk = src[start..end];
        @memcpy(out[write_pos .. write_pos + chunk.len], chunk);
        write_pos += chunk.len;
    }

    return core.str_from(out.ptr, write_pos);
}

// ─── Tests ─────────────────────────────────────────────────────

test "format: substrings_of_n_chars" {
    const s = core.str_from("Hello", 5);
    defer core.str_free(s);

    // 2-char substrings of "Hello": "He", "el", "ll", "lo" = 4 items, 3 delimiters
    const r = str_substrings_of_n_chars(s, 2);
    defer core.str_free(r);
    const data = core.str_data(r);
    const size = core.str_size(r);
    if (data) |d| {
        const slice = d[0..size];
        // Count delimiters
        var delims: usize = 0;
        for (slice) |c| {
            if (c == 0) delims += 1;
        }
        try std.testing.expectEqual(@as(usize, 3), delims); // 4 items = 3 delimiters
    }
}

test "format: reverse ascii" {
    const s = str_from("hello", 5);
    const r = str_reverse(s);
    try std.testing.expectEqual(@as(usize, 5), core.str_size(r));
    try std.testing.expect(mem.eql(u8, core.str_data(r)[0..5], "olleh"));
    core.str_free(r);
    core.str_free(s);
}

test "format: repeat" {
    const s = str_from("ab", 2);
    const r = str_repeat(s, 3);
    try std.testing.expectEqual(@as(usize, 6), core.str_size(r));
    try std.testing.expect(mem.eql(u8, core.str_data(r)[0..6], "ababab"));
    core.str_free(r);
    core.str_free(s);
}

test "format: concat" {
    const h1 = str_from("Hello", 5);
    const h2 = str_from(" World", 6);
    const r = str_concat(h1, h2);
    try std.testing.expectEqual(@as(usize, 11), core.str_size(r));
    try std.testing.expect(mem.eql(u8, core.str_data(r)[0..11], "Hello World"));
    core.str_free(r);
    core.str_free(h1);
    core.str_free(h2);
}

test "format: slug" {
    const h = str_from("Hello World! Test", 17);
    const r = str_slug(h);
    try std.testing.expect(mem.eql(u8, core.str_data(r)[0..core.str_size(r)], "hello-world-test"));
    core.str_free(r);
    core.str_free(h);
}

test "format: sort_words" {
    const h = str_from("banana apple cherry", 19);
    const r = str_sort_words(h);
    try std.testing.expect(mem.eql(u8, core.str_data(r)[0..core.str_size(r)], "apple banana cherry"));
    core.str_free(r);
    core.str_free(h);
}

test "format: run_length_encode" {
    const h = str_from("aaabbc", 6);
    const r = str_run_length_encode(h);
    try std.testing.expect(mem.eql(u8, core.str_data(r)[0..core.str_size(r)], "3a2b1c"));
    core.str_free(r);
    core.str_free(h);
}

test "format: all_substrings_cs case=1" {
    const s = str_from("abc", 3);
    defer core.str_free(s);
    try std.testing.expectEqual(@as(c_int, 6), str_substrings_count(s));

    const r = str_all_substrings_cs(s, 1);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    const data = core.str_data(r.?)[0..core.str_size(r)];
    var delims: usize = 0;
    for (data) |b| {
        if (b == 0) delims += 1;
    }
    try std.testing.expectEqual(@as(usize, 5), delims);
}

test "format: all_substrings_cs case=0" {
    const s = str_from("aba", 3);
    defer core.str_free(s);
    const r = str_all_substrings_cs(s, 0);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    const data = core.str_data(r.?)[0..core.str_size(r)];
    var delims: usize = 0;
    for (data) |b| {
        if (b == 0) delims += 1;
    }
    try std.testing.expectEqual(@as(usize, 4), delims); // 5 unique - 1
}

test "format: unique_chars_cs case-insensitive" {
    const s = str_from("AaBbCc", 6);
    defer core.str_free(s);
    const r = str_unique_chars_cs(s, 0); // CI
    defer core.str_free(r);
    try std.testing.expect(r != null);
    // Should have 3 unique chars (a, b, c) separated by \x00
    const data = core.str_data(r.?)[0..core.str_size(r)];
    var delims: usize = 0;
    for (data) |b| {
        if (b == 0) delims += 1;
    }
    try std.testing.expectEqual(@as(usize, 2), delims); // 3 chars - 1
}

test "format: unique_chars_cs case-sensitive" {
    const s = str_from("AaBbCc", 6);
    defer core.str_free(s);
    const r = str_unique_chars_cs(s, 1); // CS
    defer core.str_free(r);
    try std.testing.expect(r != null);
    // Should have 6 unique chars (A, a, B, b, C, c) separated by \x00
    const data = core.str_data(r.?)[0..core.str_size(r)];
    var delims: usize = 0;
    for (data) |b| {
        if (b == 0) delims += 1;
    }
    try std.testing.expectEqual(@as(usize, 5), delims); // 6 chars - 1
}

// ─── str_only_punctuation ───

/// Keep only punctuation characters (Unicode categories Pc, Pd, Ps, Pe, Pi, Pf, Po).
/// Returns new handle.
pub fn str_only_punctuation(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_punctuation(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── str_only_symbols ───

/// Keep only symbol characters (Unicode categories Sm, Sc, Sk, So).
/// Returns new handle.
pub fn str_only_symbols(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_symbol(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── str_only_spaces ───

/// Keep only space/whitespace characters (Unicode category Zs + ASCII whitespace).
/// Returns new handle.
pub fn str_only_spaces(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_space(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── str_only_marks ───

/// Keep only mark characters (Unicode categories Mn, Mc, Me -- diacritics, combining marks).
/// Returns new handle.
pub fn str_only_marks(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_mark(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── str_only_controls ───

/// Keep only control characters (Unicode categories Cc, Cf).
/// Returns new handle.
pub fn str_only_controls(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_control(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── Tests for new str_only_* functions ───

test "format: only_punctuation" {
    const s = str_from("Hello, world! 42.", 17);
    defer core.str_free(s);
    const r = str_only_punctuation(s);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    const data = core.str_data(r.?)[0..core.str_size(r)];
    try std.testing.expectEqualStrings(",!.", data);
}

test "format: only_symbols" {
    const s = str_from("a+b=c $5", 8);
    defer core.str_free(s);
    const r = str_only_symbols(s);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    const data = core.str_data(r.?)[0..core.str_size(r)];
    // @ is Unicode Po (Punctuation, other), not a symbol
    try std.testing.expectEqualStrings("+=$", data);
}

test "format: only_spaces" {
    const s = str_from("a b\tc", 5);
    defer core.str_free(s);
    const r = str_only_spaces(s);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    const data = core.str_data(r.?)[0..core.str_size(r)];
    try std.testing.expectEqualStrings(" \t", data);
}

test "format: only_marks empty for ascii" {
    const s = str_from("Hello", 5);
    defer core.str_free(s);
    const r = str_only_marks(s);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 0), core.str_size(r));
}

test "format: only_controls" {
    const s = str_from("A\x01B\x02C", 5);
    defer core.str_free(s);
    const r = str_only_controls(s);
    defer core.str_free(r);
    try std.testing.expect(r != null);
    const data = core.str_data(r.?)[0..core.str_size(r)];
    try std.testing.expectEqualStrings("\x01\x02", data);
}

test "format: sort_words_cs CI" {
    const h = str_from("Banana apple Cherry", 19);
    const r = str_sort_words_cs(h, 0);
    try std.testing.expect(r != null);
    try std.testing.expect(core.mem.eql(u8, core.str_data(r.?)[0..core.str_size(r)], "apple Banana Cherry"));
    core.str_free(r);
    core.str_free(h);
}

test "format: unique_words_cs CI" {
    const h = str_from("Hello hello HELLO world", 23);
    const r = str_unique_words_cs(h, 0);
    try std.testing.expect(r != null);
    try std.testing.expect(core.mem.eql(u8, core.str_data(r.?)[0..core.str_size(r)], "Hello world"));
    core.str_free(r);
    core.str_free(h);
}

test "format: deduplicate_lines_cs CI" {
    const h = str_from("Hello\nhello\nWorld\nworld", 23);
    const r = str_deduplicate_lines_cs(h, 0);
    try std.testing.expect(r != null);
    try std.testing.expect(core.mem.eql(u8, core.str_data(r.?)[0..core.str_size(r)], "Hello\nWorld"));
    core.str_free(r);
    core.str_free(h);
}

test "format: ensure_prefix_cs CI" {
    const h = str_from("Hello World", 11);
    // CI: "hello" matches "Hello" prefix, so no change
    const r = str_ensure_prefix_cs(h, "hello", 5, 0);
    try std.testing.expect(r != null);
    try std.testing.expect(core.mem.eql(u8, core.str_data(r.?)[0..core.str_size(r)], "Hello World"));
    core.str_free(r);
    // CS: "hello" does NOT match "Hello", so prefix is added
    const r2 = str_ensure_prefix_cs(h, "hello", 5, 1);
    try std.testing.expect(r2 != null);
    try std.testing.expect(core.mem.eql(u8, core.str_data(r2.?)[0..core.str_size(r2)], "helloHello World"));
    core.str_free(r2);
    core.str_free(h);
}

test "format: ensure_suffix_cs CI" {
    const h = str_from("Hello World", 11);
    // CI: "WORLD" matches "World" suffix
    const r = str_ensure_suffix_cs(h, "WORLD", 5, 0);
    try std.testing.expect(r != null);
    try std.testing.expect(core.mem.eql(u8, core.str_data(r.?)[0..core.str_size(r)], "Hello World"));
    core.str_free(r);
    core.str_free(h);
}
