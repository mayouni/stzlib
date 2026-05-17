// Softanza Engine -- String Case Transforms (Phase D)
//
// Upper, lower, title, camel, snake, kebab, pascal, sentence,
// alternating, spongebob, dot, path, constant case transforms
// extracted from string.zig.
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
const str_free = core.str_free;
const casefoldAlloc = core.casefoldAlloc;
const decodeCodepoint = core.decodeCodepoint;

// ─── ToUpper ───

pub fn str_to_upper(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * 2) catch { setError(.out_of_memory); };
        var buf: [64]u8 = undefined;
        const len = unicode.stz_unicode_to_upper_str(src.ptr, src.len, &buf, 64);
        if (len > 0 and len <= 64) {
            r.data.appendSlice(gpa, buf[0..len]) catch { setError(.out_of_memory); };
        } else if (src.len > 0) {
            const big_buf = gpa.alloc(u8, src.len * 4) catch return r;
            defer gpa.free(big_buf);
            const big_len = unicode.stz_unicode_to_upper_str(src.ptr, src.len, big_buf.ptr, big_buf.len);
            if (big_len > 0) r.data.appendSlice(gpa, big_buf[0..big_len]) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

// ─── ToLower ───

pub fn str_to_lower(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * 2) catch { setError(.out_of_memory); };
        var buf: [64]u8 = undefined;
        const len = unicode.stz_unicode_to_lower_str(src.ptr, src.len, &buf, 64);
        if (len > 0 and len <= 64) {
            r.data.appendSlice(gpa, buf[0..len]) catch { setError(.out_of_memory); };
        } else if (src.len > 0) {
            const big_buf = gpa.alloc(u8, src.len * 4) catch return r;
            defer gpa.free(big_buf);
            const big_len = unicode.stz_unicode_to_lower_str(src.ptr, src.len, big_buf.ptr, big_buf.len);
            if (big_len > 0) r.data.appendSlice(gpa, big_buf[0..big_len]) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

// ─── FoldCase ───

pub fn str_foldcase(handle: StzStringHandle) callconv(.c) StzStringHandle {
    // Full Unicode case folding via utf8proc (handles sharp-s -> "ss", etc.)
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return str_new();
        const folded = casefoldAlloc(src) orelse return str_new();
        // casefoldAlloc returns gpa-allocated memory, wrap it in a StzString
        const r = gpa.create(StzString) catch {
            gpa.free(folded);
            return null;
        };
        r.* = StzString.init();
        r.data.appendSlice(gpa, folded) catch {
            gpa.free(folded);
            r.deinit();
            gpa.destroy(r);
            return null;
        };
        gpa.free(folded);
        return r;
    }
    return str_new();
}

// ─── ToTitle ───

pub fn str_to_title(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * 2) catch { setError(.out_of_memory); };
        const big_buf = gpa.alloc(u8, src.len * 4) catch return r;
        defer gpa.free(big_buf);
        const len = unicode.stz_unicode_to_title_str(src.ptr, src.len, big_buf.ptr, big_buf.len);
        if (len > 0) r.data.appendSlice(gpa, big_buf[0..len]) catch { setError(.out_of_memory); };
        return r;
    }
    return str_new();
}

// ─── SwapCase ───

