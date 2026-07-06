// Softanza Engine -- Text Analytics (was nlp.zig)
//
// String metrics, phonetics, frequency/statistics, and text transforms. This is
// text ANALYTICS, not linguistic NLP: it does statistics over already-tokenized
// text. Tokenization itself lives behind the segmentation seam in word_break.zig
// (UAX#29), which every word/sentence consumer here routes through. The genuinely
// linguistic layer (stemming, lemmatization, POS, dictionary CJK/Thai
// segmentation) is a future vendor step (ICU / snowball / libthai), not this file.
//
// Categories:
//   Similarity/fuzzy: Levenshtein, Hamming, Jaro, Jaro-Winkler, Jaccard, edit-cluster
//   Phonetics: Soundex, Metaphone
//   Frequency/stats: word/char/n-gram frequency, streaming accumulator,
//                    collocations (PMI), cosine similarity, TF-IDF
//   N-grams: ngram, ngram_count, char_ngrams, word_ngrams
//   Extraction/aggregates: numbers (+ numeric aggregates), emails, words, sentence stats
//   Transforms: pluralize, to_pig_latin, to_nato, mask_email

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");

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
const ciMatch = core.ciMatch;
const StzFindResult = core.StzFindResult;
const StzFindResultHandle = core.StzFindResultHandle;
const StzStrListResult = core.StzStrListResult;
const StzStrListResultHandle = core.StzStrListResultHandle;
const isVowelAscii = core.isVowelAscii;

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
    // Tokenize through the UAX#29 word-segmentation seam (word_break.zig):
    // digits stay in words ("word2vec"), apostrophes/decimals hold ("don't",
    // "3.14"), CJK breaks per codepoint, punctuation/symbols separate.
    var wit = wb.WordIter.init(src);
    var first = true;
    while (wit.next()) |span| {
        if (!first) result.data.appendSlice(gpa, " ") catch { setError(.out_of_memory); };
        result.data.appendSlice(gpa, src[span.start..span.end]) catch { setError(.out_of_memory); };
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

fn allAscii(bytes: []const u8) bool {
    for (bytes) |b| {
        if (b >= 0x80) return false;
    }
    return true;
}

// ASCII-fast whole-buffer fold for cs=0: pure-ASCII -> byte lowercase (== ASCII
// casefold, no utf8proc); else utf8proc casefold. Returns null when cs!=0 (the
// caller then uses the raw buffer). Caller frees the returned buffer.
fn foldWholeAlloc(raw: []const u8, cs: c_int, is_ascii: bool) ?[]u8 {
    if (cs != 0) return null;
    if (is_ascii) {
        const buf = gpa.alloc(u8, raw.len) catch return casefoldAlloc(raw);
        for (raw, 0..) |ch, idx| buf[idx] = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
        return buf;
    }
    return casefoldAlloc(raw);
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
    _ = accumulateWords(&map, &order, src, cs);

    finalizeFreq(&map, n_top, r);
    return r;
}

// Tokenize `src` (word = run of isWordByte + interior apostrophes) and fold its
// counts into `map`: key is a casefolded copy when cs==0 else a raw copy, and
// value.rep is an owned copy of the ORIGINAL first-seen bytes. *order advances
// per newly-seen key. Returns the number of tokens seen. Shared by str_word_freq
// (one-shot) and the streaming accumulator so both tokenize identically.
// If `word` is pure ASCII, lowercase it into `buf` and return that slice
// (ASCII casefold == ASCII lowercase). Returns null if any byte is >= 0x80
// (needs full Unicode casefold) or the word doesn't fit the buffer.
fn asciiFoldInto(word: []const u8, buf: []u8) ?[]u8 {
    if (word.len > buf.len) return null;
    var i: usize = 0;
    while (i < word.len) : (i += 1) {
        const ch = word[i];
        if (ch >= 0x80) return null;
        buf[i] = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
    }
    return buf[0..word.len];
}

fn accumulateWords(map: *std.StringHashMap(FreqEntry), order: *usize, src: []const u8, cs: c_int) u64 {
    var total: u64 = 0;
    var foldbuf: [256]u8 = undefined;
    var wit = wb.WordIter.init(src);
    while (wit.next()) |span| {
        const word = src[span.start..span.end];
        total += 1;

        // Build a PROBE key without allocating in the common case. cs=1 -> raw
        // word; cs=0 ASCII -> reused stack buffer; cs=0 non-ASCII -> owned fold.
        var probe: []const u8 = word;
        var fold_owned: ?[]u8 = null;
        if (cs == 0) {
            if (asciiFoldInto(word, &foldbuf)) |f| {
                probe = f;
            } else if (casefoldAlloc(word)) |f| {
                probe = f;
                fold_owned = f;
            }
        }

        // Probe first: an EXISTING word just bumps its count -- zero allocation.
        // This is the hot path (Zipf-distributed text hits the same keys again
        // and again), so it must not touch the allocator.
        if (map.getPtr(probe)) |vp| {
            vp.count += 1;
            if (fold_owned) |f| gpa.free(f);
            continue;
        }

        // New word: own the key (a copy of the fold) and the rep (the ORIGINAL
        // first-seen bytes).
        const key = gpa.alloc(u8, probe.len) catch {
            if (fold_owned) |f| gpa.free(f);
            continue;
        };
        @memcpy(key, probe);
        if (fold_owned) |f| gpa.free(f);
        const rep = gpa.alloc(u8, word.len) catch {
            gpa.free(key);
            continue;
        };
        @memcpy(rep, word);
        map.put(key, .{ .rep = rep, .count = 1, .order = order.* }) catch {
            gpa.free(key);
            gpa.free(rep);
            continue;
        };
        order.* += 1;
    }
    return total;
}

// Shared: collect the hashmap entries, sort (first-appearance for n_top<=0,
// count-desc for top-N), move the kept reps into r, free dropped reps + all
// keys, deinit the map. Used by str_word_freq and str_char_freq.
fn finalizeFreq(map: *std.StringHashMap(FreqEntry), n_top: c_int, r: *StzWordFreqResult) void {
    var entries = std.ArrayList(FreqEntry){};
    defer entries.deinit(gpa);
    var it = map.iterator();
    while (it.next()) |kv| entries.append(gpa, kv.value_ptr.*) catch {};
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
            gpa.free(entries.items[i].rep);
        }
    }
    var kit = map.keyIterator();
    while (kit.next()) |k| gpa.free(k.*);
    map.deinit();
}

