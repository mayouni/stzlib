// Softanza Engine -- String Operations (Tier 1)
//
// Domain functions for string manipulation. Shared infrastructure
// (types, lifecycle, helpers) lives in string/core.zig.
//
// Phase D module separation: core.zig holds StzString, lifecycle,
// error reporting, indexing config, and shared helpers. This file
// holds all domain functions and re-exports core's public API.

const std = @import("std");

// ─── Core imports ───
const core = @import("string/core.zig");

// Re-export core public API (callers see a flat namespace)
pub const StrError = core.StrError;
pub const StzStringHandle = core.StzStringHandle;
pub const StzFindResultHandle = core.StzFindResultHandle;
pub const INDEX_BASE = core.INDEX_BASE;
pub const str_last_error = core.str_last_error;
pub const str_clear_error = core.str_clear_error;
pub const str_new = core.str_new;
pub const str_from = core.str_from;
pub const str_free = core.str_free;
pub const str_data = core.str_data;
pub const str_size = core.str_size;
pub const str_count = core.str_count;
pub const str_append = core.str_append;
pub const str_insert = core.str_insert;

// Local aliases for core types and helpers
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzFindResult = core.StzFindResult;
const setError = core.setError;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const casefoldAlloc = core.casefoldAlloc;
const ciEqlUnicode = core.ciEqlUnicode;
const ciMatch = core.ciMatch;
const toLowerAscii = core.toLowerAscii;
const utf8CodepointCount = core.utf8CodepointCount;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const byteOffsetToCodepointIndex = core.byteOffsetToCodepointIndex;
const decodeCodepoint = core.decodeCodepoint;
const isAllAscii = core.isAllAscii;
const bmhSearch = core.bmhSearch;
const formatUsize = core.formatUsize;
const isVowelAscii = core.isVowelAscii;

// ─── Encode submodule imports ───
const encode = @import("string/encode.zig");

// Re-export encode public API
pub const str_url_encode = encode.str_url_encode;
pub const str_url_decode = encode.str_url_decode;
pub const str_encode_hex = encode.str_encode_hex;
pub const str_decode_hex = encode.str_decode_hex;
pub const str_to_hex = encode.str_to_hex;
pub const str_from_hex = encode.str_from_hex;
pub const str_escape_html = encode.str_escape_html;
pub const str_unescape_html = encode.str_unescape_html;
pub const str_to_base64 = encode.str_to_base64;
pub const str_from_base64 = encode.str_from_base64;
pub const str_to_binary = encode.str_to_binary;
pub const str_from_binary = encode.str_from_binary;
pub const str_to_morse = encode.str_to_morse;
pub const str_quote = encode.str_quote;
pub const str_unquote = encode.str_unquote;
pub const str_to_csv_field = encode.str_to_csv_field;
pub const str_caesar = encode.str_caesar;
pub const str_xor_cipher = encode.str_xor_cipher;
pub const str_vigenere_encrypt = encode.str_vigenere_encrypt;
pub const str_atbash = encode.str_atbash;
pub const str_rot47 = encode.str_rot47;
pub const str_zigzag = encode.str_zigzag;
pub const str_hash = encode.str_hash;
pub const str_entropy = encode.str_entropy;

// ─── NLP submodule imports ───
const nlp = @import("string/nlp.zig");

pub const str_levenshtein = nlp.str_levenshtein;
pub const str_hamming_distance = nlp.str_hamming_distance;
pub const str_jaro = nlp.str_jaro;
pub const str_jaro_winkler = nlp.str_jaro_winkler;
pub const str_jaccard_similarity = nlp.str_jaccard_similarity;
pub const str_soundex = nlp.str_soundex;
pub const str_metaphone = nlp.str_metaphone;
pub const str_ngram = nlp.str_ngram;
pub const str_ngram_count = nlp.str_ngram_count;
pub const str_char_ngrams = nlp.str_char_ngrams;
pub const str_word_ngrams = nlp.str_word_ngrams;
pub const str_extract_numbers = nlp.str_extract_numbers;
pub const str_extract_emails = nlp.str_extract_emails;
pub const str_extract_words = nlp.str_extract_words;
pub const str_pluralize = nlp.str_pluralize;
pub const str_to_pig_latin = nlp.str_to_pig_latin;
pub const str_to_nato = nlp.str_to_nato;
pub const str_mask_email = nlp.str_mask_email;

// ─── Split submodule imports ───
const split = @import("string/split.zig");

pub const str_split_count = split.str_split_count;
pub const str_split_get = split.str_split_get;
pub const str_split_count_cs = split.str_split_count_cs;
pub const str_split_count_ci = split.str_split_count_ci;
pub const str_split_get_cs = split.str_split_get_cs;
pub const str_split_get_ci = split.str_split_get_ci;
pub const str_lines_count = split.str_lines_count;
pub const str_lines_split_count = split.str_lines_split_count;
pub const str_line_at = split.str_line_at;
pub const str_count_lines = split.str_count_lines;
pub const str_word_count = split.str_word_count;
pub const str_count_words = split.str_count_words;
pub const str_word_at = split.str_word_at;
pub const str_nth_word = split.str_nth_word;
pub const str_first_word = split.str_first_word;
pub const str_last_word = split.str_last_word;
pub const str_swap_words = split.str_swap_words;
pub const str_sentence_count = split.str_sentence_count;
pub const str_partition = split.str_partition;
pub const str_partition_after = split.str_partition_after;
pub const str_rpartition = split.str_rpartition;
pub const str_rpartition_after = split.str_rpartition_after;
pub const str_chunk = split.str_chunk;
pub const str_chars_split = split.str_chars_split;

// ─── Find submodule imports ───
const find = @import("string/find.zig");

pub const str_index_of_cs = find.str_index_of_cs;
pub const str_index_of = find.str_index_of;
pub const str_index_of_from_cs = find.str_index_of_from_cs;
pub const str_index_of_from = find.str_index_of_from;
pub const str_index_of_ci = find.str_index_of_ci;
pub const str_byte_to_cp = find.str_byte_to_cp;
pub const str_count_of = find.str_count_of;
pub const str_count_of_cs = find.str_count_of_cs;
pub const str_count_of_ci = find.str_count_of_ci;
pub const str_find_all_cs = find.str_find_all_cs;
pub const str_find_all = find.str_find_all;
pub const str_find_all_ci = find.str_find_all_ci;
pub const stz_find_result_count = find.stz_find_result_count;
pub const stz_find_result_get = find.stz_find_result_get;
pub const stz_find_result_free = find.stz_find_result_free;
pub const str_last_index_of_cs = find.str_last_index_of_cs;
pub const str_last_index_of = find.str_last_index_of;
pub const str_last_index_of_ci = find.str_last_index_of_ci;
pub const str_contains_cs = find.str_contains_cs;
pub const str_contains = find.str_contains;
pub const str_contains_ci = find.str_contains_ci;
pub const str_starts_with_cs = find.str_starts_with_cs;
pub const str_starts_with = find.str_starts_with;
pub const str_starts_with_ci = find.str_starts_with_ci;
pub const str_ends_with_cs = find.str_ends_with_cs;
pub const str_ends_with = find.str_ends_with;
pub const str_ends_with_ci = find.str_ends_with_ci;
pub const str_equals_cs = find.str_equals_cs;
pub const str_equals = find.str_equals;
pub const str_equals_ci = find.str_equals_ci;
pub const str_find_nth_cs = find.str_find_nth_cs;
pub const str_find_nth = find.str_find_nth;
pub const str_find_nth_ci = find.str_find_nth_ci;
pub const str_starts_with_digit = find.str_starts_with_digit;
pub const str_starts_with_letter = find.str_starts_with_letter;
pub const str_ends_with_digit = find.str_ends_with_digit;
pub const str_ends_with_letter = find.str_ends_with_letter;
pub const str_find_all_char = find.str_find_all_char;
pub const str_starts_with_any = find.str_starts_with_any;
pub const str_ends_with_any = find.str_ends_with_any;

// ─── Extraction ───

pub fn str_mid(handle: StzStringHandle, start: usize, length: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const sl = s.slice();
        if (start >= sl.len) return str_new();
        const end = @min(start + length, sl.len);
        return str_from(sl[start..end].ptr, end - start);
    }
    return str_new();
}

pub fn str_left(handle: StzStringHandle, length: usize) callconv(.c) StzStringHandle {
    return str_mid(handle, 0, length);
}

pub fn str_right(handle: StzStringHandle, length: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const sl = s.slice();
        if (length >= sl.len) return str_from(sl.ptr, sl.len);
        const start = sl.len - length;
        return str_from(sl[start..].ptr, length);
    }
    return str_new();
}

pub fn str_trimmed(handle: StzStringHandle) callconv(.c) StzStringHandle {
    // Delegate to the Unicode-aware trim implementation
    return str_trim(handle);
}

// ─── Codepoint-aware Extraction ───

/// Get nth char (INDEX_BASE-based codepoint position). Returns new handle with that single codepoint.
pub fn str_nth_char(handle: StzStringHandle, cp_index: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const internal_idx = toInternal(@intCast(cp_index));
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < internal_idx) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        if (byte_pos < hay.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            return str_from(hay[byte_pos..].ptr, cp_len);
        }
    }
    return str_new();
}

/// Extract substring by codepoint range [start_cp, start_cp + cp_count).
/// start_cp uses INDEX_BASE convention. cp_count is a length (not a position).
pub fn str_slice(handle: StzStringHandle, start_cp: usize, cp_count: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const internal_start = toInternal(@intCast(start_cp));
        // Find byte start
        var byte_pos: usize = 0;
        var cp: usize = 0;
        while (byte_pos < hay.len and cp < internal_start) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            cp += 1;
        }
        const byte_start = byte_pos;
        // Find byte end
        var count: usize = 0;
        while (byte_pos < hay.len and count < cp_count) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            byte_pos += cp_len;
            count += 1;
        }
        return str_from(hay[byte_start..byte_pos].ptr, byte_pos - byte_start);
    }
    return str_new();
}

/// Get all chars as an array of handles. Caller must free each handle and the array.
/// Returns count via out parameter. Array allocated with c_allocator.
pub fn str_chars(handle: StzStringHandle, out_count: *usize) callconv(.c) [*c]StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const n = utf8CodepointCount(hay);
        out_count.* = n;
        if (n == 0) return null;
        const arr = gpa.alloc(StzStringHandle, n) catch return null;
        var byte_pos: usize = 0;
        var i: usize = 0;
        while (byte_pos < hay.len and i < n) {
            const cp_len = std.unicode.utf8ByteSequenceLength(hay[byte_pos]) catch 1;
            arr[i] = str_from(hay[byte_pos..].ptr, cp_len);
            byte_pos += cp_len;
            i += 1;
        }
        return arr.ptr;
    }
    out_count.* = 0;
    return null;
}

/// Free an array of string handles returned by str_chars.
pub fn str_chars_free(arr: [*c]StzStringHandle, count: usize) callconv(.c) void {
    if (arr == null) return;
    for (0..count) |i| {
        str_free(arr[i]);
    }
    gpa.free(arr[0..count]);
}

// ─── Search ───

/// Unified index_of with case sensitivity parameter.
/// case=1: case-sensitive, case=0: case-insensitive (Unicode casefold).
// str_index_of_cs, str_index_of, str_index_of_from_cs, str_index_of_from, str_index_of_ci -> string/find.zig
// str_byte_to_cp, str_count_of -> string/find.zig

pub fn str_replace_range(handle: StzStringHandle, start: usize, range: usize, new: [*c]const u8, new_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const hay = s.slice();
        const end = @min(start + range, hay.len);
        const result_len = start + new_len + (hay.len - end);
        const out = gpa.create(StzString) catch return null;
        out.* = StzString.init();
        out.data.ensureTotalCapacity(gpa, result_len) catch {
            out.deinit();
            gpa.destroy(out);
            return null;
        };
        out.data.appendSlice(gpa, hay[0..start]) catch unreachable;
        if (new != null and new_len > 0) {
            out.data.appendSlice(gpa, new[0..new_len]) catch unreachable;
        }
        if (end < hay.len) {
            out.data.appendSlice(gpa, hay[end..]) catch unreachable;
        }
        return out;
    }
    return null;
}

// str_split_count, str_split_get -> string/split.zig

// Find all, find result accessors, last_index_of, count_of_cs/ci -> string/find.zig
// contains, starts_with, ends_with (all CS variants) -> string/find.zig

// ─── Transform ───


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

pub fn str_replace_ci(handle: StzStringHandle, old: [*c]const u8, old_len: usize, new: [*c]const u8, new_len: usize) callconv(.c) void {
    str_replace_cs(handle, old, old_len, new, new_len, 0);
}

// Split CS (split_count_cs, split_count_ci, split_get_cs, split_get_ci) -> string/split.zig

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

// ─── Codepoint-aware Operations ───

pub fn str_char_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) i32 {
    if (handle) |s| {
        const internal: c_int = @intCast(toInternal(cp_index));
        const byte_off = unicode.stz_unicode_cp_to_byte(s.data.items.ptr, s.data.items.len, internal);
        if (byte_off < 0) return -1;
        return unicode.stz_unicode_iterate(s.data.items.ptr, s.data.items.len, @intCast(byte_off));
    }
    return -1;
}

pub fn str_mid_cp(handle: StzStringHandle, cp_start: c_int, cp_count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const internal_start: c_int = @intCast(toInternal(cp_start));
        const byte_start = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, internal_start);
        if (byte_start < 0) return str_new();
        const byte_end = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, internal_start + cp_count);
        const end: usize = if (byte_end < 0) src.len else @intCast(byte_end);
        const start: usize = @intCast(byte_start);
        return str_from(src[start..end].ptr, end - start);
    }
    return str_new();
}

pub fn str_left_cp(handle: StzStringHandle, cp_count: c_int) callconv(.c) StzStringHandle {
    // left_cp takes a COUNT, not a position -- pass internal 0 as start
    return str_mid_cp(handle, INDEX_BASE, cp_count);
}

pub fn str_right_cp(handle: StzStringHandle, cp_count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        const total_cp = utf8CodepointCount(src);
        // right_cp: start from (total - count), expressed in INDEX_BASE convention
        const start_cp: c_int = @intCast(total_cp -| @as(usize, @intCast(@max(cp_count, 0))));
        return str_mid_cp(handle, start_cp + INDEX_BASE, cp_count);
    }
    return str_new();
}

pub fn str_insert_cp(handle: StzStringHandle, cp_pos: c_int, utf8: [*c]const u8, len: usize) callconv(.c) void {
    if (handle) |s| {
        if (utf8 == null or len == 0) return;
        const internal: c_int = @intCast(toInternal(cp_pos));
        const byte_pos = unicode.stz_unicode_cp_to_byte(s.data.items.ptr, s.data.items.len, internal);
        if (byte_pos < 0) return;
        s.data.insertSlice(gpa, @intCast(byte_pos), utf8[0..len]) catch { setError(.out_of_memory); };
        s.invalidateCache();
    }
}

pub fn str_grapheme_count(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return unicode.stz_unicode_grapheme_count(s.data.items.ptr, s.data.items.len);
    }
    return 0;
}

pub fn str_normalize(handle: StzStringHandle, form: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        var out_len: usize = 0;
        const result = unicode.stz_unicode_normalize(s.data.items.ptr, s.data.items.len, form, &out_len);
        if (result == null or out_len == 0) return str_new();
        defer unicode.stz_unicode_normalize_free(result, out_len);
        return str_from(result, out_len);
    }
    return str_new();
}

pub fn str_strip_marks(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        var out_len: usize = 0;
        const result = unicode.stz_unicode_strip_marks(s.data.items.ptr, s.data.items.len, &out_len);
        if (result == null or out_len == 0) return str_new();
        defer unicode.stz_unicode_strip_marks_free(result, out_len);
        return str_from(result, out_len);
    }
    return str_new();
}

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
        r.data.ensureTotalCapacity(gpa, src.len + pad_needed * pad_slice.len) catch { setError(.out_of_memory); };
        for (0..pad_needed) |_| {
            r.data.appendSlice(gpa, pad_slice) catch { setError(.out_of_memory); };
        }
        r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
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
        r.data.ensureTotalCapacity(gpa, src.len + pad_needed * pad_slice.len) catch { setError(.out_of_memory); };
        r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        for (0..pad_needed) |_| {
            r.data.appendSlice(gpa, pad_slice) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

/// Remove a range of codepoints from the string. Returns a new handle.
/// `start_cp` uses INDEX_BASE convention, `cp_count` is the number of codepoints to remove.
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
        r.data.ensureTotalCapacity(gpa, src.len - (remove_end - remove_start)) catch { setError(.out_of_memory); };
        if (remove_start > 0) r.data.appendSlice(gpa, src[0..remove_start]) catch { setError(.out_of_memory); };
        if (remove_end < src.len) r.data.appendSlice(gpa, src[remove_end..]) catch { setError(.out_of_memory); };
        return r;
    }
    return str_new();
}

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

/// Check if two strings are equal (case-sensitive). Returns 1 or 0.
/// Unified equals with case sensitivity parameter.
// str_equals_cs, str_equals, str_equals_ci -> string/find.zig
// str_find_nth_cs, str_find_nth, str_find_nth_ci -> string/find.zig

// ─── Replace First / Last / Nth ───

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

// ─── String Queries ───

/// Returns 1 if string is empty (0 codepoints), 0 otherwise.
pub fn str_is_empty(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return if (s.slice().len == 0) 1 else 0;
    }
    return 1; // null handle considered empty
}

/// Extract the substring between the first occurrence of `open` and the first
/// subsequent occurrence of `close`. Returns new handle, or null if not found.
pub fn str_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const haystack = s.slice();
        const open_needle = open[0..open_len];
        const close_needle = close[0..close_len];
        if (mem.indexOf(u8, haystack, open_needle)) |open_pos| {
            const after_open = open_pos + open_len;
            if (mem.indexOfPos(u8, haystack, after_open, close_needle)) |close_pos| {
                const between = haystack[after_open..close_pos];
                return str_from(@ptrCast(between.ptr), between.len);
            }
        }
    }
    return null;
}

/// Count how many codepoints match a predicate class.
/// Classes: 0=letter, 1=digit, 2=whitespace, 3=uppercase, 4=lowercase, 5=punctuation
pub fn str_count_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var count: c_int = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) count += 1;
            i += cp_len;
        }
        return count;
    }
    return 0;
}

/// Check if the string contains only digits. Returns 1 or 0.
pub fn str_is_numeric(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        for (bytes) |b| {
            if (b < '0' or b > '9') return 0;
        }
        return 1;
    }
    return 0;
}

/// Check if the string contains only letters. Returns 1 or 0.
pub fn str_is_alpha(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        if (bytes.len == 0) return 0;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            if (unicode.stz_unicode_is_letter(cp_val) != 1) return 0;
            i += cp_len;
        }
        return 1;
    }
    return 0;
}

// ─── Remove / Lines / Palindrome ───

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

// str_lines_count -> string/split.zig

/// Check if the string is a palindrome (codepoint-level). Returns 1 or 0.
pub fn str_is_palindrome(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return 1;
        // Count codepoints and build byte offset array
        const cp_count = utf8CodepointCount(src);
        if (cp_count <= 1) return 1;
        // Compare first with last, etc.
        var left: usize = 0;
        var right: usize = cp_count - 1;
        while (left < right) {
            const left_offset = codepointIndexToByteOffset(src, left);
            const right_offset = codepointIndexToByteOffset(src, right);
            const left_len = std.unicode.utf8ByteSequenceLength(src[left_offset]) catch 1;
            const right_len = std.unicode.utf8ByteSequenceLength(src[right_offset]) catch 1;
            if (left_len != right_len) return 0;
            if (!mem.eql(u8, src[left_offset .. left_offset + left_len], src[right_offset .. right_offset + right_len])) return 0;
            left += 1;
            right -= 1;
        }
        return 1;
    }
    return 0;
}

/// Find positions (0-based codepoint indices) of characters matching a type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn str_find_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var cp_idx: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) {
                r.positions.append(gpa, toExternal(cp_idx)) catch break;
            }
            cp_idx += 1;
            i += cp_len;
        }
    }
    return r;
}

/// Extract characters matching a type as a new string (letters only, digits only, etc).
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower
pub fn str_extract_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const bytes = s.slice();
        const result = str_new() orelse return null;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_end = @min(i + cp_len, bytes.len);
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) {
                result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
            }
            i += cp_len;
        }
        return result;
    }
    return null;
}

/// Check if string contains only ASCII characters (bytes 0-127). Returns 1 or 0.
/// Uses cached result when available (Phase C optimization).
pub fn str_is_ascii(handle: StzStringHandle) callconv(.c) c_int {
    if (handle) |s| {
        return if (s.isAscii()) @as(c_int, 1) else @as(c_int, 0);
    }
    return 1;
}

/// Remove a single codepoint at the given codepoint index (INDEX_BASE convention). Returns new handle.
pub fn str_remove_char_at(handle: StzStringHandle, cp_index: usize) callconv(.c) StzStringHandle {
    return str_remove_range(handle, cp_index, 1);
}

/// Return the character type at a codepoint index (INDEX_BASE convention).
/// Returns: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct, -1=invalid
pub fn str_char_type_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < INDEX_BASE) return -1;
        const idx: usize = toInternal(@intCast(cp_index));
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return -1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return -1;
        const cp_val: i32 = decodeCodepoint(src, byte_offset, cp_len);
        if (cp_val < 0) return -1;
        if (unicode.stz_unicode_is_upper(cp_val) == 1) return 3;
        if (unicode.stz_unicode_is_lower(cp_val) == 1) return 4;
        if (unicode.stz_unicode_is_letter(cp_val) == 1) return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 1) return 1;
        if (unicode.stz_unicode_is_space(cp_val) == 1) return 2;
        return 5; // punctuation/other
    }
    return -1;
}

/// Concatenate two strings, returning a new handle.
pub fn str_concat(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (h1) |s1| result.data.appendSlice(gpa, s1.slice()) catch return null;
    if (h2) |s2| result.data.appendSlice(gpa, s2.slice()) catch return null;
    return result;
}

/// Check if all letter codepoints are uppercase. Returns 1 if true, 0 if false.
/// Non-letter characters are ignored. Empty string or no letters returns 0.
pub fn str_is_uppercase(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    var has_letter = false;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (unicode.stz_unicode_is_upper(cp_val) == 0) return 0;
        }
        i += cp_len;
    }
    return if (has_letter) 1 else 0;
}

