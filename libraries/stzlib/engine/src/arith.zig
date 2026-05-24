const std = @import("std");

// ── Arithmetic Expression Evaluator ────────────────────────
// Supports: +, -, *, /, %, parentheses, decimals, unary minus
// No variables, no functions -- pure numeric expressions.

const MAX_EXPR = 1024;

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn isSpace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

const Parser = struct {
    src: []const u8,
    pos: usize = 0,

    fn peek(self: *Parser) ?u8 {
        self.skipSpaces();
        if (self.pos >= self.src.len) return null;
        return self.src[self.pos];
    }

    fn advance(self: *Parser) void {
        self.pos += 1;
    }

    fn skipSpaces(self: *Parser) void {
        while (self.pos < self.src.len and isSpace(self.src[self.pos])) {
            self.pos += 1;
        }
    }

    fn parseNumber(self: *Parser) ?f64 {
        self.skipSpaces();
        const start = self.pos;
        var has_dot = false;
        while (self.pos < self.src.len) {
            const c = self.src[self.pos];
            if (isDigit(c)) {
                self.pos += 1;
            } else if (c == '.' and !has_dot) {
                has_dot = true;
                self.pos += 1;
            } else break;
        }
        if (self.pos == start) return null;
        return std.fmt.parseFloat(f64, self.src[start..self.pos]) catch null;
    }

    fn parseAtom(self: *Parser) ?f64 {
        const c = self.peek() orelse return null;
        if (c == '(') {
            self.advance();
            const val = self.parseExpr() orelse return null;
            if ((self.peek() orelse 0) != ')') return null;
            self.advance();
            return val;
        }
        if (c == '-') {
            self.advance();
            const val = self.parseAtom() orelse return null;
            return -val;
        }
        if (c == '+') {
            self.advance();
            return self.parseAtom();
        }
        return self.parseNumber();
    }

    fn parseFactor(self: *Parser) ?f64 {
        var left = self.parseAtom() orelse return null;
        while (true) {
            const op = self.peek() orelse break;
            if (op == '*') {
                self.advance();
                const right = self.parseAtom() orelse return null;
                left *= right;
            } else if (op == '/') {
                self.advance();
                const right = self.parseAtom() orelse return null;
                if (right == 0) return null;
                left /= right;
            } else if (op == '%') {
                self.advance();
                const right = self.parseAtom() orelse return null;
                if (right == 0) return null;
                left = @mod(left, right);
            } else break;
        }
        return left;
    }

    fn parseExpr(self: *Parser) ?f64 {
        var left = self.parseFactor() orelse return null;
        while (true) {
            const op = self.peek() orelse break;
            if (op == '+') {
                self.advance();
                const right = self.parseFactor() orelse return null;
                left += right;
            } else if (op == '-') {
                self.advance();
                const right = self.parseFactor() orelse return null;
                left -= right;
            } else break;
        }
        return left;
    }
};

pub fn arith_eval(src_ptr: [*]const u8, src_len: usize, result: *f64) callconv(.c) i32 {
    if (src_len == 0 or src_len > MAX_EXPR) return -1;
    var parser = Parser{ .src = src_ptr[0..src_len] };
    const val = parser.parseExpr() orelse return -2;
    parser.skipSpaces();
    if (parser.pos != src_len) return -3;
    result.* = val;
    return 0;
}

pub fn arith_eval_default(src_ptr: [*]const u8, src_len: usize, default: f64) callconv(.c) f64 {
    var result: f64 = undefined;
    if (arith_eval(src_ptr, src_len, &result) == 0) return result;
    return default;
}

// ── C ABI exports ────────────────────────────────────────────

pub export fn stz_arith_eval(p: [*]const u8, l: usize, r: *f64) callconv(.c) i32 { return arith_eval(p, l, r); }
pub export fn stz_arith_eval_default(p: [*]const u8, l: usize, d: f64) callconv(.c) f64 { return arith_eval_default(p, l, d); }

// ── Tests ────────────────────────────────────────────────────

test "arith: simple add" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("2+3".ptr, 3, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 5.0), result, 0.001);
}

test "arith: precedence" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("2+3*4".ptr, 5, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 14.0), result, 0.001);
}

test "arith: parentheses" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("(2+3)*4".ptr, 7, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 20.0), result, 0.001);
}

test "arith: decimals" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("3.14*2".ptr, 6, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 6.28), result, 0.01);
}

test "arith: unary minus" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("-5+3".ptr, 4, &result));
    try std.testing.expectApproxEqAbs(@as(f64, -2.0), result, 0.001);
}

test "arith: division" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("10/4".ptr, 4, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 2.5), result, 0.001);
}

test "arith: modulo" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval("10%3".ptr, 4, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 1.0), result, 0.001);
}

test "arith: div by zero" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, -2), arith_eval("5/0".ptr, 3, &result));
}

test "arith: default on error" {
    const val = arith_eval_default("bad".ptr, 3, 42.0);
    try std.testing.expectApproxEqAbs(@as(f64, 42.0), val, 0.001);
}

test "arith: spaces" {
    var result: f64 = undefined;
    try std.testing.expectEqual(@as(i32, 0), arith_eval(" 1 + 2 ".ptr, 7, &result));
    try std.testing.expectApproxEqAbs(@as(f64, 3.0), result, 0.001);
}