// Like finalizeFreq but NON-destructive: COPIES the kept reps into r and leaves
// `map` (its reps AND keys) intact so a streaming accumulator can keep growing
// and be queried again. Used by str_word_stream_top.
fn snapshotFreq(map: *std.StringHashMap(FreqEntry), n_top: c_int, r: *StzWordFreqResult) void {
    var entries = std.ArrayList(FreqEntry){};
    defer entries.deinit(gpa);
    var it = map.iterator();
    while (it.next()) |kv| entries.append(gpa, kv.value_ptr.*) catch {};
    if (n_top <= 0) {
        std.sort.pdq(FreqEntry, entries.items, {}, orderLessThan);
    } else {
        std.sort.pdq(FreqEntry, entries.items, {}, freqLessThan);
    }
    const keep: usize = if (n_top <= 0) entries.items.len else @min(@as(usize, @intCast(n_top)), entries.items.len);
    var i: usize = 0;
    while (i < keep) : (i += 1) {
        const src_rep = entries.items[i].rep;
        const rep_copy = gpa.alloc(u8, src_rep.len) catch continue;
        @memcpy(rep_copy, src_rep);
        r.words.append(gpa, rep_copy) catch {
            gpa.free(rep_copy);
            continue;
        };
        r.counts.append(gpa, entries.items[i].count) catch {};
    }
}

