const std = @import("std");

// ── Paragraph splitting ────────────────────────────────────────

pub fn text_split_paragraphs(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0 or max < 2) return 0;
    const data = ptr[0..len];
    var writer = BufWriter{ .buf = out, .max = max };

    var start: usize = 0;
    var i: usize = 0;
    while (i < data.len) {
        if (data[i] == '\n') {
            var nl_count: usize = 1;
            var j = i + 1;
            while (j < data.len and (data[j] == '\n' or data[j] == '\r' or data[j] == ' ' or data[j] == '\t')) : (j += 1) {
                if (data[j] == '\n') nl_count += 1;
            }
            if (nl_count >= 2) {
                const para = std.mem.trim(u8, data[start..i], &[_]u8{ ' ', '\t', '\r', '\n' });
                if (para.len > 0) {
                    if (writer.pos > 0) writer.writeByte('\n') catch return @intCast(writer.pos);
                    writer.writeAll(para) catch return @intCast(writer.pos);
                }
                start = j;
                i = j;
            } else {
                i = j;
            }
        } else {
            i += 1;
        }
    }
    const last = std.mem.trim(u8, data[start..], &[_]u8{ ' ', '\t', '\r', '\n' });
    if (last.len > 0) {
        if (writer.pos > 0) writer.writeByte('\n') catch return @intCast(writer.pos);
        writer.writeAll(last) catch return @intCast(writer.pos);
    }
    return @intCast(writer.pos);
}

pub fn text_paragraph_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    var in_text = false;
    var i: usize = 0;
    while (i < data.len) {
        if (data[i] == '\n') {
            var nl_count: usize = 1;
            var j = i + 1;
            while (j < data.len and (data[j] == '\n' or data[j] == '\r' or data[j] == ' ' or data[j] == '\t')) : (j += 1) {
                if (data[j] == '\n') nl_count += 1;
            }
            if (nl_count >= 2 and in_text) {
                count += 1;
                in_text = false;
            }
            i = j;
        } else if (data[i] != ' ' and data[i] != '\t' and data[i] != '\r') {
            in_text = true;
            i += 1;
        } else {
            i += 1;
        }
    }
    if (in_text) count += 1;
    return count;
}

// ── Sentence segmentation ──────────────────────────────────────

fn isSentenceEnd(data: []const u8, pos: usize) bool {
    if (pos >= data.len) return false;
    const ch = data[pos];
    if (ch != '.' and ch != '!' and ch != '?') return false;

    if (ch == '.') {
        if (pos > 0 and pos + 1 < data.len) {
            const prev = data[pos - 1];
            const next = data[pos + 1];
            if (prev >= 'A' and prev <= 'Z' and (next == ' ' or next == '\n')) {
                if (pos >= 2 and (data[pos - 2] == ' ' or data[pos - 2] == '\n' or pos == 1)) {
                    return false;
                }
            }
        }
        if (pos + 1 < data.len and data[pos + 1] >= '0' and data[pos + 1] <= '9') return false;
        if (pos + 1 < data.len and data[pos + 1] == '.') return false;
    }

    if (pos + 1 >= data.len) return true;
    const after = data[pos + 1];
    return after == ' ' or after == '\n' or after == '\r' or after == '\t';
}

pub fn text_sentence_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    for (0..data.len) |i| {
        if (isSentenceEnd(data, i)) count += 1;
    }
    if (count == 0 and len > 0) {
        const trimmed = std.mem.trim(u8, data, &[_]u8{ ' ', '\t', '\r', '\n' });
        if (trimmed.len > 0) count = 1;
    }
    return count;
}

pub fn text_split_sentences(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0 or max < 2) return 0;
    const data = ptr[0..len];
    var writer = BufWriter{ .buf = out, .max = max };
    var start: usize = 0;

    for (0..data.len) |i| {
        if (isSentenceEnd(data, i)) {
            const sent = std.mem.trim(u8, data[start .. i + 1], &[_]u8{ ' ', '\t', '\r', '\n' });
            if (sent.len > 0) {
                if (writer.pos > 0) writer.writeByte('\n') catch return @intCast(writer.pos);
                writer.writeAll(sent) catch return @intCast(writer.pos);
            }
            start = i + 1;
            while (start < data.len and (data[start] == ' ' or data[start] == '\t')) : (start += 1) {}
        }
    }
    const last = std.mem.trim(u8, data[start..], &[_]u8{ ' ', '\t', '\r', '\n' });
    if (last.len > 0) {
        if (writer.pos > 0) writer.writeByte('\n') catch return @intCast(writer.pos);
        writer.writeAll(last) catch return @intCast(writer.pos);
    }
    return @intCast(writer.pos);
}

// ── Word counting ──────────────────────────────────────────────

pub fn text_word_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    var in_word = false;
    for (data) |ch| {
        if (ch == ' ' or ch == '\t' or ch == '\n' or ch == '\r') {
            if (in_word) {
                count += 1;
                in_word = false;
            }
        } else {
            in_word = true;
        }
    }
    if (in_word) count += 1;
    return count;
}