/// Check if all letter codepoints are lowercase. Returns 1 if true, 0 if false.
/// Non-letter characters are ignored. Empty string or no letters returns 0.
pub fn str_is_lowercase(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    var has_letter = false;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (unicode.stz_unicode_is_lower(cp_val) == 0) return 0;
        }
        i += cp_len;
    }
    return if (has_letter) 1 else 0;
}

/// Check if the string contains only whitespace. Returns 1 if true, 0 if false.
/// Empty string returns 0.
pub fn str_is_whitespace(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) return 0;
        i += cp_len;
    }
    return 1;
}

// str_word_count -> string/split.zig

/// Check if string contains only characters of a given type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn str_is_only_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        const matches = switch (char_type) {
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
        if (!matches) return 0;
        i += cp_len;
    }
    return 1;
}

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

// str_starts_with_digit, str_starts_with_letter, str_ends_with_digit, str_ends_with_letter -> string/find.zig

/// Replace codepoint at a given index (INDEX_BASE convention) with a new string. Returns new handle.
pub fn str_replace_char_at(handle: StzStringHandle, cp_index: c_int, replacement: [*c]const u8, rep_len: usize) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;
    if (cp_index < INDEX_BASE) {
        result.data.appendSlice(gpa, bytes) catch { setError(.out_of_memory); };
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

/// Compute Levenshtein edit distance between two strings (codepoint-level).
// Levenshtein -> string/nlp.zig

/// Check if string matches another string with case-insensitive comparison. Returns 1 or 0.
pub fn str_is_title_case(handle: StzStringHandle) callconv(.c) c_int {
    // Title case: first letter of each word is uppercase, rest lowercase
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;

    var after_space = true; // start of string counts as word boundary
    var has_letter = false;
    var i_pos: usize = 0;
    while (i_pos < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i_pos]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i_pos, cp_len);

        if (unicode.stz_unicode_is_letter(cp_val) != 0) {
            has_letter = true;
            if (after_space) {
                // First letter of word must be uppercase
                if (unicode.stz_unicode_is_upper(cp_val) == 0) return 0;
            } else {
                // Other letters in word must be lowercase
                if (unicode.stz_unicode_is_lower(cp_val) == 0) return 0;
            }
            after_space = false;
        } else {
            if (unicode.stz_unicode_is_space(cp_val) != 0) {
                after_space = true;
            } else {
                after_space = false;
            }
        }
        i_pos += cp_len;
    }
    return if (has_letter) @as(c_int, 1) else @as(c_int, 0);
}

// str_lines_split_count, str_line_at -> string/split.zig

/// Return a new string with duplicate codepoints removed (preserves first occurrence order).
pub fn str_unique_chars(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;

    // Track seen codepoints with a simple array (works for BMP + beyond)
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (!seen.contains(cp_val)) {
            seen.put(cp_val, {}) catch break;
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

/// Remove all occurrences of needle (case-insensitive). Returns new handle.
pub fn str_remove_all_ci(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) StzStringHandle {
    return str_remove_all_cs(handle, needle, needle_len, 0);
}

/// Check if string contains only letters (Unicode-aware). Returns 1 or 0.
pub fn str_is_alpha_only(handle: StzStringHandle) callconv(.c) c_int {
    return str_is_only_type(handle, 0); // type 0 = letter
}

/// Check if string is alphanumeric (letters + digits only). Returns 1 or 0.
pub fn str_is_alnum(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (bytes.len == 0) return 0;
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        i += cp_len;
    }
    return 1;
}

/// Return number of unique codepoints.
pub fn str_unique_char_count(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        seen.put(cp_val, {}) catch break;
        i += cp_len;
    }
    return @intCast(seen.count());
}

/// Check if string contains char (codepoint). Returns 1 or 0.
pub fn str_contains_char(handle: StzStringHandle, codepoint: i32) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (cp_val == codepoint) return 1;
        i += cp_len;
    }
    return 0;
}

/// Return a substring between two delimiters, searching from a given occurrence.
/// nth=0 means first occurrence of open delimiter. Returns new handle.
pub fn str_between_nth(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize, nth: c_int) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    if (open_len == 0 or close_len == 0) return null;
    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    var occurrence: c_int = 0;
    var i: usize = 0;
    while (i + open_len <= bytes.len) {
        if (std.mem.eql(u8, bytes[i..][0..open_len], open_s)) {
            if (occurrence == nth) {
                const after_open = i + open_len;
                var j = after_open;
                while (j + close_len <= bytes.len) {
                    if (std.mem.eql(u8, bytes[j..][0..close_len], close_s)) {
                        return str_from(bytes[after_open..j].ptr, j - after_open);
                    }
                    j += 1;
                }
                return null;
            }
            occurrence += 1;
            i += open_len;
        } else {
            i += 1;
        }
    }
    return null;
}

/// Count occurrences of a substring between two delimiters.
pub fn str_count_between(handle: StzStringHandle, open: [*c]const u8, open_len: usize, close: [*c]const u8, close_len: usize) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    if (open_len == 0 or close_len == 0) return 0;
    const open_s = open[0..open_len];
    const close_s = close[0..close_len];

    var count: c_int = 0;
    var i: usize = 0;
    while (i + open_len <= bytes.len) {
        if (std.mem.eql(u8, bytes[i..][0..open_len], open_s)) {
            const after_open = i + open_len;
            var j = after_open;
            while (j + close_len <= bytes.len) {
                if (std.mem.eql(u8, bytes[j..][0..close_len], close_s)) {
                    count += 1;
                    i = j + close_len;
                    break;
                }
                j += 1;
            } else {
                break;
            }
            continue;
        }
        i += 1;
    }
    return count;
}

// ─── Tests ───

test "string lifecycle" {
    const s = str_new();
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(usize, 0), str_size(s));

    str_append(s, "Hello", 5);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));

    str_append(s, " World", 6);
    try std.testing.expectEqual(@as(usize, 11), str_size(s));

    str_free(s);
}

test "string from" {
    const s = str_from("Softanza", 8);
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(usize, 8), str_size(s));
    try std.testing.expectEqual(@as(usize, 8), str_count(s));

    const data = str_data(s);
    try std.testing.expect(mem.eql(u8, data[0..8], "Softanza"));

    str_free(s);
}

test "string unicode count" {
    const s = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));
    try std.testing.expectEqual(@as(usize, 4), str_count(s));
    str_free(s);
}

test "string search" {
    const s = str_from("Hello Ring World", 16);

    try std.testing.expectEqual(@as(i64, 7), str_index_of(s, "Ring", 4));
    try std.testing.expectEqual(@as(i64, -1), str_index_of(s, "Zig", 3));
    try std.testing.expectEqual(@as(c_int, 1), str_contains(s, "World", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with(s, "Hello", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with(s, "World", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with(s, "Ring", 4));

    str_free(s);
}

test "string mid/left/right" {
    const s = str_from("Softanza", 8);

    const mid = str_mid(s, 4, 4);
    try std.testing.expect(mem.eql(u8, str_data(mid)[0..4], "anza"));
    str_free(mid);

    const left = str_left(s, 4);
    try std.testing.expect(mem.eql(u8, str_data(left)[0..4], "Soft"));
    str_free(left);

    const right = str_right(s, 4);
    try std.testing.expect(mem.eql(u8, str_data(right)[0..4], "anza"));
    str_free(right);

    str_free(s);
}

test "string replace" {
    const s = str_from("Hello Qt World", 14);
    str_replace(s, "Qt", 2, "Zig", 3);
    try std.testing.expectEqual(@as(usize, 15), str_size(s));
    try std.testing.expect(mem.eql(u8, str_data(s)[0..15], "Hello Zig World"));
    str_free(s);
}

test "string trimmed" {
    const s = str_from("  hello  ", 9);
    const trimmed = str_trimmed(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(trimmed));
    try std.testing.expect(mem.eql(u8, str_data(trimmed)[0..5], "hello"));
    str_free(trimmed);
    str_free(s);
}

test "string case" {
    const s = str_from("Hello", 5);

    const upper = str_to_upper(s);
    try std.testing.expect(mem.eql(u8, str_data(upper)[0..5], "HELLO"));
    str_free(upper);

    const lower = str_to_lower(s);
    try std.testing.expect(mem.eql(u8, str_data(lower)[0..5], "hello"));
    str_free(lower);

    str_free(s);
}

test "string unicode case" {
    // Greek lowercase -> uppercase
    const s = str_from("\xCE\xB1\xCE\xB2\xCE\xB3", 6);
    const upper = str_to_upper(s);
    try std.testing.expectEqual(@as(usize, 6), str_size(upper));
    try std.testing.expect(mem.eql(u8, str_data(upper)[0..6], "\xCE\x91\xCE\x92\xCE\x93"));
    str_free(upper);
    str_free(s);
}

test "string char_at codepoint" {
    // "cafe\xCC\x81" = c(0x63) a(0x61) f(0x66) e-acute(0xE9 as 2 bytes)
    const s = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(i32, 'c'), str_char_at(s, 1));
    try std.testing.expectEqual(@as(i32, 'a'), str_char_at(s, 2));
    try std.testing.expectEqual(@as(i32, 'f'), str_char_at(s, 3));
    try std.testing.expectEqual(@as(i32, 0xE9), str_char_at(s, 4));
    try std.testing.expectEqual(@as(i32, -1), str_char_at(s, 5));
    str_free(s);
}

test "string mid_cp" {
    // "cafe\xCC\x81" (4 codepoints, 5 bytes)
    const s = str_from("caf\xC3\xA9", 5);
    const mid = str_mid_cp(s, 3, 2);
    try std.testing.expectEqual(@as(usize, 3), str_size(mid));
    try std.testing.expect(mem.eql(u8, str_data(mid)[0..3], "f\xC3\xA9"));
    str_free(mid);
    str_free(s);
}

test "string grapheme count" {
    // e + combining acute = 1 grapheme
    const s = str_from("e\xCC\x81", 3);
    try std.testing.expectEqual(@as(usize, 2), str_count(s)); // 2 codepoints
    try std.testing.expectEqual(@as(c_int, 1), str_grapheme_count(s)); // 1 grapheme
    str_free(s);
}

test "string normalize" {
    // NFD: e + combining acute -> NFC: e-acute
    const s = str_from("e\xCC\x81", 3);
    const nfc = str_normalize(s, 0);
    try std.testing.expectEqual(@as(usize, 2), str_size(nfc));
    try std.testing.expect(mem.eql(u8, str_data(nfc)[0..2], "\xC3\xA9"));
    str_free(nfc);
    str_free(s);
}

test "string strip marks" {
    const s = str_from("\xC3\xA9", 2); // e-acute
    const stripped = str_strip_marks(s);
    try std.testing.expectEqual(@as(usize, 1), str_size(stripped));
    try std.testing.expect(mem.eql(u8, str_data(stripped)[0..1], "e"));
    str_free(stripped);
    str_free(s);
}

test "string insert" {
    const s = str_from("Helo", 4);
    str_insert(s, 2, "l", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));
    try std.testing.expect(mem.eql(u8, str_data(s)[0..5], "Hello"));
    str_free(s);
}

test "string index_of_from" {
    const s = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(i64, 1), str_index_of_from(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 4), str_index_of_from(s, "abc", 3, 2));
    try std.testing.expectEqual(@as(i64, 7), str_index_of_from(s, "abc", 3, 5));
    try std.testing.expectEqual(@as(i64, -1), str_index_of_from(s, "abc", 3, 8));
    str_free(s);
}

test "string index_of_ci" {
    const s = str_from("Hello WORLD", 11);
    try std.testing.expectEqual(@as(i64, 1), str_index_of_ci(s, "hello", 5, 1));
    try std.testing.expectEqual(@as(i64, 7), str_index_of_ci(s, "world", 5, 1));
    try std.testing.expectEqual(@as(i64, -1), str_index_of_ci(s, "xyz", 3, 1));
    try std.testing.expectEqual(@as(i64, 7), str_index_of_ci(s, "WORLD", 5, 4));
    str_free(s);
}

test "string find_all" {
    const s = str_from("ring is ring and ring", 21);
    const r = str_find_all(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 9), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 18), stz_find_result_get(r, 2));
    stz_find_result_free(r);

    // Not found
    const r2 = str_find_all(s, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_find_result_count(r2));
    stz_find_result_free(r2);
    str_free(s);
}

test "string find_all_ci" {
    const s = str_from("Ring RING ring", 14);
    const r = str_find_all_ci(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 11), stz_find_result_get(r, 2));
    stz_find_result_free(r);
    str_free(s);
}

test "string count_of_ci" {
    const s = str_from("Hello hello HELLO hElLo", 23);
    try std.testing.expectEqual(@as(c_int, 4), str_count_of_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_count_of_ci(s, "xyz", 3));
    str_free(s);
}

test "string last_index_of_ci" {
    const s = str_from("abc-ABC-Abc", 11);
    try std.testing.expectEqual(@as(i64, 9), str_last_index_of_ci(s, "abc", 3));
    try std.testing.expectEqual(@as(i64, -1), str_last_index_of_ci(s, "xyz", 3));
    str_free(s);
}

test "string starts_with_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "HELLO", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_ci(s, "world", 5));
    str_free(s);
}

test "string ends_with_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "world", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_ci(s, "hello", 5));
    str_free(s);
}

test "string contains_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_ci(s, "xyz", 3));
    str_free(s);
}

test "string split_count_ci" {
    const s = str_from("oneABCtwoabcthree", 17);
    try std.testing.expectEqual(@as(c_int, 3), str_split_count_ci(s, "abc", 3));
    str_free(s);
}

test "string split_get_ci" {
    const s = str_from("oneABCtwoAbCthree", 17);
    const p0 = str_split_get_ci(s, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(p0)[0..str_size(p0)], "one"));
    str_free(p0);
    const p1 = str_split_get_ci(s, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(p1)[0..str_size(p1)], "two"));
    str_free(p1);
    const p2 = str_split_get_ci(s, "abc", 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(p2)[0..str_size(p2)], "three"));
    str_free(p2);
    str_free(s);
}

test "string replace_ci" {
    const s = str_from("Hello hello HELLO", 17);
    str_replace_ci(s, "hello", 5, "hi", 2);
    try std.testing.expectEqual(@as(usize, 8), str_size(s));
    try std.testing.expect(mem.eql(u8, str_data(s)[0..8], "hi hi hi"));
    str_free(s);
}

test "string count_of" {
    const s = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_of(s, "abc", 3));
    try std.testing.expectEqual(@as(c_int, 0), str_count_of(s, "xyz", 3));
    str_free(s);
}

test "string byte_to_cp" {
    // "caf\xC3\xA9" = c(0) a(1) f(2) e-acute(3,4 bytes -> cp 3)
    const s = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(i64, 1), str_byte_to_cp(s, 0));
    try std.testing.expectEqual(@as(i64, 2), str_byte_to_cp(s, 1));
    try std.testing.expectEqual(@as(i64, 3), str_byte_to_cp(s, 2));
    try std.testing.expectEqual(@as(i64, 4), str_byte_to_cp(s, 3));
    str_free(s);
}

test "string replace_range" {
    const s = str_from("Hello World", 11);
    const r = str_replace_range(s, 5, 1, "_beautiful_", 11);
    try std.testing.expectEqual(@as(usize, 21), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..21], "Hello_beautiful_World"));
    str_free(r);
    str_free(s);
}

test "string replace_range at edges" {
    const s = str_from("abc", 3);
    const r1 = str_replace_range(s, 0, 1, "X", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..3], "Xbc"));
    str_free(r1);
    const r2 = str_replace_range(s, 2, 1, "Z", 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..3], "abZ"));
    str_free(r2);
    str_free(s);
}

test "string split_count" {
    const s = str_from("a:b:c", 5);
    try std.testing.expectEqual(@as(c_int, 3), str_split_count(s, ":", 1));
    str_free(s);
}

test "string split_get" {
    const s = str_from("one::two::three", 15);
    const p0 = str_split_get(s, "::", 2, 0);
    try std.testing.expect(mem.eql(u8, str_data(p0)[0..str_size(p0)], "one"));
    str_free(p0);
    const p1 = str_split_get(s, "::", 2, 1);
    try std.testing.expect(mem.eql(u8, str_data(p1)[0..str_size(p1)], "two"));
    str_free(p1);
    const p2 = str_split_get(s, "::", 2, 2);
    try std.testing.expect(mem.eql(u8, str_data(p2)[0..str_size(p2)], "three"));
    str_free(p2);
    str_free(s);
}

// ─── Unicode codepoint-position tests ───

test "find_all unicode codepoint positions" {
    // "bullet heart bullet bullet bullet bullet heart bullet bullet"
    // Each char is 3 bytes (U+2022=E2 80 A2, U+2665=E2 99 A5)
    // String: bullet(0) heart(1) bullet(2) bullet(3) bullet(4) bullet(5) heart(6) bullet(7) bullet(8)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2";
    const s = str_from(str, 27);
    try std.testing.expectEqual(@as(usize, 9), str_count(s));

    // Find heart (E2 99 A5) -- should be at codepoint positions 2 and 7 (1-based)
    const r = str_find_all(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 7), stz_find_result_get(r, 1));
    stz_find_result_free(r);

    // Find "bullet heart bullet" (9 bytes) -- at codepoint positions 1 and 6 (1-based)
    const sub = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const r2 = str_find_all(s, sub, 9);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r2));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r2, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r2, 1));
    stz_find_result_free(r2);

    str_free(s);
}

test "index_of unicode codepoint position" {
    // "cafe" with e-acute: "caf\xC3\xA9X" -- 5 bytes, 4 codepoints + X
    const s = str_from("caf\xC3\xA9X", 6);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    // 'X' is at byte 5 but codepoint position 5 (1-based)
    try std.testing.expectEqual(@as(i64, 5), str_index_of(s, "X", 1));
    str_free(s);
}

test "last_index_of unicode" {
    // Two hearts in multibyte string
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 12); // 4 chars, 12 bytes
    try std.testing.expectEqual(@as(usize, 4), str_count(s));
    // Last heart at codepoint position 4 (1-based)
    try std.testing.expectEqual(@as(i64, 4), str_last_index_of(s, "\xe2\x99\xa5", 3));
    str_free(s);
}

test "nth_char unicode" {
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const s = str_from(str, 9); // 3 chars
    // nth_char(2) should be heart (1-based: position 2)
    const ch = str_nth_char(s, 2);
    try std.testing.expectEqual(@as(usize, 3), str_size(ch));
    try std.testing.expect(mem.eql(u8, str_data(ch)[0..3], "\xe2\x99\xa5"));
    str_free(ch);
    str_free(s);
}

test "slice unicode" {
    // "bullet heart bullet bullet heart" = 5 chars
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 15);
    // slice(2, 3) = chars at positions 2,3,4 = heart bullet bullet (1-based start)
    const sl = str_slice(s, 2, 3);
    try std.testing.expectEqual(@as(usize, 9), str_size(sl));
    try std.testing.expect(mem.eql(u8, str_data(sl)[0..3], "\xe2\x99\xa5"));
    str_free(sl);
    str_free(s);
}

test "reverse ascii" {
    const s = str_from("hello", 5);
    const r = str_reverse(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "olleh"));
    str_free(r);
    str_free(s);
}

test "reverse unicode" {
    // ABC where A=bullet(3b), B=heart(3b), C=bullet(3b)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const s = str_from(str, 9);
    const r = str_reverse(s);
    // reversed = C B A = bullet heart bullet (same bytes, different order)
    try std.testing.expectEqual(@as(usize, 9), str_size(r));
    // First char should be the LAST original char (bullet)
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x80\xa2"));
    // Second char should be heart
    try std.testing.expect(mem.eql(u8, str_data(r)[3..6], "\xe2\x99\xa5"));
    // Third char should be bullet
    try std.testing.expect(mem.eql(u8, str_data(r)[6..9], "\xe2\x80\xa2"));
    str_free(r);
    str_free(s);
}

test "reverse mixed ascii unicode" {
    // "aBC" where a='a'(1b), B=heart(3b), C='z'(1b)
    const s = str_from("a\xe2\x99\xa5z", 5);
    const r = str_reverse(s);
    // reversed = "z heart a"
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..1], "z"));
    try std.testing.expect(mem.eql(u8, str_data(r)[1..4], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, str_data(r)[4..5], "a"));
    str_free(r);
    str_free(s);
}

test "repeat" {
    const s = str_from("ab", 2);
    const r = str_repeat(s, 3);
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "ababab"));
    str_free(r);
    str_free(s);
}

test "repeat unicode" {
    // heart = 3 bytes
    const s = str_from("\xe2\x99\xa5", 3);
    const r = str_repeat(s, 4);
    try std.testing.expectEqual(@as(usize, 12), str_size(r));
    try std.testing.expectEqual(@as(usize, 4), str_count(r));
    str_free(r);
    str_free(s);
}

test "repeat zero" {
    const s = str_from("hello", 5);
    const r = str_repeat(s, 0);
    try std.testing.expectEqual(@as(usize, 0), str_size(r));
    str_free(r);
    str_free(s);
}

test "pad_left ascii" {
    const s = str_from("hi", 2);
    const r = str_pad_left(s, 5, ".", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "...hi"));
    str_free(r);
    str_free(s);
}

test "pad_left unicode fill" {
    // Pad "ab" to 5 codepoints using heart (3 bytes each)
    const s = str_from("ab", 2);
    const r = str_pad_left(s, 5, "\xe2\x99\xa5", 3);
    // Result: heart heart heart a b = 3*3 + 2 = 11 bytes, 5 codepoints
    try std.testing.expectEqual(@as(usize, 11), str_size(r));
    try std.testing.expectEqual(@as(usize, 5), str_count(r));
    // First 9 bytes = 3 hearts
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, str_data(r)[9..11], "ab"));
    str_free(r);
    str_free(s);
}