// --- Streaming / incremental word-frequency accumulator ---
// Bounded-memory word counting over data too large (or too live) to hold at
// once: feed chunks, query top-N / totals at any point, keep feeding. State is
// bounded by the VOCABULARY size, not the input size -- a 10 GB log costs only
// its distinct-word table. Reuses the FreqEntry map + stz_word_freq_* accessors.
pub const StzWordStream = struct {
    map: std.StringHashMap(FreqEntry),
    order: usize,
    cs: c_int,
    total: u64, // running count of ALL tokens fed (with multiplicity)
};
pub const StzWordStreamHandle = ?*StzWordStream;

pub fn str_word_stream_new(cs: c_int) callconv(.c) StzWordStreamHandle {
    const st = gpa.create(StzWordStream) catch return null;
    st.* = .{ .map = std.StringHashMap(FreqEntry).init(gpa), .order = 0, .cs = cs, .total = 0 };
    return st;
}

pub fn str_word_stream_feed(handle: StzWordStreamHandle, chunk: [*c]const u8, chunk_len: usize) callconv(.c) void {
    const st = handle orelse return;
    if (chunk_len == 0) return;
    const src = chunk[0..chunk_len];
    st.total += accumulateWords(&st.map, &st.order, src, st.cs);
}

// Snapshot the current top-N (n_top<=0 = all, first-appearance order) WITHOUT
// consuming the accumulator. Returns a StzWordFreqResult drained the usual way.
pub fn str_word_stream_top(handle: StzWordStreamHandle, n_top: c_int) callconv(.c) StzWordFreqResultHandle {
    const r = gpa.create(StzWordFreqResult) catch return null;
    r.* = .{ .words = .{}, .counts = .{} };
    const st = handle orelse return r;
    snapshotFreq(&st.map, n_top, r);
    return r;
}

pub fn str_word_stream_total(handle: StzWordStreamHandle) callconv(.c) i64 {
    const st = handle orelse return 0;
    return @intCast(st.total);
}

pub fn str_word_stream_distinct(handle: StzWordStreamHandle) callconv(.c) i64 {
    const st = handle orelse return 0;
    return @intCast(st.map.count());
}

pub fn str_word_stream_free(handle: StzWordStreamHandle) callconv(.c) void {
    const st = handle orelse return;
    var vit = st.map.valueIterator();
    while (vit.next()) |v| gpa.free(v.rep);
    var kit = st.map.keyIterator();
    while (kit.next()) |k| gpa.free(k.*);
    st.map.deinit();
    gpa.destroy(st);
}

// Character (codepoint) frequency -- histograms, cryptanalysis, entropy. One
// pass, same result shape as str_word_freq (reuses stz_word_freq_* accessors).
// n_top<=0 -> all chars first-appearance order; else top-N by count. cs=0 folds.
pub fn str_char_freq(handle: StzStringHandle, cs: c_int, n_top: c_int) callconv(.c) StzWordFreqResultHandle {
    const r = gpa.create(StzWordFreqResult) catch return null;
    r.* = .{ .words = .{}, .counts = .{} };
    const s = handle orelse return r;
    const src = s.slice();
    var map = std.StringHashMap(FreqEntry).init(gpa);
    var order: usize = 0;
    var pos: usize = 0;
    var cbuf: [1]u8 = undefined; // reused fold buffer for a single ASCII codepoint
    while (pos < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[pos]) catch 1;
        const end = @min(pos + cp_len, src.len);
        const ch = src[pos..end];

        // Probe key without allocating in the common case. cs=1 -> raw cp; cs=0
        // ASCII single byte -> reused stack buffer; cs=0 multibyte -> owned fold.
        var probe: []const u8 = ch;
        var probe_owned: ?[]u8 = null;
        if (cs == 0) {
            if (ch.len == 1 and ch[0] < 0x80) {
                cbuf[0] = if (ch[0] >= 'A' and ch[0] <= 'Z') ch[0] + 32 else ch[0];
                probe = cbuf[0..1];
            } else if (casefoldAlloc(ch)) |f| {
                probe = f;
                probe_owned = f;
            }
        }

        // Probe first: an already-seen codepoint just bumps its count (a text
        // has few distinct codepoints, so nearly every char is a zero-alloc hit).
        if (map.getPtr(probe)) |vp| {
            vp.count += 1;
            if (probe_owned) |f| gpa.free(f);
            pos = end;
            continue;
        }
        const key = gpa.alloc(u8, probe.len) catch {
            if (probe_owned) |f| gpa.free(f);
            pos = end;
            continue;
        };
        @memcpy(key, probe);
        if (probe_owned) |f| gpa.free(f);
        const rep = gpa.alloc(u8, ch.len) catch {
            gpa.free(key);
            pos = end;
            continue;
        };
        @memcpy(rep, ch);
        map.put(key, .{ .rep = rep, .count = 1, .order = order }) catch {
            gpa.free(key);
            gpa.free(rep);
            pos = end;
            continue;
        };
        order += 1;
        pos = end;
    }
    finalizeFreq(&map, n_top, r);
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

