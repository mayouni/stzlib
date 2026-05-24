const std = @import("std");

// ─── Polyglot String Registry ───
// Maps tokens to translations in multiple languages.

const MAX_TOKENS: usize = 128;
const MAX_LANGS_PER_TOKEN: usize = 16;
const MAX_KEY: usize = 64;
const MAX_TRANS: usize = 256;

const Translation = struct {
    lang: [MAX_KEY]u8 = undefined,
    lang_len: usize = 0,
    text: [MAX_TRANS]u8 = undefined,
    text_len: usize = 0,
};

const Token = struct {
    key: [MAX_KEY]u8 = undefined,
    key_len: usize = 0,
    translations: [MAX_LANGS_PER_TOKEN]Translation = [_]Translation{.{}} ** MAX_LANGS_PER_TOKEN,
    lang_count: usize = 0,
    active: bool = false,
};

var tokens: [MAX_TOKENS]Token = [_]Token{.{}} ** MAX_TOKENS;
var token_count: usize = 0;

fn findToken(key: []const u8) ?usize {
    for (0..MAX_TOKENS) |i| {
        if (tokens[i].active and tokens[i].key_len == key.len and
            std.mem.eql(u8, tokens[i].key[0..tokens[i].key_len], key))
            return i;
    }
    return null;
}

fn findOrCreateToken(key: []const u8) ?usize {
    if (findToken(key)) |idx| return idx;
    if (token_count >= MAX_TOKENS) return null;
    for (0..MAX_TOKENS) |i| {
        if (!tokens[i].active) {
            const kl = @min(key.len, MAX_KEY);
            @memcpy(tokens[i].key[0..kl], key[0..kl]);
            tokens[i].key_len = kl;
            tokens[i].lang_count = 0;
            tokens[i].active = true;
            token_count += 1;
            return i;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_pg_register(token: [*]const u8, tok_len: usize, lang: [*]const u8, lang_len: usize, translation: [*]const u8, trans_len: usize) i32 {
    const ti = findOrCreateToken(token[0..tok_len]) orelse return -1;
    // check if lang already exists, update if so
    for (0..tokens[ti].lang_count) |j| {
        if (tokens[ti].translations[j].lang_len == lang_len and
            std.mem.eql(u8, tokens[ti].translations[j].lang[0..tokens[ti].translations[j].lang_len], lang[0..lang_len]))
        {
            const tl = @min(trans_len, MAX_TRANS);
            @memcpy(tokens[ti].translations[j].text[0..tl], translation[0..tl]);
            tokens[ti].translations[j].text_len = tl;
            return 0;
        }
    }
    if (tokens[ti].lang_count >= MAX_LANGS_PER_TOKEN) return -1;
    const slot = tokens[ti].lang_count;
    const ll = @min(lang_len, MAX_KEY);
    @memcpy(tokens[ti].translations[slot].lang[0..ll], lang[0..ll]);
    tokens[ti].translations[slot].lang_len = ll;
    const tl = @min(trans_len, MAX_TRANS);
    @memcpy(tokens[ti].translations[slot].text[0..tl], translation[0..tl]);
    tokens[ti].translations[slot].text_len = tl;
    tokens[ti].lang_count += 1;
    return 0;
}

pub export fn stz_pg_translate(token: [*]const u8, tok_len: usize, lang: [*]const u8, lang_len: usize, out: [*]u8) i32 {
    const ti = findToken(token[0..tok_len]) orelse return 0;
    for (0..tokens[ti].lang_count) |j| {
        if (tokens[ti].translations[j].lang_len == lang_len and
            std.mem.eql(u8, tokens[ti].translations[j].lang[0..tokens[ti].translations[j].lang_len], lang[0..lang_len]))
        {
            const len = tokens[ti].translations[j].text_len;
            @memcpy(out[0..len], tokens[ti].translations[j].text[0..len]);
            return @intCast(len);
        }
    }
    return 0;
}

pub export fn stz_pg_has_token(token: [*]const u8, tok_len: usize) i32 {
    if (findToken(token[0..tok_len])) |_| return 1;
    return 0;
}

pub export fn stz_pg_lang_count(token: [*]const u8, tok_len: usize) i32 {
    const ti = findToken(token[0..tok_len]) orelse return 0;
    return @intCast(tokens[ti].lang_count);
}

pub export fn stz_pg_token_count() i32 {
    return @intCast(token_count);
}

pub export fn stz_pg_clear() void {
    for (0..MAX_TOKENS) |i| {
        tokens[i].active = false;
        tokens[i].lang_count = 0;
    }
    token_count = 0;
}

// ─── Tests ───

test "register and translate" {
    stz_pg_clear();
    _ = stz_pg_register("hello", 5, "fr", 2, "bonjour", 7);
    var buf: [256]u8 = undefined;
    const len = stz_pg_translate("hello", 5, "fr", 2, &buf);
    try std.testing.expectEqual(@as(i32, 7), len);
    try std.testing.expectEqualSlices(u8, "bonjour", buf[0..@intCast(len)]);
    stz_pg_clear();
}

test "multiple languages" {
    stz_pg_clear();
    _ = stz_pg_register("hello", 5, "fr", 2, "bonjour", 7);
    _ = stz_pg_register("hello", 5, "es", 2, "hola", 4);
    try std.testing.expectEqual(@as(i32, 2), stz_pg_lang_count("hello", 5));
    stz_pg_clear();
}

test "has token" {
    stz_pg_clear();
    _ = stz_pg_register("world", 5, "en", 2, "world", 5);
    try std.testing.expectEqual(@as(i32, 1), stz_pg_has_token("world", 5));
    try std.testing.expectEqual(@as(i32, 0), stz_pg_has_token("xyz", 3));
    stz_pg_clear();
}

test "token count" {
    stz_pg_clear();
    _ = stz_pg_register("a", 1, "en", 2, "a", 1);
    _ = stz_pg_register("b", 1, "en", 2, "b", 1);
    try std.testing.expectEqual(@as(i32, 2), stz_pg_token_count());
    stz_pg_clear();
}

test "translate missing returns 0" {
    stz_pg_clear();
    var buf: [256]u8 = undefined;
    const len = stz_pg_translate("none", 4, "en", 2, &buf);
    try std.testing.expectEqual(@as(i32, 0), len);
}
