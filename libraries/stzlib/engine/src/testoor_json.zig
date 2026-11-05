//! Testoor core -- a JSON reader that tolerates what the Ring writer produces.
//!
//! Ring's `_TourJsonStr` escapes five bytes and writes every other byte raw, so a tour whose
//! output holds an ESC or a byte that is not UTF-8 gives a document `std.json` refuses.
//! The core must read its own requests, so this reader accepts any byte inside a string,
//! decodes the standard escapes (including \uXXXX and surrogate pairs) and keeps objects in
//! the order they were written. It reads; it does not validate.

const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Pair = struct { key: []const u8, val: Value };

pub const Value = union(enum) {
    null,
    bool: bool,
    num: f64,
    str: []const u8,
    arr: []Value,
    obj: []Pair,

    pub fn get(self: Value, key: []const u8) ?Value {
        switch (self) {
            .obj => |pairs| {
                for (pairs) |p| if (std.mem.eql(u8, p.key, key)) return p.val;
                return null;
            },
            else => return null,
        }
    }
    pub fn str_(self: Value) []const u8 {
        return switch (self) {
            .str => |s| s,
            else => "",
        };
    }
    pub fn int_(self: Value) i64 {
        return switch (self) {
            .num => |n| if (std.math.isFinite(n) and @abs(n) < 9.0e18) @as(i64, @intFromFloat(n)) else 0,
            .bool => |b| if (b) 1 else 0,
            else => 0,
        };
    }
    pub fn num_(self: Value) f64 {
        return switch (self) {
            .num => |n| n,
            .bool => |b| if (b) 1 else 0,
            else => 0,
        };
    }
    pub fn truthy(self: Value) bool {
        return switch (self) {
            .num => |n| n != 0,
            .bool => |b| b,
            else => false,
        };
    }
    pub fn items(self: Value) []Value {
        return switch (self) {
            .arr => |x| x,
            else => &[_]Value{},
        };
    }
};

pub const Error = error{ BadJson, OutOfMemory };