// Count occurrences of `word` as a WHOLE WORD (same tokenization as
// str_extract_words), in ONE pass -- no materialization of the word list.
// Replaces the Ring NumberOfOccurrenceOfWordCS which did Words() (materialize
// EVERY word) then a Ring compare loop. cs=0 is ASCII-case-insensitive
// (casefold fallback for length-changing folds).
fn wordEql(token: []const u8, w: []const u8, cs: c_int) bool {
    if (cs != 0) return mem.eql(u8, token, w);
    if (token.len == w.len) return ciMatch(token, w);
    // Rare: fold both (length-changing case fold, e.g. ß).
    const ft = casefoldAlloc(token) orelse return false;
    defer gpa.free(ft);
    const fw = casefoldAlloc(w) orelse return false;
    defer gpa.free(fw);
    return mem.eql(u8, ft, fw);
}

pub fn str_count_word_cs(handle: StzStringHandle, word: [*c]const u8, word_len: usize, cs: c_int) callconv(.c) c_int {
    const s = (handle orelse return 0);
    if (word == null or word_len == 0) return 0;
    const src = s.slice();
    const w = word[0..word_len];
    var count: c_int = 0;
    var wit = wb.WordIter.init(src);
    while (wit.next()) |span| {
        if (wordEql(src[span.start..span.end], w, cs)) count += 1;
    }
    return count;
}