test "pad_left no padding needed" {
    const s = str_from("hello", 5);
    const r = str_pad_left(s, 3, " ", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "pad_right ascii" {
    const s = str_from("hi", 2);
    const r = str_pad_right(s, 5, ".", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hi..."));
    str_free(r);
    str_free(s);
}

test "pad_right unicode content" {
    // heart(3b) padded right to 4 codepoints with spaces
    const s = str_from("\xe2\x99\xa5", 3);
    const r = str_pad_right(s, 4, " ", 1);
    // Result: heart + 3 spaces = 3 + 3 = 6 bytes, 4 codepoints
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expectEqual(@as(usize, 4), str_count(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, str_data(r)[3..6], "   "));
    str_free(r);
    str_free(s);
}

test "remove_range ascii" {
    const s = str_from("hello world", 11);
    // Remove "lo " (codepoints at positions 4,5,6 = 1-based)
    const r = str_remove_range(s, 4, 3);
    try std.testing.expectEqual(@as(usize, 8), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..8], "helworld"));
    str_free(r);
    str_free(s);
}

test "remove_range unicode" {
    // "a heart b" = a(1b) heart(3b) b(1b) = 3 codepoints
    const s = str_from("a\xe2\x99\xa5b", 5);
    // Remove heart (position 2, count 1) -- 1-based
    const r = str_remove_range(s, 2, 1);
    try std.testing.expectEqual(@as(usize, 2), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..2], "ab"));
    str_free(r);
    str_free(s);
}

test "trim_left" {
    const s = str_from("  \thello", 8);
    const r = str_trim_left(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trim_right" {
    const s = str_from("hello  \t", 8);
    const r = str_trim_right(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trim_left preserves unicode" {
    // spaces + heart
    const s = str_from("  \xe2\x99\xa5", 5);
    const r = str_trim_left(s);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x99\xa5"));
    str_free(r);
    str_free(s);
}

test "equals" {
    const a = str_from("hello", 5);
    const b = str_from("hello", 5);
    const c = str_from("world", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals(a, b));
    try std.testing.expectEqual(@as(c_int, 0), str_equals(a, c));
    str_free(a);
    str_free(b);
    str_free(c);
}

test "replace_first" {
    const s = str_from("aXbXc", 5);
    const r = str_replace_first(s, "X", 1, "YY", 2);
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "aYYbXc"));
    str_free(r);
    str_free(s);
}

test "replace_last" {
    const s = str_from("aXbXc", 5);
    const r = str_replace_last(s, "X", 1, "ZZ", 2);
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "aXbZZc"));
    str_free(r);
    str_free(s);
}

test "replace_nth" {
    const s = str_from("aXbXcXd", 7);
    // Replace 2nd occurrence
    const r = str_replace_nth(s, "X", 1, "**", 2, 2);
    try std.testing.expectEqual(@as(usize, 8), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..8], "aXb**cXd"));
    str_free(r);
    str_free(s);
}

test "replace_first no match" {
    const s = str_from("hello", 5);
    const r = str_replace_first(s, "Z", 1, "X", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "is_empty" {
    const empty = str_new();
    try std.testing.expectEqual(@as(c_int, 1), str_is_empty(empty));
    str_free(empty);

    const nonempty = str_from("x", 1);
    try std.testing.expectEqual(@as(c_int, 0), str_is_empty(nonempty));
    str_free(nonempty);
}

test "between" {
    const s = str_from("hello [world] end", 17);
    const r = str_between(s, "[", 1, "]", 1);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "world"));
    str_free(r);
    str_free(s);
}

test "between multi-char delimiters" {
    const s = str_from("start<<content>>end", 19);
    const r = str_between(s, "<<", 2, ">>", 2);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 7), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..7], "content"));
    str_free(r);
    str_free(s);
}

test "between not found" {
    const s = str_from("hello world", 11);
    const r = str_between(s, "[", 1, "]", 1);
    try std.testing.expect(r == null);
    str_free(s);
}

test "is_numeric" {
    const num = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric(num));
    str_free(num);

    const mixed = str_from("12a45", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric(mixed));
    str_free(mixed);

    const empty = str_new();
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric(empty));
    str_free(empty);
}

test "is_alpha" {
    const alpha = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alpha(alpha));
    str_free(alpha);

    const mixed = str_from("Hello1", 6);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alpha(mixed));
    str_free(mixed);

    // Unicode letters
    const uni = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alpha(uni));
    str_free(uni);
}

test "count_chars_of_type letters" {
    const s = str_from("Hello 123!", 10);
    // Type 0 = letters: H,e,l,l,o = 5
    try std.testing.expectEqual(@as(c_int, 5), str_count_chars_of_type(s, 0));
    // Type 1 = digits: 1,2,3 = 3
    try std.testing.expectEqual(@as(c_int, 3), str_count_chars_of_type(s, 1));
    // Type 2 = whitespace: 1 space
    try std.testing.expectEqual(@as(c_int, 1), str_count_chars_of_type(s, 2));
    str_free(s);
}

test "find_nth" {
    const s = str_from("aXbXcXd", 7);
    // 1st X at position 2 (1-based)
    try std.testing.expectEqual(@as(i64, 2), str_find_nth(s, "X", 1, 1));
    // 2nd X at position 4
    try std.testing.expectEqual(@as(i64, 4), str_find_nth(s, "X", 1, 2));
    // 3rd X at position 6
    try std.testing.expectEqual(@as(i64, 6), str_find_nth(s, "X", 1, 3));
    // 4th X doesn't exist
    try std.testing.expectEqual(@as(i64, -1), str_find_nth(s, "X", 1, 4));
    str_free(s);
}

test "find_nth unicode" {
    // "heart bullet heart bullet heart" = 5 chars
    const str = "\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 15);
    // 1st heart at position 1 (1-based)
    try std.testing.expectEqual(@as(i64, 1), str_find_nth(s, "\xe2\x99\xa5", 3, 1));
    // 2nd heart at position 3
    try std.testing.expectEqual(@as(i64, 3), str_find_nth(s, "\xe2\x99\xa5", 3, 2));
    // 3rd heart at position 5
    try std.testing.expectEqual(@as(i64, 5), str_find_nth(s, "\xe2\x99\xa5", 3, 3));
    str_free(s);
}

test "remove_all" {
    const s = str_from("aXbXcXd", 7);
    const r = str_remove_all(s, "X", 1);
    try std.testing.expectEqual(@as(usize, 4), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..4], "abcd"));
    str_free(r);
    str_free(s);
}

test "remove_all multi-byte" {
    // Remove heart from "a heart b heart c"
    const s = str_from("a\xe2\x99\xa5b\xe2\x99\xa5c", 9);
    const r = str_remove_all(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "abc"));
    str_free(r);
    str_free(s);
}

test "lines_count" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_lines_count(s1));
    str_free(s1);

    const s2 = str_from("a\nb\nc", 5);
    try std.testing.expectEqual(@as(c_int, 3), str_lines_count(s2));
    str_free(s2);

    const s3 = str_new();
    try std.testing.expectEqual(@as(c_int, 0), str_lines_count(s3));
    str_free(s3);
}

test "is_palindrome ascii" {
    const s1 = str_from("racecar", 7);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s1));
    str_free(s1);

    const s2 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome(s2));
    str_free(s2);

    const s3 = str_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s3));
    str_free(s3);
}

test "is_palindrome unicode" {
    // heart bullet heart = palindrome
    const str = "\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 9);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s));
    str_free(s);
}

test "concat" {
    const h1 = str_from("Hello", 5);
    const h2 = str_from(" World", 6);
    const r = str_concat(h1, h2);
    try std.testing.expectEqual(@as(usize, 11), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..11], "Hello World"));
    str_free(r);
    str_free(h1);
    str_free(h2);
}

test "is_ascii" {
    const ascii = str_from("Hello 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(ascii));
    str_free(ascii);

    const uni = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_ascii(uni));
    str_free(uni);
}

test "remove_char_at" {
    const s = str_from("abcde", 5);
    // Remove 'c' at position 3 (1-based)
    const r = str_remove_char_at(s, 3);
    try std.testing.expectEqual(@as(usize, 4), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..4], "abde"));
    str_free(r);
    str_free(s);
}

test "char_type_at" {
    const s = str_from("A1 z!", 5);
    try std.testing.expectEqual(@as(c_int, 3), str_char_type_at(s, 1)); // 'A' = upper
    try std.testing.expectEqual(@as(c_int, 1), str_char_type_at(s, 2)); // '1' = digit
    try std.testing.expectEqual(@as(c_int, 2), str_char_type_at(s, 3)); // ' ' = space
    try std.testing.expectEqual(@as(c_int, 4), str_char_type_at(s, 4)); // 'z' = lower
    try std.testing.expectEqual(@as(c_int, 5), str_char_type_at(s, 5)); // '!' = punct
    str_free(s);
}

test "find_chars_of_type letters" {
    const s = str_from("a1b2c", 5);
    const r = str_find_chars_of_type(s, 0); // letters
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0)); // 'a'
    try std.testing.expectEqual(@as(i64, 3), stz_find_result_get(r, 1)); // 'b'
    try std.testing.expectEqual(@as(i64, 5), stz_find_result_get(r, 2)); // 'c'
    stz_find_result_free(r);
    str_free(s);
}

test "find_chars_of_type digits" {
    const s = str_from("a1b2c", 5);
    const r = str_find_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 0)); // '1'
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 1)); // '2'
    stz_find_result_free(r);
    str_free(s);
}

test "extract_chars_of_type letters" {
    const s = str_from("H3ll0 W0rld!", 12);
    const r = str_extract_chars_of_type(s, 0); // letters
    // "H3ll0 W0rld!" -> letters: H, l, l, W, r, l, d = 7
    try std.testing.expectEqual(@as(usize, 7), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..7], "HllWrld"));
    str_free(r);
    str_free(s);
}

test "extract_chars_of_type digits" {
    const s = str_from("abc123def456", 12);
    const r = str_extract_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "123456"));
    str_free(r);
    str_free(s);
}

test "is_uppercase" {
    const s1 = str_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_uppercase(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_uppercase(s2));
    str_free(s2);

    const s3 = str_from("HELLO 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), str_is_uppercase(s3));
    str_free(s3);

    const s4 = str_from("123", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_uppercase(s4));
    str_free(s4);
}

test "is_lowercase" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_lowercase(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_lowercase(s2));
    str_free(s2);

    const s3 = str_from("hello 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), str_is_lowercase(s3));
    str_free(s3);
}

test "is_whitespace" {
    const s1 = str_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_whitespace(s1));
    str_free(s1);

    const s2 = str_from(" a ", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_whitespace(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_whitespace(s3));
    str_free(s3);
}

test "word_count" {
    const s1 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 2), str_word_count(s1));
    str_free(s1);

    const s2 = str_from("  hello   world  ", 17);
    try std.testing.expectEqual(@as(c_int, 2), str_word_count(s2));
    str_free(s2);

    const s3 = str_from("one", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_word_count(s3));
    str_free(s3);

    const s4 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_word_count(s4));
    str_free(s4);
}

test "is_only_type" {
    const s1 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_only_type(s1, 0)); // letters
    try std.testing.expectEqual(@as(c_int, 0), str_is_only_type(s1, 1)); // digits
    str_free(s1);

    const s2 = str_from("123", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_only_type(s2, 1)); // digits
    try std.testing.expectEqual(@as(c_int, 0), str_is_only_type(s2, 0)); // letters
    str_free(s2);

    const s3 = str_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_only_type(s3, 2)); // space
    str_free(s3);
}

test "trim" {
    const s1 = str_from("  hello  ", 9);
    const r1 = str_trim(s1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r1));
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..5], "hello"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("hello", 5);
    const r2 = str_trim(s2);
    try std.testing.expectEqual(@as(usize, 5), str_size(r2));
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..5], "hello"));
    str_free(r2);
    str_free(s2);

    const s3 = str_from("   ", 3);
    const r3 = str_trim(s3);
    try std.testing.expectEqual(@as(usize, 0), str_size(r3));
    str_free(r3);
    str_free(s3);
}

test "swap_case" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_swap_case(s1);
    try std.testing.expectEqual(@as(usize, 11), str_size(r1));
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..11], "hELLO wORLD"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("123", 3);
    const r2 = str_swap_case(s2);
    try std.testing.expectEqual(@as(usize, 3), str_size(r2));
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..3], "123"));
    str_free(r2);
    str_free(s2);
}

test "remove_chars_of_type" {
    const s1 = str_from("Hello 123 World!", 16);
    // Remove digits
    const r1 = str_remove_chars_of_type(s1, 1);
    try std.testing.expectEqual(@as(usize, 13), str_size(r1));
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..13], "Hello  World!"));
    str_free(r1);
    // Remove spaces
    const r2 = str_remove_chars_of_type(s1, 2);
    try std.testing.expectEqual(@as(usize, 14), str_size(r2));
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..14], "Hello123World!"));
    str_free(r2);
    // Remove punctuation
    const r3 = str_remove_chars_of_type(s1, 5);
    try std.testing.expectEqual(@as(usize, 15), str_size(r3));
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..15], "Hello 123 World"));
    str_free(r3);
    str_free(s1);
}

test "unique_chars" {
    const s = str_from("aabbcc", 6);
    const u = str_unique_chars(s);
    try std.testing.expectEqual(@as(usize, 3), str_size(u));
    try std.testing.expect(mem.eql(u8, str_data(u)[0..3], "abc"));
    str_free(u);
    str_free(s);

    const s_hello = str_from("Hello", 5);
    const u_hello = str_unique_chars(s_hello);
    try std.testing.expectEqual(@as(usize, 4), str_size(u_hello));
    try std.testing.expect(mem.eql(u8, str_data(u_hello)[0..4], "Helo"));
    str_free(u_hello);
    str_free(s_hello);
}

test "unique_char_count" {
    const s = str_from("aabbcc", 6);
    try std.testing.expectEqual(@as(c_int, 3), str_unique_char_count(s));
    str_free(s);

    const s_hello = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), str_unique_char_count(s_hello));
    str_free(s_hello);
}

test "remove_all_ci" {
    const s = str_from("Hello HELLO hello", 17);
    const r = str_remove_all_ci(s, "hello", 5);
    try std.testing.expectEqual(@as(usize, 2), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..2], "  "));
    str_free(r);
    str_free(s);
}

test "is_alpha_only" {
    const s1 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alpha_only(s1));
    str_free(s1);

    const s2 = str_from("Hello123", 8);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alpha_only(s2));
    str_free(s2);
}

test "is_alnum" {
    const s1 = str_from("Hello123", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alnum(s1));
    str_free(s1);

    const s2 = str_from("Hello 123", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alnum(s2));
    str_free(s2);

    const s3 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alnum(s3));
    str_free(s3);
}

test "contains_char" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_char(s, 'H'));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_char(s, 'o'));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_char(s, 'Z'));
    str_free(s);
}

test "between_nth" {
    const s = str_from("[a] [b] [c]", 11);
    const r0 = str_between_nth(s, "[", 1, "]", 1, 0);
    try std.testing.expect(r0 != null);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..1], "a"));
    str_free(r0);

    const r1 = str_between_nth(s, "[", 1, "]", 1, 1);
    try std.testing.expect(r1 != null);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..1], "b"));
    str_free(r1);

    const r2 = str_between_nth(s, "[", 1, "]", 1, 2);
    try std.testing.expect(r2 != null);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..1], "c"));
    str_free(r2);

    const r3 = str_between_nth(s, "[", 1, "]", 1, 3);
    try std.testing.expect(r3 == null);
    str_free(s);
}

test "count_between" {
    const s = str_from("[a] [b] [c]", 11);
    try std.testing.expectEqual(@as(c_int, 3), str_count_between(s, "[", 1, "]", 1));
    str_free(s);

    const s2 = str_from("no brackets", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_count_between(s2, "[", 1, "]", 1));
    str_free(s2);
}

test "replace_char_at" {
    const s = str_from("Hello", 5);
    const r = str_replace_char_at(s, 1, "J", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "Jello"));
    str_free(r);

    // Replace with multi-byte
    const r2 = str_replace_char_at(s, 5, "!", 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..5], "Hell!"));
    str_free(r2);

    // Replace with empty (deletion)
    const r3 = str_replace_char_at(s, 1, "", 0);
    try std.testing.expectEqual(@as(usize, 4), str_size(r3));
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..4], "ello"));
    str_free(r3);

    str_free(s);
}

test "levenshtein" {
    const s1 = str_from("kitten", 6);
    const s2 = str_from("sitting", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_levenshtein(s1, s2));
    str_free(s1);
    str_free(s2);

    const s3 = str_from("hello", 5);
    const s4 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_levenshtein(s3, s4));
    str_free(s3);
    str_free(s4);

    const s5 = str_from("", 0);
    const s6 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 3), str_levenshtein(s5, s6));
    str_free(s5);
    str_free(s6);
}

test "is_title_case" {
    const s1 = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_title_case(s1));
    str_free(s1);

    const s2 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_title_case(s2));
    str_free(s2);

    const s3 = str_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_title_case(s3));
    str_free(s3);

    const s4 = str_from("A", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_title_case(s4));
    str_free(s4);
}

test "line_at" {
    const s = str_from("line1\nline2\nline3", 17);
    const l0 = str_line_at(s, 0);
    try std.testing.expect(mem.eql(u8, str_data(l0)[0..5], "line1"));
    str_free(l0);

    const l1 = str_line_at(s, 1);
    try std.testing.expect(mem.eql(u8, str_data(l1)[0..5], "line2"));
    str_free(l1);

    const l2 = str_line_at(s, 2);
    try std.testing.expect(mem.eql(u8, str_data(l2)[0..5], "line3"));
    str_free(l2);

    try std.testing.expect(str_line_at(s, 3) == null);
    str_free(s);

    // CRLF
    const s2 = str_from("a\r\nb\r\nc", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_lines_split_count(s2));
    const la = str_line_at(s2, 0);
    try std.testing.expect(mem.eql(u8, str_data(la)[0..1], "a"));
    str_free(la);
    str_free(s2);
}

test "simplify" {
    const s1 = str_from("  hello   world  ", 17);
    const r1 = str_simplify(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..11], "hello world"));
    try std.testing.expectEqual(@as(usize, 11), str_size(r1));
    str_free(r1);
    str_free(s1);

    // Tabs and newlines
    const s2 = str_from("\thello\n\n  world\r\n", 18);
    const r2 = str_simplify(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..11], "hello world"));
    str_free(r2);
    str_free(s2);
}

test "starts_with_digit_letter" {
    const s1 = str_from("123abc", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_digit(s1));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_letter(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_digit(s2));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_letter(s2));
    str_free(s2);
}

test "ends_with_digit_letter" {
    const s1 = str_from("abc123", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_digit(s1));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_letter(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_digit(s2));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_letter(s2));
    str_free(s2);
}

// ─── IsWord: letters, digits, underscore, hyphen ───

pub fn str_is_word(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        // underscore=95, hyphen=45
        if (cp_val != 95 and cp_val != 45 and
            unicode.stz_unicode_is_letter(cp_val) == 0 and
            unicode.stz_unicode_is_digit(cp_val) == 0)
        {
            return 0;
        }
        off += cp_len;
    }
    return 1;
}

// ─── CountLeadingChar / CountTrailingChar ───

pub fn str_count_leading_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var off: usize = 0;
    var count: c_int = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val != codepoint) break;
        count += 1;
        off += cp_len;
    }
    return count;
}

pub fn str_count_trailing_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    // Walk from the end backwards through UTF-8 sequences
    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos > 0) {
        // Find start of previous codepoint
        var start = pos - 1;
        while (start > 0 and (buf[start] & 0xC0) == 0x80) {
            start -= 1;
        }
        const cp_len = pos - start;
        const cp_val = std.unicode.utf8Decode(buf[start..pos]) catch break;
        _ = cp_len;
        if (cp_val != codepoint) break;
        count += 1;
        pos = start;
    }
    return count;
}

// ─── IsNumericString: all digits, optional leading +/- ───

pub fn str_is_numeric_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    // Allow optional leading sign
    if (buf[0] == '+' or buf[0] == '-') {
        off = 1;
        if (off >= buf.len) return 0; // sign alone is not numeric
    }

    var has_digit = false;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        has_digit = true;
        off += cp_len;
    }
    return if (has_digit) @as(c_int, 1) else @as(c_int, 0);
}

// URL encode/decode -> string/encode.zig

// ─── CharAtToString: return codepoint at cp-index as UTF-8 string handle ───

pub fn str_char_at_to_string(handle: StzStringHandle, cp_index: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const idx: usize = if (cp_index >= INDEX_BASE) toInternal(@intCast(cp_index)) else return null;

    var off: usize = 0;
    var cp_i: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return null;
        if (off + cp_len > buf.len) return null;
        if (cp_i == idx) {
            const result = gpa.create(StzString) catch return null;
            result.* = StzString.init();
            result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
            return result;
        }
        off += cp_len;
        cp_i += 1;
    }
    return null;
}

// ─── SpacifyChars: "abc" → "a b c" (codepoint-aware) ───

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

// ─── NumberOfBytesPerChar: returns list as "1 1 2 3" for mixed-byte chars ───

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

// ─── Tests for new functions ───

test "is_word" {
    const s1 = str_from("hello-world_123", 15);
    try std.testing.expectEqual(@as(c_int, 1), str_is_word(s1));
    str_free(s1);

    const s2 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_word(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_word(s3));
    str_free(s3);
}

test "count_leading_trailing_char" {
    const s1 = str_from("   hello", 8);
    try std.testing.expectEqual(@as(c_int, 3), str_count_leading_char(s1, ' '));
    try std.testing.expectEqual(@as(c_int, 0), str_count_trailing_char(s1, ' '));
    str_free(s1);

    const s2 = str_from("hello...", 8);
    try std.testing.expectEqual(@as(c_int, 0), str_count_leading_char(s2, '.'));
    try std.testing.expectEqual(@as(c_int, 3), str_count_trailing_char(s2, '.'));
    str_free(s2);
}

test "is_numeric_string" {
    const s1 = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric_string(s1));
    str_free(s1);

    const s2 = str_from("+42", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric_string(s2));
    str_free(s2);

    const s3 = str_from("-7", 2);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric_string(s3));
    str_free(s3);

    const s4 = str_from("12.5", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric_string(s4));
    str_free(s4);

    const s5 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric_string(s5));
    str_free(s5);
}

