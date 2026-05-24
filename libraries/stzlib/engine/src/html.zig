const std = @import("std");

// ── HTML Entity Encoding ─────────────────────────────────────

pub fn html_encode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    for (data) |ch| {
        const replacement: ?[]const u8 = switch (ch) {
            '&' => "&amp;",
            '<' => "&lt;",
            '>' => "&gt;",
            '"' => "&quot;",
            '\'' => "&#39;",
            else => null,
        };
        if (replacement) |rep| {
            if (pos + rep.len > max) return -1;
            @memcpy(out[pos .. pos + rep.len], rep);
            pos += rep.len;
        } else {
            if (pos >= max) return -1;
            out[pos] = ch;
            pos += 1;
        }
    }
    return @intCast(pos);
}

pub fn html_decode(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    var i: usize = 0;
    while (i < data.len) {
        if (pos >= max) return -1;
        if (data[i] == '&') {
            if (matchEntity(data[i..], "&amp;")) |_| {
                out[pos] = '&';
                pos += 1;
                i += 5;
            } else if (matchEntity(data[i..], "&lt;")) |_| {
                out[pos] = '<';
                pos += 1;
                i += 4;
            } else if (matchEntity(data[i..], "&gt;")) |_| {
                out[pos] = '>';
                pos += 1;
                i += 4;
            } else if (matchEntity(data[i..], "&quot;")) |_| {
                out[pos] = '"';
                pos += 1;
                i += 6;
            } else if (matchEntity(data[i..], "&#39;")) |_| {
                out[pos] = '\'';
                pos += 1;
                i += 5;
            } else if (matchEntity(data[i..], "&apos;")) |_| {
                out[pos] = '\'';
                pos += 1;
                i += 6;
            } else if (matchEntity(data[i..], "&nbsp;")) |_| {
                out[pos] = ' ';
                pos += 1;
                i += 6;
            } else if (matchNumericEntity(data[i..])) |result| {
                const cp = result.codepoint;
                const entity_len = result.len;
                const utf8_len = std.unicode.utf8Encode(cp, out[pos..@min(pos + 4, max)]) catch {
                    out[pos] = '?';
                    pos += 1;
                    i += entity_len;
                    continue;
                };
                pos += utf8_len;
                i += entity_len;
            } else {
                out[pos] = data[i];
                pos += 1;
                i += 1;
            }
        } else {
            out[pos] = data[i];
            pos += 1;
            i += 1;
        }
    }
    return @intCast(pos);
}

fn matchEntity(data: []const u8, entity: []const u8) ?void {
    if (data.len < entity.len) return null;
    if (std.mem.eql(u8, data[0..entity.len], entity)) return {};
    return null;
}

const NumericResult = struct { codepoint: u21, len: usize };

fn matchNumericEntity(data: []const u8) ?NumericResult {
    if (data.len < 4) return null;
    if (data[0] != '&' or data[1] != '#') return null;

    var i: usize = 2;
    var is_hex = false;
    if (i < data.len and (data[i] == 'x' or data[i] == 'X')) {
        is_hex = true;
        i += 1;
    }

    const start = i;
    var val: u32 = 0;
    while (i < data.len and data[i] != ';') : (i += 1) {
        if (is_hex) {
            const d = hexDigit(data[i]) orelse return null;
            val = val *% 16 +% d;
        } else {
            if (data[i] < '0' or data[i] > '9') return null;
            val = val *% 10 +% (data[i] - '0');
        }
        if (val > 0x10FFFF) return null;
    }
    if (i >= data.len or data[i] != ';') return null;
    if (i == start) return null;

    const cp = std.math.cast(u21, val) orelse return null;
    return NumericResult{ .codepoint = cp, .len = i + 1 };
}

fn hexDigit(ch: u8) ?u32 {
    if (ch >= '0' and ch <= '9') return ch - '0';
    if (ch >= 'a' and ch <= 'f') return ch - 'a' + 10;
    if (ch >= 'A' and ch <= 'F') return ch - 'A' + 10;
    return null;
}

// ── HTML Tag Stripping ───────────────────────────────────────

