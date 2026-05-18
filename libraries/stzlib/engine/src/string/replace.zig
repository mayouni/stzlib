// Softanza Engine -- String Replace/Remove/Insert/Strip (Phase D)
//
// Replace, remove, insert, strip, and filter operations extracted
// from string.zig. All functions use C calling convention.

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
const str_free = core.str_free;
const str_data = core.str_data;
const str_size = core.str_size;
const INDEX_BASE = core.INDEX_BASE;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const casefoldAlloc = core.casefoldAlloc;
const decodeCodepoint = core.decodeCodepoint;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const utf8CodepointCount = core.utf8CodepointCount;
const isVowelAscii = core.isVowelAscii;

// ─── Local helpers ───

/// Return a copy of the string. Used by remove functions when no match is found.
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

// ═══════════════════════════════════════════════════════════════
// ─── REPLACE ─────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════

// ─── ReplaceRange: replace codepoint range with new content ───
// start_cp: 1-based from host (converted to 0-based internally via toInternal)
// cp_count: number of codepoints to replace

pub fn str_replace_range(handle: StzStringHandle, start_cp: usize, cp_count: usize, new: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        if (hay.len == 0) return str_from(hay.ptr, hay.len);

        const internal_start = toInternal(@intCast(start_cp));

        // Find byte position of start codepoint
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < internal_start) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        const byte_start = byte_pos;

        // Find byte position of end (start + cp_count codepoints)
        var replaced: usize = 0;
        while (byte_pos < hay.len and replaced < cp_count) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            replaced += 1;
        }
        const byte_end = byte_pos;

        const result_len = byte_start + new_len + (hay.len - byte_end);
        const out = gpa.create(StzString) catch return null;
        out.* = StzString.init();
        out.data.ensureTotalCapacity(gpa, result_len) catch {
            out.deinit();
            gpa.destroy(out);
            return null;
        };
        out.data.appendSlice(gpa, hay[0..byte_start]) catch unreachable;
        if (new != null and new_len > 0) {
            out.data.appendSlice(gpa, new[0..new_len]) catch unreachable;
        }
        if (byte_end < hay.len) {
            out.data.appendSlice(gpa, hay[byte_end..]) catch unreachable;
        }
        return out;
    }
    return null;
}

// ─── ReplaceCS: in-place mutation with case sensitivity ───

/// Unified replace with case sensitivity parameter (in-place mutation).
pub fn str_replace_cs(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new: [*c]const u8, new_len: usize, case: c_int) callconv(.c) void {
    if (handle) |s| {
        if (old == null or old_len == 0) return;
        const old_slice = old[0..old_len];
        const new_slice = if (new != null and new_len > 0) new[0..new_len] else "";
        const src = s.slice();

        if (case == 0) {
            // Case-insensitive: casefold for matching, copy from original
            const src_folded = casefoldAlloc(src) orelse return;
            defer gpa.free(src_folded);
            const old_folded = casefoldAlloc(old_slice) orelse return;
            defer gpa.free(old_folded);

            var result: std.ArrayList(u8) = .{};
            var pos: usize = 0;
            var fpos: usize = 0;

            while (pos <= src.len and fpos <= src_folded.len) {
                if (fpos + old_folded.len <= src_folded.len and
                    mem.eql(u8, src_folded[fpos..][0..old_folded.len], old_folded))
                {
                    result.appendSlice(gpa, new_slice) catch return;
                    pos += old_len;
                    fpos += old_folded.len;
                } else if (pos < src.len) {
                    const cp_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
                    const fcp_len = if (fpos < src_folded.len)
                        std.unicode.utf8ByteSequenceLength(src_folded[fpos]) catch 1
                    else
                        1;
                    result.appendSlice(gpa, src[pos..@min(pos + cp_len, src.len)]) catch return;
                    pos += cp_len;
                    fpos += fcp_len;
                } else {
                    break;
                }
            }

            s.data.deinit(gpa);
            s.data = result;
            s.invalidateCache();
        } else {
            // Case-sensitive: direct comparison
            var result: std.ArrayList(u8) = .{};
            var pos: usize = 0;

            while (pos <= src.len) {
                if (pos + old_len <= src.len and mem.eql(u8, src[pos..][0..old_len], old_slice)) {
                    result.appendSlice(gpa, new_slice) catch return;
                    pos += old_len;
                } else if (pos < src.len) {
                    result.append(gpa, src[pos]) catch return;
                    pos += 1;
                } else {
                    break;
                }
            }

            s.data.deinit(gpa);
            s.data = result;
            s.invalidateCache();
        }
    }
}

