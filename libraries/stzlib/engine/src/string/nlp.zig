// Softanza Engine -- String NLP / Text Analysis Operations
//
// Similarity metrics, phonetic encoding, n-grams, text extraction,
// and linguistic transforms. Extracted from string.zig as part of
// Phase D module separation.
//
// Categories:
//   Similarity: Levenshtein, Hamming, Jaro, Jaro-Winkler, Jaccard
//   Phonetics: Soundex, Metaphone
//   N-grams: ngram, ngram_count, char_ngrams, word_ngrams
//   Extraction: extract_numbers, extract_emails, extract_words
//   Linguistic: pluralize, to_pig_latin, to_nato, mask_email

const std = @import("std");
const core = @import("core.zig");

const mem = core.mem;
const gpa = core.gpa;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const INDEX_BASE = core.INDEX_BASE;
const setError = core.setError;
const str_new = core.str_new;
const str_from = core.str_from;
const str_free = core.str_free;
const decodeCodepoint = core.decodeCodepoint;
const utf8CodepointCount = core.utf8CodepointCount;
const casefoldAlloc = core.casefoldAlloc;
const isVowelAscii = core.isVowelAscii;

// ─── Similarity Metrics ───

/// Levenshtein edit distance between two strings (codepoint-level).
pub fn str_levenshtein(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = (h1 orelse return 0);
    const s2 = (h2 orelse return 0);
    const b1 = s1.slice();
    const b2 = s2.slice();

    // Decode codepoints from both strings
    var cp1_buf: [4096]i32 = undefined;
    var cp2_buf: [4096]i32 = undefined;
    var len1: usize = 0;
    var len2: usize = 0;

    var i: usize = 0;
    while (i < b1.len and len1 < 4096) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b1[i]) catch 1;
        cp1_buf[len1] = decodeCodepoint(b1, i, cp_len);
        len1 += 1;
        i += cp_len;
    }
    i = 0;
    while (i < b2.len and len2 < 4096) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b2[i]) catch 1;
        cp2_buf[len2] = decodeCodepoint(b2, i, cp_len);
        len2 += 1;
        i += cp_len;
    }

    if (len1 == 0) return @intCast(len2);
    if (len2 == 0) return @intCast(len1);

    // Use two rows for space efficiency
    const row_alloc = gpa.alloc(c_int, len2 + 1) catch return -1;
    defer gpa.free(row_alloc);
    const prev_alloc = gpa.alloc(c_int, len2 + 1) catch return -1;
    defer gpa.free(prev_alloc);
    var prev = prev_alloc;
    var curr = row_alloc;

    for (0..len2 + 1) |j| {
        prev[j] = @intCast(j);
    }

    for (0..len1) |r| {
        curr[0] = @as(c_int, @intCast(r)) + 1;
        for (0..len2) |c| {
            const cost: c_int = if (cp1_buf[r] == cp2_buf[c]) 0 else 1;
            const del = prev[c + 1] + 1;
            const ins = curr[c] + 1;
            const sub = prev[c] + cost;
            curr[c + 1] = @min(del, @min(ins, sub));
        }
        const tmp = prev;
        prev = curr;
        curr = tmp;
    }

    return prev[len2];
}

/// Hamming distance: count of positions where codepoints differ.
/// Returns -1 if strings have different lengths.
pub fn str_hamming_distance(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return -1;
    const s2 = h2 orelse return -1;
    const src1 = s1.slice();
    const src2 = s2.slice();

    var off1: usize = 0;
    var off2: usize = 0;
    var dist: c_int = 0;

    while (off1 < src1.len and off2 < src2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(src1[off1]) catch break;
        const len2 = std.unicode.utf8ByteSequenceLength(src2[off2]) catch break;
        if (off1 + len1 > src1.len or off2 + len2 > src2.len) break;

        if (len1 != len2 or !mem.eql(u8, src1[off1..][0..len1], src2[off2..][0..len2])) {
            dist += 1;
        }
        off1 += len1;
        off2 += len2;
    }

    // If one string has remaining chars, lengths differ
    if (off1 < src1.len or off2 < src2.len) return -1;
    return dist;
}