pub fn text_char_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 0;
    for (data) |ch| {
        if (ch != ' ' and ch != '\t' and ch != '\n' and ch != '\r') count += 1;
    }
    return count;
}

pub fn text_line_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var count: i32 = 1;
    for (data) |ch| {
        if (ch == '\n') count += 1;
    }
    return count;
}

// ── Readability metrics ────────────────────────────────────────

fn countSyllables(word: []const u8) u32 {
    if (word.len == 0) return 0;
    var count: u32 = 0;
    var prev_vowel = false;
    for (word) |ch| {
        const lower = if (ch >= 'A' and ch <= 'Z') ch + 32 else ch;
        const is_vowel = lower == 'a' or lower == 'e' or lower == 'i' or lower == 'o' or lower == 'u' or lower == 'y';
        if (is_vowel and !prev_vowel) count += 1;
        prev_vowel = is_vowel;
    }
    if (count == 0) count = 1;
    if (word.len > 2) {
        const last = if (word[word.len - 1] >= 'A' and word[word.len - 1] <= 'Z') word[word.len - 1] + 32 else word[word.len - 1];
        if (last == 'e' and count > 1) count -= 1;
    }
    return count;
}

pub fn text_syllable_count(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var total: i32 = 0;
    var start: usize = 0;
    var in_word = false;
    for (data, 0..) |ch, i| {
        const is_alpha = (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '\'';
        if (is_alpha) {
            if (!in_word) start = i;
            in_word = true;
        } else {
            if (in_word) {
                total += @intCast(countSyllables(data[start..i]));
                in_word = false;
            }
        }
    }
    if (in_word) total += @intCast(countSyllables(data[start..]));
    return total;
}

pub fn text_flesch_reading_ease(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    const words = text_word_count(ptr, len);
    const sents = text_sentence_count(ptr, len);
    const sylls = text_syllable_count(ptr, len);
    if (words == 0 or sents == 0) return 0;
    const asl: f64 = @as(f64, @floatFromInt(words)) / @as(f64, @floatFromInt(sents));
    const asw: f64 = @as(f64, @floatFromInt(sylls)) / @as(f64, @floatFromInt(words));
    const score = 206.835 - 1.015 * asl - 84.6 * asw;
    return @intFromFloat(@round(score * 100));
}

pub fn text_flesch_kincaid_grade(ptr: [*]const u8, len: usize) callconv(.c) i32 {
    const words = text_word_count(ptr, len);
    const sents = text_sentence_count(ptr, len);
    const sylls = text_syllable_count(ptr, len);
    if (words == 0 or sents == 0) return 0;
    const asl: f64 = @as(f64, @floatFromInt(words)) / @as(f64, @floatFromInt(sents));
    const asw: f64 = @as(f64, @floatFromInt(sylls)) / @as(f64, @floatFromInt(words));
    const grade = 0.39 * asl + 11.8 * asw - 15.59;
    return @intFromFloat(@round(grade * 100));
}

// ── Text summarization helpers ─────────────────────────────────

pub fn text_truncate(ptr: [*]const u8, len: usize, max_words: i32, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0 or max < 4 or max_words <= 0) return 0;
    const data = ptr[0..len];
    const mw: usize = @intCast(max_words);

    var word_count: usize = 0;
    var cut_pos: usize = data.len;
    var in_word = false;

    for (data, 0..) |ch, i| {
        const is_ws = ch == ' ' or ch == '\t' or ch == '\n' or ch == '\r';
        if (is_ws) {
            if (in_word) {
                word_count += 1;
                if (word_count >= mw) {
                    cut_pos = i;
                    break;
                }
                in_word = false;
            }
        } else {
            in_word = true;
        }
    }

    const needs_ellipsis = cut_pos < data.len;
    const text_max = if (needs_ellipsis) max -| 3 else max;
    const text_len = @min(cut_pos, text_max);
    @memcpy(out[0..text_len], data[0..text_len]);
    var pos = text_len;
    if (needs_ellipsis and pos + 3 <= max) {
        out[pos] = '.';
        out[pos + 1] = '.';
        out[pos + 2] = '.';
        pos += 3;
    }
    return @intCast(pos);
}

// ── C ABI exports ──────────────────────────────────────────────

pub export fn stz_text_paragraph_count(p: [*]const u8, l: usize) callconv(.c) i32 { return text_paragraph_count(p, l); }
pub export fn stz_text_split_paragraphs(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return text_split_paragraphs(p, l, o, m); }
pub export fn stz_text_sentence_count(p: [*]const u8, l: usize) callconv(.c) i32 { return text_sentence_count(p, l); }
pub export fn stz_text_split_sentences(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return text_split_sentences(p, l, o, m); }
pub export fn stz_text_word_count(p: [*]const u8, l: usize) callconv(.c) i32 { return text_word_count(p, l); }
pub export fn stz_text_char_count(p: [*]const u8, l: usize) callconv(.c) i32 { return text_char_count(p, l); }
pub export fn stz_text_line_count(p: [*]const u8, l: usize) callconv(.c) i32 { return text_line_count(p, l); }
pub export fn stz_text_syllable_count(p: [*]const u8, l: usize) callconv(.c) i32 { return text_syllable_count(p, l); }
pub export fn stz_text_flesch_reading_ease(p: [*]const u8, l: usize) callconv(.c) i32 { return text_flesch_reading_ease(p, l); }
pub export fn stz_text_flesch_kincaid_grade(p: [*]const u8, l: usize) callconv(.c) i32 { return text_flesch_kincaid_grade(p, l); }
pub export fn stz_text_truncate(p: [*]const u8, l: usize, mw: i32, o: [*]u8, m: usize) callconv(.c) i32 { return text_truncate(p, l, mw, o, m); }