pub fn str_replace(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new: [*c]const u8, new_len: usize) callconv(.c) void {
    str_replace_cs(handle, old, old_len, new, new_len, 1);
}

// ─── ReplaceFirst: replace only the first occurrence ───

/// Replace only the first occurrence of `old` with `new_str`. Returns new handle.
pub fn str_replace_first(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new_str: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const needle = old[0..old_len];
        const replacement = new_str[0..new_len];
        if (mem.indexOf(u8, haystack, needle)) |pos| {
            const result = str_new() orelse return null;
            result.data.appendSlice(gpa, haystack[0..pos]) catch return null;
            result.data.appendSlice(gpa, replacement) catch return null;
            result.data.appendSlice(gpa, haystack[pos + old_len ..]) catch return null;
            return result;
        }
        // No match: return copy
        return str_from(s.data.items.ptr, haystack.len);
    }
    return null;
}

// ─── ReplaceLast: replace only the last occurrence ───

/// Replace only the last occurrence of `old` with `new_str`. Returns new handle.
pub fn str_replace_last(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new_str: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const needle = old[0..old_len];
        const replacement = new_str[0..new_len];
        // Find last occurrence by scanning forward
        var last_pos: ?usize = null;
        var search_from: usize = 0;
        while (search_from <= haystack.len) {
            if (mem.indexOfPos(u8, haystack, search_from, needle)) |pos| {
                last_pos = pos;
                search_from = pos + 1;
            } else break;
        }
        if (last_pos) |pos| {
            const result = str_new() orelse return null;
            result.data.appendSlice(gpa, haystack[0..pos]) catch return null;
            result.data.appendSlice(gpa, replacement) catch return null;
            result.data.appendSlice(gpa, haystack[pos + old_len ..]) catch return null;
            return result;
        }
        return str_from(s.data.items.ptr, haystack.len);
    }
    return null;
}

// ─── ReplaceNth: replace the Nth occurrence (1-based) ───

/// Replace the Nth occurrence (1-based) of `old` with `new_str`. Returns new handle.
pub fn str_replace_nth(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new_str: [*c]const u8, new_len: usize, n: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        if (n < 1) return str_from(s.data.items.ptr, s.slice().len);
        const haystack = s.slice();
        const needle = old[0..old_len];
        const replacement = new_str[0..new_len];
        var occurrence: c_int = 0;
        var search_from: usize = 0;
        while (search_from <= haystack.len) {
            if (mem.indexOfPos(u8, haystack, search_from, needle)) |pos| {
                occurrence += 1;
                if (occurrence == n) {
                    const result = str_new() orelse return null;
                    result.data.appendSlice(gpa, haystack[0..pos]) catch return null;
                    result.data.appendSlice(gpa, replacement) catch return null;
                    result.data.appendSlice(gpa, haystack[pos + old_len ..]) catch return null;
                    return result;
                }
                search_from = pos + 1;
            } else break;
        }
        return str_from(s.data.items.ptr, haystack.len);
    }
    return null;
}

// ─── ReplaceCharAt: replace codepoint at index ───

/// Replace codepoint at a given index (1-based from host, converted to 0-based internally) with a new string. Returns new handle.
pub fn str_replace_char_at(handle: StzStringHandle, cp_index: c_int, replacement: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;
    if (cp_index < INDEX_BASE) {
        result.data.appendSlice(gpa, bytes) catch {
            setError(.out_of_memory);
        };
        return result;
    }
    const idx: usize = toInternal(@intCast(cp_index));
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        if (cp_count == idx) {
            // Insert replacement instead of this codepoint
            if (rep_len > 0) {
                result.data.appendSlice(gpa, replacement[0..rep_len]) catch break;
            }
        } else {
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        cp_count += 1;
        i += cp_len;
    }
    return result;
}