// Word N-GRAM frequency -- sequences of N consecutive words (bigrams,
// trigrams). Language modeling, autocomplete, collocation detection,
// plagiarism. One pass over the tokenized words; reuses StzWordFreqResult +
// the word-freq accessors. n_gram = words per gram (2=bigram, ...). Grams are
// the member words joined by a single space. cs=0 case-folds the key.
pub fn str_word_ngram_freq(handle: StzStringHandle, n_gram: c_int, cs: c_int, n_top: c_int) callconv(.c) StzWordFreqResultHandle {
    const r = gpa.create(StzWordFreqResult) catch return null;
    r.* = .{ .words = .{}, .counts = .{} };
    const s = handle orelse return r;
    if (n_gram <= 0) return r;
    const N: usize = @intCast(n_gram);
    const src = s.slice();

    // Collect word slices (views into src) through the UAX#29 seam.
    var words: std.ArrayList([]const u8) = .{};
    defer words.deinit(gpa);
    {
        var wit = wb.WordIter.init(src);
        while (wit.next()) |span| words.append(gpa, src[span.start..span.end]) catch {};
    }
    if (words.items.len < N) {
        return r; // fewer words than the gram size -> no grams
    }

    var map = std.StringHashMap(FreqEntry).init(gpa);
    var order: usize = 0;
    var i: usize = 0;
    var grambuf: std.ArrayList(u8) = .{}; // reused: raw gram (original case) -> rep
    defer grambuf.deinit(gpa);
    var foldbuf: std.ArrayList(u8) = .{}; // reused: ASCII-folded gram -> probe key
    defer foldbuf.deinit(gpa);
    while (i + N <= words.items.len) : (i += 1) {
        // Build the gram: words[i..i+N] joined by a single space, into a REUSED
        // buffer (no per-position ArrayList alloc/free).
        grambuf.clearRetainingCapacity();
        var j: usize = 0;
        while (j < N) : (j += 1) {
            if (j > 0) grambuf.append(gpa, ' ') catch {};
            grambuf.appendSlice(gpa, words.items[i + j]) catch {};
        }
        const g = grambuf.items;

        // Fold for cs=0 into a REUSED buffer (ASCII) or an owned alloc (multibyte);
        // the raw `g` is kept for the display rep.
        var probe: []const u8 = g;
        var probe_owned: ?[]u8 = null;
        if (cs == 0) {
            if (allAscii(g)) {
                foldbuf.clearRetainingCapacity();
                foldbuf.appendSlice(gpa, g) catch continue;
                for (foldbuf.items, 0..) |ch, idx| foldbuf.items[idx] = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
                probe = foldbuf.items;
            } else if (casefoldAlloc(g)) |f| {
                probe = f;
                probe_owned = f;
            }
        }

        // Probe first: a repeated gram just bumps its count -- zero allocation.
        if (map.getPtr(probe)) |vp| {
            vp.count += 1;
            if (probe_owned) |f| gpa.free(f);
            continue;
        }
        const key = gpa.alloc(u8, probe.len) catch {
            if (probe_owned) |f| gpa.free(f);
            continue;
        };
        @memcpy(key, probe);
        if (probe_owned) |f| gpa.free(f);
        const rep = gpa.alloc(u8, g.len) catch {
            gpa.free(key);
            continue;
        };
        @memcpy(rep, g);
        map.put(key, .{ .rep = rep, .count = 1, .order = order }) catch {
            gpa.free(key);
            gpa.free(rep);
            continue;
        };
        order += 1;
    }
    finalizeFreq(&map, n_top, r);
    return r;
}

// Cosine similarity of two documents' word-frequency (bag-of-words) vectors.
// 1.0 = identical term distribution, 0.0 = no shared terms. Plagiarism / near-
// duplicate / clustering / "find similar". One pass each; cs=0 folds. Term
// vectors are TF; for corpus TF-IDF weighting see str_tfidf_keywords.
fn tokenCounts(work: []const u8, map: *std.StringHashMap(f64)) void {
    var wit = wb.WordIter.init(work);
    while (wit.next()) |span| {
        const gop = map.getOrPut(work[span.start..span.end]) catch continue;
        if (!gop.found_existing) gop.value_ptr.* = 0;
        gop.value_ptr.* += 1;
    }
}

pub fn str_cosine_similarity(handle: StzStringHandle, other: [*c]const u8, other_len: usize, cs: c_int) callconv(.c) f64 {
    const s = (handle orelse return 0);
    const a_raw = s.slice();
    const b_raw = if (other == null) &[_]u8{} else other[0..other_len];
    // ASCII fast-fold (the cached flag for a; a scan for the other buffer).
    const fa = foldWholeAlloc(a_raw, cs, s.isAscii());
    defer if (fa) |f| gpa.free(f);
    const fb = foldWholeAlloc(b_raw, cs, allAscii(b_raw));
    defer if (fb) |f| gpa.free(f);
    const wa: []const u8 = if (fa) |f| f else a_raw;
    const wdb: []const u8 = if (fb) |f| f else b_raw;

    var ta = std.StringHashMap(f64).init(gpa);
    defer ta.deinit();
    var tb = std.StringHashMap(f64).init(gpa);
    defer tb.deinit();
    tokenCounts(wa, &ta);
    tokenCounts(wdb, &tb);

    var dot: f64 = 0;
    var na: f64 = 0;
    var it = ta.iterator();
    while (it.next()) |kv| {
        const v = kv.value_ptr.*;
        na += v * v;
        if (tb.get(kv.key_ptr.*)) |bv| dot += v * bv;
    }
    var nb: f64 = 0;
    var itb = tb.valueIterator();
    while (itb.next()) |vp| nb += vp.* * vp.*;
    if (na == 0 or nb == 0) return 0;
    return dot / (@sqrt(na) * @sqrt(nb));
}