/// Jaro similarity. Returns value * 1000 (integer to avoid float in C API).
pub fn str_jaro(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const a = s1.slice();
    const b = s2.slice();
    if (a.len == 0 and b.len == 0) return 1000; // identical empty
    if (a.len == 0 or b.len == 0) return 0;

    // Count codepoints
    const len_a = utf8CodepointCount(a);
    const len_b = utf8CodepointCount(b);
    if (len_a == 0 or len_b == 0) return 0;

    // Match window
    const max_len = if (len_a > len_b) len_a else len_b;
    const match_dist = if (max_len > 1) max_len / 2 - 1 else 0;

    // Collect codepoints from both strings
    var cps_a: [1024]i32 = undefined;
    var cps_b: [1024]i32 = undefined;
    const ca = @min(len_a, 1024);
    const cb = @min(len_b, 1024);

    var idx: usize = 0;
    var pos: usize = 0;
    while (idx < ca and pos < a.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(a[pos]) catch 1;
        cps_a[idx] = decodeCodepoint(a, pos, cp_len);
        pos += cp_len;
        idx += 1;
    }
    idx = 0;
    pos = 0;
    while (idx < cb and pos < b.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(b[pos]) catch 1;
        cps_b[idx] = decodeCodepoint(b, pos, cp_len);
        pos += cp_len;
        idx += 1;
    }

    // Find matches
    var matched_a: [1024]bool = [_]bool{false} ** 1024;
    var matched_b: [1024]bool = [_]bool{false} ** 1024;
    var matches: usize = 0;

    var i: usize = 0;
    while (i < ca) : (i += 1) {
        const lo = if (i > match_dist) i - match_dist else 0;
        const hi = @min(i + match_dist + 1, cb);
        var j: usize = lo;
        while (j < hi) : (j += 1) {
            if (!matched_b[j] and cps_a[i] == cps_b[j]) {
                matched_a[i] = true;
                matched_b[j] = true;
                matches += 1;
                break;
            }
        }
    }

    if (matches == 0) return 0;

    // Count transpositions
    var transpositions: usize = 0;
    var k: usize = 0;
    i = 0;
    while (i < ca) : (i += 1) {
        if (matched_a[i]) {
            while (k < cb and !matched_b[k]) k += 1;
            if (k < cb and cps_a[i] != cps_b[k]) transpositions += 1;
            k += 1;
        }
    }

    // Jaro = (m/|a| + m/|b| + (m-t/2)/m) / 3
    const m_f: f64 = @floatFromInt(matches);
    const la_f: f64 = @floatFromInt(ca);
    const lb_f: f64 = @floatFromInt(cb);
    const t_f: f64 = @floatFromInt(transpositions / 2);
    const jaro_val = (m_f / la_f + m_f / lb_f + (m_f - t_f) / m_f) / 3.0;
    return @intFromFloat(jaro_val * 1000.0);
}

/// Jaro-Winkler similarity. Returns value * 1000. Boosts for common prefix.
pub fn str_jaro_winkler(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const jaro = str_jaro(h1, h2);
    if (jaro == 0) return 0;
    const jaro_f: f64 = @as(f64, @floatFromInt(jaro)) / 1000.0;

    // Common prefix (up to 4 chars)
    const s1 = h1 orelse return jaro;
    const s2 = h2 orelse return jaro;
    const a = s1.slice();
    const b = s2.slice();
    var prefix: usize = 0;
    var pa: usize = 0;
    var pb: usize = 0;
    while (prefix < 4 and pa < a.len and pb < b.len) {
        const cpa_len = std.unicode.utf8ByteSequenceLength(a[pa]) catch break;
        const cpb_len = std.unicode.utf8ByteSequenceLength(b[pb]) catch break;
        if (cpa_len != cpb_len) break;
        if (!mem.eql(u8, a[pa..pa + cpa_len], b[pb..pb + cpb_len])) break;
        pa += cpa_len;
        pb += cpb_len;
        prefix += 1;
    }

    const p_f: f64 = @floatFromInt(prefix);
    const jw = jaro_f + p_f * 0.1 * (1.0 - jaro_f);
    return @intFromFloat(jw * 1000.0);
}

/// Jaccard similarity (byte-level character sets). Returns percentage (0-100).
pub fn str_jaccard_similarity(h1: ?*StzString, h2: ?*StzString) callconv(.c) c_int {
    const s1 = h1 orelse return 0;
    const s2 = h2 orelse return 0;
    const src1 = s1.slice();
    const src2 = s2.slice();

    // Build char sets (ASCII only for speed)
    var set1: [256]bool = [_]bool{false} ** 256;
    var set2: [256]bool = [_]bool{false} ** 256;
    for (src1) |c| set1[c] = true;
    for (src2) |c| set2[c] = true;

    var intersection: u32 = 0;
    var union_count: u32 = 0;
    for (0..256) |i| {
        if (set1[i] or set2[i]) union_count += 1;
        if (set1[i] and set2[i]) intersection += 1;
    }
    if (union_count == 0) return 100; // both empty = identical
    return @intCast((intersection * 100) / union_count);
}