// ─── ReplaceSubstring: replace codepoint range [from..to] (1-based from host) ───

pub fn str_replace_substring(handle: StzStringHandle, from_cp: c_int, to_cp: c_int, replacement: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const from: usize = if (from_cp >= INDEX_BASE) toInternal(@intCast(from_cp)) else return null;
    const to: usize = if (to_cp >= INDEX_BASE) toInternal(@intCast(to_cp)) else return null;
    if (to < from) return null;

    var off: usize = 0;
    var cp_i: usize = 0;
    var start_byte: usize = 0;
    var end_byte: usize = buf.len;
    var found_start = false;

    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (cp_i == from) {
            start_byte = off;
            found_start = true;
        }
        if (cp_i == to) {
            end_byte = off + cp_len;
            break;
        }
        off += cp_len;
        cp_i += 1;
    }

    if (!found_start) return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    // Before range
    result.data.appendSlice(gpa, buf[0..start_byte]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    // Replacement
    if (replacement != null and rep_len > 0) {
        result.data.appendSlice(gpa, replacement[0..rep_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    // After range
    if (end_byte < buf.len) {
        result.data.appendSlice(gpa, buf[end_byte..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── ReplaceChar: replace all occurrences of one codepoint with another ───

pub fn str_replace_char(handle: StzStringHandle, old_cp: u32, new_cp: u32) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var new_bytes: [4]u8 = undefined;
    const new_cp21: u21 = @intCast(new_cp);
    const new_len = std.unicode.utf8Encode(new_cp21, &new_bytes) catch return null;

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == old_cp) {
            result.data.appendSlice(gpa, new_bytes[0..new_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        } else {
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        off += cp_len;
    }
    return result;
}

// ─── ReplaceAt: replace codepoint position range with new string ───

pub fn str_replace_at(handle: StzStringHandle, cp_pos: c_int, cp_count: c_int, rep: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (cp_pos < INDEX_BASE or cp_count <= 0) return str_copy(handle);

    const target_start: usize = toInternal(@intCast(cp_pos));
    const target_count: usize = @intCast(cp_count);

    // Find byte offsets for codepoint positions
    var off: usize = 0;
    var cp_idx: usize = 0;
    var start_byte: usize = 0;
    var end_byte: usize = 0;
    var found_start = false;

    while (off < buf.len) {
        if (cp_idx == target_start) {
            start_byte = off;
            found_start = true;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_idx += 1;
        if (found_start and cp_idx == target_start + target_count) {
            end_byte = off;
            break;
        }
    }
    if (!found_start) return str_copy(handle);
    if (end_byte == 0) end_byte = off; // To end of string

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[0..start_byte]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    if (rep != null and rep_len > 0) {
        result.data.appendSlice(gpa, rep[0..rep_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    if (end_byte < buf.len) {
        result.data.appendSlice(gpa, buf[end_byte..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── Replace2: double replace in one pass ───

/// Replace first occurrence of old1 with new1, old2 with new2 in one pass.
pub fn str_replace2(handle: StzStringHandle, old1: [*c]const u8, old1_len: usize, new1: [*c]const u8, new1_len: usize, old2: [*c]const u8, old2_len: usize, new2: [*c]const u8, new2_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    // First replace old1 with new1
    const needle1 = if (old1_len > 0) old1[0..old1_len] else "";
    const repl1 = if (new1_len > 0) new1[0..new1_len] else "";
    const needle2 = if (old2_len > 0) old2[0..old2_len] else "";
    const repl2 = if (new2_len > 0) new2[0..new2_len] else "";

    const r = str_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        // Try needle1
        if (needle1.len > 0 and off + needle1.len <= src.len and mem.eql(u8, src[off..][0..needle1.len], needle1)) {
            r.data.appendSlice(gpa, repl1) catch {
                setError(.out_of_memory);
            };
            off += needle1.len;
            continue;
        }
        // Try needle2
        if (needle2.len > 0 and off + needle2.len <= src.len and mem.eql(u8, src[off..][0..needle2.len], needle2)) {
            r.data.appendSlice(gpa, repl2) catch {
                setError(.out_of_memory);
            };
            off += needle2.len;
            continue;
        }
        r.data.append(gpa, src[off]) catch {
            setError(.out_of_memory);
        };
        off += 1;
    }
    return r;
}

// ─── ReplaceAnyChar: replace any char from a set ───

/// Replace any codepoint found in `chars` set with `replacement`.
/// E.g., replace_any_char("hello", "lo", "*") => "he***"
pub fn str_replace_any_char(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize, repl: [*c]const u8, repl_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const charset = if (chars_len > 0) chars[0..chars_len] else return str_from(src.ptr, src.len);
    const replacement = if (repl_len > 0) repl[0..repl_len] else "";

    const r = str_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var found = false;
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                found = true;
                break;
            }
            coff += c_len;
        }

        if (found) {
            r.data.appendSlice(gpa, replacement) catch {
                setError(.out_of_memory);
            };
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {
                setError(.out_of_memory);
            };
        }
        off += cp_len;
    }
    return r;
}

// ─── ReplaceBetween: replace content between delimiters ───

/// Replace content between first `open` and matching `close` (inclusive of delimiters)
/// with `replacement`. Returns new handle.
pub fn str_replace_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize, rep: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or open_len == 0 or close_len == 0) return str_from(src.ptr, src.len);

    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    // Find first open
    const open_pos = mem.indexOf(u8, src, open_s) orelse return str_from(src.ptr, src.len);
    const search_start = open_pos + open_len;
    if (search_start > src.len) return str_from(src.ptr, src.len);
    const close_rel = mem.indexOf(u8, src[search_start..], close_s) orelse return str_from(src.ptr, src.len);
    const close_end = search_start + close_rel + close_len;

    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src[0..open_pos]) catch {
        str_free(result);
        return null;
    };
    if (rep_len > 0) {
        result.data.appendSlice(gpa, rep[0..rep_len]) catch {
            str_free(result);
            return null;
        };
    }
    if (close_end < src.len) {
        result.data.appendSlice(gpa, src[close_end..]) catch {
            str_free(result);
            return null;
        };
    }
    return result;
}

// ═══════════════════════════════════════════════════════════════
// ─── REMOVE ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════

// ─── RemoveRange: remove codepoints by position ───

/// Remove a range of codepoints from the string. Returns a new handle.
/// `start_cp` is 1-based from host (converted to 0-based internally via toInternal), `cp_count` is the number of codepoints to remove.
pub fn str_remove_range(handle: StzStringHandle, start_cp: usize, cp_count: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0 or cp_count == 0) return str_from(src.ptr, src.len);
        const internal_start = toInternal(@intCast(start_cp));

        // Find byte boundaries for the range to remove
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < src.len and cp < internal_start) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        const remove_start = byte_pos;

        var removed: usize = 0;
        while (byte_pos < src.len and removed < cp_count) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_pos]) catch 1;
            byte_pos += cp_len;
            removed += 1;
        }
        const remove_end = byte_pos;

        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len - (remove_end - remove_start)) catch {
            setError(.out_of_memory);
        };
        if (remove_start > 0) r.data.appendSlice(gpa, src[0..remove_start]) catch {
            setError(.out_of_memory);
        };
        if (remove_end < src.len) r.data.appendSlice(gpa, src[remove_end..]) catch {
            setError(.out_of_memory);
        };
        return r;
    }
    return str_new();
}

// ─── RemoveAll: remove all occurrences ───

/// Remove all occurrences of `needle` from the string. Returns new handle.
/// Unified remove_all with case sensitivity parameter.
pub fn str_remove_all_cs(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, case: c_int) callconv(.c) StzStringHandle {
    if (case == 0) {
        const s = (handle orelse return null);
        _ = s;
        const result = str_new() orelse return null;
        if (handle) |src| {
            result.data.appendSlice(gpa, src.slice()) catch return null;
        }
        str_replace_cs(result, needle, needle_len, "".ptr, 0, 0);
        return result;
    }
    if (handle) |s| {
        const hay = s.slice();
        const ndl = needle[0..needle_len];
        if (ndl.len == 0) return str_from(hay.ptr, hay.len);
        const result = str_new() orelse return null;
        var start: usize = 0;
        while (mem.indexOfPos(u8, hay, start, ndl)) |pos| {
            result.data.appendSlice(gpa, hay[start..pos]) catch return null;
            start = pos + ndl.len;
        }
        result.data.appendSlice(gpa, hay[start..]) catch return null;
        return result;
    }
    return null;
}

pub fn str_remove_all(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    return str_remove_all_cs(handle, needle, needle_len, 1);
}

// ─── RemoveCharAt: remove single codepoint at index ───

/// Remove a single codepoint at the given codepoint index (1-based from host). Returns new handle.
pub fn str_remove_char_at(handle: StzStringHandle, cp_index: usize) callconv(.c) StzStringHandle {
    return str_remove_range(handle, cp_index, 1);
}

// ─── RemoveCharsOfType: remove by character class ───

/// Remove all characters of a given type. Returns new handle.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn str_remove_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        const is_type = switch (char_type) {
            0 => unicode.stz_unicode_is_letter(cp_val) != 0,
            1 => unicode.stz_unicode_is_digit(cp_val) != 0,
            2 => unicode.stz_unicode_is_space(cp_val) != 0,
            3 => unicode.stz_unicode_is_upper(cp_val) != 0,
            4 => unicode.stz_unicode_is_lower(cp_val) != 0,
            5 => blk: {
                const is_letter = unicode.stz_unicode_is_letter(cp_val) != 0;
                const is_digit = unicode.stz_unicode_is_digit(cp_val) != 0;
                const is_space = unicode.stz_unicode_is_space(cp_val) != 0;
                break :blk !is_letter and !is_digit and !is_space;
            },
            else => false,
        };
        if (!is_type) {
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

// ─── RemoveConsecutiveDuplicates: "aabbcc" -> "abc" ───

pub fn str_remove_consecutive_duplicates(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    if (buf.len == 0) return result;

    var off: usize = 0;
    var prev_cp: u21 = 0x10FFFF; // max valid codepoint, used as sentinel
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val != prev_cp) {
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            prev_cp = cp_val;
        }
        off += cp_len;
    }
    return result;
}