test "url_encode_decode" {
    const s1 = str_from("hello world", 11);
    const enc = str_url_encode(s1);
    try std.testing.expect(mem.eql(u8, str_data(enc)[0..@intCast(str_size(enc))], "hello%20world"));

    const dec = str_url_decode(enc);
    try std.testing.expect(mem.eql(u8, str_data(dec)[0..@intCast(str_size(dec))], "hello world"));

    str_free(dec);
    str_free(enc);
    str_free(s1);
}

test "char_at_to_string" {
    const s1 = str_from("Hello", 5);
    const ch = str_char_at_to_string(s1, 1);
    try std.testing.expect(ch != null);
    try std.testing.expect(mem.eql(u8, str_data(ch)[0..@intCast(str_size(ch))], "H"));
    str_free(ch);
    str_free(s1);
}

test "spacify" {
    const s1 = str_from("abc", 3);
    const sp = str_spacify(s1);
    try std.testing.expect(mem.eql(u8, str_data(sp)[0..@intCast(str_size(sp))], "a b c"));
    str_free(sp);
    str_free(s1);
}

test "bytes_per_char" {
    const s1 = str_from("ab", 2);
    const bp = str_bytes_per_char(s1);
    try std.testing.expect(mem.eql(u8, str_data(bp)[0..@intCast(str_size(bp))], "1 1"));
    str_free(bp);
    str_free(s1);
}

// ─── IsHexString: all chars are 0-9, a-f, A-F, optional 0x prefix ───

pub fn str_is_hex_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    // Skip optional 0x or 0X prefix
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'x' or buf[1] == 'X')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_hex = false;
    while (off < buf.len) {
        const b = buf[off];
        if ((b >= '0' and b <= '9') or (b >= 'a' and b <= 'f') or (b >= 'A' and b <= 'F')) {
            has_hex = true;
        } else {
            return 0;
        }
        off += 1;
    }
    return if (has_hex) @as(c_int, 1) else @as(c_int, 0);
}

// ─── IsBinaryString: all chars are 0 or 1, optional 0b prefix ───

pub fn str_is_binary_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'b' or buf[1] == 'B')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_bit = false;
    while (off < buf.len) {
        if (buf[off] != '0' and buf[off] != '1') return 0;
        has_bit = true;
        off += 1;
    }
    return if (has_bit) @as(c_int, 1) else @as(c_int, 0);
}

// ─── IsOctalString: all chars are 0-7, optional 0o prefix ───

pub fn str_is_octal_string(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    var off: usize = 0;
    if (buf.len >= 2 and buf[0] == '0' and (buf[1] == 'o' or buf[1] == 'O')) {
        off = 2;
        if (off >= buf.len) return 0;
    }

    var has_oct = false;
    while (off < buf.len) {
        if (buf[off] < '0' or buf[off] > '7') return 0;
        has_oct = true;
        off += 1;
    }
    return if (has_oct) @as(c_int, 1) else @as(c_int, 0);
}

// str_word_at, isWhitespace -> string/split.zig

// ─── CenterPad: pad string to target width, centering content ───

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
    const left_pad = total_pad / 2;
    const right_pad = total_pad - left_pad;

    var pad_bytes: [4]u8 = undefined;
    const pad_cp: u21 = @intCast(pad_char);
    const pad_len = std.unicode.utf8Encode(pad_cp, &pad_bytes) catch return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    // Left padding
    for (0..left_pad) |_| {
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
    for (0..right_pad) |_| {
        result.data.appendSlice(gpa, pad_bytes[0..pad_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── RemoveConsecutiveDuplicates: "aabbcc" → "abc" ───

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

// ─── Tests for new batch ───

test "is_hex_string" {
    const s1 = str_from("0xFF", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_hex_string(s1));
    str_free(s1);

    const s2 = str_from("deadBEEF", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_hex_string(s2));
    str_free(s2);

    const s3 = str_from("0xGG", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_hex_string(s3));
    str_free(s3);
}

test "is_binary_string" {
    const s1 = str_from("0b1010", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_is_binary_string(s1));
    str_free(s1);

    const s2 = str_from("1100", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_binary_string(s2));
    str_free(s2);

    const s3 = str_from("1020", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_binary_string(s3));
    str_free(s3);
}

test "is_octal_string" {
    const s1 = str_from("0o777", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_octal_string(s1));
    str_free(s1);

    const s2 = str_from("0o89", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_octal_string(s2));
    str_free(s2);
}

test "word_at" {
    const s1 = str_from("hello world foo", 15);
    const w0 = str_word_at(s1, 0);
    try std.testing.expect(mem.eql(u8, str_data(w0)[0..@intCast(str_size(w0))], "hello"));
    str_free(w0);

    const w2 = str_word_at(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(w2)[0..@intCast(str_size(w2))], "foo"));
    str_free(w2);

    const w3 = str_word_at(s1, 3);
    try std.testing.expectEqual(@as(StzStringHandle, null), w3);
    str_free(s1);
}

test "center" {
    const s1 = str_from("hi", 2);
    const c1 = str_center(s1, 6, ' ');
    try std.testing.expect(mem.eql(u8, str_data(c1)[0..@intCast(str_size(c1))], "  hi  "));
    str_free(c1);
    str_free(s1);
}

test "remove_consecutive_duplicates" {
    const s1 = str_from("aabbcc", 6);
    const r1 = str_remove_consecutive_duplicates(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abc"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("mississippi", 11);
    const r2 = str_remove_consecutive_duplicates(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "misisipi"));
    str_free(r2);
    str_free(s2);
}

// ─── Substring: extract between two codepoint positions (inclusive, INDEX_BASE convention) ───

pub fn str_substring(handle: StzStringHandle, from_cp: c_int, to_cp: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    const from: usize = if (from_cp >= INDEX_BASE) toInternal(@intCast(from_cp)) else return null;
    const to: usize = if (to_cp >= INDEX_BASE) toInternal(@intCast(to_cp)) else return null;
    if (to < from) return null;

    var off: usize = 0;
    var cp_i: usize = 0;
    var start_byte: usize = 0;
    var end_byte: usize = 0;
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
    // Handle case where to_cp is the last codepoint
    if (end_byte == 0 and cp_i == to) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return null;
        end_byte = off + cp_len;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[start_byte..end_byte]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── ReplaceSubstring: replace codepoint range [from..to] with new string (INDEX_BASE convention) ───

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

// ─── HasPrefix / HasSuffix with count (how many times a prefix/suffix repeats) ───

pub fn str_prefix_count(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0 or buf.len == 0) return 0;
    const pref = prefix[0..prefix_len];

    var count: c_int = 0;
    var off: usize = 0;
    while (off + prefix_len <= buf.len) {
        if (mem.eql(u8, buf[off .. off + prefix_len], pref)) {
            count += 1;
            off += prefix_len;
        } else {
            break;
        }
    }
    return count;
}

pub fn str_suffix_count(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0 or buf.len == 0) return 0;
    const suf = suffix[0..suffix_len];

    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos >= suffix_len) {
        if (mem.eql(u8, buf[pos - suffix_len .. pos], suf)) {
            count += 1;
            pos -= suffix_len;
        } else {
            break;
        }
    }
    return count;
}

// ─── CommonPrefix / CommonSuffix between two strings ───

pub fn str_common_prefix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    var off: usize = 0;
    var last_cp_end: usize = 0;
    while (off < b1.len and off < b2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(b1[off]) catch break;
        const len2 = std.unicode.utf8ByteSequenceLength(b2[off]) catch break;
        if (len1 != len2 or off + len1 > b1.len or off + len2 > b2.len) break;
        if (!mem.eql(u8, b1[off .. off + len1], b2[off .. off + len2])) break;
        off += len1;
        last_cp_end = off;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    if (last_cp_end > 0) {
        result.data.appendSlice(gpa, b1[0..last_cp_end]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_common_suffix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    if (b1.len == 0 or b2.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    // Walk backwards byte by byte, but verify codepoint boundaries
    var i: usize = 0;
    const min_len = @min(b1.len, b2.len);
    while (i < min_len) {
        if (b1[b1.len - 1 - i] != b2[b2.len - 1 - i]) break;
        i += 1;
    }

    // Adjust to codepoint boundary
    const start = b1.len - i;
    var adjusted_start = start;
    while (adjusted_start < b1.len and (b1[adjusted_start] & 0xC0) == 0x80) {
        adjusted_start += 1;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    if (adjusted_start < b1.len) {
        result.data.appendSlice(gpa, b1[adjusted_start..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── Tests for new batch ───

test "substring" {
    const s1 = str_from("Hello World", 11);
    const sub = str_substring(s1, 1, 5);
    try std.testing.expect(mem.eql(u8, str_data(sub)[0..@intCast(str_size(sub))], "Hello"));
    str_free(sub);

    const sub2 = str_substring(s1, 7, 11);
    try std.testing.expect(mem.eql(u8, str_data(sub2)[0..@intCast(str_size(sub2))], "World"));
    str_free(sub2);
    str_free(s1);
}

test "replace_substring" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_replace_substring(s1, 7, 11, "Zig", 3);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello Zig"));
    str_free(r1);
    str_free(s1);
}

test "prefix_suffix_count" {
    const s1 = str_from("ababab", 6);
    try std.testing.expectEqual(@as(c_int, 3), str_prefix_count(s1, "ab", 2));
    str_free(s1);

    const s2 = str_from("xyzxyzxyz", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_suffix_count(s2, "xyz", 3));
    str_free(s2);
}

test "common_prefix_suffix" {
    const s1 = str_from("hello world", 11);
    const s2 = str_from("hello there", 11);
    const cp = str_common_prefix(s1, s2);
    try std.testing.expect(mem.eql(u8, str_data(cp)[0..@intCast(str_size(cp))], "hello "));
    str_free(cp);
    str_free(s2);
    str_free(s1);

    const s3 = str_from("testing", 7);
    const s4 = str_from("working", 7);
    const cs = str_common_suffix(s3, s4);
    try std.testing.expect(mem.eql(u8, str_data(cs)[0..@intCast(str_size(cs))], "ing"));
    str_free(cs);
    str_free(s4);
    str_free(s3);
}

// ─── SortChars: sort codepoints ascending/descending ───

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

// str_find_all_char -> string/find.zig

// Hash -> string/encode.zig

// ─── CountChar: count occurrences of a specific codepoint ───

pub fn str_count_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == codepoint) count += 1;
        off += cp_len;
    }
    return count;
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

// ─── Copy ───

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

// ─── Compare ───

pub fn str_compare(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return -2;
    const s2 = h2 orelse return -2;
    const buf1 = s1.slice();
    const buf2 = s2.slice();

    // Codepoint-by-codepoint comparison
    var off1: usize = 0;
    var off2: usize = 0;
    while (off1 < buf1.len and off2 < buf2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(buf1[off1]) catch return -2;
        const len2 = std.unicode.utf8ByteSequenceLength(buf2[off2]) catch return -2;
        if (off1 + len1 > buf1.len or off2 + len2 > buf2.len) return -2;
        const cp1 = std.unicode.utf8Decode(buf1[off1..][0..len1]) catch return -2;
        const cp2 = std.unicode.utf8Decode(buf2[off2..][0..len2]) catch return -2;
        if (cp1 < cp2) return -1;
        if (cp1 > cp2) return 1;
        off1 += len1;
        off2 += len2;
    }
    if (off1 < buf1.len) return 1; // s1 longer
    if (off2 < buf2.len) return -1; // s2 longer
    return 0;
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

// ─── IsCharsSortedAsc ───

pub fn str_is_chars_sorted_asc(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 1;

    var off: usize = 0;
    var prev_cp: u21 = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (!first and cp < prev_cp) return 0;
        prev_cp = cp;
        first = false;
        off += cp_len;
    }
    return 1;
}

// ─── IsCharsSortedDesc ───

pub fn str_is_chars_sorted_desc(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 1;

    var off: usize = 0;
    var prev_cp: u21 = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch return 0;
        if (off + cp_len > buf.len) return 0;
        const cp = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch return 0;
        if (!first and cp > prev_cp) return 0;
        prev_cp = cp;
        first = false;
        off += cp_len;
    }
    return 1;
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

// ─── RepeatChar ───

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

// ─── Truncate ───

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

// ─── WrapAt ───

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

// ─── EnsurePrefix ───

pub fn str_ensure_prefix(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0) return str_copy(handle);
    const pfx: []const u8 = prefix[0..prefix_len];
    if (mem.startsWith(u8, buf, pfx)) return str_copy(handle);

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

// ─── EnsureSuffix ───

pub fn str_ensure_suffix(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0) return str_copy(handle);
    const sfx: []const u8 = suffix[0..suffix_len];
    if (mem.endsWith(u8, buf, sfx)) return str_copy(handle);

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

// ─── SqueezeChar ───

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
        return str_copy(handle);
    };
    if (first_len > buf.len) return str_copy(handle);
    const first_cp = std.unicode.utf8Decode(buf[0..first_len]) catch return str_copy(handle);

    if (first_cp >= 'a' and first_cp <= 'z') {
        const upper_cp: u21 = @intCast(first_cp - 32);
        var upper_bytes: [4]u8 = undefined;
        const upper_len = std.unicode.utf8Encode(upper_cp, &upper_bytes) catch return str_copy(handle);
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

    const first_len = std.unicode.utf8ByteSequenceLength(buf[0]) catch return str_copy(handle);
    if (first_len > buf.len) return str_copy(handle);
    const first_cp = std.unicode.utf8Decode(buf[0..first_len]) catch return str_copy(handle);

    if (first_cp >= 'A' and first_cp <= 'Z') {
        const lower_cp: u21 = @intCast(first_cp + 32);
        var lower_bytes: [4]u8 = undefined;
        const lower_len = std.unicode.utf8Encode(lower_cp, &lower_bytes) catch return str_copy(handle);
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

// ─── TabExpand ───

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

// ─── CountOverlapping ───
// Count overlapping occurrences of needle in string

pub fn str_count_overlapping(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) return 0;
    const ndl: []const u8 = needle[0..needle_len];

    var count: c_int = 0;
    var pos: usize = 0;
    while (pos + needle_len <= buf.len) {
        if (mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            count += 1;
            // Move by 1 byte for overlapping (not by needle_len)
            pos += 1;
        } else {
            pos += 1;
        }
    }
    return count;
}

// ─── ReplaceAt ───
// Replace a specific codepoint position range with a new string

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

// ─── CharFrequency ───
// Returns "char:count" pairs separated by newlines, e.g. "a:3\nb:2\n"

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
        var num_buf: [20]u8 = undefined;
        const num_str = std.fmt.bufPrint(&num_buf, "{d}", .{counts.items[i]}) catch break;
        result.data.appendSlice(gpa, num_str) catch break;
        result.data.append(gpa, '\n') catch break;
    }
    return result;
}

// ─── ContainsAnyOf ───
// Check if string contains any of the characters in the given string

pub fn str_contains_any_of(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (chars == null or chars_len == 0) return 0;
    const char_set: []const u8 = chars[0..chars_len];

    // Parse char_set into codepoints
    var set_cps: std.ArrayList(u21) = .{};
    defer set_cps.deinit(gpa);
    var coff: usize = 0;
    while (coff < char_set.len) {
        const cl = std.unicode.utf8ByteSequenceLength(char_set[coff]) catch break;
        if (coff + cl > char_set.len) break;
        const cv = std.unicode.utf8Decode(char_set[coff..][0..cl]) catch break;
        set_cps.append(gpa, cv) catch break;
        coff += cl;
    }

    // Check if any char in buf matches
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        for (set_cps.items) |set_cp| {
            if (cp_val == set_cp) return 1;
        }
        off += cp_len;
    }
    return 0;
}

// ─── ContainsAllOf ───

pub fn str_contains_all_of(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (chars == null or chars_len == 0) return 1;
    const char_set: []const u8 = chars[0..chars_len];

    // Parse char_set into codepoints
    var set_cps: std.ArrayList(u21) = .{};
    defer set_cps.deinit(gpa);
    var coff: usize = 0;
    while (coff < char_set.len) {
        const cl = std.unicode.utf8ByteSequenceLength(char_set[coff]) catch break;
        if (coff + cl > char_set.len) break;
        const cv = std.unicode.utf8Decode(char_set[coff..][0..cl]) catch break;
        set_cps.append(gpa, cv) catch break;
        coff += cl;
    }

    // For each set char, check it exists in buf
    for (set_cps.items) |set_cp| {
        var found = false;
        var off: usize = 0;
        while (off < buf.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
            if (off + cp_len > buf.len) break;
            const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
            if (cp_val == set_cp) {
                found = true;
                break;
            }
            off += cp_len;
        }
        if (!found) return 0;
    }
    return 1;
}

// ─── Center Pad ───

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
    const left_pad = total_pad / 2;
    const right_pad = total_pad - left_pad;

    const r = str_new() orelse return null;
    r.data.ensureTotalCapacity(gpa, src.len + total_pad * pad_len) catch { setError(.out_of_memory); };

    // Add left padding
    for (0..left_pad) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch { setError(.out_of_memory); };
    }
    // Add source
    r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    // Add right padding
    for (0..right_pad) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch { setError(.out_of_memory); };
    }

    return r;
}

// ─── Only Letters / Digits ───

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

// ─── Remove Whitespace ───

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
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// (str_is_palindrome already defined above)

// ─── IsAlphanumeric ───

pub fn str_is_alphanumeric(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch return 0;
        if (off + cp_len > src.len) return 0;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_letter(cp) == 0 and unicode.stz_unicode_is_digit(cp) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── Left/Right Justify (pad to width) ───

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
    r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    const needed = w - cp_count;
    for (0..needed) |_| {
        r.data.appendSlice(gpa, pad_bytes) catch { setError(.out_of_memory); };
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
        r.data.appendSlice(gpa, pad_bytes) catch { setError(.out_of_memory); };
    }
    r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    return r;
}

// (str_common_prefix already defined above)

// str_count_words, str_nth_word -> string/split.zig

// ─── Chars Between Positions ───

pub fn str_chars_between(handle: StzStringHandle, cp_from: c_int, cp_to: c_int) callconv(.c) StzStringHandle {
    // Extract characters between two codepoint positions (exclusive on both ends, INDEX_BASE convention)
    const s = handle orelse return str_new();
    const src = s.slice();
    if (cp_from < INDEX_BASE or cp_to < INDEX_BASE or cp_to <= cp_from + 1) return str_new();

    // Convert to internal 0-based, then get the range between (exclusive)
    const from_internal: c_int = @intCast(toInternal(@intCast(cp_from)));
    const to_internal: c_int = @intCast(toInternal(@intCast(cp_to)));
    const start_cp = from_internal + 1;
    const count_cp = to_internal - from_internal - 1;
    if (count_cp <= 0) return str_new();

    const byte_start = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, start_cp);
    if (byte_start < 0) return str_new();
    const byte_end = unicode.stz_unicode_cp_to_byte(src.ptr, src.len, start_cp + count_cp);
    const end: usize = if (byte_end < 0) src.len else @intCast(byte_end);
    const start: usize = @intCast(byte_start);
    if (start >= end) return str_new();

    return str_from(src[start..end].ptr, end - start);
}

// ─── Indent / Dedent ───

pub fn str_indent(handle: StzStringHandle, spaces: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const n: usize = if (spaces > 0) @intCast(spaces) else return str_from(src.ptr, src.len);

    const r = str_new() orelse return null;
    r.data.ensureTotalCapacity(gpa, src.len + src.len / 10 * n) catch { setError(.out_of_memory); };

    // Add indent before first line
    for (0..n) |_| {
        r.data.append(gpa, ' ') catch { setError(.out_of_memory); };
    }

    for (src) |byte| {
        r.data.append(gpa, byte) catch { setError(.out_of_memory); };
        if (byte == '\n') {
            // Add indent after each newline
            for (0..n) |_| {
                r.data.append(gpa, ' ') catch { setError(.out_of_memory); };
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
                r.data.appendSlice(gpa, line[min_indent..]) catch { setError(.out_of_memory); };
            }
            if (i < src.len) {
                r.data.append(gpa, '\n') catch { setError(.out_of_memory); };
            }
            line_start = i + 1;
        }
    }
    return r;
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

// Partition (str_partition, str_partition_after, str_rpartition, str_rpartition_after) -> string/split.zig

// ─── Squeeze (all consecutive duplicates) ───

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
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
            prev_cp = cp;
            first = false;
        }
        off += cp_len;
    }
    return r;
}

// ─── IsDigit (all chars are digits) ───

/// Returns 1 if all codepoints in the string are digits, 0 otherwise.
/// Empty string returns 0.
pub fn str_is_digit(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch return 0;
        if (off + cp_len > src.len) return 0;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch return 0;
        if (unicode.stz_unicode_is_digit(cp) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

// ─── StringMultiply (interleave) ───

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

// ─── StripChars ───

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
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── KeepChars ───

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
                r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return r;
}

// ─── ReplaceMultiple ───

/// Replace first occurrence of old1 with new1, old2 with new2, etc.
/// Takes alternating old/new pairs as a single concatenated buffer with lengths.
/// Simpler interface: replace two substrings in one pass.
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
            r.data.appendSlice(gpa, repl1) catch { setError(.out_of_memory); };
            off += needle1.len;
            continue;
        }
        // Try needle2
        if (needle2.len > 0 and off + needle2.len <= src.len and mem.eql(u8, src[off..][0..needle2.len], needle2)) {
            r.data.appendSlice(gpa, repl2) catch { setError(.out_of_memory); };
            off += needle2.len;
            continue;
        }
        r.data.append(gpa, src[off]) catch { setError(.out_of_memory); };
        off += 1;
    }
    return r;
}

// ─── Surround ───

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

// ─── ReplaceAnyChar ───

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
            r.data.appendSlice(gpa, replacement) catch { setError(.out_of_memory); };
        } else {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// ─── CountMatches ───

/// Count how many codepoints in the string match any char in the `chars` set.
pub fn str_count_any_char(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return 0;

    const charset = chars[0..chars_len];
    var count: c_int = 0;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                count += 1;
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return count;
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
        str_free(result);
        return null;
    };
    result.data.appendSlice(gpa, src[0..off]) catch {
        str_free(result);
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

/// Check if string is blank (empty or contains only whitespace).
/// Returns 1 if blank, 0 otherwise.
pub fn str_is_blank(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 1; // null = blank
    const src = s.slice();
    if (src.len == 0) return 1;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        if (unicode.stz_unicode_is_space(cp_val) == 0) return 0;
        off += cp_len;
    }
    return 1;
}

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

/// Check if string is a valid programming identifier (starts with letter/underscore,
/// rest are letters/digits/underscores). Returns 1 if valid, 0 otherwise.
pub fn str_is_identifier(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);

        if (first) {
            // First char must be letter or underscore
            if (cp_val != '_' and unicode.stz_unicode_is_letter(cp_val) == 0) return 0;
            first = false;
        } else {
            // Rest must be letter, digit, or underscore
            if (cp_val != '_' and unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0) return 0;
        }
        off += cp_len;
    }
    return 1;
}

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