// ─── Phonetic Encoding ───

/// Soundex phonetic code. Returns 4-character code as string handle.
pub fn str_soundex(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;
    // First letter uppercase
    const first: u8 = if (src[0] >= 'a' and src[0] <= 'z') src[0] - 32 else src[0];
    result.data.appendSlice(gpa, &[_]u8{first}) catch return result;
    const map = [26]u8{ '0', '1', '2', '3', '0', '1', '2', '0', '0', '2', '2', '4', '5', '5', '0', '1', '2', '6', '2', '3', '0', '1', '0', '2', '0', '2' };
    var count: usize = 1;
    var last_code: u8 = soundexCode(first, &map);
    var idx: usize = 1;
    while (idx < src.len and count < 4) : (idx += 1) {
        const c = src[idx];
        const code = soundexCode(c, &map);
        if (code != '0' and code != last_code) {
            result.data.appendSlice(gpa, &[_]u8{code}) catch break;
            count += 1;
        }
        if (code != '0') last_code = code;
    }
    while (count < 4) : (count += 1) {
        result.data.appendSlice(gpa, &[_]u8{'0'}) catch break;
    }
    return result;
}

fn soundexCode(c: u8, map_val: *const [26]u8) u8 {
    if (c >= 'a' and c <= 'z') return map_val[c - 'a'];
    if (c >= 'A' and c <= 'Z') return map_val[c - 'A'];
    return '0';
}

/// Metaphone phonetic encoding. Returns new handle with metaphone code.
pub fn str_metaphone(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;

    // Work with uppercase ASCII
    var buf: [256]u8 = undefined;
    const wlen = @min(src.len, 256);
    for (0..wlen) |i| {
        buf[i] = if (src[i] >= 'a' and src[i] <= 'z') src[i] - 32 else src[i];
    }
    const word = buf[0..wlen];

    // Drop initial silent consonant pairs
    var start: usize = 0;
    if (wlen >= 2) {
        const pair = [2]u8{ word[0], word[1] };
        if (mem.eql(u8, &pair, "AE") or mem.eql(u8, &pair, "GN") or
            mem.eql(u8, &pair, "KN") or mem.eql(u8, &pair, "PN") or
            mem.eql(u8, &pair, "WR"))
        {
            start = 1;
        }
    }

    var code_len: usize = 0;
    var prev: u8 = 0;
    var i: usize = start;
    while (i < wlen and code_len < 6) {
        const c = word[i];
        const next: u8 = if (i + 1 < wlen) word[i + 1] else 0;

        if (c == prev and c != 'C') {
            i += 1;
            continue;
        }

        var out: u8 = 0;
        var skip: usize = 1;

        switch (c) {
            'B' => {
                if (i == 0 or word[i - 1] != 'M') out = 'B';
            },
            'C' => {
                if (next == 'H') {
                    out = 'X';
                    skip = 2;
                } else if (next == 'I' or next == 'E' or next == 'Y') {
                    out = 'S';
                } else {
                    out = 'K';
                }
            },
            'D' => {
                if (next == 'G' and i + 2 < wlen and
                    (word[i + 2] == 'I' or word[i + 2] == 'E' or word[i + 2] == 'Y'))
                {
                    out = 'J';
                } else {
                    out = 'T';
                }
            },
            'F' => out = 'F',
            'G' => {
                if (next == 'H' and i + 2 < wlen and !isVowelAscii(word[i + 2])) {
                    i += 2;
                    continue;
                } else if (i > 0 and (next == 'N' or (next == 0))) {
                    // silent G at end
                } else if (next == 'N' and i + 2 < wlen and word[i + 2] == 'E' and i + 3 >= wlen) {
                    // silent GNE
                } else {
                    out = if (next == 'I' or next == 'E' or next == 'Y') 'J' else 'K';
                }
            },
            'H' => {
                if (isVowelAscii(next) and (i == 0 or !isVowelAscii(word[i - 1]))) out = 'H';
            },
            'J' => out = 'J',
            'K' => {
                if (i == 0 or word[i - 1] != 'C') out = 'K';
            },
            'L' => out = 'L',
            'M' => out = 'M',
            'N' => out = 'N',
            'P' => {
                if (next == 'H') {
                    out = 'F';
                    skip = 2;
                } else {
                    out = 'P';
                }
            },
            'Q' => out = 'K',
            'R' => out = 'R',
            'S' => {
                if (next == 'H') {
                    out = 'X';
                    skip = 2;
                } else if (next == 'I' and i + 2 < wlen and (word[i + 2] == 'O' or word[i + 2] == 'A')) {
                    out = 'X';
                    skip = 3;
                } else {
                    out = 'S';
                }
            },
            'T' => {
                if (next == 'H') {
                    out = '0'; // theta
                    skip = 2;
                } else if (next == 'I' and i + 2 < wlen and (word[i + 2] == 'O' or word[i + 2] == 'A')) {
                    out = 'X';
                } else {
                    out = 'T';
                }
            },
            'V' => out = 'F',
            'W', 'Y' => {
                if (isVowelAscii(next)) out = c;
            },
            'X' => {
                result.data.appendSlice(gpa, "KS") catch break;
                code_len += 2;
                prev = 'S';
                i += 1;
                continue;
            },
            'Z' => out = 'S',
            else => {},
        }

        if (out != 0) {
            result.data.appendSlice(gpa, &[_]u8{out}) catch break;
            code_len += 1;
        }
        prev = c;
        i += skip;
    }
    return result;
}