// ─── RemoveFirstOccurrence ───

pub fn str_remove_first_occurrence(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) {
        // Return copy of original
        return str_copy(handle);
    }
    const n: []const u8 = needle[0..needle_len];

    if (mem.indexOf(u8, buf, n)) |pos| {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        result.data.appendSlice(gpa, buf[0..pos]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        result.data.appendSlice(gpa, buf[pos + needle_len ..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        return result;
    }
    return str_copy(handle);
}

// ─── RemoveLastOccurrence ───

pub fn str_remove_last_occurrence(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) {
        return str_copy(handle);
    }
    const n: []const u8 = needle[0..needle_len];

    // Find last occurrence by scanning all
    var last_pos: ?usize = null;
    var search_start: usize = 0;
    while (search_start + needle_len <= buf.len) {
        if (mem.indexOf(u8, buf[search_start..], n)) |rel_pos| {
            last_pos = search_start + rel_pos;
            search_start = search_start + rel_pos + 1;
        } else break;
    }

    if (last_pos) |pos| {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        result.data.appendSlice(gpa, buf[0..pos]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        result.data.appendSlice(gpa, buf[pos + needle_len ..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        return result;
    }
    return str_copy(handle);
}

// ─── RemoveNthOccurrence ───

pub fn str_remove_nth_occurrence(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or n < 0 or needle_len > buf.len) {
        return str_copy(handle);
    }
    const ndl: []const u8 = needle[0..needle_len];

    var count: c_int = 0;
    var search_start: usize = 0;
    while (search_start + needle_len <= buf.len) {
        if (mem.indexOf(u8, buf[search_start..], ndl)) |rel_pos| {
            if (count == n) {
                const pos = search_start + rel_pos;
                const result = gpa.create(StzString) catch return null;
                result.* = StzString.init();
                result.data.appendSlice(gpa, buf[0..pos]) catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
                result.data.appendSlice(gpa, buf[pos + needle_len ..]) catch {
                    result.deinit();
                    gpa.destroy(result);
                    return null;
                };
                return result;
            }
            count += 1;
            search_start = search_start + rel_pos + 1;
        } else break;
    }
    return str_copy(handle);
}

// ─── RemovePrefix ───

pub fn str_remove_prefix(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0 or prefix_len > buf.len) return str_copy(handle);
    const pfx: []const u8 = prefix[0..prefix_len];
    if (mem.startsWith(u8, buf, pfx)) {
        return str_from(buf[prefix_len..].ptr, buf.len - prefix_len);
    }
    return str_copy(handle);
}

// ─── RemoveSuffix ───

pub fn str_remove_suffix(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0 or suffix_len > buf.len) return str_copy(handle);
    const sfx: []const u8 = suffix[0..suffix_len];
    if (mem.endsWith(u8, buf, sfx)) {
        return str_from(buf.ptr, buf.len - suffix_len);
    }
    return str_copy(handle);
}

// ─── RemoveWhitespace ───

pub fn str_remove_whitespace(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_space(cp) == 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {
                setError(.out_of_memory);
            };
        }
        off += cp_len;
    }
    return r;
}