pub fn html_strip_tags(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    var in_tag = false;
    for (data) |ch| {
        if (ch == '<') {
            in_tag = true;
        } else if (ch == '>') {
            in_tag = false;
        } else if (!in_tag) {
            if (pos >= max) return -1;
            out[pos] = ch;
            pos += 1;
        }
    }
    return @intCast(pos);
}

// ── Attribute Value Encoding ─────────────────────────────────

pub fn html_encode_attribute(ptr: [*]const u8, len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    if (len == 0) return 0;
    const data = ptr[0..len];
    var pos: usize = 0;
    for (data) |ch| {
        const replacement: ?[]const u8 = switch (ch) {
            '&' => "&amp;",
            '"' => "&quot;",
            '\'' => "&#39;",
            '<' => "&lt;",
            '>' => "&gt;",
            else => null,
        };
        if (replacement) |rep| {
            if (pos + rep.len > max) return -1;
            @memcpy(out[pos .. pos + rep.len], rep);
            pos += rep.len;
        } else {
            if (pos >= max) return -1;
            out[pos] = ch;
            pos += 1;
        }
    }
    return @intCast(pos);
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_html_encode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return html_encode(p, l, o, m); }
pub export fn stz_html_decode(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return html_decode(p, l, o, m); }
pub export fn stz_html_strip_tags(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return html_strip_tags(p, l, o, m); }
pub export fn stz_html_encode_attribute(p: [*]const u8, l: usize, o: [*]u8, m: usize) callconv(.c) i32 { return html_encode_attribute(p, l, o, m); }

// ── Tests ────────────────────────────────────────────────────

test "html: encode basic entities" {
    var buf: [256]u8 = undefined;
    const text = "<div class=\"main\">&hello</div>";
    const len = html_encode(text.ptr, text.len, &buf, 256);
    try std.testing.expect(len > 0);
    const result = buf[0..@intCast(len)];
    try std.testing.expectEqualStrings("&lt;div class=&quot;main&quot;&gt;&amp;hello&lt;/div&gt;", result);
}

test "html: encode roundtrip" {
    var enc: [256]u8 = undefined;
    var dec: [256]u8 = undefined;
    const text = "Hello <World> & \"Friends\"";
    const enc_len = html_encode(text.ptr, text.len, &enc, 256);
    const dec_len = html_decode(&enc, @intCast(enc_len), &dec, 256);
    try std.testing.expectEqualStrings(text, dec[0..@intCast(dec_len)]);
}

test "html: decode numeric entities" {
    var buf: [256]u8 = undefined;
    const text = "&#65;&#x42;&#x43;";
    const len = html_decode(text.ptr, text.len, &buf, 256);
    try std.testing.expectEqualStrings("ABC", buf[0..@intCast(len)]);
}

test "html: decode unicode numeric entity" {
    var buf: [256]u8 = undefined;
    const text = "&#x263A;";
    const len = html_decode(text.ptr, text.len, &buf, 256);
    try std.testing.expect(len > 0);
    const result = buf[0..@intCast(len)];
    try std.testing.expectEqualStrings("\u{263A}", result);
}

test "html: strip tags" {
    var buf: [256]u8 = undefined;
    const text = "<p>Hello <b>World</b></p>";
    const len = html_strip_tags(text.ptr, text.len, &buf, 256);
    try std.testing.expectEqualStrings("Hello World", buf[0..@intCast(len)]);
}

test "html: strip tags preserves text" {
    var buf: [256]u8 = undefined;
    const text = "No tags here";
    const len = html_strip_tags(text.ptr, text.len, &buf, 256);
    try std.testing.expectEqualStrings("No tags here", buf[0..@intCast(len)]);
}

test "html: encode attribute" {
    var buf: [256]u8 = undefined;
    const text = "value with \"quotes\" & <angle>";
    const len = html_encode_attribute(text.ptr, text.len, &buf, 256);
    const result = buf[0..@intCast(len)];
    try std.testing.expectEqualStrings("value with &quot;quotes&quot; &amp; &lt;angle&gt;", result);
}

test "html: empty input" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 0), html_encode("".ptr, 0, &buf, 64));
    try std.testing.expectEqual(@as(i32, 0), html_decode("".ptr, 0, &buf, 64));
    try std.testing.expectEqual(@as(i32, 0), html_strip_tags("".ptr, 0, &buf, 64));
}