// ── BufWriter helper ───────────────────────────────────────────

const BufWriter = struct {
    buf: [*]u8,
    max: usize,
    pos: usize = 0,

    fn writeByte(self: *BufWriter, b: u8) !void {
        if (self.pos >= self.max) return error.NoSpaceLeft;
        self.buf[self.pos] = b;
        self.pos += 1;
    }

    fn writeAll(self: *BufWriter, data: []const u8) !void {
        const n = @min(data.len, self.max - self.pos);
        @memcpy(self.buf[self.pos..][0..n], data[0..n]);
        self.pos += n;
        if (n < data.len) return error.NoSpaceLeft;
    }
};

// ── Tests ──────────────────────────────────────────────────────

test "text: paragraph count" {
    const text = "First paragraph.\n\nSecond paragraph.\n\nThird paragraph.";
    try std.testing.expectEqual(@as(i32, 3), text_paragraph_count(text.ptr, text.len));
}

test "text: single paragraph" {
    const text = "Just one paragraph with no double newlines.";
    try std.testing.expectEqual(@as(i32, 1), text_paragraph_count(text.ptr, text.len));
}

test "text: paragraph split" {
    var buf: [256]u8 = undefined;
    const text = "Hello world.\n\nGoodbye world.";
    const len = text_split_paragraphs(text.ptr, text.len, &buf, 256);
    try std.testing.expect(len > 0);
    const result = buf[0..@intCast(len)];
    try std.testing.expect(std.mem.indexOf(u8, result, "\n") != null);
}

test "text: sentence count" {
    const text = "Hello world. How are you? I am fine!";
    try std.testing.expectEqual(@as(i32, 3), text_sentence_count(text.ptr, text.len));
}

test "text: sentence count single" {
    const text = "No punctuation here";
    try std.testing.expectEqual(@as(i32, 1), text_sentence_count(text.ptr, text.len));
}

test "text: sentence split" {
    var buf: [256]u8 = undefined;
    const text = "First sentence. Second sentence.";
    const len = text_split_sentences(text.ptr, text.len, &buf, 256);
    try std.testing.expect(len > 0);
    const result = buf[0..@intCast(len)];
    try std.testing.expect(std.mem.indexOf(u8, result, "\n") != null);
}

test "text: word count" {
    const text = "The quick brown fox jumps";
    try std.testing.expectEqual(@as(i32, 5), text_word_count(text.ptr, text.len));
}

test "text: word count empty" {
    try std.testing.expectEqual(@as(i32, 0), text_word_count("".ptr, 0));
}

test "text: char count excludes whitespace" {
    const text = "ab cd ef";
    try std.testing.expectEqual(@as(i32, 6), text_char_count(text.ptr, text.len));
}

test "text: line count" {
    const text = "line1\nline2\nline3";
    try std.testing.expectEqual(@as(i32, 3), text_line_count(text.ptr, text.len));
}

test "text: syllable count" {
    const text = "beautiful";
    try std.testing.expect(text_syllable_count(text.ptr, text.len) >= 3);
}

test "text: flesch reading ease returns nonzero" {
    const text = "The cat sat on the mat. The dog ran in the park. Simple sentences are easy to read.";
    const score = text_flesch_reading_ease(text.ptr, text.len);
    try std.testing.expect(score > 0);
}

test "text: flesch kincaid grade returns nonzero" {
    const text = "The cat sat on the mat. The dog ran in the park. Simple sentences are easy to read.";
    const grade = text_flesch_kincaid_grade(text.ptr, text.len);
    try std.testing.expect(grade != 0);
}

test "text: truncate" {
    var buf: [64]u8 = undefined;
    const text = "The quick brown fox jumps over the lazy dog";
    const len = text_truncate(text.ptr, text.len, 4, &buf, 64);
    const result = buf[0..@intCast(len)];
    try std.testing.expect(std.mem.startsWith(u8, result, "The quick brown fox"));
    try std.testing.expect(std.mem.endsWith(u8, result, "..."));
}

test "text: truncate short" {
    var buf: [64]u8 = undefined;
    const text = "Hi there";
    const len = text_truncate(text.ptr, text.len, 10, &buf, 64);
    const result = buf[0..@intCast(len)];
    try std.testing.expectEqualStrings("Hi there", result);
}