// ─── RemoveBetween: remove text between delimiters ───

/// Remove text between first occurrence of `open` and matching `close` (inclusive of delimiters).
/// Returns new handle.
pub fn str_remove_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or open_len == 0 or close_len == 0) return str_from(src.ptr, src.len);

    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    // Find first open
    const open_pos = mem.indexOf(u8, src, open_s) orelse return str_from(src.ptr, src.len);
    // Find first close after open
    const search_start = open_pos + open_len;
    if (search_start > src.len) return str_from(src.ptr, src.len);
    const close_rel = mem.indexOf(u8, src[search_start..], close_s) orelse return str_from(src.ptr, src.len);
    const close_end = search_start + close_rel + close_len;

    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src[0..open_pos]) catch {
        str_free(result);
        return null;
    };
    if (close_end < src.len) {
        result.data.appendSlice(gpa, src[close_end..]) catch {
            str_free(result);
            return null;
        };
    }
    return result;
}

// ─── RemoveVowels ───

/// Remove ASCII vowels (a,e,i,o,u both cases) from the string. Returns new handle.
pub fn str_remove_vowels(handle: StzStringHandle) callconv(.c) StzStringHandle {
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
                off += 1;
                continue;
            }
        }
        result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        off += cp_len;
    }
    return result;
}