/// Check if string contains only characters from the given set.
/// Returns 1 if all chars are in set, 0 otherwise. Empty string returns 1.
pub fn str_contains_only(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 1;
    const src = s.slice();
    if (src.len == 0) return 1;
    if (chars_len == 0) return 0;

    const charset = chars[0..chars_len];
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
        if (!found) return 0;
        off += cp_len;
    }
    return 1;
}

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

/// Swap characters at two codepoint positions (INDEX_BASE convention). Returns new handle.
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

// Hex encode/decode -> string/encode.zig

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

/// Check if two strings are anagrams (same chars, different order).
/// Case-sensitive. Returns 1 if anagram, 0 otherwise.
pub fn str_is_anagram(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const src1 = s1.slice();
    const src2 = s2.slice();
    if (src1.len != src2.len) return 0;
    if (src1.len == 0) return 1;

    // Count codepoints in both and compare sorted
    var counts = std.AutoHashMap(i32, i32).init(gpa);
    defer counts.deinit();

    var off: usize = 0;
    while (off < src1.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
        if (off + cp_len > src1.len) break;
        const cp: i32 = decodeCodepoint(src1, off, cp_len);
        const entry = counts.getOrPut(cp) catch break;
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* += 1;
        off += cp_len;
    }

    off = 0;
    while (off < src2.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src2[off]) catch break;
        if (off + cp_len > src2.len) break;
        const cp: i32 = decodeCodepoint(src2, off, cp_len);
        const entry = counts.getOrPut(cp) catch break;
        if (!entry.found_existing) entry.value_ptr.* = 0;
        entry.value_ptr.* -= 1;
        off += cp_len;
    }

    var iter = counts.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* != 0) return 0;
    }
    return 1;
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

/// Count consecutive character runs (groups of identical adjacent chars).
/// E.g. "aabbbcc" has 3 runs: "aa", "bbb", "cc".
pub fn str_count_runs(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var runs: c_int = 1;
    var off: usize = 0;
    var prev_cp: i32 = -1;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp: i32 = decodeCodepoint(src, off, cp_len);
        if (prev_cp >= 0 and cp != prev_cp) {
            runs += 1;
        }
        prev_cp = cp;
        off += cp_len;
    }
    return runs;
}

/// Hamming distance: count positions where corresponding codepoints differ.
/// Strings must be same codepoint length; returns -1 if different lengths.
// Hamming distance -> string/nlp.zig

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

/// Check if string is a pangram (contains every letter a-z at least once, case-insensitive).
/// Returns 1 if pangram, 0 otherwise.
pub fn str_is_pangram(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 26) return 0;

    var seen: [26]bool = [_]bool{false} ** 26;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c >= 'a' and c <= 'z') seen[c - 'a'] = true
            else if (c >= 'A' and c <= 'Z') seen[c - 'A'] = true;
        }
        off += cp_len;
    }

    for (seen) |s2| {
        if (!s2) return 0;
    }
    return 1;
}

// ngram -> string/nlp.zig

/// Count ASCII consonants (letters that are not vowels). Case-insensitive.
pub fn str_count_consonants(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
            if (lower >= 'a' and lower <= 'z') {
                if (lower != 'a' and lower != 'e' and lower != 'i' and lower != 'o' and lower != 'u') {
                    count += 1;
                }
            }
        }
        off += cp_len;
    }
    return count;
}

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

/// Check if brackets/parentheses/braces are balanced.
/// Returns 1 if balanced, 0 otherwise.
pub fn str_is_balanced(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 1;
    const src = s.slice();
    var stack: [1024]u8 = undefined;
    var depth: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == '(' or c == '[' or c == '{') {
                if (depth >= 1024) return 0;
                stack[depth] = c;
                depth += 1;
            } else if (c == ')' or c == ']' or c == '}') {
                if (depth == 0) return 0;
                depth -= 1;
                const expected: u8 = switch (c) {
                    ')' => '(',
                    ']' => '[',
                    '}' => '{',
                    else => 0,
                };
                if (stack[depth] != expected) return 0;
            }
        }
        off += cp_len;
    }
    return if (depth == 0) @as(c_int, 1) else @as(c_int, 0);
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

// str_chunk -> string/split.zig

/// Count ASCII vowels (a,e,i,o,u both cases).
pub fn str_count_vowels(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                count += 1;
            }
        }
        off += cp_len;
    }
    return count;
}

/// Return the length of the longest run of consecutive identical codepoints.
pub fn str_longest_run(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var max_run: c_int = 1;
    var cur_run: c_int = 1;
    var prev_start: usize = 0;
    var prev_len: usize = 0;
    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (first) {
            first = false;
        } else {
            if (cp_len == prev_len and mem.eql(u8, src[off..][0..cp_len], src[prev_start..][0..prev_len])) {
                cur_run += 1;
                if (cur_run > max_run) max_run = cur_run;
            } else {
                cur_run = 1;
            }
        }
        prev_start = off;
        prev_len = cp_len;
        off += cp_len;
    }
    return max_run;
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

/// Basic email format check: contains exactly one @, has text before and after @,
/// has at least one dot after @. Returns 1 if email-like, 0 otherwise.
pub fn str_is_email_like(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 5) return 0; // minimum: a@b.c

    var at_pos: ?usize = null;
    var at_count: usize = 0;
    for (src, 0..) |c, i| {
        if (c == '@') {
            at_count += 1;
            at_pos = i;
        }
    }
    if (at_count != 1) return 0;
    const atp = at_pos.?;
    if (atp == 0) return 0; // nothing before @
    if (atp >= src.len - 1) return 0; // nothing after @

    // Check for dot after @
    const domain = src[atp + 1 ..];
    var has_dot = false;
    for (domain) |c| {
        if (c == '.') { has_dot = true; break; }
    }
    if (!has_dot) return 0;

    // Dot shouldn't be first or last in domain
    if (domain[0] == '.' or domain[domain.len - 1] == '.') return 0;

    return 1;
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

/// Basic URL format check: starts with "http://" or "https://".
/// Returns 1 if URL-like, 0 otherwise.
pub fn str_is_url_like(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len >= 8 and mem.eql(u8, src[0..8], "https://")) return 1;
    if (src.len >= 7 and mem.eql(u8, src[0..7], "http://")) return 1;
    return 0;
}

// HTML escape/unescape -> string/encode.zig

/// Count sentences (terminated by '.', '!', or '?').
pub fn str_count_sentences(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 0;
    for (src) |c| {
        if (c == '.' or c == '!' or c == '?') count += 1;
    }
    return count;
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

/// Check if string is a valid float format (optional sign, digits, one dot, digits).
/// E.g. "3.14", "-0.5", "+123.456" are valid. Returns 1 if valid, 0 otherwise.
pub fn str_is_float(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var off: usize = 0;
    // Optional sign
    if (off < src.len and (src[off] == '+' or src[off] == '-')) off += 1;
    if (off >= src.len) return 0;

    var has_digits_before = false;
    while (off < src.len and src[off] >= '0' and src[off] <= '9') {
        has_digits_before = true;
        off += 1;
    }

    // Must have dot
    if (off >= src.len or src[off] != '.') return 0;
    off += 1;

    var has_digits_after = false;
    while (off < src.len and src[off] >= '0' and src[off] <= '9') {
        has_digits_after = true;
        off += 1;
    }

    if (off != src.len) return 0; // trailing chars
    if (!has_digits_before and !has_digits_after) return 0;
    return 1;
}

/// Sum of all digit characters in the string. E.g. "a1b2c3" -> 6.
pub fn str_digit_sum(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var sum: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') sum += @as(c_int, c - '0');
    }
    return sum;
}

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

/// Count uppercase ASCII letters.
pub fn str_count_upper(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') count += 1;
    }
    return count;
}

/// Count lowercase ASCII letters.
pub fn str_count_lower(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') count += 1;
    }
    return count;
}

/// Check if string is in camelCase format (starts lowercase, has at least one uppercase).
/// Returns 1 if camelCase, 0 otherwise.
pub fn str_is_camel_case(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len < 2) return 0;

    // First char must be lowercase letter
    if (!(src[0] >= 'a' and src[0] <= 'z')) return 0;

    // Must contain at least one uppercase
    var has_upper = false;
    for (src[1..]) |c| {
        if (c >= 'A' and c <= 'Z') { has_upper = true; break; }
    }
    if (!has_upper) return 0;

    // Must only contain letters and digits
    for (src) |c| {
        if (!((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9'))) return 0;
    }
    return 1;
}

/// Return characters common to both strings (unique, in order of appearance in h1).
/// Returns new handle.
pub fn str_common_chars(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    const result = str_new() orelse return null;
    var seen: [256]bool = [_]bool{false} ** 256;

    var off: usize = 0;
    while (off < src1.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
        if (off + cp_len > src1.len) break;
        if (cp_len == 1) {
            const c = src1[off];
            if (!seen[c]) {
                // Check if this char exists in src2
                for (src2) |c2| {
                    if (c2 == c) {
                        result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                        seen[c] = true;
                        break;
                    }
                }
            }
        }
        off += cp_len;
    }
    return result;
}

// batch 7 ─────────────────────────────────────────────────────────

// str_count_lines -> string/split.zig

/// Check if string is in snake_case format: lowercase + underscores, starts with letter, no consecutive underscores.
pub export fn str_is_snake_case(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    // Must start with lowercase letter
    if (src[0] < 'a' or src[0] > 'z') return 0;
    var prev_underscore = false;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            prev_underscore = false;
        } else if (c >= '0' and c <= '9') {
            prev_underscore = false;
        } else if (c == '_') {
            if (prev_underscore) return 0; // consecutive underscores
            prev_underscore = true;
        } else {
            return 0; // invalid character
        }
    }
    // Must not end with underscore
    if (src[src.len - 1] == '_') return 0;
    // Must have at least one underscore to be snake_case
    for (src) |c| {
        if (c == '_') return 1;
    }
    return 0; // single word, no underscore
}

/// Check if string is in kebab-case format: lowercase + hyphens, starts with letter, no consecutive hyphens.
pub export fn str_is_kebab_case(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;
    // Must start with lowercase letter
    if (src[0] < 'a' or src[0] > 'z') return 0;
    var prev_hyphen = false;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') {
            prev_hyphen = false;
        } else if (c >= '0' and c <= '9') {
            prev_hyphen = false;
        } else if (c == '-') {
            if (prev_hyphen) return 0;
            prev_hyphen = true;
        } else {
            return 0;
        }
    }
    if (src[src.len - 1] == '-') return 0;
    // Must have at least one hyphen
    for (src) |c| {
        if (c == '-') return 1;
    }
    return 0;
}

/// Count unique (distinct) characters in the string.
pub export fn str_count_unique_chars(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    // For ASCII, use a 256-entry seen table; for multi-byte, count them separately
    var seen: [256]bool = [_]bool{false} ** 256;
    var count: c_int = 0;
    var multi_byte_count: c_int = 0;

    // Simple approach: for single-byte chars use the table, for multi-byte just count unique sequences
    // (limited to ASCII uniqueness for performance; multi-byte chars each counted as unique)
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            if (!seen[src[off]]) {
                seen[src[off]] = true;
                count += 1;
            }
        } else {
            // For multi-byte, do a naive check against previously seen multi-byte sequences
            // Simple: just count all multi-byte codepoints (approximation for ASCII-heavy use)
            multi_byte_count += 1;
        }
        off += cp_len;
    }
    return count + multi_byte_count;
}

// Caesar cipher -> string/encode.zig

// batch 8 ─────────────────────────────────────────────────────────

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

/// Check if string starts with any of the given prefixes (pipe-separated: "http|ftp|ssh")
// str_starts_with_any, str_ends_with_any -> string/find.zig

// Binary encode -> string/encode.zig

// batch 9 ─────────────────────────────────────────────────────────

/// Sort words alphabetically (case-sensitive). Words separated by spaces.
pub export fn str_sort_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Collect word boundaries
    var words: [256][2]usize = undefined; // [start, end] pairs, max 256 words
    var word_count: usize = 0;
    var i: usize = 0;
    while (i < src.len and word_count < 256) {
        // Skip spaces
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        const start = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        words[word_count] = .{ start, i };
        word_count += 1;
    }

    // Simple insertion sort on words
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

    // Build result
    for (0..word_count) |idx| {
        if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
        result.data.appendSlice(gpa, src[words[idx][0]..words[idx][1]]) catch break;
    }
    return result;
}

/// Keep only unique words (first occurrence preserved). Words separated by spaces.
pub export fn str_unique_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Collect words and track seen
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

        // Check if already seen
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
    return result;
}

// Binary decode -> string/encode.zig

// str_swap_words -> string/split.zig

// Pig latin -> string/nlp.zig

// batch 10 ────────────────────────────────────────────────────────

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

/// Count paragraphs (separated by double newlines \n\n).
pub export fn str_count_paragraphs(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 1;
    var i: usize = 0;
    while (i + 1 < src.len) {
        if (src[i] == '\n' and src[i + 1] == '\n') {
            count += 1;
            // Skip any additional consecutive newlines
            while (i + 1 < src.len and src[i + 1] == '\n') : (i += 1) {}
        }
        i += 1;
    }
    return count;
}

// Zigzag, Morse, Base64, XOR, Entropy -> string/encode.zig

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

// batch 12 ────────────────────────────────────────────────────────

// Jaccard similarity -> string/nlp.zig

/// Longest common prefix between two handles.
pub export fn str_longest_common_prefix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = str_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[i] == src2[i]) : (i += 1) {}
    result.data.appendSlice(gpa, src1[0..i]) catch { setError(.out_of_memory); };
    return result;
}

/// Longest common suffix between two handles.
pub export fn str_longest_common_suffix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = str_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[src1.len - 1 - i] == src2[src2.len - 1 - i]) : (i += 1) {}
    if (i > 0) result.data.appendSlice(gpa, src1[src1.len - i ..]) catch { setError(.out_of_memory); };
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

// batch 13 ────────────────────────────────────────────────────────

/// Hamming weight: count of 1-bits across all bytes.
pub export fn str_hamming_weight(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |byte| {
        var b = byte;
        while (b != 0) {
            count += 1;
            b &= b - 1; // clear lowest set bit
        }
    }
    return count;
}

/// Is palindrome at word level: "dog cat dog" -> true (words reversed = same sequence).
pub export fn str_is_palindrome_words(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 1;

    // Collect word boundaries
    var starts: [256]usize = undefined;
    var ends: [256]usize = undefined;
    var wc: usize = 0;

    var i: usize = 0;
    while (i < src.len and wc < 256) {
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        starts[wc] = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        ends[wc] = i;
        wc += 1;
    }
    if (wc <= 1) return 1;

    // Compare word[j] with word[wc-1-j]
    var j: usize = 0;
    while (j < wc / 2) : (j += 1) {
        const w1 = src[starts[j]..ends[j]];
        const w2 = src[starts[wc - 1 - j]..ends[wc - 1 - j]];
        if (!mem.eql(u8, w1, w2)) return 0;
    }
    return 1;
}

/// Remove the nth word (0-based). Words separated by spaces.
pub export fn str_remove_nth_word(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const target: usize = if (n >= 0) @intCast(n) else {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
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
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
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

/// Insert a word at position n (0-based). Words separated by spaces.
pub export fn str_insert_word_at(handle: ?*StzString, n: c_int, word: [*c]const u8, word_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const target: usize = if (n >= 0) @intCast(n) else 0;
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

// batch 14 ────────────────────────────────────────────────────────

/// Extract text between first occurrence of open and close delimiters.
pub export fn str_between_first(handle: ?*StzString, open: [*c]const u8, open_len: c_int, close: [*c]const u8, close_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const olen: usize = if (open_len >= 0) @intCast(open_len) else return result;
    const clen: usize = if (close_len >= 0) @intCast(close_len) else return result;
    if (olen == 0 or clen == 0) return result;

    // Find first open
    var i: usize = 0;
    while (i + olen <= src.len) {
        if (mem.eql(u8, src[i .. i + olen], open[0..olen])) {
            const start = i + olen;
            // Find close after open
            var j: usize = start;
            while (j + clen <= src.len) {
                if (mem.eql(u8, src[j .. j + clen], close[0..clen])) {
                    result.data.appendSlice(gpa, src[start..j]) catch { setError(.out_of_memory); };
                    return result;
                }
                j += 1;
            }
            return result; // no close found
        }
        i += 1;
    }
    return result;
}

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

/// Count non-overlapping occurrences of a substring.
pub export fn str_count_substring(handle: ?*StzString, needle: [*c]const u8, needle_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const nlen: usize = if (needle_len > 0) @intCast(needle_len) else return 0;
    const ndl = needle[0..nlen];

    var count: c_int = 0;
    var i: usize = 0;
    while (i + nlen <= src.len) {
        if (mem.eql(u8, src[i .. i + nlen], ndl)) {
            count += 1;
            i += nlen;
        } else {
            i += 1;
        }
    }
    return count;
}

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

// ─── Batch 15: left_pad, right_pad, is_numeric, is_alpha, is_alphanumeric ───

pub export fn str_left_pad(handle: ?*StzString, width: c_int, pad_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const w: usize = if (width < 0) 0 else @intCast(width);
    const result = str_new() orelse return null;
    if (src.len >= w) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        return result;
    }
    const pad_count = w - src.len;
    var i: usize = 0;
    while (i < pad_count) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{pad_char}) catch break;
    }
    result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    return result;
}

pub export fn str_right_pad(handle: ?*StzString, width: c_int, pad_char: u8) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const w: usize = if (width < 0) 0 else @intCast(width);
    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    if (src.len >= w) return result;
    const pad_count = w - src.len;
    var i: usize = 0;
    while (i < pad_count) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{pad_char}) catch break;
    }
    return result;
}

// to_hex, from_hex -> string/encode.zig

// Soundex -> string/nlp.zig

// ─── Batch 16: vigenere_encrypt, atbash, count_words_matching, truncate_words, to_constant_case ───

// Vigenere, Atbash -> string/encode.zig

pub export fn str_count_words_matching(handle: ?*StzString, pattern_ptr: [*c]const u8, pattern_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const plen: usize = if (pattern_len < 1) return 0 else @intCast(pattern_len);
    const pattern = pattern_ptr[0..plen];
    var count: c_int = 0;
    var pos: usize = 0;
    while (pos < src.len) {
        // skip spaces
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        const start = pos;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        const word = src[start..pos];
        if (word.len == plen and mem.eql(u8, word, pattern)) count += 1;
    }
    return count;
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

// ─── Batch 17: first_word, last_word, to_nato, commonality, diff_chars ───

// str_first_word, str_last_word -> string/split.zig

// NATO -> string/nlp.zig

pub export fn str_commonality(handle: ?*StzString, other: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const o = other orelse return 0;
    const src = s.slice();
    const oth = o.slice();
    // Count chars present in both (based on set intersection)
    var seen_src = [_]bool{false} ** 256;
    for (src) |c| seen_src[c] = true;
    var count: c_int = 0;
    var seen_counted = [_]bool{false} ** 256;
    for (oth) |c| {
        if (seen_src[c] and !seen_counted[c]) {
            count += 1;
            seen_counted[c] = true;
        }
    }
    return count;
}

pub export fn str_diff_chars(handle: ?*StzString, other: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const o = other orelse return null;
    const src = s.slice();
    const oth = o.slice();
    const result = str_new() orelse return null;
    // Chars in src not in other (unique set)
    var in_other = [_]bool{false} ** 256;
    for (oth) |c| in_other[c] = true;
    var added = [_]bool{false} ** 256;
    for (src) |c| {
        if (!in_other[c] and !added[c]) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            added[c] = true;
        }
    }
    return result;
}

// ─── Batch 18: rot47, is_isogram, reverse_each_word, count_digits, strip_tags ───

// ROT47 -> string/encode.zig

pub export fn str_is_isogram(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 1;
    var seen = [_]bool{false} ** 256;
    for (src) |c| {
        var ch = c;
        if (ch >= 'A' and ch <= 'Z') ch += 32;
        if (ch >= 'a' and ch <= 'z') {
            if (seen[ch]) return 0;
            seen[ch] = true;
        }
    }
    return 1;
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

pub export fn str_count_digits(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') count += 1;
    }
    return count;
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

// ─── Batch 19: to_slug, count_spaces, normalize_spaces, mask_email, pluralize ───

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

pub export fn str_count_spaces(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c == ' ') count += 1;
    }
    return count;
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

// mask_email, pluralize -> string/nlp.zig

// ─── Batch 20: deduplicate_lines, remove_blank_lines, extract_numbers, extract_emails, quote ───

pub export fn str_deduplicate_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    // Track seen lines — simple O(n^2) for correctness
    var line_starts: [1024]usize = undefined;
    var line_ends: [1024]usize = undefined;
    var line_count: usize = 0;
    // Parse lines
    var pos: usize = 0;
    var first = true;
    while (pos <= src.len and line_count < 1024) {
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        const end = pos;
        // Check if this line is a duplicate
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
        if (pos < src.len) pos += 1 else break; // skip \n
    }
    return result;
}

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
            if (!first) result.data.appendSlice(gpa, "\n") catch { setError(.out_of_memory); };
            result.data.appendSlice(gpa, line) catch { setError(.out_of_memory); };
            first = false;
        }
        if (pos < src.len) pos += 1 else break;
    }
    return result;
}

// extract_numbers, extract_emails -> string/nlp.zig

// Quote, Unquote, CSV field -> string/encode.zig

// ─── Batch 21: number_lines, hide, extract_words ───

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

// extract_words -> string/nlp.zig

// ─── Batch 22: expand_tabs, sentence_count, chop, scan_int, to_ordinal ───