const P = struct {
    a: Allocator,
    s: []const u8,
    i: usize = 0,

    fn ws(self: *P) void {
        while (self.i < self.s.len) : (self.i += 1) {
            switch (self.s[self.i]) {
                ' ', '\t', '\n', '\r' => {},
                else => return,
            }
        }
    }

    fn value(self: *P) Error!Value {
        self.ws();
        if (self.i >= self.s.len) return Error.BadJson;
        switch (self.s[self.i]) {
            '{' => return self.object(),
            '[' => return self.array(),
            '"' => return Value{ .str = try self.string() },
            't' => return self.word("true", .{ .bool = true }),
            'f' => return self.word("false", .{ .bool = false }),
            'n' => return self.word("null", .null),
            else => return self.number(),
        }
    }

    fn word(self: *P, w: []const u8, v: Value) Error!Value {
        if (self.i + w.len > self.s.len or !std.mem.eql(u8, self.s[self.i .. self.i + w.len], w)) return Error.BadJson;
        self.i += w.len;
        return v;
    }

    fn number(self: *P) Error!Value {
        const start = self.i;
        while (self.i < self.s.len) : (self.i += 1) {
            switch (self.s[self.i]) {
                '0'...'9', '-', '+', '.', 'e', 'E' => {},
                else => break,
            }
        }
        if (self.i == start) return Error.BadJson;
        const n = std.fmt.parseFloat(f64, self.s[start..self.i]) catch return Error.BadJson;
        return Value{ .num = n };
    }

    fn hex4(self: *P) Error!u21 {
        if (self.i + 4 > self.s.len) return Error.BadJson;
        const n = std.fmt.parseInt(u21, self.s[self.i .. self.i + 4], 16) catch return Error.BadJson;
        self.i += 4;
        return n;
    }

    fn string(self: *P) Error![]const u8 {
        self.i += 1; // the opening quote
        var out: std.ArrayList(u8) = .empty;
        while (true) {
            if (self.i >= self.s.len) return Error.BadJson;
            const ch = self.s[self.i];
            self.i += 1;
            if (ch == '"') break;
            if (ch != '\\') {
                try out.append(self.a, ch);
                continue;
            }
            if (self.i >= self.s.len) return Error.BadJson;
            const e = self.s[self.i];
            self.i += 1;
            switch (e) {
                'n' => try out.append(self.a, '\n'),
                't' => try out.append(self.a, '\t'),
                'r' => try out.append(self.a, '\r'),
                'b' => try out.append(self.a, 8),
                'f' => try out.append(self.a, 12),
                '/' => try out.append(self.a, '/'),
                '\\' => try out.append(self.a, '\\'),
                '"' => try out.append(self.a, '"'),
                'u' => {
                    var cp = try self.hex4();
                    if (cp >= 0xD800 and cp <= 0xDBFF and self.i + 1 < self.s.len and self.s[self.i] == '\\' and self.s[self.i + 1] == 'u') {
                        self.i += 2;
                        const lo = try self.hex4();
                        if (lo >= 0xDC00 and lo <= 0xDFFF) cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
                    }
                    var tmp: [4]u8 = undefined;
                    const n = std.unicode.utf8Encode(cp, &tmp) catch blk: {
                        // a lone surrogate: keep its three bytes, as a tolerant reader should
                        tmp[0] = 0xE0 | @as(u8, @intCast(cp >> 12));
                        tmp[1] = 0x80 | @as(u8, @intCast((cp >> 6) & 0x3F));
                        tmp[2] = 0x80 | @as(u8, @intCast(cp & 0x3F));
                        break :blk @as(u3, 3);
                    };
                    try out.appendSlice(self.a, tmp[0..n]);
                },
                else => try out.append(self.a, e),
            }
        }
        return out.toOwnedSlice(self.a);
    }

    fn array(self: *P) Error!Value {
        self.i += 1;
        var out: std.ArrayList(Value) = .empty;
        self.ws();
        if (self.i < self.s.len and self.s[self.i] == ']') {
            self.i += 1;
            return Value{ .arr = try out.toOwnedSlice(self.a) };
        }
        while (true) {
            try out.append(self.a, try self.value());
            self.ws();
            if (self.i >= self.s.len) return Error.BadJson;
            const ch = self.s[self.i];
            self.i += 1;
            if (ch == ',') continue;
            if (ch == ']') break;
            return Error.BadJson;
        }
        return Value{ .arr = try out.toOwnedSlice(self.a) };
    }

    fn object(self: *P) Error!Value {
        self.i += 1;
        var out: std.ArrayList(Pair) = .empty;
        self.ws();
        if (self.i < self.s.len and self.s[self.i] == '}') {
            self.i += 1;
            return Value{ .obj = try out.toOwnedSlice(self.a) };
        }
        while (true) {
            self.ws();
            if (self.i >= self.s.len or self.s[self.i] != '"') return Error.BadJson;
            const k = try self.string();
            self.ws();
            if (self.i >= self.s.len or self.s[self.i] != ':') return Error.BadJson;
            self.i += 1;
            const v = try self.value();
            try out.append(self.a, .{ .key = k, .val = v });
            self.ws();
            if (self.i >= self.s.len) return Error.BadJson;
            const ch = self.s[self.i];
            self.i += 1;
            if (ch == ',') continue;
            if (ch == '}') break;
            return Error.BadJson;
        }
        return Value{ .obj = try out.toOwnedSlice(self.a) };
    }
};

pub fn parse(a: Allocator, text: []const u8) Error!Value {
    var p = P{ .a = a, .s = text };
    const v = try p.value();
    p.ws();
    if (p.i != text.len) return Error.BadJson;
    return v;
}

const testing = std.testing;

test "the reader accepts raw control bytes and keeps key order" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const v = try parse(arena.allocator(), "{\"b\":\"x\x01y\xff\",\"a\":[1,-2,null,true],\"c\":{}}");
    try testing.expectEqualStrings("b", v.obj[0].key);
    try testing.expectEqualStrings("x\x01y\xff", v.get("b").?.str_());
    try testing.expectEqual(@as(i64, -2), v.get("a").?.items()[1].int_());
    try testing.expect(v.get("a").?.items()[3].truthy());
}

test "escapes decode, including a surrogate pair" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const v = try parse(arena.allocator(), "\"a\\n\\u00e9\\ud83d\\ude00\\\"\"");
    try testing.expectEqualStrings("a\n\xc3\xa9\xf0\x9f\x98\x80\"", v.str_());
}

test "a malformed document is refused" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    try testing.expectError(Error.BadJson, parse(arena.allocator(), "{\"a\":"));
    try testing.expectError(Error.BadJson, parse(arena.allocator(), "[1,2"));
    try testing.expectError(Error.BadJson, parse(arena.allocator(), "{} x"));
}