// ─── N-grams ───

/// Return the n-th n-gram of given size (codepoint-level, 1-based from host, converted to 0-based internally).
pub fn str_ngram(handle: StzStringHandle, size: c_int, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or size <= 0 or n < INDEX_BASE) return null;

    const sz: usize = @intCast(size);
    const idx: usize = @intCast(n - INDEX_BASE);

    // Walk to start position (codepoint idx)
    var off: usize = 0;
    var cp_idx: usize = 0;
    while (cp_idx < idx and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        cp_idx += 1;
    }
    if (cp_idx != idx) return null;

    const start_off = off;
    // Walk `size` codepoints
    var count: usize = 0;
    while (count < sz and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        count += 1;
    }
    if (count != sz) return null;

    return str_from(src[start_off..].ptr, off - start_off);
}

/// Count the number of n-grams of given size in the string.
pub fn str_ngram_count(handle: StzStringHandle, size: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0 or size <= 0) return 0;

    const sz: usize = @intCast(size);

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count < sz) return 0;
    return @intCast(cp_count - sz + 1);
}

/// Generate character n-grams. Returns joined result with separator "|".
pub fn str_char_ngrams(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (n < 1) return result;
    const ng: usize = @intCast(n);

    // Collect codepoint byte offsets
    var offsets: [4096]usize = undefined;
    var num_cps: usize = 0;
    var pos: usize = 0;
    while (pos < src.len and num_cps < 4096) {
        offsets[num_cps] = pos;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
        pos += cp_len;
        num_cps += 1;
    }
    if (num_cps < ng) return result;

    var first = true;
    var i: usize = 0;
    while (i + ng <= num_cps) : (i += 1) {
        if (!first) result.data.appendSlice(gpa, "|") catch break;
        const start_off = offsets[i];
        const end = if (i + ng < num_cps) offsets[i + ng] else src.len;
        result.data.appendSlice(gpa, src[start_off..end]) catch break;
        first = false;
    }
    return result;
}

/// Generate word n-grams. Returns joined result with separator "|".
pub fn str_word_ngrams(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (n < 1) return result;
    const ng: usize = @intCast(n);

    // Collect word boundaries
    var word_starts: [1024]usize = undefined;
    var word_ends: [1024]usize = undefined;
    var num_words: usize = 0;
    var i: usize = 0;
    while (i < src.len and num_words < 1024) {
        // Skip whitespace
        while (i < src.len and (src[i] == ' ' or src[i] == '\t' or src[i] == '\n' or src[i] == '\r')) i += 1;
        if (i >= src.len) break;
        word_starts[num_words] = i;
        // Find word end
        while (i < src.len and src[i] != ' ' and src[i] != '\t' and src[i] != '\n' and src[i] != '\r') i += 1;
        word_ends[num_words] = i;
        num_words += 1;
    }
    if (num_words < ng) return result;

    var first = true;
    i = 0;
    while (i + ng <= num_words) : (i += 1) {
        if (!first) result.data.appendSlice(gpa, "|") catch break;
        const start_off = word_starts[i];
        const end = word_ends[i + ng - 1];
        result.data.appendSlice(gpa, src[start_off..end]) catch break;
        first = false;
    }
    return result;
}

// ─── Text Extraction ───