pub export fn str_expand_tabs(handle: ?*StzString, tab_size: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const ts: usize = if (tab_size < 1) 4 else @intCast(tab_size);
    const result = str_new() orelse return null;
    for (src) |c| {
        if (c == '\t') {
            var i: usize = 0;
            while (i < ts) : (i += 1) {
                result.data.appendSlice(gpa, " ") catch break;
            }
        } else {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// str_sentence_count -> string/split.zig

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

// ─── cp_count: number of codepoints in the string ───

pub export fn str_cp_count(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    return @intCast(utf8CodepointCount(src));
}

// str_chars_split -> string/split.zig

// batch 17 ─── NLP: Jaro-Winkler, Metaphone, N-grams ───

// Jaro, Jaro-Winkler -> string/nlp.zig

// Metaphone -> string/nlp.zig

// char_ngrams, word_ngrams -> string/nlp.zig

// ─── Tests ───

test "sort_chars" {
    const s1 = str_from("dcba", 4);
    const asc = str_sort_chars_asc(s1);
    try std.testing.expect(mem.eql(u8, str_data(asc)[0..@intCast(str_size(asc))], "abcd"));
    str_free(asc);

    const desc = str_sort_chars_desc(s1);
    try std.testing.expect(mem.eql(u8, str_data(desc)[0..@intCast(str_size(desc))], "dcba"));
    str_free(desc);
    str_free(s1);
}

test "find_all_char" {
    const s1 = str_from("abcabc", 6);
    const fr = str_find_all_char(s1, 'a');
    try std.testing.expect(fr != null);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try std.testing.expectEqual(@as(c_int, 1), stz_find_result_get(fr, 0));
    try std.testing.expectEqual(@as(c_int, 4), stz_find_result_get(fr, 1));
    stz_find_result_free(fr);
    str_free(s1);
}

test "hash" {
    const s1 = str_from("hello", 5);
    const h1 = str_hash(s1);
    const s2 = str_from("hello", 5);
    const h2 = str_hash(s2);
    try std.testing.expectEqual(h1, h2);
    str_free(s2);

    const s3 = str_from("world", 5);
    const h3 = str_hash(s3);
    try std.testing.expect(h1 != h3);
    str_free(s3);
    str_free(s1);
}

test "count_char" {
    const s1 = str_from("mississippi", 11);
    try std.testing.expectEqual(@as(c_int, 4), str_count_char(s1, 's'));
    try std.testing.expectEqual(@as(c_int, 2), str_count_char(s1, 'p'));
    try std.testing.expectEqual(@as(c_int, 4), str_count_char(s1, 'i'));
    str_free(s1);
}

test "replace_char" {
    const s1 = str_from("hello", 5);
    const r1 = str_replace_char(s1, 'l', 'r');
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "herro"));
    str_free(r1);
    str_free(s1);
}

test "copy" {
    const s1 = str_from("hello", 5);
    const s2 = str_copy(s1);
    try std.testing.expect(mem.eql(u8, str_data(s2)[0..@intCast(str_size(s2))], "hello"));
    str_free(s2);
    str_free(s1);
}

test "compare" {
    const s1 = str_from("abc", 3);
    const s2 = str_from("abc", 3);
    const s3 = str_from("abd", 3);
    const s4 = str_from("ab", 2);
    try std.testing.expectEqual(@as(c_int, 0), str_compare(s1, s2));
    try std.testing.expectEqual(@as(c_int, -1), str_compare(s1, s3));
    try std.testing.expectEqual(@as(c_int, 1), str_compare(s3, s1));
    try std.testing.expectEqual(@as(c_int, 1), str_compare(s1, s4));
    try std.testing.expectEqual(@as(c_int, -1), str_compare(s4, s1));
    str_free(s4);
    str_free(s3);
    str_free(s2);
    str_free(s1);
}

test "remove_first_occurrence" {
    const s1 = str_from("hello world hello", 17);
    const r1 = str_remove_first_occurrence(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], " world hello"));
    str_free(r1);
    str_free(s1);
}

test "remove_last_occurrence" {
    const s1 = str_from("hello world hello", 17);
    const r1 = str_remove_last_occurrence(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world "));
    str_free(r1);
    str_free(s1);
}

test "remove_nth_occurrence" {
    const s1 = str_from("abcabcabc", 9);
    const r0 = str_remove_nth_occurrence(s1, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..@intCast(str_size(r0))], "abcabc"));
    str_free(r0);
    const r1 = str_remove_nth_occurrence(s1, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abcabc"));
    str_free(r1);
    const r2 = str_remove_nth_occurrence(s1, "abc", 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abcabc"));
    str_free(r2);
    str_free(s1);
}

test "repeat_char" {
    const r1 = str_repeat_char('*', 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "*****"));
    str_free(r1);

    const r2 = str_repeat_char('-', 0);
    try std.testing.expectEqual(@as(c_int, 0), str_size(r2));
    str_free(r2);
}

test "insert_before_each" {
    const s1 = str_from("abcabc", 6);
    const r1 = str_insert_before_each(s1, "abc", 3, "[", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "[abc[abc"));
    str_free(r1);
    str_free(s1);
}

test "insert_after_each" {
    const s1 = str_from("abcabc", 6);
    const r1 = str_insert_after_each(s1, "abc", 3, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abc]abc]"));
    str_free(r1);
    str_free(s1);
}

test "truncate" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_truncate(s1, 5, "...", 3);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello..."));
    str_free(r1);

    // String shorter than max - no truncation
    const r2 = str_truncate(s1, 20, "...", 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Hello World"));
    str_free(r2);
    str_free(s1);
}

test "wrap_at" {
    const s1 = str_from("hello world foo bar", 19);
    const r1 = str_wrap_at(s1, 10);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello\nworld foo\nbar"));
    str_free(r1);
    str_free(s1);
}

test "is_chars_sorted" {
    const s1 = str_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_asc(s1));
    try std.testing.expectEqual(@as(c_int, 0), str_is_chars_sorted_desc(s1));
    str_free(s1);

    const s2 = str_from("dcba", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_chars_sorted_asc(s2));
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_desc(s2));
    str_free(s2);

    const s3 = str_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_asc(s3));
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_desc(s3));
    str_free(s3);
}

test "remove_prefix_suffix" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_remove_prefix(s1, "Hello ", 6);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "World"));
    str_free(r1);

    const r2 = str_remove_suffix(s1, " World", 6);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Hello"));
    str_free(r2);

    // No match - returns copy
    const r3 = str_remove_prefix(s1, "xyz", 3);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "Hello World"));
    str_free(r3);
    str_free(s1);
}

test "ensure_prefix_suffix" {
    const s1 = str_from("world", 5);
    const r1 = str_ensure_prefix(s1, "hello ", 6);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("hello world", 11);
    const r2 = str_ensure_prefix(s2, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello world"));
    str_free(r2);

    const r3 = str_ensure_suffix(s2, ".txt", 4);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "hello world.txt"));
    str_free(r3);
    str_free(s2);
}

test "squeeze_char" {
    const s1 = str_from("heeellooo", 9);
    const r1 = str_squeeze_char(s1, 'e');
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hellooo"));
    str_free(r1);

    const r2 = str_squeeze_char(s1, 'o');
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "heeello"));
    str_free(r2);
    str_free(s1);
}

test "capitalize_decapitalize_first" {
    const s1 = str_from("hello world", 11);
    const r1 = str_capitalize_first(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello world"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("Hello", 5);
    const r2 = str_decapitalize_first(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello"));
    str_free(r2);
    str_free(s2);
}

test "zfill" {
    const s1 = str_from("42", 2);
    const r1 = str_zfill(s1, 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "00042"));
    str_free(r1);

    const r2 = str_zfill(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "42"));
    str_free(r2);
    str_free(s1);
}

test "tab_expand" {
    const s1 = str_from("a\tb\tc", 5);
    const r1 = str_tab_expand(s1, 4);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "a    b    c"));
    str_free(r1);
    str_free(s1);
}

test "count_overlapping" {
    const s1 = str_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 3), str_count_overlapping(s1, "aa", 2));
    str_free(s1);

    const s2 = str_from("abcabc", 6);
    try std.testing.expectEqual(@as(c_int, 2), str_count_overlapping(s2, "abc", 3));
    str_free(s2);
}

test "replace_at" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_replace_at(s1, 6, 1, "-", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello-World"));
    str_free(r1);
    str_free(s1);
}

test "contains_any_of" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_any_of(s1, "aeiou", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_any_of(s1, "xyz", 3));
    str_free(s1);
}

test "contains_all_of" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_all_of(s1, "helo", 4));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_all_of(s1, "heloz", 5));
    str_free(s1);
}

test "foldcase" {
    const s1 = str_from("Hello WORLD", 11);
    const folded = str_foldcase(s1);
    try std.testing.expect(mem.eql(u8, str_data(folded)[0..@intCast(str_size(folded))], "hello world"));
    str_free(folded);
    str_free(s1);
}

test "center_pad" {
    const s1 = str_from("hi", 2);
    const padded = str_center_pad(s1, 6, "-", 1);
    try std.testing.expect(mem.eql(u8, str_data(padded)[0..@intCast(str_size(padded))], "--hi--"));
    str_free(padded);

    const padded_odd = str_center_pad(s1, 7, "*", 1);
    try std.testing.expect(mem.eql(u8, str_data(padded_odd)[0..@intCast(str_size(padded_odd))], "**hi***"));
    str_free(padded_odd);
    str_free(s1);
}

test "only_letters" {
    const s1 = str_from("h3ll0 w0rld!", 12);
    const letters = str_only_letters(s1);
    try std.testing.expect(mem.eql(u8, str_data(letters)[0..@intCast(str_size(letters))], "hllwrld"));
    str_free(letters);
    str_free(s1);
}

test "only_digits" {
    const s1 = str_from("a1b2c3", 6);
    const digits = str_only_digits(s1);
    try std.testing.expect(mem.eql(u8, str_data(digits)[0..@intCast(str_size(digits))], "123"));
    str_free(digits);
    str_free(s1);
}

test "remove_whitespace" {
    const s1 = str_from("h e l l o", 9);
    const nows = str_remove_whitespace(s1);
    try std.testing.expect(mem.eql(u8, str_data(nows)[0..@intCast(str_size(nows))], "hello"));
    str_free(nows);
    str_free(s1);
}

test "is_palindrome" {
    const s1 = str_from("abcba", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s1));
    str_free(s1);

    const s2 = str_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome(s2));
    str_free(s2);

    const s3 = str_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s3));
    str_free(s3);
}

test "count_words" {
    const s1 = str_from("hello world foo", 15);
    try std.testing.expectEqual(@as(c_int, 3), str_count_words(s1));
    str_free(s1);

    const s2 = str_from("  hello  ", 9);
    try std.testing.expectEqual(@as(c_int, 1), str_count_words(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_count_words(s3));
    str_free(s3);
}

test "nth_word" {
    const s1 = str_from("hello world foo", 15);
    const w0 = str_nth_word(s1, 0);
    try std.testing.expect(mem.eql(u8, str_data(w0)[0..@intCast(str_size(w0))], "hello"));
    str_free(w0);

    const w1 = str_nth_word(s1, 1);
    try std.testing.expect(mem.eql(u8, str_data(w1)[0..@intCast(str_size(w1))], "world"));
    str_free(w1);

    const w2 = str_nth_word(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(w2)[0..@intCast(str_size(w2))], "foo"));
    str_free(w2);
    str_free(s1);
}

test "chars_between" {
    const s1 = str_from("abcdef", 6);
    const between = str_chars_between(s1, 2, 5);
    try std.testing.expect(mem.eql(u8, str_data(between)[0..@intCast(str_size(between))], "cd"));
    str_free(between);
    str_free(s1);
}

test "is_alphanumeric" {
    const s1 = str_from("hello123", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alphanumeric(s1));
    str_free(s1);

    const s2 = str_from("hello 123", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alphanumeric(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alphanumeric(s3));
    str_free(s3);
}

test "ljust_rjust" {
    const s1 = str_from("hi", 2);
    const lj = str_ljust(s1, 5, ".", 1);
    try std.testing.expect(mem.eql(u8, str_data(lj)[0..@intCast(str_size(lj))], "hi..."));
    str_free(lj);

    const rj = str_rjust(s1, 5, ".", 1);
    try std.testing.expect(mem.eql(u8, str_data(rj)[0..@intCast(str_size(rj))], "...hi"));
    str_free(rj);
    str_free(s1);
}

test "common_prefix" {
    const s1 = str_from("hello world", 11);
    const s2 = str_from("hello there", 11);
    const cp = str_common_prefix(s1, s2);
    try std.testing.expect(mem.eql(u8, str_data(cp)[0..@intCast(str_size(cp))], "hello "));
    str_free(cp);
    str_free(s2);
    str_free(s1);
}

test "indent_dedent" {
    const s1 = str_from("line1\nline2", 11);
    const indented = str_indent(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(indented)[0..@intCast(str_size(indented))], "  line1\n  line2"));
    str_free(indented);
    str_free(s1);

    const s2 = str_from("    hello\n    world", 19);
    const dedented = str_dedent(s2);
    try std.testing.expect(mem.eql(u8, str_data(dedented)[0..@intCast(str_size(dedented))], "hello\nworld"));
    str_free(dedented);
    str_free(s2);
}

test "camel_snake_kebab" {
    const s1 = str_from("hello world", 11);
    const camel = str_to_camel_case(s1);
    try std.testing.expect(mem.eql(u8, str_data(camel)[0..@intCast(str_size(camel))], "helloWorld"));
    str_free(camel);
    str_free(s1);

    const s2 = str_from("helloWorld", 10);
    const snake = str_to_snake_case(s2);
    try std.testing.expect(mem.eql(u8, str_data(snake)[0..@intCast(str_size(snake))], "hello_world"));
    str_free(snake);

    const kebab = str_to_kebab_case(s2);
    try std.testing.expect(mem.eql(u8, str_data(kebab)[0..@intCast(str_size(kebab))], "hello-world"));
    str_free(kebab);
    str_free(s2);
}

test "partition" {
    const s1 = str_from("hello:world:foo", 15);
    const before = str_partition(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(before)[0..@intCast(str_size(before))], "hello"));
    str_free(before);

    const after = str_partition_after(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(after)[0..@intCast(str_size(after))], "world:foo"));
    str_free(after);

    // Not found
    const before2 = str_partition(s1, "xyz", 3);
    try std.testing.expect(mem.eql(u8, str_data(before2)[0..@intCast(str_size(before2))], "hello:world:foo"));
    str_free(before2);

    const after2 = str_partition_after(s1, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_size(after2));
    str_free(after2);
    str_free(s1);
}

test "rpartition" {
    const s1 = str_from("hello:world:foo", 15);
    const before = str_rpartition(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(before)[0..@intCast(str_size(before))], "hello:world"));
    str_free(before);

    const after = str_rpartition_after(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(after)[0..@intCast(str_size(after))], "foo"));
    str_free(after);
    str_free(s1);
}

test "squeeze" {
    const s1 = str_from("heeellooo", 9);
    const r1 = str_squeeze(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "helo"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("aabbcc", 6);
    const r2 = str_squeeze(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);
    str_free(s2);
}

test "is_digit" {
    const s1 = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_digit(s1));
    str_free(s1);

    const s2 = str_from("123a5", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_digit(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_digit(s3));
    str_free(s3);
}

test "interleave" {
    const s1 = str_from("abc", 3);
    const r1 = str_interleave(s1, ",", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "a,b,c"));
    str_free(r1);

    const r2 = str_interleave(s1, " - ", 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "a - b - c"));
    str_free(r2);
    str_free(s1);
}

test "strip_chars" {
    const s1 = str_from("hello world!", 12);
    const r1 = str_strip_chars(s1, "lo", 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "he wrd!"));
    str_free(r1);
    str_free(s1);

    // Strip vowels
    const s2 = str_from("programming", 11);
    const r2 = str_strip_chars(s2, "aeiou", 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "prgrmmng"));
    str_free(r2);
    str_free(s2);
}

test "keep_chars" {
    const s1 = str_from("hello world!", 12);
    const r1 = str_keep_chars(s1, "lo", 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "llool"));
    str_free(r1);
    str_free(s1);
}

test "replace2" {
    const s1 = str_from("hello world", 11);
    const r1 = str_replace2(s1, "hello", 5, "hi", 2, "world", 5, "earth", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hi earth"));
    str_free(r1);
    str_free(s1);
}

test "rotate" {
    const s1 = str_from("abcde", 5);
    const r1 = str_rotate(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "cdeab"));
    str_free(r1);

    // Rotate right (negative)
    const r2 = str_rotate(s1, -1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "eabcd"));
    str_free(r2);

    // Rotate by length = no change
    const r3 = str_rotate(s1, 5);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "abcde"));
    str_free(r3);
    str_free(s1);
}

test "repeat_to_length" {
    const s1 = str_from("abc", 3);
    const r1 = str_repeat_to_length(s1, 7);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abcabca"));
    str_free(r1);

    const r2 = str_repeat_to_length(s1, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);

    const r3 = str_repeat_to_length(s1, 1);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "a"));
    str_free(r3);
    str_free(s1);
}

test "remove_between" {
    const s1 = str_from("hello [world] end", 17);
    const r1 = str_remove_between(s1, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello  end"));
    str_free(r1);
    str_free(s1);

    // HTML tags
    const s2 = str_from("before<tag>inside</tag>after", 28);
    const r2 = str_remove_between(s2, "<tag>", 5, "</tag>", 6);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "beforeafter"));
    str_free(r2);
    str_free(s2);
}

test "is_blank" {
    const s1 = str_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_blank(s1));
    str_free(s1);

    const s2 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 1), str_is_blank(s2));
    str_free(s2);

    const s3 = str_from(" a ", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_blank(s3));
    str_free(s3);
}

test "to_pascal_case" {
    const s1 = str_from("hello_world", 11);
    const r1 = str_to_pascal_case(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "HelloWorld"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("my-kebab-case", 13);
    const r2 = str_to_pascal_case(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "MyKebabCase"));
    str_free(r2);
    str_free(s2);

    const s3 = str_from("already PascalCase", 18);
    const r3 = str_to_pascal_case(s3);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "AlreadyPascalCase"));
    str_free(r3);
    str_free(s3);
}

test "is_identifier" {
    const s1 = str_from("hello_world", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_identifier(s1));
    str_free(s1);

    const s2 = str_from("_private", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_identifier(s2));
    str_free(s2);

    const s3 = str_from("3invalid", 8);
    try std.testing.expectEqual(@as(c_int, 0), str_is_identifier(s3));
    str_free(s3);

    const s4 = str_from("has space", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_identifier(s4));
    str_free(s4);

    const s5 = str_from("CamelCase123", 12);
    try std.testing.expectEqual(@as(c_int, 1), str_is_identifier(s5));
    str_free(s5);
}

test "replace_between" {
    const s1 = str_from("hello [world] end", 17);
    const r1 = str_replace_between(s1, "[", 1, "]", 1, "REPLACED", 8);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello REPLACED end"));
    str_free(r1);
    str_free(s1);

    // Replace with empty
    const s2 = str_from("a<b>c", 5);
    const r2 = str_replace_between(s2, "<", 1, ">", 1, "", 0);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "ac"));
    str_free(r2);
    str_free(s2);
}

test "contains_only" {
    const s1 = str_from("aabbcc", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_only(s1, "abc", 3));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_only(s1, "ab", 2));
    str_free(s1);

    const s2 = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_only(s2, "0123456789", 10));
    str_free(s2);
}

test "capitalize_words" {
    const s1 = str_from("hello world", 11);
    const r1 = str_capitalize_words(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello World"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("already OK here", 15);
    const r2 = str_capitalize_words(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Already OK Here"));
    str_free(r2);
    str_free(s2);
}

test "swap_chars" {
    const s1 = str_from("abcde", 5);
    const r1 = str_swap_chars(s1, 1, 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "ebcda"));
    str_free(r1);

    const r2 = str_swap_chars(s1, 2, 4);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "adcbe"));
    str_free(r2);
    str_free(s1);
}

test "encode_hex" {
    const s1 = str_from("Hi", 2);
    const r1 = str_encode_hex(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "4869"));
    str_free(r1);
    str_free(s1);
}

test "decode_hex" {
    const s1 = str_from("4869", 4);
    const r1 = str_decode_hex(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hi"));
    str_free(r1);
    str_free(s1);
}

test "reverse_words" {
    const s1 = str_from("hello world foo", 15);
    const r1 = str_reverse_words(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "foo world hello"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("single", 6);
    const r2 = str_reverse_words(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "single"));
    str_free(r2);
    str_free(s2);
}

test "collapse_spaces" {
    const s1 = str_from("  hello   world  ", 17);
    const r1 = str_collapse_spaces(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("no extra spaces", 15);
    const r2 = str_collapse_spaces(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "no extra spaces"));
    str_free(r2);
    str_free(s2);
}

test "is_anagram" {
    const s1 = str_from("listen", 6);
    const s2 = str_from("silent", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_is_anagram(s1, s2));
    str_free(s2);

    const s3 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_anagram(s1, s3));
    str_free(s3);
    str_free(s1);
}

test "mask" {
    const s1 = str_from("hello@mail.com", 14);
    const r1 = str_mask(s1, "*", 1, 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "he**********om"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("ab", 2);
    const r2 = str_mask(s2, "*", 1, 2);
    // Too short to mask (2 chars, keep 2+2=4), returns as-is
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "ab"));
    str_free(r2);
    str_free(s2);
}

test "count_runs" {
    const s1 = str_from("aabbbcc", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_count_runs(s1));
    str_free(s1);

    const s2 = str_from("abcde", 5);
    try std.testing.expectEqual(@as(c_int, 5), str_count_runs(s2));
    str_free(s2);

    const s3 = str_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_count_runs(s3));
    str_free(s3);
}

test "hamming_distance" {
    const s1 = str_from("karolin", 7);
    const s2 = str_from("kathrin", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_hamming_distance(s1, s2));
    str_free(s2);
    str_free(s1);

    const s3 = str_from("abc", 3);
    const s4 = str_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, -1), str_hamming_distance(s3, s4));
    str_free(s4);
    str_free(s3);
}

