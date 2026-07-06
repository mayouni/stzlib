// Softanza Engine -- Phonetic encoding (extracted from the old nlp.zig)
//
// Soundex and Metaphone: collapse a word to a phonetic key so that similarly-
// sounding names/words compare equal ("Robert"/"Rupert" -> R163). English-
// oriented by construction. Used for fuzzy name matching and search.

const std = @import("std");
const core = @import("core.zig");
const mem = core.mem;
const gpa = core.gpa;
const StzString = core.StzString;
const StzStringHandle = core.StzStringHandle;
const setError = core.setError;
const str_new = core.str_new;
const str_from = core.str_from;
const str_free = core.str_free;
const isVowelAscii = core.isVowelAscii;

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


// ─── Tests ───

const testing = std.testing;

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