/// Extract all numbers (digit sequences, may include '.') separated by spaces.
pub fn str_extract_numbers(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos < src.len) {
        if (src[pos] >= '0' and src[pos] <= '9') {
            const start_off = pos;
            while (pos < src.len and ((src[pos] >= '0' and src[pos] <= '9') or src[pos] == '.')) pos += 1;
            if (!first) result.data.appendSlice(gpa, " ") catch { setError(.out_of_memory); };
            result.data.appendSlice(gpa, src[start_off..pos]) catch { setError(.out_of_memory); };
            first = false;
        } else {
            pos += 1;
        }
    }
    return result;
}

/// Extract email addresses from text, separated by spaces.
pub fn str_extract_emails(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos < src.len) {
        if (src[pos] == '@' and pos > 0) {
            // Scan back for local part
            var local_start = pos;
            while (local_start > 0) {
                const c = src[local_start - 1];
                if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or c == '.' or c == '_' or c == '-' or c == '+') {
                    local_start -= 1;
                } else break;
            }
            // Scan forward for domain
            var domain_end = pos + 1;
            var has_dot = false;
            while (domain_end < src.len) {
                const c = src[domain_end];
                if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or c == '.' or c == '-') {
                    if (c == '.') has_dot = true;
                    domain_end += 1;
                } else break;
            }
            if (local_start < pos and domain_end > pos + 1 and has_dot) {
                if (!first) result.data.appendSlice(gpa, " ") catch { setError(.out_of_memory); };
                result.data.appendSlice(gpa, src[local_start..domain_end]) catch { setError(.out_of_memory); };
                first = false;
                pos = domain_end;
            } else {
                pos += 1;
            }
        } else {
            pos += 1;
        }
    }
    return result;
}

/// Extract alphabetic words from text, separated by spaces.
// A "word byte": ASCII letter, or any byte >= 0x80 (a UTF-8 lead/continuation
// byte of a multibyte letter). Keeps accented/CJK words intact while leaving
// ASCII punctuation/whitespace as separators.
fn isWordByte(b: u8) bool {
    return (b >= 'a' and b <= 'z') or (b >= 'A' and b <= 'Z') or b >= 0x80;
}

pub fn str_extract_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    var first = true;
    while (pos < src.len) {
        // Skip non-word bytes (ASCII punctuation/whitespace). A word byte is
        // an ASCII letter OR any byte >= 0x80 -- the lead/continuation bytes
        // of a multibyte UTF-8 letter -- so accented/CJK words stay intact
        // ('café' was being split into 'caf'). ASCII punctuation still
        // separates, matching the previous behaviour.
        while (pos < src.len and !isWordByte(src[pos])) pos += 1;
        if (pos >= src.len) break;
        const start_off = pos;
        while (pos < src.len and (isWordByte(src[pos]) or src[pos] == '\'')) pos += 1;
        if (!first) result.data.appendSlice(gpa, " ") catch { setError(.out_of_memory); };
        result.data.appendSlice(gpa, src[start_off..pos]) catch { setError(.out_of_memory); };
        first = false;
    }
    return result;
}

// ─── Word frequency (one-pass, engine-direct) ───
//
// Ranked (word, count) table computed in a SINGLE pass with a hashmap --
// replaces the Ring-side WordsAndTheirFrequencies which did UniqueWords() then
// re-scanned the whole text once PER unique word (O(unique x length), quadratic
// on any real document). This is O(length). Same tokenization as
// str_extract_words (word = run of isWordByte + apostrophe).

pub const StzWordFreqResult = struct {
    words: std.ArrayList([]u8), // representative (first-seen) original word bytes
    counts: std.ArrayList(i64), // parallel counts, sorted with words by count desc

    pub fn deinit(self: *StzWordFreqResult) void {
        for (self.words.items) |w| gpa.free(w);
        self.words.deinit(gpa);
        self.counts.deinit(gpa);
    }
};
pub const StzWordFreqResultHandle = ?*StzWordFreqResult;

const FreqEntry = struct { rep: []u8, count: i64, order: usize };

fn freqLessThan(_: void, a: FreqEntry, b: FreqEntry) bool {
    if (a.count != b.count) return a.count > b.count; // higher count first
    return a.order < b.order; // stable tie-break: first appearance
}
fn orderLessThan(_: void, a: FreqEntry, b: FreqEntry) bool {
    return a.order < b.order; // first-appearance order
}