test "remove_vowels" {
    const h = str_from("Hello World", 11);
    const r = str_remove_vowels(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hll Wrld"));
    str_free(r);
    str_free(h);

    const h2 = str_from("aeiou", 5);
    const r2 = str_remove_vowels(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_size(r2));
    str_free(r2);
    str_free(h2);
}

test "only_vowels" {
    const h = str_from("Hello World", 11);
    const r = str_only_vowels(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "eoo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("xyz", 3);
    const r2 = str_only_vowels(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_size(r2));
    str_free(r2);
    str_free(h2);
}

test "is_pangram" {
    const h = str_from("The quick brown fox jumps over the lazy dog", 43);
    try std.testing.expectEqual(@as(c_int, 1), str_is_pangram(h));
    str_free(h);

    const h2 = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_pangram(h2));
    str_free(h2);
}

test "ngram" {
    const h = str_from("hello", 5);
    const r = str_ngram(h, 2, 0);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "he"));
    str_free(r);

    const r2 = str_ngram(h, 2, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "lo"));
    str_free(r2);

    const r3 = str_ngram(h, 2, 4);
    try std.testing.expectEqual(@as(StzStringHandle, null), r3);
    str_free(h);
}

test "ngram_count" {
    const h = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), str_ngram_count(h, 2));
    try std.testing.expectEqual(@as(c_int, 3), str_ngram_count(h, 3));
    try std.testing.expectEqual(@as(c_int, 1), str_ngram_count(h, 5));
    try std.testing.expectEqual(@as(c_int, 0), str_ngram_count(h, 6));
    str_free(h);
}

test "count_consonants" {
    const h = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 7), str_count_consonants(h));
    str_free(h);

    const h2 = str_from("aeiou", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_count_consonants(h2));
    str_free(h2);
}

test "to_sentence_case" {
    const h = str_from("hELLO WORLD", 11);
    const r = str_to_sentence_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello world"));
    str_free(r);
    str_free(h);

    const h2 = str_from("already lowercase", 17);
    const r2 = str_to_sentence_case(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Already lowercase"));
    str_free(r2);
    str_free(h2);
}

test "is_balanced" {
    const h1 = str_from("(hello [world])", 15);
    try std.testing.expectEqual(@as(c_int, 1), str_is_balanced(h1));
    str_free(h1);

    const h2 = str_from("(hello [world)", 14);
    try std.testing.expectEqual(@as(c_int, 0), str_is_balanced(h2));
    str_free(h2);

    const h3 = str_from("{[()]}", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_is_balanced(h3));
    str_free(h3);
}

test "slug" {
    const h = str_from("Hello World! This is a Test", 27);
    const r = str_slug(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello-world-this-is-a-test"));
    str_free(r);
    str_free(h);

    const h2 = str_from("  Multiple   Spaces  ", 21);
    const r2 = str_slug(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "multiple-spaces"));
    str_free(r2);
    str_free(h2);
}

test "chunk" {
    const h = str_from("abcdefgh", 8);
    const r0 = str_chunk(h, 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..@intCast(str_size(r0))], "abc"));
    str_free(r0);

    const r1 = str_chunk(h, 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "def"));
    str_free(r1);

    const r2 = str_chunk(h, 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "gh"));
    str_free(r2);

    const r3 = str_chunk(h, 3, 3);
    try std.testing.expectEqual(@as(StzStringHandle, null), r3);
    str_free(h);
}

test "count_vowels" {
    const h = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 3), str_count_vowels(h));
    str_free(h);

    const h2 = str_from("bcdfg", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_count_vowels(h2));
    str_free(h2);
}

test "longest_run" {
    const h = str_from("aabbbcccc", 9);
    try std.testing.expectEqual(@as(c_int, 4), str_longest_run(h));
    str_free(h);

    const h2 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_longest_run(h2));
    str_free(h2);
}

test "trim_chars" {
    const h = str_from("***hello***", 11);
    const r = str_trim_chars(h, "*", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello"));
    str_free(r);
    str_free(h);

    const h2 = str_from("--=hello=--", 11);
    const r2 = str_trim_chars(h2, "-=", 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello"));
    str_free(r2);
    str_free(h2);
}

test "is_email_like" {
    const h1 = str_from("user@example.com", 16);
    try std.testing.expectEqual(@as(c_int, 1), str_is_email_like(h1));
    str_free(h1);

    const h2 = str_from("no-at-sign.com", 14);
    try std.testing.expectEqual(@as(c_int, 0), str_is_email_like(h2));
    str_free(h2);

    const h3 = str_from("@nodomain", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_email_like(h3));
    str_free(h3);
}

test "camel_to_words" {
    const h = str_from("camelCaseString", 15);
    const r = str_camel_to_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "camel Case String"));
    str_free(r);
    str_free(h);

    const h2 = str_from("HTMLParser", 10);
    const r2 = str_camel_to_words(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "HTML Parser"));
    str_free(r2);
    str_free(h2);
}

test "initials" {
    const h = str_from("Hello World", 11);
    const r = str_initials(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "HW"));
    str_free(r);
    str_free(h);

    const h2 = str_from("united states of america", 24);
    const r2 = str_initials(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "usoa"));
    str_free(r2);
    str_free(h2);
}

test "remove_duplicate_words" {
    const h = str_from("the the cat sat on the mat", 26);
    const r = str_remove_duplicate_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "the cat sat on mat"));
    str_free(r);
    str_free(h);

    const h2 = str_from("abc def abc", 11);
    const r2 = str_remove_duplicate_words(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc def"));
    str_free(r2);
    str_free(h2);
}

test "is_url_like" {
    const h1 = str_from("https://example.com", 19);
    try std.testing.expectEqual(@as(c_int, 1), str_is_url_like(h1));
    str_free(h1);

    const h2 = str_from("http://example.com", 18);
    try std.testing.expectEqual(@as(c_int, 1), str_is_url_like(h2));
    str_free(h2);

    const h3 = str_from("ftp://files.com", 15);
    try std.testing.expectEqual(@as(c_int, 0), str_is_url_like(h3));
    str_free(h3);
}

test "escape_html" {
    const h = str_from("<b>&hi</b>", 10);
    const r = str_escape_html(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "&lt;b&gt;&amp;hi&lt;/b&gt;"));
    str_free(r);
    str_free(h);
}

test "unescape_html" {
    const h = str_from("&lt;b&gt;hello&lt;/b&gt;", 24);
    const r = str_unescape_html(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "<b>hello</b>"));
    str_free(r);
    str_free(h);
}

test "count_sentences" {
    const h = str_from("Hello. How are you? Fine!", 25);
    try std.testing.expectEqual(@as(c_int, 3), str_count_sentences(h));
    str_free(h);

    const h2 = str_from("No sentence end", 15);
    try std.testing.expectEqual(@as(c_int, 0), str_count_sentences(h2));
    str_free(h2);
}

test "title_smart" {
    const h = str_from("the lord of the rings", 21);
    const r = str_title_smart(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "The Lord of the Rings"));
    str_free(r);
    str_free(h);

    const h2 = str_from("a tale of two cities", 20);
    const r2 = str_title_smart(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "A Tale of Two Cities"));
    str_free(r2);
    str_free(h2);
}

test "remove_punctuation" {
    const h = str_from("Hello, World! How's it?", 23);
    const r = str_remove_punctuation(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello World Hows it"));
    str_free(r);
    str_free(h);
}

test "is_float" {
    const h1 = str_from("3.14", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_float(h1));
    str_free(h1);

    const h2 = str_from("-0.5", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_float(h2));
    str_free(h2);

    const h3 = str_from("42", 2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_float(h3));
    str_free(h3);

    const h4 = str_from("1.2.3", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_float(h4));
    str_free(h4);
}

test "digit_sum" {
    const h = str_from("a1b2c3", 6);
    try std.testing.expectEqual(@as(c_int, 6), str_digit_sum(h));
    str_free(h);

    const h2 = str_from("999", 3);
    try std.testing.expectEqual(@as(c_int, 27), str_digit_sum(h2));
    str_free(h2);

    const h3 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_digit_sum(h3));
    str_free(h3);
}

test "to_alternating_case" {
    const h = str_from("hello world", 11);
    const r = str_to_alternating_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hElLo WoRlD"));
    str_free(r);
    str_free(h);
}

test "count_upper_lower" {
    const h = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 2), str_count_upper(h));
    try std.testing.expectEqual(@as(c_int, 8), str_count_lower(h));
    str_free(h);
}

test "is_camel_case" {
    const h1 = str_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 1), str_is_camel_case(h1));
    str_free(h1);

    const h2 = str_from("PascalCase", 10);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h2));
    str_free(h2);

    const h3 = str_from("lowercase", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h3));
    str_free(h3);

    const h4 = str_from("has space", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h4));
    str_free(h4);
}

test "common_chars" {
    const h1 = str_from("hello", 5);
    const h2 = str_from("world", 5);
    const r = str_common_chars(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "lo"));
    str_free(r);
    str_free(h2);
    str_free(h1);
}

test "count_lines" {
    const h1 = str_from("hello\nworld\nfoo", 15);
    try std.testing.expectEqual(@as(c_int, 3), str_count_lines(h1));
    str_free(h1);

    const h2 = str_from("single line", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_count_lines(h2));
    str_free(h2);

    const h3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_count_lines(h3));
    str_free(h3);
}

test "is_snake_case" {
    const h1 = str_from("hello_world", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_snake_case(h1));
    str_free(h1);

    const h2 = str_from("my_var_name", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_snake_case(h2));
    str_free(h2);

    const h3 = str_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h3));
    str_free(h3);

    const h4 = str_from("hello__world", 12);
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h4));
    str_free(h4);

    const h5 = str_from("single", 6);
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h5));
    str_free(h5);
}

test "is_kebab_case" {
    const h1 = str_from("hello-world", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_kebab_case(h1));
    str_free(h1);

    const h2 = str_from("my-var-name", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_kebab_case(h2));
    str_free(h2);

    const h3 = str_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_kebab_case(h3));
    str_free(h3);

    const h4 = str_from("hello--world", 12);
    try std.testing.expectEqual(@as(c_int, 0), str_is_kebab_case(h4));
    str_free(h4);
}

test "count_unique_chars" {
    const h1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), str_count_unique_chars(h1));
    str_free(h1);

    const h2 = str_from("aaa", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_count_unique_chars(h2));
    str_free(h2);

    const h3 = str_from("abcdef", 6);
    try std.testing.expectEqual(@as(c_int, 6), str_count_unique_chars(h3));
    str_free(h3);
}

test "caesar" {
    const h1 = str_from("abc", 3);
    const r1 = str_caesar(h1, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "bcd"));
    str_free(r1);
    str_free(h1);

    const h2 = str_from("xyz", 3);
    const r2 = str_caesar(h2, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);
    str_free(h2);

    const h3 = str_from("Hello, World!", 13);
    const r3 = str_caesar(h3, 13);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "Uryyb, Jbeyq!"));
    str_free(r3);
    str_free(h3);
}

test "mirror" {
    const h = str_from("abc", 3);
    const r = str_mirror(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "abccba"));
    str_free(r);
    str_free(h);

    const h2 = str_from("a", 1);
    const r2 = str_mirror(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "aa"));
    str_free(r2);
    str_free(h2);
}

test "repeat_each_char" {
    const h = str_from("abc", 3);
    const r = str_repeat_each_char(h, 2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "aabbcc"));
    str_free(r);
    str_free(h);

    const h2 = str_from("hi", 2);
    const r2 = str_repeat_each_char(h2, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hhhiii"));
    str_free(r2);
    str_free(h2);
}

test "starts_with_any" {
    const h = str_from("https://example.com", 19);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_any(h, "http|ftp|ssh", 12));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_any(h, "ftp|ssh", 7));
    str_free(h);
}

test "ends_with_any" {
    const h = str_from("file.zig", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_any(h, ".txt|.zig|.rs", 13));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_any(h, ".txt|.rs|.go", 12));
    str_free(h);
}

test "to_binary" {
    const h = str_from("Hi", 2);
    const r = str_to_binary(h);
    // H = 72 = 01001000, i = 105 = 01101001
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "01001000 01101001"));
    str_free(r);
    str_free(h);
}

test "sort_words" {
    const h = str_from("banana apple cherry", 19);
    const r = str_sort_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "apple banana cherry"));
    str_free(r);
    str_free(h);

    const h2 = str_from("zig is fun", 10);
    const r2 = str_sort_words(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "fun is zig"));
    str_free(r2);
    str_free(h2);
}

test "unique_words" {
    const h = str_from("the cat and the dog and cat", 27);
    const r = str_unique_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "the cat and dog"));
    str_free(r);
    str_free(h);
}

test "from_binary" {
    const h = str_from("01001000 01101001", 17);
    const r = str_from_binary(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hi"));
    str_free(r);
    str_free(h);
}

test "swap_words" {
    const h = str_from("hello world foo", 15);
    const r = str_swap_words(h, 0, 2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "foo world hello"));
    str_free(r);
    str_free(h);
}

test "to_pig_latin" {
    const h = str_from("hello world", 11);
    const r = str_to_pig_latin(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "ellohay orldway"));
    str_free(r);
    str_free(h);

    const h2 = str_from("apple is", 8);
    const r2 = str_to_pig_latin(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "appleyay isyay"));
    str_free(r2);
    str_free(h2);
}

test "run_length_encode" {
    const h = str_from("aaabbc", 6);
    const r = str_run_length_encode(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "3a2b1c"));
    str_free(r);
    str_free(h);

    const h2 = str_from("abc", 3);
    const r2 = str_run_length_encode(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "1a1b1c"));
    str_free(r2);
    str_free(h2);
}

test "run_length_decode" {
    const h = str_from("3a2b1c", 6);
    const r = str_run_length_decode(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "aaabbc"));
    str_free(r);
    str_free(h);
}

test "count_paragraphs" {
    const h1 = str_from("para1\n\npara2\n\npara3", 19);
    try std.testing.expectEqual(@as(c_int, 3), str_count_paragraphs(h1));
    str_free(h1);

    const h2 = str_from("single paragraph", 16);
    try std.testing.expectEqual(@as(c_int, 1), str_count_paragraphs(h2));
    str_free(h2);
}

test "zigzag" {
    const h = str_from("WEAREDISCOVERED", 15);
    const r = str_zigzag(h, 3);
    // Rail 0: W...E...C...R...  -> WECR (positions 0,4,8,12)
    // Rail 1: .A.R.D.S.O.E.E.  -> ARDSOEE (positions 1,3,5,7,9,11,13)
    // Rail 2: ..E...I...V...D  -> EIVD (positions 2,6,10,14)
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "WECRERDSOEEAIVD"));
    str_free(r);
    str_free(h);
}

test "to_morse" {
    const h = str_from("SOS", 3);
    const r = str_to_morse(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "... --- ..."));
    str_free(r);
    str_free(h);

    const h2 = str_from("HI", 2);
    const r2 = str_to_morse(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], ".... .."));
    str_free(r2);
    str_free(h2);
}

test "to_base64" {
    const h = str_from("Hello", 5);
    const r = str_to_base64(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "SGVsbG8="));
    str_free(r);
    str_free(h);

    const h2 = str_from("Hi", 2);
    const r2 = str_to_base64(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "SGk="));
    str_free(r2);
    str_free(h2);
}

test "from_base64" {
    const h = str_from("SGVsbG8=", 8);
    const r = str_from_base64(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello"));
    str_free(r);
    str_free(h);
}

test "xor_cipher" {
    const h = str_from("ABC", 3);
    const r = str_xor_cipher(h, 0x20);
    // A(65)^32=97='a', B(66)^32=98='b', C(67)^32=99='c'
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "abc"));
    // XOR again to get back original
    const r2 = str_xor_cipher(r, 0x20);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "ABC"));
    str_free(r2);
    str_free(r);
    str_free(h);
}

test "entropy" {
    const h1 = str_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_entropy(h1));
    str_free(h1);

    // "ab" has entropy of 1.0 bit -> *100 = 100
    const h2 = str_from("ab", 2);
    try std.testing.expectEqual(@as(c_int, 100), str_entropy(h2));
    str_free(h2);
}

test "char_frequency_top" {
    const h = str_from("aabbbcc", 7);
    const r = str_char_frequency_top(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "b"));
    str_free(r);
    str_free(h);
}

test "jaccard_similarity" {
    const h1 = str_from("abc", 3);
    const h2 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 100), str_jaccard_similarity(h1, h2));
    str_free(h2);
    str_free(h1);

    const h3 = str_from("abc", 3);
    const h4 = str_from("xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_jaccard_similarity(h3, h4));
    str_free(h4);
    str_free(h3);

    // "ab" and "bc" share 'b' -> intersection=1, union=3 -> 33%
    const h5 = str_from("ab", 2);
    const h6 = str_from("bc", 2);
    try std.testing.expectEqual(@as(c_int, 33), str_jaccard_similarity(h5, h6));
    str_free(h6);
    str_free(h5);
}

test "longest_common_prefix" {
    const h1 = str_from("hello world", 11);
    const h2 = str_from("hello there", 11);
    const r = str_longest_common_prefix(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello "));
    str_free(r);
    str_free(h2);
    str_free(h1);
}

test "longest_common_suffix" {
    const h1 = str_from("testing", 7);
    const h2 = str_from("resting", 7);
    const r = str_longest_common_suffix(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "esting"));
    str_free(r);
    str_free(h2);
    str_free(h1);
}

test "wrap_with" {
    const h = str_from("hello", 5);
    const r = str_wrap_with(h, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "[hello]"));
    str_free(r);
    str_free(h);
}

test "to_title_case_strict" {
    const h = str_from("hello world foo", 15);
    const r = str_to_title_case_strict(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello World Foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("the LORD of war", 15);
    const r2 = str_to_title_case_strict(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "The Lord Of War"));
    str_free(r2);
    str_free(h2);
}

test "hamming_weight" {
    // 'A' = 0x41 = 01000001 = 2 bits, 'B' = 0x42 = 01000010 = 2 bits
    const h = str_from("AB", 2);
    try std.testing.expectEqual(@as(c_int, 4), str_hamming_weight(h));
    str_free(h);

    const h2 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_hamming_weight(h2));
    str_free(h2);
}

test "is_palindrome_words" {
    const h1 = str_from("dog cat dog", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome_words(h1));
    str_free(h1);

    const h2 = str_from("a b c b a", 9);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome_words(h2));
    str_free(h2);

    const h3 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome_words(h3));
    str_free(h3);
}

test "remove_nth_word" {
    const h = str_from("hello world foo", 15);
    const r = str_remove_nth_word(h, 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("hello world foo", 15);
    const r2 = str_remove_nth_word(h2, 0);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "world foo"));
    str_free(r2);
    str_free(h2);
}

test "insert_word_at" {
    const h = str_from("hello foo", 9);
    const r = str_insert_word_at(h, 1, "world", 5);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello world foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("world foo", 9);
    const r2 = str_insert_word_at(h2, 0, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello world foo"));
    str_free(r2);
    str_free(h2);
}

test "to_spongebob_case" {
    const h = str_from("hello world", 11);
    const r = str_to_spongebob_case(h);
    // H(0)e(1)L(2)l(3)O(4) W(5)o(6)R(7)l(8)D(9) -> "HeLlO wOrLd"
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "HeLlO wOrLd"));
    str_free(r);
    str_free(h);
}

test "between_first" {
    const h = str_from("say [hello] world [bye]", 23);
    const r = str_between_first(h, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello"));
    str_free(r);
    str_free(h);

    const h2 = str_from("<b>hi</b>", 9);
    const r2 = str_between_first(h2, "<b>", 3, "</b>", 4);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hi"));
    str_free(r2);
    str_free(h2);
}

test "to_dot_case" {
    const h = str_from("helloWorld", 10);
    const r = str_to_dot_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello.world"));
    str_free(r);
    str_free(h);

    const h2 = str_from("MyVarName", 9);
    const r2 = str_to_dot_case(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "my.var.name"));
    str_free(r2);
    str_free(h2);
}

test "abbreviate" {
    // abbreviate("hello world", 8) -> "hello..." (5 text + 3 dots = 8 total)
    const h = str_from("hello world", 11);
    const r = str_abbreviate(h, 8);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello..."));
    str_free(r);
    str_free(h);

    // abbreviate("hello world", 5) -> "he..." (2 text + 3 dots = 5 total)
    const h1b = str_from("hello world", 11);
    const r1b = str_abbreviate(h1b, 5);
    try std.testing.expect(mem.eql(u8, str_data(r1b)[0..@intCast(str_size(r1b))], "he..."));
    str_free(r1b);
    str_free(h1b);

    // shorter than limit -> returned as-is
    const h2 = str_from("hi", 2);
    const r2 = str_abbreviate(h2, 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hi"));
    str_free(r2);
    str_free(h2);
}

test "count_substring" {
    const h = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_substring(h, "abc", 3));
    str_free(h);

    const h2 = str_from("aaa", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_count_substring(h2, "aa", 2));
    str_free(h2);
}

test "to_path_case" {
    const h = str_from("helloWorld", 10);
    const r = str_to_path_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello/world"));
    str_free(r);
    str_free(h);
}

test "left_pad" {
    const h = str_from("42", 2);
    const r = str_left_pad(h, 5, '0');
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "00042"));
    str_free(r);
    str_free(h);

    // No padding needed when already wide enough
    const h2 = str_from("hello", 5);
    const r2 = str_left_pad(h2, 3, 'x');
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello"));
    str_free(r2);
    str_free(h2);
}

test "right_pad" {
    const h = str_from("hi", 2);
    const r = str_right_pad(h, 5, '.');
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hi..."));
    str_free(r);
    str_free(h);
}

test "to_hex" {
    const h = str_from("ABC", 3);
    const r = str_to_hex(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "414243"));
    str_free(r);
    str_free(h);
}

test "from_hex" {
    const h = str_from("414243", 6);
    const r = str_from_hex(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "ABC"));
    str_free(r);
    str_free(h);
}

test "soundex" {
    const h = str_from("Robert", 6);
    const r = str_soundex(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "R163"));
    str_free(r);
    str_free(h);

    const h2 = str_from("Ashcraft", 8);
    const r2 = str_soundex(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "A261"));
    str_free(r2);
    str_free(h2);
}

test "vigenere_encrypt" {
    const h = str_from("hello", 5);
    const r = str_vigenere_encrypt(h, "key", 3);
    // h+k=r, e+e=i, l+y=j, l+k=v, o+e=s
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "rijvs"));
    str_free(r);
    str_free(h);
}