// ─── RemoveDuplicateWords ───

/// Remove duplicate words (keeping first occurrence). Words separated by spaces.
/// E.g. "the the cat sat on the mat" -> "the cat sat on mat"
/// Returns new handle.
pub fn str_remove_duplicate_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;

    // Simple approach: split by spaces, track seen words
    var seen_words: [256]struct { start: usize, len: usize } = undefined;
    var seen_count: usize = 0;
    var off: usize = 0;
    var first_word = true;

    while (off < src.len) {
        // Skip spaces
        while (off < src.len and (src[off] == ' ' or src[off] == '\t')) off += 1;
        if (off >= src.len) break;

        // Find word end
        const word_start = off;
        while (off < src.len and src[off] != ' ' and src[off] != '\t') off += 1;
        const word_len = off - word_start;
        if (word_len == 0) continue;

        const word = src[word_start..][0..word_len];

        // Check if already seen
        var is_dup = false;
        var i: usize = 0;
        while (i < seen_count) : (i += 1) {
            if (seen_words[i].len == word_len and
                mem.eql(u8, src[seen_words[i].start..][0..seen_words[i].len], word))
            {
                is_dup = true;
                break;
            }
        }

        if (!is_dup) {
            if (!first_word) {
                result.data.appendSlice(gpa, " ") catch break;
            }
            result.data.appendSlice(gpa, word) catch break;
            first_word = false;
            if (seen_count < 256) {
                seen_words[seen_count] = .{ .start = word_start, .len = word_len };
                seen_count += 1;
            }
        }
    }
    return result;
}

// ─── RemovePunctuation ───

/// Remove all ASCII punctuation characters. Returns new handle.
pub fn str_remove_punctuation(handle: StzStringHandle) callconv(.c) StzStringHandle {
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
            if (!((c >= '!' and c <= '/') or (c >= ':' and c <= '@') or
                (c >= '[' and c <= '`') or (c >= '{' and c <= '~')))
            {
                result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            }
        } else {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        }
        off += cp_len;
    }
    return result;
}