// n_top <= 0 -> all words; else the top n_top by count. cs != 0 case-sensitive.
pub fn str_word_freq(handle: StzStringHandle, cs: c_int, n_top: c_int) callconv(.c) StzWordFreqResultHandle {
    const r = gpa.create(StzWordFreqResult) catch return null;
    r.* = .{ .words = .{}, .counts = .{} };
    const s = handle orelse return r;
    const src = s.slice();

    // key (owned) -> FreqEntry. key is casefolded when cs==0, else raw word.
    var map = std.StringHashMap(FreqEntry).init(gpa);
    var order: usize = 0;
    {
        var pos: usize = 0;
        while (pos < src.len) {
            while (pos < src.len and !isWordByte(src[pos])) pos += 1;
            if (pos >= src.len) break;
            const start_off = pos;
            while (pos < src.len and (isWordByte(src[pos]) or src[pos] == '\'')) pos += 1;
            const word = src[start_off..pos];

            // The map key: casefolded copy (cs=0) or a raw copy (cs=1).
            const key: []u8 = if (cs == 0)
                (casefoldAlloc(word) orelse continue)
            else blk: {
                const k = gpa.alloc(u8, word.len) catch continue;
                @memcpy(k, word);
                break :blk k;
            };
            const gop = map.getOrPut(key) catch {
                gpa.free(key);
                continue;
            };
            if (gop.found_existing) {
                gpa.free(key); // key already stored
                gop.value_ptr.count += 1;
            } else {
                // first sighting: keep an owned copy of the ORIGINAL word as rep
                const rep = gpa.alloc(u8, word.len) catch {
                    _ = map.remove(key);
                    gpa.free(key);
                    continue;
                };
                @memcpy(rep, word);
                gop.value_ptr.* = .{ .rep = rep, .count = 1, .order = order };
                order += 1;
            }
        }
    }

    // Collect, sort by count desc (stable), truncate to n_top.
    var entries = std.ArrayList(FreqEntry){};
    defer entries.deinit(gpa);
    var it = map.iterator();
    while (it.next()) |kv| entries.append(gpa, kv.value_ptr.*) catch {};
    // n_top<=0 -> ALL words in first-appearance order (parallels the classic
    // WordsAndTheir* text order). n_top>0 -> the top-N ranked by count desc.
    if (n_top <= 0) {
        std.sort.pdq(FreqEntry, entries.items, {}, orderLessThan);
    } else {
        std.sort.pdq(FreqEntry, entries.items, {}, freqLessThan);
    }

    const keep: usize = if (n_top <= 0) entries.items.len else @min(@as(usize, @intCast(n_top)), entries.items.len);
    var i: usize = 0;
    while (i < entries.items.len) : (i += 1) {
        if (i < keep) {
            r.words.append(gpa, entries.items[i].rep) catch gpa.free(entries.items[i].rep);
            r.counts.append(gpa, entries.items[i].count) catch {};
        } else {
            gpa.free(entries.items[i].rep); // dropped rep
        }
    }
    // Free the map keys (reps were moved into r or freed above).
    var kit = map.keyIterator();
    while (kit.next()) |k| gpa.free(k.*);
    map.deinit();
    return r;
}

pub fn stz_word_freq_count(r: StzWordFreqResultHandle) callconv(.c) c_int {
    if (r) |res| return @intCast(res.words.items.len);
    return 0;
}
// 1-based; returns a FRESH string handle for the i-th word (caller frees).
pub fn stz_word_freq_word(r: StzWordFreqResultHandle, index: c_int) callconv(.c) StzStringHandle {
    if (r) |res| {
        if (index >= 1 and @as(usize, @intCast(index)) <= res.words.items.len) {
            const w = res.words.items[@as(usize, @intCast(index)) - 1];
            return str_from(w.ptr, w.len);
        }
    }
    return str_new();
}
pub fn stz_word_freq_num(r: StzWordFreqResultHandle, index: c_int) callconv(.c) i64 {
    if (r) |res| {
        if (index >= 1 and @as(usize, @intCast(index)) <= res.counts.items.len) {
            return res.counts.items[@as(usize, @intCast(index)) - 1];
        }
    }
    return 0;
}
pub fn stz_word_freq_free(r: StzWordFreqResultHandle) callconv(.c) void {
    if (r) |res| {
        res.deinit();
        gpa.destroy(res);
    }
}

// ─── Linguistic Transforms ───