test "atbash" {
    const h = str_from("abc", 3);
    const r = str_atbash(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "zyx"));
    str_free(r);
    str_free(h);

    const h2 = str_from("Hello", 5);
    const r2 = str_atbash(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "Svool"));
    str_free(r2);
    str_free(h2);
}

test "count_words_matching" {
    const h = str_from("the cat and the dog", 19);
    try std.testing.expectEqual(@as(c_int, 2), str_count_words_matching(h, "the", 3));
    str_free(h);
}

test "truncate_words" {
    const h = str_from("one two three four five", 23);
    const r = str_truncate_words(h, 3);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "one two three"));
    str_free(r);
    str_free(h);
}

test "to_constant_case" {
    const h = str_from("hello world", 11);
    const r = str_to_constant_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "HELLO_WORLD"));
    str_free(r);
    str_free(h);

    const h2 = str_from("camelCase", 9);
    const r2 = str_to_constant_case(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "CAMEL_CASE"));
    str_free(r2);
    str_free(h2);
}

test "first_word" {
    const h = str_from("hello world foo", 15);
    const r = str_first_word(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello"));
    str_free(r);
    str_free(h);
}

test "last_word" {
    const h = str_from("hello world foo", 15);
    const r = str_last_word(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "foo"));
    str_free(r);
    str_free(h);
}

test "to_nato" {
    const h = str_from("AB", 2);
    const r = str_to_nato(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "Alfa Bravo"));
    str_free(r);
    str_free(h);
}

test "commonality" {
    const h1 = str_from("abc", 3);
    const h2 = str_from("bcd", 3);
    try std.testing.expectEqual(@as(c_int, 2), str_commonality(h1, h2));
    str_free(h1);
    str_free(h2);
}

test "diff_chars" {
    const h1 = str_from("abcd", 4);
    const h2 = str_from("bc", 2);
    const r = str_diff_chars(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "ad"));
    str_free(r);
    str_free(h1);
    str_free(h2);
}

test "rot47" {
    const h = str_from("Hello", 5);
    const r = str_rot47(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "w6==@"));
    str_free(r);
    str_free(h);
}

test "is_isogram" {
    const h1 = str_from("subdermatoglyphic", 17);
    try std.testing.expectEqual(@as(c_int, 1), str_is_isogram(h1));
    str_free(h1);

    const h2 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_isogram(h2));
    str_free(h2);
}

test "reverse_each_word" {
    const h = str_from("hello world", 11);
    const r = str_reverse_each_word(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "olleh dlrow"));
    str_free(r);
    str_free(h);
}

test "count_digits" {
    const h = str_from("abc123def45", 11);
    try std.testing.expectEqual(@as(c_int, 5), str_count_digits(h));
    str_free(h);
}

test "strip_tags" {
    const h = str_from("<b>hello</b> <i>world</i>", 25);
    const r = str_strip_tags(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello world"));
    str_free(r);
    str_free(h);
}

test "to_slug" {
    const h = str_from("Hello World! Test", 17);
    const r = str_to_slug(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello-world-test"));
    str_free(r);
    str_free(h);
}

test "count_spaces" {
    const h = str_from("hello  world  foo", 17);
    try std.testing.expectEqual(@as(c_int, 4), str_count_spaces(h));
    str_free(h);
}

test "normalize_spaces" {
    const h = str_from("  hello   world  ", 17);
    const r = str_normalize_spaces(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello world"));
    str_free(r);
    str_free(h);
}

test "mask_email" {
    const h = str_from("john@example.com", 16);
    const r = str_mask_email(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "j***@example.com"));
    str_free(r);
    str_free(h);
}

test "pluralize" {
    const h1 = str_from("cat", 3);
    const r1 = str_pluralize(h1);
    try std.testing.expect(mem.eql(u8, str_data(r1.?)[0..@intCast(str_size(r1.?))], "cats"));
    str_free(r1);
    str_free(h1);

    const h2 = str_from("city", 4);
    const r2 = str_pluralize(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "cities"));
    str_free(r2);
    str_free(h2);

    const h3 = str_from("box", 3);
    const r3 = str_pluralize(h3);
    try std.testing.expect(mem.eql(u8, str_data(r3.?)[0..@intCast(str_size(r3.?))], "boxes"));
    str_free(r3);
    str_free(h3);
}

test "deduplicate_lines" {
    const input = "hello\nworld\nhello\nfoo";
    const h = str_from(input, input.len);
    const r = str_deduplicate_lines(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello\nworld\nfoo"));
    str_free(r);
    str_free(h);
}

test "remove_blank_lines" {
    const input = "hello\n\nworld\n  \nfoo";
    const h = str_from(input, input.len);
    const r = str_remove_blank_lines(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello\nworld\nfoo"));
    str_free(r);
    str_free(h);
}

test "extract_numbers" {
    const h = str_from("price is 42.5 and qty 10", 24);
    const r = str_extract_numbers(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "42.5 10"));
    str_free(r);
    str_free(h);
}

test "extract_emails" {
    const h = str_from("contact john@example.com or jane@test.org", 41);
    const r = str_extract_emails(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "john@example.com jane@test.org"));
    str_free(r);
    str_free(h);
}

test "quote" {
    const h = str_from("hello", 5);
    const r = str_quote(h, '"');
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "\"hello\""));
    str_free(r);
    str_free(h);
}

test "unquote" {
    const h = str_from("\"hello\"", 7);
    const r = str_unquote(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello"));
    str_free(r);
    str_free(h);

    const h2 = str_from("no quotes", 9);
    const r2 = str_unquote(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "no quotes"));
    str_free(r2);
    str_free(h2);
}

test "to_csv_field" {
    const h = str_from("hello,world", 11);
    const r = str_to_csv_field(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "\"hello,world\""));
    str_free(r);
    str_free(h);

    const h2 = str_from("simple", 6);
    const r2 = str_to_csv_field(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "simple"));
    str_free(r2);
    str_free(h2);
}

test "number_lines" {
    const input = "hello\nworld";
    const h = str_from(input, input.len);
    const r = str_number_lines(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "1: hello\n2: world"));
    str_free(r);
    str_free(h);
}

test "hide" {
    const h = str_from("1234567890", 10);
    const r = str_hide(h, '*', 2, 2);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "12******90"));
    str_free(r);
    str_free(h);
}

test "extract_words" {
    const h = str_from("hello, world! foo-bar 123", 25);
    const r = str_extract_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello world foo bar"));
    str_free(r);
    str_free(h);
}

test "expand_tabs" {
    const h = str_from("a\tb", 3);
    const r = str_expand_tabs(h, 4);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "a    b"));
    str_free(r);
    str_free(h);
}

test "sentence_count" {
    const h = str_from("Hello. How are you? Fine!", 25);
    try std.testing.expectEqual(@as(c_int, 3), str_sentence_count(h));
    str_free(h);
}

test "chop" {
    const h = str_from("hello", 5);
    const r = str_chop(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hell"));
    str_free(r);
    str_free(h);
}

test "scan_int" {
    const h = str_from("42abc", 5);
    try std.testing.expectEqual(@as(c_int, 42), str_scan_int(h));
    str_free(h);

    const h2 = str_from("-7", 2);
    try std.testing.expectEqual(@as(c_int, -7), str_scan_int(h2));
    str_free(h2);
}

test "to_ordinal" {
    const h1 = str_from("1", 1);
    const r1 = str_to_ordinal(h1);
    try std.testing.expect(mem.eql(u8, str_data(r1.?)[0..@intCast(str_size(r1.?))], "1st"));
    str_free(r1);
    str_free(h1);

    const h2 = str_from("12", 2);
    const r2 = str_to_ordinal(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "12th"));
    str_free(r2);
    str_free(h2);

    const h3 = str_from("23", 2);
    const r3 = str_to_ordinal(h3);
    try std.testing.expect(mem.eql(u8, str_data(r3.?)[0..@intCast(str_size(r3.?))], "23rd"));
    str_free(r3);
    str_free(h3);
}

test "left_cp" {
    const s = str_from("Hello", 5);
    const r = str_left_cp(s, 3);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..3], "Hel"));
    str_free(r);
    str_free(s);
}

test "left_cp utf8" {
    // "cafe\xCC\x81" = "café" (5 bytes, 4 codepoints with combining accent)
    const s = str_from("caf\xC3\xA9!", 6); // café! = 5 codepoints
    const r = str_left_cp(s, 4); // "café"
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..5], "caf\xC3\xA9"));
    str_free(r);
    str_free(s);
}

test "right_cp" {
    const s = str_from("Hello", 5);
    const r = str_right_cp(s, 3);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..3], "llo"));
    str_free(r);
    str_free(s);
}

test "cp_count" {
    const s1 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 5), str_cp_count(s1));
    str_free(s1);

    const s2 = str_from("caf\xC3\xA9", 5); // café = 4 codepoints
    try std.testing.expectEqual(@as(c_int, 4), str_cp_count(s2));
    str_free(s2);
}

test "nth_char" {
    const s = str_from("caf\xC3\xA9!", 6); // café! = 5 codepoints
    const c0 = str_nth_char(s, 1); // 'c' (1-based)
    try std.testing.expectEqual(@as(usize, 1), str_size(c0));
    try std.testing.expect(mem.eql(u8, str_data(c0.?)[0..1], "c"));
    str_free(c0);

    const c3 = str_nth_char(s, 4); // 'é' (1-based)
    try std.testing.expectEqual(@as(usize, 2), str_size(c3));
    try std.testing.expect(mem.eql(u8, str_data(c3.?)[0..2], "\xC3\xA9"));
    str_free(c3);

    const c4 = str_nth_char(s, 5); // '!' (1-based)
    try std.testing.expectEqual(@as(usize, 1), str_size(c4));
    try std.testing.expect(mem.eql(u8, str_data(c4.?)[0..1], "!"));
    str_free(c4);

    str_free(s);
}

// ─── Unicode CI Tests ───

test "equals_ci unicode" {
    // German sharp-s: "strasse" should equal "STRASSE" case-insensitively
    const a = str_from("hello", 5);
    const b = str_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals_ci(a, b));
    str_free(a);
    str_free(b);

    // French accented: "cafe" vs "CAFE" (basic)
    const c = str_from("caf\xC3\xA9", 5);
    const d = str_from("CAF\xC3\x89", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals_ci(c, d));
    str_free(c);
    str_free(d);
}

test "contains_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_ci(s, "xyz", 3));
    str_free(s);
}

test "starts_with_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "HELLO", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_ci(s, "world", 5));
    str_free(s);
}

test "ends_with_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "world", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_ci(s, "hello", 5));
    str_free(s);
}

test "find_all_ci unicode" {
    const s = str_from("abcABCabc", 9);
    const r = str_find_all_ci(s, "abc", 3);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 7), stz_find_result_get(r, 2));
    stz_find_result_free(r);
    str_free(s);
}

test "count_of_ci unicode" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_of_ci(s, "abc", 3));
    str_free(s);
}

test "foldcase unicode" {
    const s = str_from("Hello WORLD", 11);
    const r = str_foldcase(s);
    const data = str_data(r);
    try std.testing.expect(mem.eql(u8, data[0..11], "hello world"));
    str_free(r);
    str_free(s);
}

test "trim_left unicode whitespace" {
    // U+00A0 (no-break space) = C2 A0 in UTF-8
    const s = str_from("\xC2\xA0 hello", 8);
    const r = str_trim_left(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trim_right unicode whitespace" {
    // U+00A0 (no-break space) = C2 A0 in UTF-8
    const s = str_from("hello \xC2\xA0", 8);
    const r = str_trim_right(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trimmed delegates to unicode trim" {
    // U+00A0 on both sides
    const s = str_from("\xC2\xA0hello\xC2\xA0", 9);
    const r = str_trimmed(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

// ─── NLP Tests ───

test "jaro identical" {
    const a = str_from("hello", 5);
    const b = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1000), str_jaro(a, b));
    str_free(a);
    str_free(b);
}

test "jaro similar" {
    const a = str_from("martha", 6);
    const b = str_from("marhta", 6);
    const j = str_jaro(a, b);
    // Jaro("martha", "marhta") should be ~944
    try std.testing.expect(j > 900 and j <= 1000);
    str_free(a);
    str_free(b);
}

test "jaro_winkler boosts prefix" {
    const a = str_from("martha", 6);
    const b = str_from("marhta", 6);
    const j = str_jaro(a, b);
    const jw = str_jaro_winkler(a, b);
    // Jaro-Winkler should be >= Jaro (prefix boost)
    try std.testing.expect(jw >= j);
    str_free(a);
    str_free(b);
}

test "jaro_winkler different strings" {
    const a = str_from("abc", 3);
    const b = str_from("xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_jaro_winkler(a, b));
    str_free(a);
    str_free(b);
}

test "metaphone basic" {
    const h = str_from("smith", 5);
    const r = str_metaphone(h);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    // Metaphone of "smith" should be "SM0" (0 = theta for TH)
    try std.testing.expect(size > 0);
    try std.testing.expect(mem.eql(u8, data[0..size], "SM0"));
    str_free(r);
    str_free(h);
}

test "metaphone phone" {
    const h = str_from("phone", 5);
    const r = str_metaphone(h);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    // PH -> F, so "phone" -> "FN"
    try std.testing.expect(mem.eql(u8, data[0..size], "FN"));
    str_free(r);
    str_free(h);
}

test "char_ngrams bigrams" {
    const h = str_from("hello", 5);
    const r = str_char_ngrams(h, 2);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    try std.testing.expect(mem.eql(u8, data[0..size], "he|el|ll|lo"));
    str_free(r);
    str_free(h);
}

test "word_ngrams bigrams" {
    const input = "the quick brown fox";
    const h = str_from(input, input.len);
    const r = str_word_ngrams(h, 2);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    try std.testing.expect(mem.eql(u8, data[0..size], "the quick|quick brown|brown fox"));
    str_free(r);
    str_free(h);
}

// ─── CS Merge Tests ───

test "index_of_cs case sensitive" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(i64, 7), str_index_of_cs(s, "World", 5, 1));
    try std.testing.expectEqual(@as(i64, -1), str_index_of_cs(s, "world", 5, 1));
    str_free(s);
}

test "index_of_cs case insensitive" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(i64, 7), str_index_of_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(i64, 1), str_index_of_cs(s, "hello", 5, 0));
    str_free(s);
}

test "find_all_cs" {
    const s = str_from("abcABCabc", 9);
    const r1 = str_find_all_cs(s, "abc", 3, 1);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r1));
    stz_find_result_free(r1);
    const r0 = str_find_all_cs(s, "abc", 3, 0);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r0));
    stz_find_result_free(r0);
    str_free(s);
}

test "contains_cs" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "World", 5, 1));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_cs(s, "world", 5, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "world", 5, 0));
    str_free(s);
}

test "equals_cs" {
    const a = str_from("Hello", 5);
    const b = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_equals_cs(a, b, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_equals_cs(a, b, 0));
    str_free(a);
    str_free(b);
}

test "starts_with_cs ends_with_cs" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_cs(s, "hello", 5, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_cs(s, "WORLD", 5, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_cs(s, "WORLD", 5, 0));
    str_free(s);
}

test "find_nth_cs" {
    const s = str_from("aXaXaXa", 7);
    try std.testing.expectEqual(@as(i64, 2), str_find_nth_cs(s, "X", 1, 1, 1));
    try std.testing.expectEqual(@as(i64, 6), str_find_nth_cs(s, "X", 1, 3, 1));
    str_free(s);
}

test "last_index_of_cs" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(i64, 7), str_last_index_of_cs(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 7), str_last_index_of_cs(s, "abc", 3, 0)); // last CI match at pos 7
    str_free(s);
}

test "count_of_cs" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(c_int, 2), str_count_of_cs(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(c_int, 3), str_count_of_cs(s, "abc", 3, 0));
    str_free(s);
}

// ─── Phase B: Safety & Robustness Tests ───

test "str_last_error initial state" {
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
}

test "str_clear_error" {
    // Force an error, then clear
    _ = str_from("\xff\xfe", 2); // invalid UTF-8
    try std.testing.expect(str_last_error() != 0);
    str_clear_error();
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
}

test "str_from rejects invalid UTF-8" {
    // Invalid continuation byte
    const bad1 = str_from("\xff\xfe", 2);
    try std.testing.expect(bad1 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error()); // invalid_utf8

    // Overlong encoding
    const bad2 = str_from("\xc0\x80", 2);
    try std.testing.expect(bad2 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());

    // Truncated sequence
    const bad3 = str_from("\xe2\x82", 2);
    try std.testing.expect(bad3 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());

    // Valid UTF-8 should succeed and clear error
    const good = str_from("Hello", 5);
    try std.testing.expect(good != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    str_free(good);
}

test "str_from accepts valid multi-byte UTF-8" {
    // 2-byte: e with acute
    const s2 = str_from("\xc3\xa9", 2);
    try std.testing.expect(s2 != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    str_free(s2);

    // 3-byte: Euro sign
    const s3 = str_from("\xe2\x82\xac", 3);
    try std.testing.expect(s3 != null);
    str_free(s3);

    // 4-byte: emoji
    const s4 = str_from("\xf0\x9f\x98\x80", 4);
    try std.testing.expect(s4 != null);
    str_free(s4);
}

test "str_from null pointer with len 0 succeeds" {
    const s = str_from(null, 0);
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    try std.testing.expectEqual(@as(usize, 0), str_size(s));
    str_free(s);
}

test "str_from null pointer with len > 0 fails" {
    const s = str_from(null, 5);
    try std.testing.expect(s == null);
    try std.testing.expectEqual(@as(c_int, 5), str_last_error()); // invalid_argument
}

test "str_data null-terminated" {
    const s = str_from("Hello", 5);
    const data = str_data(s);
    // The 6th byte (index 5) should be '\0' for C compatibility
    try std.testing.expectEqual(@as(u8, 0), data[5]);
    str_free(s);
}

test "str_data empty string returns empty" {
    const s = str_new();
    const data = str_data(s);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
    str_free(s);
}

test "str_data null handle returns empty" {
    const data = str_data(null);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
}

test "str_append sets error on null handle" {
    str_append(null, "test", 4);
    try std.testing.expectEqual(@as(c_int, 4), str_last_error()); // null_handle
}

test "str_insert sets error on null handle" {
    str_insert(null, 0, "test", 4);
    try std.testing.expectEqual(@as(c_int, 4), str_last_error()); // null_handle
}

test "error enum values" {
    // Verify the enum constants match the documented values
    try std.testing.expectEqual(@as(c_int, 0), @intFromEnum(StrError.none));
    try std.testing.expectEqual(@as(c_int, 1), @intFromEnum(StrError.out_of_memory));
    try std.testing.expectEqual(@as(c_int, 2), @intFromEnum(StrError.invalid_utf8));
    try std.testing.expectEqual(@as(c_int, 3), @intFromEnum(StrError.index_out_of_bounds));
    try std.testing.expectEqual(@as(c_int, 4), @intFromEnum(StrError.null_handle));
    try std.testing.expectEqual(@as(c_int, 5), @intFromEnum(StrError.invalid_argument));
}

// ─── Phase C: Performance Tests ───

test "cpCount cache works" {
    const s = str_from("Hello", 5);
    // First call computes; second should use cache
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    str_free(s);
}

test "cpCount cache invalidated on append" {
    const s = str_from("Hi", 2);
    try std.testing.expectEqual(@as(usize, 2), str_count(s));
    str_append(s, " there", 6);
    try std.testing.expectEqual(@as(usize, 8), str_count(s));
    str_free(s);
}

test "isAscii cache works" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(s));
    // Should use cached value
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(s));
    str_free(s);
}

test "isAscii detects non-ASCII" {
    const s = str_from("\xc3\xa9", 2); // e with acute
    try std.testing.expectEqual(@as(c_int, 0), str_is_ascii(s));
    str_free(s);
}

test "isAscii cache invalidated on append" {
    const s = str_from("Hi", 2);
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(s));
    str_append(s, "\xc3\xa9", 2); // append non-ASCII
    try std.testing.expectEqual(@as(c_int, 0), str_is_ascii(s));
    str_free(s);
}

test "BMH search basic" {
    // Verify BMH finds correct positions
    const hay = "The quick brown fox jumps over the lazy dog";
    try std.testing.expectEqual(@as(?usize, 16), bmhSearch(hay, "fox j", 0));
    try std.testing.expectEqual(@as(?usize, 31), bmhSearch(hay, "the lazy", 0));
    try std.testing.expect(bmhSearch(hay, "cat jumps", 0) == null);
}

test "BMH search with start offset" {
    const hay = "abcdef abcdef abcdef";
    try std.testing.expectEqual(@as(?usize, 0), bmhSearch(hay, "abcdef", 0));
    try std.testing.expectEqual(@as(?usize, 7), bmhSearch(hay, "abcdef", 1));
    try std.testing.expectEqual(@as(?usize, 14), bmhSearch(hay, "abcdef", 8));
}

test "index_of uses BMH for long ASCII needles" {
    // Needle > 4 bytes, ASCII string -- should use BMH path
    const s = str_from("The quick brown fox jumps over the lazy dog", 43);
    try std.testing.expectEqual(@as(i64, 17), str_index_of(s, "fox j", 5)); // 1-based
    try std.testing.expectEqual(@as(i64, 32), str_index_of(s, "the lazy", 8)); // 1-based
    try std.testing.expectEqual(@as(i64, -1), str_index_of(s, "cat jumps", 9));
    str_free(s);
}

test "cpCount ASCII fast-path" {
    // ASCII: codepoint count == byte count
    const s = str_from("Hello World!", 12);
    try std.testing.expectEqual(@as(usize, 12), str_count(s));
    str_free(s);
}

test "cpCount multi-byte correct" {
    // "cafe" with accented e = 5 codepoints, 6 bytes
    const s = str_from("caf\xc3\xa9!", 6);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    try std.testing.expectEqual(@as(usize, 6), str_size(s));
    str_free(s);
}

test "isAllAscii helper" {
    try std.testing.expect(isAllAscii("Hello World"));
    try std.testing.expect(!isAllAscii("\xc3\xa9"));
    try std.testing.expect(isAllAscii(""));
    try std.testing.expect(!isAllAscii("Hi\xf0\x9f\x98\x80"));
}