// ─── RemoveNthWord (pub export fn) ───

/// Remove the nth word (1-based from host, converted to 0-based internally). Words separated by spaces.
pub export fn str_remove_nth_word(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const target: usize = if (n >= INDEX_BASE) @intCast(n - INDEX_BASE) else {
        result.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
        };
        return result;
    };

    var starts: [256]usize = undefined;
    var ends_arr: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends_arr[wc] = i;
        wc += 1;
    }

    if (target >= wc) {
        result.data.appendSlice(gpa, src) catch {
            setError(.out_of_memory);
        };
        return result;
    }

    // Build result skipping word at target index
    var first = true;
    for (0..wc) |idx| {
        if (idx == target) continue;
        if (!first) result.data.appendSlice(gpa, " ") catch break;
        result.data.appendSlice(gpa, src[starts[idx]..ends_arr[idx]]) catch break;
        first = false;
    }
    return result;
}

// ─── RemoveBlankLines (pub export fn) ───

pub export fn str_remove_blank_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos <= src.len) {
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        const line = src[start..pos];
        // Check if line is blank (only spaces/tabs)
        var is_blank = true;
        for (line) |c| {
            if (c != ' ' and c != '\t' and c != '\r') {
                is_blank = false;
                break;
            }
        }
        if (!is_blank) {
            if (!first) result.data.appendSlice(gpa, "\n") catch {
                setError(.out_of_memory);
            };
            result.data.appendSlice(gpa, line) catch {
                setError(.out_of_memory);
            };
            first = false;
        }
        if (pos < src.len) pos += 1 else break;
    }
    return result;
}

// ═══════════════════════════════════════════════════════════════
// ─── INSERT ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════

// ─── InsertCp: insert at codepoint position (in-place) ───

pub fn str_insert_cp(handle: StzStringHandle, cp_pos: c_int, utf8: [*c]const u8, len: usize) callconv(.c) void {
    if (handle) |s| {
        if (utf8 == null or len == 0) return;
        const internal: c_int = @intCast(toInternal(cp_pos));
        const byte_pos = unicode.stz_unicode_cp_to_byte(s.data.items.ptr, s.data.items.len, internal);
        if (byte_pos < 0) return;
        s.data.insertSlice(gpa, @intCast(byte_pos), utf8[0..len]) catch {
            setError(.out_of_memory);
        };
        s.invalidateCache();
    }
}

// ─── InsertBeforeEach ───

pub fn str_insert_before_each(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, ins: [*c]const u8, ins_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or ins == null or needle_len == 0) return str_copy(handle);
    const ndl: []const u8 = needle[0..needle_len];
    const insert: []const u8 = ins[0..ins_len];

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var pos: usize = 0;
    while (pos < buf.len) {
        if (pos + needle_len <= buf.len and mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            result.data.appendSlice(gpa, insert) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            result.data.appendSlice(gpa, ndl) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += needle_len;
        } else {
            result.data.append(gpa, buf[pos]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += 1;
        }
    }
    return result;
}

// ─── InsertAfterEach ───

pub fn str_insert_after_each(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize, ins: [*c]const u8, ins_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (needle == null or ins == null or needle_len == 0) return str_copy(handle);
    const ndl: []const u8 = needle[0..needle_len];
    const insert: []const u8 = ins[0..ins_len];

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var pos: usize = 0;
    while (pos < buf.len) {
        if (pos + needle_len <= buf.len and mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            result.data.appendSlice(gpa, ndl) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            result.data.appendSlice(gpa, insert) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += needle_len;
        } else {
            result.data.append(gpa, buf[pos]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            pos += 1;
        }
    }
    return result;
}

// ─── InsertWordAt (pub export fn) ───

/// Insert a word at position n (1-based from host, converted to 0-based internally). Words separated by spaces.
pub export fn str_insert_word_at(handle: ?*StzString, n: c_int, word: [*c]const u8, word_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const target: usize = if (n >= INDEX_BASE) @intCast(n - INDEX_BASE) else 0;
    const wlen: usize = if (word_len >= 0) @intCast(word_len) else 0;

    // Collect existing words
    var starts: [256]usize = undefined;
    var ends_arr: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends_arr[wc] = i;
        wc += 1;
    }

    // Build result inserting new word at position
    var first = true;
    var idx: usize = 0;
    const insert_pos = if (target > wc) wc else target;

    while (idx <= wc) : (idx += 1) {
        if (idx == insert_pos) {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, word[0..wlen]) catch break;
            first = false;
        }
        if (idx < wc) {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, src[starts[idx]..ends_arr[idx]]) catch break;
            first = false;
        }
    }
    return result;
}