/// Simple English pluralization.
pub fn str_pluralize(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;
    result.data.appendSlice(gpa, src) catch return result;
    const last = src[src.len - 1];
    if (last == 's' or last == 'x' or last == 'z') {
        result.data.appendSlice(gpa, "es") catch { setError(.out_of_memory); };
    } else if (last == 'y' and src.len > 1) {
        const prev_ch = src[src.len - 2];
        if (!(prev_ch == 'a' or prev_ch == 'e' or prev_ch == 'i' or prev_ch == 'o' or prev_ch == 'u')) {
            // Replace y with ies
            _ = result.data.pop();
            result.data.appendSlice(gpa, "ies") catch { setError(.out_of_memory); };
        } else {
            result.data.appendSlice(gpa, "s") catch { setError(.out_of_memory); };
        }
    } else if (src.len >= 2 and src[src.len - 2] == 'c' and last == 'h') {
        result.data.appendSlice(gpa, "es") catch { setError(.out_of_memory); };
    } else if (src.len >= 2 and src[src.len - 2] == 's' and last == 'h') {
        result.data.appendSlice(gpa, "es") catch { setError(.out_of_memory); };
    } else {
        result.data.appendSlice(gpa, "s") catch { setError(.out_of_memory); };
    }
    return result;
}

/// Simple pig latin: move leading consonants to end + "ay". Vowel-starting words get "yay".
pub fn str_to_pig_latin(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const vowels = "aeiouAEIOU";

    var first_word = true;
    var ii: usize = 0;
    while (ii < src.len) {
        // Skip/copy spaces
        if (src[ii] == ' ') {
            result.data.appendSlice(gpa, " ") catch break;
            ii += 1;
            continue;
        }

        if (!first_word) {} // spaces already handled
        first_word = false;

        // Find word boundaries
        const word_start = ii;
        while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
        const word = src[word_start..ii];

        // Check if first char is vowel
        var is_vowel_start = false;
        for (vowels) |v| {
            if (word[0] == v) {
                is_vowel_start = true;
                break;
            }
        }

        if (is_vowel_start) {
            result.data.appendSlice(gpa, word) catch break;
            result.data.appendSlice(gpa, "yay") catch break;
        } else {
            // Find first vowel position
            var vowel_pos: usize = word.len;
            for (word, 0..) |c, ci| {
                for (vowels) |v| {
                    if (c == v) {
                        vowel_pos = ci;
                        break;
                    }
                }
                if (vowel_pos != word.len) break;
            }
            if (vowel_pos == word.len) {
                // No vowel, just append + "ay"
                result.data.appendSlice(gpa, word) catch break;
                result.data.appendSlice(gpa, "ay") catch break;
            } else {
                result.data.appendSlice(gpa, word[vowel_pos..]) catch break;
                result.data.appendSlice(gpa, word[0..vowel_pos]) catch break;
                result.data.appendSlice(gpa, "ay") catch break;
            }
        }
    }
    return result;
}

/// Convert to NATO phonetic alphabet. Non-letters skipped except spaces -> [space].
pub fn str_to_nato(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const nato = [26][]const u8{ "Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu" };
    var first = true;
    for (src) |c| {
        var idx: ?usize = null;
        if (c >= 'a' and c <= 'z') idx = c - 'a';
        if (c >= 'A' and c <= 'Z') idx = c - 'A';
        if (idx) |i| {
            if (!first) result.data.appendSlice(gpa, " ") catch { setError(.out_of_memory); };
            result.data.appendSlice(gpa, nato[i]) catch { setError(.out_of_memory); };
            first = false;
        } else if (c == ' ') {
            if (!first) result.data.appendSlice(gpa, " ") catch { setError(.out_of_memory); };
            result.data.appendSlice(gpa, "[space]") catch { setError(.out_of_memory); };
            first = false;
        }
    }
    return result;
}

/// Mask an email address: show first char of local part, mask rest with *.
pub fn str_mask_email(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    // Find @ position
    var at_pos: ?usize = null;
    for (src, 0..) |c, idx| {
        if (c == '@') {
            at_pos = idx;
            break;
        }
    }
    if (at_pos) |ap| {
        if (ap > 0) {
            // Show first char, mask rest of local part
            result.data.appendSlice(gpa, &[_]u8{src[0]}) catch { setError(.out_of_memory); };
            var i: usize = 1;
            while (i < ap) : (i += 1) {
                result.data.appendSlice(gpa, &[_]u8{'*'}) catch break;
            }
        }
        // Append @domain
        result.data.appendSlice(gpa, src[ap..]) catch { setError(.out_of_memory); };
    } else {
        // No @, just copy
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    }
    return result;
}

// ─── Tests ───

const testing = std.testing;