// ─── Collocations via PMI (statistically significant word pairs) ───
//
// Pointwise Mutual Information ranks adjacent word pairs: PMI(w1,w2) =
// log( c(w1,w2) * Ntokens / (c(w1) * c(w2)) ). High PMI = a pair that occurs
// together far more than chance ("machine learning", "New York"). min_count
// filters rare/noisy pairs. Returns the top-N bigrams by PMI as a
// StzStrListResult (the phrases). cs=0 folds. One pass over the tokens.
const Colloc = struct { phrase: []const u8, pmi: f64 };
fn collLess(_: void, a: Colloc, b: Colloc) bool {
    return a.pmi > b.pmi;
}

pub fn str_collocations(handle: StzStringHandle, min_count: c_int, top: c_int, cs: c_int) callconv(.c) StzStrListResultHandle {
    const r = gpa.create(StzStrListResult) catch return null;
    r.* = StzStrListResult.init();
    const s = (handle orelse return r);
    const raw = s.slice();
    // Fold once for cs=0, ASCII fast-path (avoids utf8proc over the whole buffer).
    const folded = foldWholeAlloc(raw, cs, s.isAscii());
    defer if (folded) |f| gpa.free(f);
    const work: []const u8 = if (folded) |f| f else raw;

    var words: std.ArrayList([]const u8) = .{};
    defer words.deinit(gpa);
    {
        var wit = wb.WordIter.init(work);
        while (wit.next()) |span| words.append(gpa, work[span.start..span.end]) catch {};
    }
    if (words.items.len < 2) return r;

    var uni = std.StringHashMap(f64).init(gpa);
    defer uni.deinit();
    for (words.items) |w| {
        const gop = uni.getOrPut(w) catch continue;
        if (!gop.found_existing) gop.value_ptr.* = 0;
        gop.value_ptr.* += 1;
    }
    // bigram counts, keyed by owned "w1 w2".
    var big = std.StringHashMap(i64).init(gpa);
    defer {
        var kit = big.keyIterator();
        while (kit.next()) |k| gpa.free(k.*);
        big.deinit();
    }
    var i: usize = 0;
    var keybuf: [512]u8 = undefined; // reused probe buffer for "w1 w2"
    while (i + 1 < words.items.len) : (i += 1) {
        const w1 = words.items[i];
        const w2 = words.items[i + 1];
        const klen = w1.len + 1 + w2.len;

        // Build the probe key WITHOUT allocating when it fits the stack buffer.
        var probe: []const u8 = undefined;
        var probe_owned: ?[]u8 = null;
        if (klen <= keybuf.len) {
            @memcpy(keybuf[0..w1.len], w1);
            keybuf[w1.len] = ' ';
            @memcpy(keybuf[w1.len + 1 .. klen], w2);
            probe = keybuf[0..klen];
        } else {
            const k = gpa.alloc(u8, klen) catch continue;
            @memcpy(k[0..w1.len], w1);
            k[w1.len] = ' ';
            @memcpy(k[w1.len + 1 ..], w2);
            probe = k;
            probe_owned = k;
        }

        // Probe first: a repeated bigram just bumps its count -- zero allocation.
        if (big.getPtr(probe)) |vp| {
            vp.* += 1;
            if (probe_owned) |k| gpa.free(k);
            continue;
        }
        // New bigram: reuse the owned buffer if we made one, else copy the stack
        // key into an owned slot.
        const key = probe_owned orelse blk: {
            const k = gpa.alloc(u8, klen) catch continue;
            @memcpy(k, probe);
            break :blk k;
        };
        big.put(key, 1) catch {
            gpa.free(key);
            continue;
        };
    }

    const Nu: f64 = @floatFromInt(words.items.len);
    const minc: i64 = min_count;
    var entries: std.ArrayList(Colloc) = .{};
    defer entries.deinit(gpa);
    var it = big.iterator();
    while (it.next()) |kv| {
        if (kv.value_ptr.* < minc) continue;
        const phrase = kv.key_ptr.*;
        const sp = std.mem.indexOfScalar(u8, phrase, ' ') orelse continue;
        const c1 = uni.get(phrase[0..sp]) orelse continue;
        const c2 = uni.get(phrase[sp + 1 ..]) orelse continue;
        const cbg: f64 = @floatFromInt(kv.value_ptr.*);
        const pmi = @log(cbg * Nu / (c1 * c2));
        entries.append(gpa, .{ .phrase = phrase, .pmi = pmi }) catch {};
    }
    std.sort.pdq(Colloc, entries.items, {}, collLess);
    const keep: usize = if (top <= 0) entries.items.len else @min(@as(usize, @intCast(top)), entries.items.len);
    var k: usize = 0;
    while (k < keep) : (k += 1) r.push(entries.items[k].phrase);
    return r;
}