/// Swap case of all letter codepoints. Returns new handle.
pub fn str_swap_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_upper(cp_val) != 0) {
            // Convert to lower via Engine to_lower on single char
            const tmp = str_from(bytes[i..cp_end].ptr, cp_end - i) orelse {
                i += cp_len;
                continue;
            };
            const lower = str_to_lower(tmp);
            if (lower) |l| {
                result.data.appendSlice(gpa, l.slice()) catch break;
                str_free(lower);
            }
            str_free(tmp);
        } else if (unicode.stz_unicode_is_lower(cp_val) != 0) {
            const tmp = str_from(bytes[i..cp_end].ptr, cp_end - i) orelse {
                i += cp_len;
                continue;
            };
            const upper = str_to_upper(tmp);
            if (upper) |u| {
                result.data.appendSlice(gpa, u.slice()) catch break;
                str_free(upper);
            }
            str_free(tmp);
        } else {
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

// ─── CapitalizeFirst ───

pub fn str_capitalize_first(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const first_len = std.unicode.utf8ByteSequenceLength(buf[0]) catch {
        result.deinit();
        gpa.destroy(result);
        return str_from(buf.ptr, buf.len);
    };
    if (first_len > buf.len) return str_from(buf.ptr, buf.len);
    const first_cp = std.unicode.utf8Decode(buf[0..first_len]) catch return str_from(buf.ptr, buf.len);

    if (first_cp >= 'a' and first_cp <= 'z') {
        const upper_cp: u21 = @intCast(first_cp - 32);
        var upper_bytes: [4]u8 = undefined;
        const upper_len = std.unicode.utf8Encode(upper_cp, &upper_bytes) catch return str_from(buf.ptr, buf.len);
        result.data.appendSlice(gpa, upper_bytes[0..upper_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    } else {
        result.data.appendSlice(gpa, buf[0..first_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    if (first_len < buf.len) {
        result.data.appendSlice(gpa, buf[first_len..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── DecapitalizeFirst ───

pub fn str_decapitalize_first(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const first_len = std.unicode.utf8ByteSequenceLength(buf[0]) catch return str_from(buf.ptr, buf.len);
    if (first_len > buf.len) return str_from(buf.ptr, buf.len);
    const first_cp = std.unicode.utf8Decode(buf[0..first_len]) catch return str_from(buf.ptr, buf.len);

    if (first_cp >= 'A' and first_cp <= 'Z') {
        const lower_cp: u21 = @intCast(first_cp + 32);
        var lower_bytes: [4]u8 = undefined;
        const lower_len = std.unicode.utf8Encode(lower_cp, &lower_bytes) catch return str_from(buf.ptr, buf.len);
        result.data.appendSlice(gpa, lower_bytes[0..lower_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    } else {
        result.data.appendSlice(gpa, buf[0..first_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    if (first_len < buf.len) {
        result.data.appendSlice(gpa, buf[first_len..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── CamelCase / SnakeCase / KebabCase ───

pub fn str_to_camel_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const r = str_new() orelse return null;
    var capitalize_next = false;
    var first = true;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (cp == ' ' or cp == '_' or cp == '-' or cp == '\t') {
            capitalize_next = true;
        } else {
            if (first) {
                // First char: lowercase
                const lc = unicode.stz_unicode_to_lower(cp);
                var buf: [4]u8 = undefined;
                const enc_len = std.unicode.utf8Encode(@intCast(lc), &buf) catch break;
                r.data.appendSlice(gpa, buf[0..enc_len]) catch { setError(.out_of_memory); };
                first = false;
            } else if (capitalize_next) {
                const uc = unicode.stz_unicode_to_upper(cp);
                var buf: [4]u8 = undefined;
                const enc_len = std.unicode.utf8Encode(@intCast(uc), &buf) catch break;
                r.data.appendSlice(gpa, buf[0..enc_len]) catch { setError(.out_of_memory); };
                capitalize_next = false;
            } else {
                r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
            }
        }
        off += cp_len;
    }
    return r;
}

pub fn str_to_snake_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const r = str_new() orelse return null;
    var prev_was_lower = false;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (cp == ' ' or cp == '-' or cp == '\t') {
            r.data.append(gpa, '_') catch { setError(.out_of_memory); };
            prev_was_lower = false;
        } else if (unicode.stz_unicode_is_upper(cp) != 0) {
            if (prev_was_lower) {
                r.data.append(gpa, '_') catch { setError(.out_of_memory); };
            }
            const lc = unicode.stz_unicode_to_lower(cp);
            var buf: [4]u8 = undefined;
            const enc_len = std.unicode.utf8Encode(@intCast(lc), &buf) catch break;
            r.data.appendSlice(gpa, buf[0..enc_len]) catch { setError(.out_of_memory); };
            prev_was_lower = false;
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
            prev_was_lower = unicode.stz_unicode_is_lower(cp) != 0;
        }
        off += cp_len;
    }
    return r;
}

pub fn str_to_kebab_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const r = str_new() orelse return null;
    var prev_was_lower = false;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;

        if (cp == ' ' or cp == '_' or cp == '\t') {
            r.data.append(gpa, '-') catch { setError(.out_of_memory); };
            prev_was_lower = false;
        } else if (unicode.stz_unicode_is_upper(cp) != 0) {
            if (prev_was_lower) {
                r.data.append(gpa, '-') catch { setError(.out_of_memory); };
            }
            const lc = unicode.stz_unicode_to_lower(cp);
            var buf: [4]u8 = undefined;
            const enc_len = std.unicode.utf8Encode(@intCast(lc), &buf) catch break;
            r.data.appendSlice(gpa, buf[0..enc_len]) catch { setError(.out_of_memory); };
            prev_was_lower = false;
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
            prev_was_lower = unicode.stz_unicode_is_lower(cp) != 0;
        }
        off += cp_len;
    }
    return r;
}

// ─── PascalCase ───

/// Convert to PascalCase: first letter of each word uppercase, rest lowercase.
/// Word boundaries: spaces, underscores, hyphens, camelCase transitions.
/// Returns new handle.
pub fn str_to_pascal_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var capitalize_next = true;
    var prev_was_lower = false;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        // Check if this is a word separator
        if (unicode.stz_unicode_is_space(cp_val) != 0 or cp_val == '_' or cp_val == '-') {
            capitalize_next = true;
            prev_was_lower = false;
            off += cp_len;
            continue;
        }

        // camelCase boundary: lowercase followed by uppercase
        const is_upper = unicode.stz_unicode_is_upper(cp_val) != 0;
        if (prev_was_lower and is_upper) {
            capitalize_next = true;
        }

        if (capitalize_next) {
            // Uppercase this char
            var upper_buf: [4]u8 = undefined;
            const upper_cp = unicode.stz_unicode_to_upper(cp_val);
            const upper_u21: u21 = if (upper_cp >= 0) @intCast(@as(u32, @intCast(upper_cp))) else @intCast(@as(u32, @intCast(cp_val)));
            const enc_len = std.unicode.utf8Encode(upper_u21, &upper_buf) catch {
                off += cp_len;
                continue;
            };
            result.data.appendSlice(gpa, upper_buf[0..enc_len]) catch break;
            capitalize_next = false;
            prev_was_lower = !is_upper;
        } else {
            // Lowercase this char
            var lower_buf: [4]u8 = undefined;
            const lower_cp = unicode.stz_unicode_to_lower(cp_val);
            const lower_u21: u21 = if (lower_cp >= 0) @intCast(@as(u32, @intCast(lower_cp))) else @intCast(@as(u32, @intCast(cp_val)));
            const enc_len = std.unicode.utf8Encode(lower_u21, &lower_buf) catch {
                off += cp_len;
                continue;
            };
            result.data.appendSlice(gpa, lower_buf[0..enc_len]) catch break;
            prev_was_lower = !is_upper;
        }
        off += cp_len;
    }
    return result;
}

// ─── CapitalizeWords ───

/// Capitalize first letter of each whitespace-delimited word.
/// Unlike to_title (Unicode titlecase), this simply uppercases the first char of each word.
/// Returns new handle.
pub fn str_capitalize_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var capitalize_next = true;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        if (unicode.stz_unicode_is_space(cp_val) != 0) {
            // Copy space as-is
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
            capitalize_next = true;
        } else if (capitalize_next) {
            // Uppercase this char
            var upper_buf: [4]u8 = undefined;
            const upper_cp = unicode.stz_unicode_to_upper(cp_val);
            const upper_u21: u21 = if (upper_cp >= 0) @intCast(@as(u32, @intCast(upper_cp))) else @intCast(@as(u32, @intCast(cp_val)));
            const enc_len = std.unicode.utf8Encode(upper_u21, &upper_buf) catch {
                off += cp_len;
                continue;
            };
            result.data.appendSlice(gpa, upper_buf[0..enc_len]) catch break;
            capitalize_next = false;
        } else {
            // Copy as-is (don't lowercase)
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        }
        off += cp_len;
    }
    return result;
}

// ─── SentenceCase ───

/// Convert to sentence case: first character uppercase, rest lowercase.
/// Returns new handle.
pub fn str_to_sentence_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var off: usize = 0;
    var first_letter_done = false;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (cp_len == 1 and !first_letter_done) {
            const c = src[off];
            if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
                const upper = if (c >= 'a' and c <= 'z') c - 32 else c;
                result.data.appendSlice(gpa, &[_]u8{upper}) catch break;
                first_letter_done = true;
                off += 1;
                continue;
            }
        } else if (cp_len == 1 and first_letter_done) {
            const c = src[off];
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                off += 1;
                continue;
            }
        }
        result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        if (!first_letter_done and cp_len == 1) {
            // non-letter single byte, keep going
        } else if (!first_letter_done and cp_len > 1) {
            first_letter_done = true;
        }
        off += cp_len;
    }
    return result;
}

// ─── AlternatingCase ───

/// Convert to alternating case: first letter lower, second upper, etc.
/// E.g. "hello world" -> "hElLo wOrLd". Non-letters don't count.
/// Returns new handle.
pub fn str_to_alternating_case(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var letter_idx: usize = 0;
    for (src) |c| {
        if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
            if (letter_idx % 2 == 0) {
                // lowercase
                const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
                result.data.appendSlice(gpa, &[_]u8{lower}) catch break;
            } else {
                // uppercase
                const upper = if (c >= 'a' and c <= 'z') c - 32 else c;
                result.data.appendSlice(gpa, &[_]u8{upper}) catch break;
            }
            letter_idx += 1;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// ─── TitleCaseStrict ───

/// Strict title case: capitalize first letter of every word (unlike smart which skips small words).
pub export fn str_to_title_case_strict(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var word_start = true;
    for (src) |c| {
        if (c == ' ' or c == '\t' or c == '\n') {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            word_start = true;
        } else if (word_start) {
            if (c >= 'a' and c <= 'z') {
                result.data.appendSlice(gpa, &[_]u8{c - 32}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
            word_start = false;
        } else {
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            } else {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            }
        }
    }
    return result;
}

// ─── SpongebobCase ───

/// Spongebob case: alternating case starting with UPPER (opposite of alternating_case which starts lower).
pub export fn str_to_spongebob_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var letter_idx: usize = 0;
    for (src) |c| {
        if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
            if (letter_idx % 2 == 0) {
                // Upper
                if (c >= 'a' and c <= 'z') {
                    result.data.appendSlice(gpa, &[_]u8{c - 32}) catch break;
                } else {
                    result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                }
            } else {
                // Lower
                if (c >= 'A' and c <= 'Z') {
                    result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                } else {
                    result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                }
            }
            letter_idx += 1;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// ─── DotCase ───

/// Convert camelCase/PascalCase to dot.case.
pub export fn str_to_dot_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var prev_sep = false;
    for (src, 0..) |c, idx| {
        if (c >= 'A' and c <= 'Z') {
            if (idx > 0 and !prev_sep) result.data.appendSlice(gpa, ".") catch break;
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_sep = false;
        } else if (c == '_' or c == '-' or c == ' ') {
            if (!prev_sep and idx > 0) result.data.appendSlice(gpa, ".") catch break;
            prev_sep = true;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_sep = false;
        }
    }
    return result;
}

// ─── PathCase ───

/// Convert camelCase/PascalCase to path/case (slash-separated).
pub export fn str_to_path_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var prev_sep = false;
    for (src, 0..) |c, idx| {
        if (c >= 'A' and c <= 'Z') {
            if (idx > 0 and !prev_sep) result.data.appendSlice(gpa, "/") catch break;
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_sep = false;
        } else if (c == '_' or c == '-' or c == ' ') {
            if (!prev_sep and idx > 0) result.data.appendSlice(gpa, "/") catch break;
            prev_sep = true;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_sep = false;
        }
    }
    return result;
}

// ─── ConstantCase ───

pub export fn str_to_constant_case(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var prev_was_sep = false;
    for (src, 0..) |c, idx| {
        if (c == ' ' or c == '-' or c == '\t') {
            if (!prev_was_sep and idx > 0) {
                result.data.appendSlice(gpa, &[_]u8{'_'}) catch break;
            }
            prev_was_sep = true;
        } else if (c >= 'a' and c <= 'z') {
            result.data.appendSlice(gpa, &[_]u8{c - 32}) catch break;
            prev_was_sep = false;
        } else if (c >= 'A' and c <= 'Z') {
            // Insert underscore before uppercase if preceded by lowercase
            if (idx > 0 and !prev_was_sep) {
                const prev = src[idx - 1];
                if (prev >= 'a' and prev <= 'z') {
                    result.data.appendSlice(gpa, &[_]u8{'_'}) catch break;
                }
            }
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_sep = false;
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_sep = false;
        }
    }
    return result;
}

// ─── Tests ───

fn sliceFromHandle(h: StzStringHandle) []const u8 {
    return if (h) |s| s.slice() else "";
}

test "str_to_upper - ASCII" {
    const h = str_from("hello", 5);
    defer str_free(h);
    const r = str_to_upper(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("HELLO", sliceFromHandle(r));
}

test "str_to_lower - ASCII" {
    const h = str_from("HELLO", 5);
    defer str_free(h);
    const r = str_to_lower(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("hello", sliceFromHandle(r));
}

test "str_swap_case - mixed" {
    const h = str_from("Hello World", 11);
    defer str_free(h);
    const r = str_swap_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("hELLO wORLD", sliceFromHandle(r));
}

test "str_to_camel_case" {
    const h = str_from("hello world", 11);
    defer str_free(h);
    const r = str_to_camel_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("helloWorld", sliceFromHandle(r));
}

test "str_to_snake_case" {
    const h = str_from("helloWorld", 10);
    defer str_free(h);
    const r = str_to_snake_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("hello_world", sliceFromHandle(r));
}

test "str_capitalize_first" {
    const h = str_from("hello", 5);
    defer str_free(h);
    const r = str_capitalize_first(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("Hello", sliceFromHandle(r));
}

test "str_to_kebab_case" {
    const h = str_from("helloWorld", 10);
    defer str_free(h);
    const r = str_to_kebab_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("hello-world", sliceFromHandle(r));
}

test "str_to_pascal_case" {
    const h = str_from("hello world", 11);
    defer str_free(h);
    const r = str_to_pascal_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("HelloWorld", sliceFromHandle(r));
}

test "str_to_sentence_case" {
    const h = str_from("hELLO WORLD", 11);
    defer str_free(h);
    const r = str_to_sentence_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("Hello world", sliceFromHandle(r));
}

test "str_to_constant_case" {
    const h = str_from("helloWorld", 10);
    defer str_free(h);
    const r = str_to_constant_case(h);
    defer str_free(r);
    try std.testing.expectEqualStrings("HELLO_WORLD", sliceFromHandle(r));
}