test "levenshtein distance" {
    const s1 = str_from("kitten", 6) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("sitting", 7) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 3), str_levenshtein(s1, s2));
}

test "levenshtein identical" {
    const s1 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 0), str_levenshtein(s1, s2));
}

test "hamming distance same length" {
    const s1 = str_from("karolin", 7) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("kathrin", 7) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 3), str_hamming_distance(s1, s2));
}

test "hamming distance different length returns -1" {
    const s1 = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("abcd", 4) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, -1), str_hamming_distance(s1, s2));
}

test "jaro identical" {
    const s1 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 1000), str_jaro(s1, s2));
}

test "jaro_winkler >= jaro" {
    const s1 = str_from("martha", 6) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("marhta", 6) orelse return error.SkipZigTest;
    defer str_free(s2);
    const j = str_jaro(s1, s2);
    const jw = str_jaro_winkler(s1, s2);
    try testing.expect(jw >= j);
}

test "jaccard similarity identical" {
    const s1 = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s1);
    const s2 = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s2);
    try testing.expectEqual(@as(c_int, 100), str_jaccard_similarity(s1, s2));
}

test "soundex" {
    const s = str_from("Robert", 6) orelse return error.SkipZigTest;
    defer str_free(s);
    const code = str_soundex(s) orelse return error.SkipZigTest;
    defer str_free(code);
    try testing.expectEqualStrings("R163", code.slice());
}

test "metaphone" {
    const s = str_from("Smith", 5) orelse return error.SkipZigTest;
    defer str_free(s);
    const code = str_metaphone(s) orelse return error.SkipZigTest;
    defer str_free(code);
    try testing.expectEqualStrings("SM0", code.slice());
}

test "ngram count" {
    const s = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s);
    try testing.expectEqual(@as(c_int, 4), str_ngram_count(s, 2));
}

test "char ngrams" {
    const s = str_from("abc", 3) orelse return error.SkipZigTest;
    defer str_free(s);
    const ng = str_char_ngrams(s, 2) orelse return error.SkipZigTest;
    defer str_free(ng);
    try testing.expectEqualStrings("ab|bc", ng.slice());
}

test "word ngrams" {
    const s = str_from("the quick brown", 15) orelse return error.SkipZigTest;
    defer str_free(s);
    const ng = str_word_ngrams(s, 2) orelse return error.SkipZigTest;
    defer str_free(ng);
    try testing.expectEqualStrings("the quick|quick brown", ng.slice());
}

test "extract numbers" {
    const s = str_from("call 123 or 456", 15) orelse return error.SkipZigTest;
    defer str_free(s);
    const nums = str_extract_numbers(s) orelse return error.SkipZigTest;
    defer str_free(nums);
    try testing.expectEqualStrings("123 456", nums.slice());
}

test "extract emails" {
    const s = str_from("contact me@here.com now", 23) orelse return error.SkipZigTest;
    defer str_free(s);
    const emails = str_extract_emails(s) orelse return error.SkipZigTest;
    defer str_free(emails);
    try testing.expectEqualStrings("me@here.com", emails.slice());
}

test "pluralize regular" {
    const s = str_from("cat", 3) orelse return error.SkipZigTest;
    defer str_free(s);
    const p = str_pluralize(s) orelse return error.SkipZigTest;
    defer str_free(p);
    try testing.expectEqualStrings("cats", p.slice());
}

test "pluralize y-ending" {
    const s = str_from("baby", 4) orelse return error.SkipZigTest;
    defer str_free(s);
    const p = str_pluralize(s) orelse return error.SkipZigTest;
    defer str_free(p);
    try testing.expectEqualStrings("babies", p.slice());
}

test "pig latin" {
    const s = str_from("hello world", 11) orelse return error.SkipZigTest;
    defer str_free(s);
    const pl = str_to_pig_latin(s) orelse return error.SkipZigTest;
    defer str_free(pl);
    try testing.expectEqualStrings("ellohay orldway", pl.slice());
}

test "nato alphabet" {
    const s = str_from("SOS", 3) orelse return error.SkipZigTest;
    defer str_free(s);
    const nato = str_to_nato(s) orelse return error.SkipZigTest;
    defer str_free(nato);
    try testing.expectEqualStrings("Sierra Oscar Sierra", nato.slice());
}

test "mask email" {
    const s = str_from("user@example.com", 16) orelse return error.SkipZigTest;
    defer str_free(s);
    const masked = str_mask_email(s) orelse return error.SkipZigTest;
    defer str_free(masked);
    try testing.expectEqualStrings("u***@example.com", masked.slice());
}