// ═══════════════════════════════════════════════════════════════
// ─── STRIP / FILTER ──────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════

// ─── StripChars: remove all codepoints in a set ───

/// Remove all codepoints that appear in the `chars` set string.
/// E.g., strip_chars("hello world!", "lo") => "he wrd!"
pub fn str_strip_chars(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return str_from(src.ptr, src.len);

    const charset = if (chars_len > 0) chars[0..chars_len] else return str_from(src.ptr, src.len);

    // Build set of codepoints to strip
    const r = str_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        // Check if this char appears in the charset
        var found = false;
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                found = true;
                break;
            }
            coff += c_len;
        }

        if (!found) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {
                setError(.out_of_memory);
            };
        }
        off += cp_len;
    }
    return r;
}

// ─── KeepChars: keep only codepoints in a set ───

/// Keep only codepoints that appear in the `chars` set string.
/// E.g., keep_chars("hello world!", "lo") => "llool"
pub fn str_keep_chars(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return str_new();

    const charset = if (chars_len > 0) chars[0..chars_len] else return str_new();

    const r = str_new() orelse return null;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        // Check if this char appears in the charset
        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                r.data.appendSlice(gpa, src[off..][0..cp_len]) catch {
                    setError(.out_of_memory);
                };
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return r;
}

// ═══════════════════════════════════════════════════════════════
// ─── TESTS ───────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════

const testing = std.testing;

test "replace_range" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    // Position 6 (1-based) = " ", replace 1 codepoint with "_"
    const r = str_replace_range(s, 6, 1, "_", 1);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("Hello_World", r.?.slice());
}

test "str_replace in-place" {
    const s = str_from("hello world hello", 17);
    defer str_free(s);
    str_replace(s, "hello", 5, "hi", 2);
    try testing.expectEqualStrings("hi world hi", s.?.slice());
}

test "replace_first" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    const r = str_replace_first(s, "abc", 3, "XY", 2);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("XYabc", r.?.slice());
}

test "replace_last" {
    const s = str_from("abcabc", 6);
    defer str_free(s);
    const r = str_replace_last(s, "abc", 3, "XY", 2);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("abcXY", r.?.slice());
}

test "remove_range" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    // Remove "World" (positions 7..11 in 1-based = cp 7, count 5)
    const r = str_remove_range(s, 7, 5);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("Hello ", r.?.slice());
}

test "remove_all" {
    const s = str_from("banana", 6);
    defer str_free(s);
    const r = str_remove_all(s, "an", 2);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("ba", r.?.slice());
}

test "remove_prefix" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    const r = str_remove_prefix(s, "Hello ", 6);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("World", r.?.slice());
}

test "remove_suffix" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    const r = str_remove_suffix(s, " World", 6);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("Hello", r.?.slice());
}

test "strip_chars" {
    const s = str_from("hello world!", 12);
    defer str_free(s);
    const r = str_strip_chars(s, "lo", 2);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("he wrd!", r.?.slice());
}

test "replace_between" {
    const s = str_from("hello [world] bye", 17);
    defer str_free(s);
    const r = str_replace_between(s, "[", 1, "]", 1, "REPLACED", 8);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("hello REPLACED bye", r.?.slice());
}

test "remove_vowels" {
    const s = str_from("Hello World", 11);
    defer str_free(s);
    const r = str_remove_vowels(s);
    defer str_free(r);
    try testing.expect(r != null);
    try testing.expectEqualStrings("Hll Wrld", r.?.slice());
}