// ─── TF-IDF keyword extraction across a document corpus ───
//
// Input: documents NUL-packed into one buffer. For each document, rank its
// terms by TF-IDF = tf(term,doc) * ln(Ndocs / df(term)) and emit the top-N
// keywords. Output packing: documents separated by 0x01, keywords within a
// document by NUL. Keyword extraction, search relevance, doc summarization,
// tag suggestion. cs=0 folds the whole corpus once (keywords come out folded).
const TfidfEntry = struct { term: []const u8, score: f64 };
fn tfidfLess(_: void, a: TfidfEntry, b: TfidfEntry) bool {
    return a.score > b.score; // higher score first
}

pub fn str_tfidf_keywords(handle: StzStringHandle, n_top: c_int, cs: c_int) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = (handle orelse return result);
    const raw = s.slice();
    if (raw.len == 0) return result;
    const folded: ?[]u8 = if (cs == 0) casefoldAlloc(raw) else null;
    defer if (folded) |f| gpa.free(f);
    const work: []const u8 = if (folded) |f| f else raw; // NUL folds to NUL -> doc boundaries preserved

    var docs: std.ArrayList([]const u8) = .{};
    defer docs.deinit(gpa);
    core.splitNul(work, &docs);
    const ND = docs.items.len;
    if (ND == 0) return result;

    // Pass 1: document frequency df[term] = # docs containing term. Keys are
    // views into `work` (stable for the whole call), so no key ownership.
    var df = std.StringHashMap(f64).init(gpa);
    defer df.deinit();
    for (docs.items) |doc| {
        var seen = std.StringHashMap(void).init(gpa);
        defer seen.deinit();
        var wit = wb.WordIter.init(doc);
        while (wit.next()) |span| {
            const term = doc[span.start..span.end];
            if (!seen.contains(term)) {
                seen.put(term, {}) catch {};
                const gop = df.getOrPut(term) catch continue;
                if (!gop.found_existing) gop.value_ptr.* = 0;
                gop.value_ptr.* += 1;
            }
        }
    }

    const NDf: f64 = @floatFromInt(ND);
    const keep_n: usize = if (n_top <= 0) std.math.maxInt(usize) else @intCast(n_top);
    // Pass 2: per document, TF-IDF, rank, emit.
    for (docs.items, 0..) |doc, di| {
        var tf = std.StringHashMap(f64).init(gpa);
        defer tf.deinit();
        var wit = wb.WordIter.init(doc);
        while (wit.next()) |span| {
            const term = doc[span.start..span.end];
            const gop = tf.getOrPut(term) catch continue;
            if (!gop.found_existing) gop.value_ptr.* = 0;
            gop.value_ptr.* += 1;
        }
        var entries: std.ArrayList(TfidfEntry) = .{};
        defer entries.deinit(gpa);
        var it = tf.iterator();
        while (it.next()) |kv| {
            const dfv = df.get(kv.key_ptr.*) orelse 1;
            const idf = @log(NDf / dfv);
            entries.append(gpa, .{ .term = kv.key_ptr.*, .score = kv.value_ptr.* * idf }) catch {};
        }
        std.sort.pdq(TfidfEntry, entries.items, {}, tfidfLess);
        const keep = @min(keep_n, entries.items.len);

        if (di > 0) result.data.append(gpa, 0x01) catch {}; // doc separator
        var j: usize = 0;
        while (j < keep) : (j += 1) {
            if (j > 0) result.data.append(gpa, 0) catch {}; // keyword separator (NUL)
            result.data.appendSlice(gpa, entries.items[j].term) catch {};
        }
    }
    return result;
}

// Sentence-length extremes (readability stats). Sentence = text up to each
// .!? terminator (matching str_count_sentences). mode 0 = max words in any
// sentence, 1 = min words over NON-empty sentences. One pass. Multibyte words
// count as one (a run of isWordByte).
pub fn str_sentence_stat(handle: StzStringHandle, mode: c_int) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const src = s.slice();
    // Segment through the sentence seam (handles decimals / abbreviations), and
    // count words in each sentence through the word seam.
    var maxw: c_int = 0;
    var minw: c_int = -1;
    var sit = wb.SentenceIter.init(src);
    while (sit.next()) |span| {
        const cur: c_int = @intCast(wb.countWords(src[span.start..span.end]));
        if (cur > maxw) maxw = cur;
        if (cur > 0 and (minw < 0 or cur < minw)) minw = cur;
    }
    return switch (mode) {
        0 => maxw,
        1 => if (minw < 0) 0 else minw,
        else => 0,
    };
}

// One-pass numeric aggregate over the numbers embedded in text (invoices,
// logs, totals, data extraction). A number token = optional '-', digits, one
// optional '.' with more digits -- matching Numbers(). Parses each to f64 and
// returns the requested aggregate WITHOUT materializing a number list.
//   mode 0=sum  1=count  2=min  3=max  4=mean
pub fn str_numbers_agg(handle: StzStringHandle, mode: c_int) callconv(.c) f64 {
    const s = (handle orelse return 0);
    const src = s.slice();
    var count: usize = 0;
    var sum: f64 = 0;
    var vmin: f64 = 0;
    var vmax: f64 = 0;
    var pos: usize = 0;
    while (pos < src.len) {
        const c = src[pos];
        const digit_next = pos + 1 < src.len and src[pos + 1] >= '0' and src[pos + 1] <= '9';
        const is_start = (c >= '0' and c <= '9') or (c == '-' and digit_next);
        if (!is_start) {
            pos += 1;
            continue;
        }
        const start = pos;
        if (src[pos] == '-') pos += 1;
        var seen_dot = false;
        while (pos < src.len) {
            const d = src[pos];
            if (d >= '0' and d <= '9') {
                pos += 1;
            } else if (d == '.' and !seen_dot) {
                seen_dot = true;
                pos += 1;
            } else break;
        }
        var tok = src[start..pos];
        if (tok.len > 0 and tok[tok.len - 1] == '.') tok = tok[0 .. tok.len - 1]; // "5." -> "5"
        const v = std.fmt.parseFloat(f64, tok) catch continue;
        count += 1;
        sum += v;
        if (count == 1) {
            vmin = v;
            vmax = v;
        } else {
            if (v < vmin) vmin = v;
            if (v > vmax) vmax = v;
        }
    }
    return switch (mode) {
        0 => sum,
        1 => @floatFromInt(count),
        2 => if (count == 0) 0 else vmin,
        3 => if (count == 0) 0 else vmax,
        4 => if (count == 0) 0 else sum / @as(f64, @floatFromInt(count)),
        else => 0,
    };
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
