// Softanza Engine -- Expression compiler and evaluator
//
// Compiles expression strings like "@item > 3 and isString(@item)"
// into bytecode and evaluates them natively over list items.
// Replaces Ring's eval() for Map, Filter, Reduce, FindW, and all
// ...W() functions.
//
// Expression language:
//   Literals:    42, 3.14, "hello", true, false
//   Variables:   @item, @i, @accumulator, @numberofitems
//   Arithmetic:  +, -, *, /, %
//   Comparison:  =, !=, <, >, <=, >=
//   Logical:     and, or, not
//   Functions:   isstring(), isnumber(), islist(), len(), lower(),
//                upper(), abs(), type()
//   Grouping:    ( )
//
// C ABI: stz_expr_* prefix.

const std = @import("std");
const alloc = std.heap.page_allocator;

// ─── Evaluation value ───

pub const Val = struct {
    tag: Tag,
    data: Data,

    pub const Tag = enum(u8) { null_v, bool_v, int_v, float_v, str_v };
    const Data = union { b: bool, i: i64, f: f64, s: Slice };
    const Slice = struct { ptr: [*]const u8, len: usize };

    pub fn initNull() Val {
        return .{ .tag = .null_v, .data = .{ .i = 0 } };
    }
    pub fn initBool(b: bool) Val {
        return .{ .tag = .bool_v, .data = .{ .b = b } };
    }
    pub fn initInt(i: i64) Val {
        return .{ .tag = .int_v, .data = .{ .i = i } };
    }
    pub fn initFloat(f: f64) Val {
        return .{ .tag = .float_v, .data = .{ .f = f } };
    }
    pub fn initStr(ptr: [*]const u8, len: usize) Val {
        return .{ .tag = .str_v, .data = .{ .s = .{ .ptr = ptr, .len = len } } };
    }

    pub fn isTruthy(self: Val) bool {
        return switch (self.tag) {
            .null_v => false,
            .bool_v => self.data.b,
            .int_v => self.data.i != 0,
            .float_v => self.data.f != 0.0,
            .str_v => self.data.s.len > 0,
        };
    }

    pub fn asFloat(self: Val) f64 {
        return switch (self.tag) {
            .int_v => @floatFromInt(self.data.i),
            .float_v => self.data.f,
            .bool_v => if (self.data.b) @as(f64, 1.0) else @as(f64, 0.0),
            else => 0.0,
        };
    }

    pub fn asInt(self: Val) i64 {
        return switch (self.tag) {
            .int_v => self.data.i,
            .float_v => @intFromFloat(self.data.f),
            .bool_v => if (self.data.b) @as(i64, 1) else @as(i64, 0),
            else => 0,
        };
    }
};

// ─── Bytecode instructions ───

pub const Op = enum(u8) {
    push_int,
    push_float,
    push_str,
    push_true,
    push_false,
    push_null,
    load_item,
    load_index,
    load_accum,
    load_count,
    load_char,
    add,
    sub,
    mul,
    div,
    mod,
    neg,
    eq,
    neq,
    lt,
    gt,
    lte,
    gte,
    land,
    lor,
    lnot,
    fn_is_string,
    fn_is_number,
    fn_is_list,
    fn_is_bool,
    fn_is_null,
    fn_len,
    fn_lower,
    fn_upper,
    fn_abs,
    fn_type,
    fn_sqrt,
    fn_floor,
    fn_ceil,
    fn_round,
    fn_trim,
    fn_reversed,
    fn_number,
    fn_string,
    fn_min,
    fn_max,
    fn_contains,
    fn_startswith,
    fn_endswith,
    fn_left,
    fn_right,
    fn_substr,
    fn_if,
    fn_replace,
    fn_repeat,
    fn_indexof,
};

pub const Inst = struct {
    op: Op,
    int_val: i64 = 0,
    float_val: f64 = 0,
    str_start: u32 = 0,
    str_len: u32 = 0,
};

// ─── Compiled program ───

pub const Program = struct {
    code: []Inst,
    source: []u8,

    pub fn deinit(self: *Program) void {
        alloc.free(self.code);
        alloc.free(self.source);
        alloc.destroy(self);
    }
};

// ─── Tokenizer ───

const TTag = enum(u8) {
    int_lit,
    float_lit,
    string_lit,
    kw_true,
    kw_false,
    kw_and,
    kw_or,
    kw_not,
    var_item,
    var_index,
    var_accum,
    var_count,
    var_char,
    fn_is_string,
    fn_is_number,
    fn_is_list,
    fn_is_bool,
    fn_is_null,
    fn_len,
    fn_lower,
    fn_upper,
    fn_abs,
    fn_type,
    fn_sqrt,
    fn_floor,
    fn_ceil,
    fn_round,
    fn_trim,
    fn_reversed,
    fn_number,
    fn_string,
    fn_min,
    fn_max,
    fn_contains,
    fn_startswith,
    fn_endswith,
    fn_left,
    fn_right,
    fn_substr,
    fn_if,
    fn_replace,
    fn_repeat,
    fn_indexof,
    plus,
    minus,
    star,
    slash,
    percent,
    eq,
    neq,
    lt,
    gt,
    lte,
    gte,
    lparen,
    rparen,
    comma,
    eof,
    err,
};

const Token = struct {
    tag: TTag,
    start: u32,
    len: u32,
    int_val: i64 = 0,
    float_val: f64 = 0,
};

fn isAlpha(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_';
}

fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

fn toLower(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
}

fn tokenize(src: []const u8, pos: *usize) Token {
    while (pos.* < src.len and (src[pos.*] == ' ' or src[pos.*] == '\t' or src[pos.*] == '\n' or src[pos.*] == '\r')) : (pos.* += 1) {}

    if (pos.* >= src.len) return .{ .tag = .eof, .start = @intCast(pos.*), .len = 0 };

    const start: u32 = @intCast(pos.*);
    const c = src[pos.*];

    // Operators and delimiters
    switch (c) {
        '+' => {
            pos.* += 1;
            return .{ .tag = .plus, .start = start, .len = 1 };
        },
        '*' => {
            pos.* += 1;
            return .{ .tag = .star, .start = start, .len = 1 };
        },
        '/' => {
            pos.* += 1;
            return .{ .tag = .slash, .start = start, .len = 1 };
        },
        '%' => {
            pos.* += 1;
            return .{ .tag = .percent, .start = start, .len = 1 };
        },
        '(' => {
            pos.* += 1;
            return .{ .tag = .lparen, .start = start, .len = 1 };
        },
        ')' => {
            pos.* += 1;
            return .{ .tag = .rparen, .start = start, .len = 1 };
        },
        ',' => {
            pos.* += 1;
            return .{ .tag = .comma, .start = start, .len = 1 };
        },
        '!' => {
            pos.* += 1;
            if (pos.* < src.len and src[pos.*] == '=') {
                pos.* += 1;
                return .{ .tag = .neq, .start = start, .len = 2 };
            }
            return .{ .tag = .err, .start = start, .len = 1 };
        },
        '<' => {
            pos.* += 1;
            if (pos.* < src.len and src[pos.*] == '=') {
                pos.* += 1;
                return .{ .tag = .lte, .start = start, .len = 2 };
            }
            if (pos.* < src.len and src[pos.*] == '>') {
                pos.* += 1;
                return .{ .tag = .neq, .start = start, .len = 2 };
            }
            return .{ .tag = .lt, .start = start, .len = 1 };
        },
        '>' => {
            pos.* += 1;
            if (pos.* < src.len and src[pos.*] == '=') {
                pos.* += 1;
                return .{ .tag = .gte, .start = start, .len = 2 };
            }
            return .{ .tag = .gt, .start = start, .len = 1 };
        },
        '=' => {
            pos.* += 1;
            if (pos.* < src.len and src[pos.*] == '=') {
                pos.* += 1;
            }
            return .{ .tag = .eq, .start = start, .len = @intCast(pos.* - start) };
        },
        '-' => {
            pos.* += 1;
            return .{ .tag = .minus, .start = start, .len = 1 };
        },
        else => {},
    }

    // String literals
    if (c == '"' or c == '\'') {
        const quote = c;
        pos.* += 1;
        const s_start = pos.*;
        while (pos.* < src.len and src[pos.*] != quote) : (pos.* += 1) {}
        const s_end = pos.*;
        if (pos.* < src.len) pos.* += 1;
        return .{ .tag = .string_lit, .start = @intCast(s_start), .len = @intCast(s_end - s_start) };
    }

    // Numbers
    if (isDigit(c)) {
        var is_float = false;
        while (pos.* < src.len and isDigit(src[pos.*])) : (pos.* += 1) {}
        if (pos.* < src.len and src[pos.*] == '.') {
            is_float = true;
            pos.* += 1;
            while (pos.* < src.len and isDigit(src[pos.*])) : (pos.* += 1) {}
        }
        const num_str = src[start..pos.*];
        if (is_float) {
            const fv = std.fmt.parseFloat(f64, num_str) catch 0.0;
            return .{ .tag = .float_lit, .start = start, .len = @intCast(pos.* - start), .float_val = fv };
        } else {
            const iv = std.fmt.parseInt(i64, num_str, 10) catch 0;
            return .{ .tag = .int_lit, .start = start, .len = @intCast(pos.* - start), .int_val = iv };
        }
    }

    // Identifiers, variables, keywords
    if (c == '@' or isAlpha(c)) {
        while (pos.* < src.len and (isAlpha(src[pos.*]) or isDigit(src[pos.*]) or src[pos.*] == '@')) : (pos.* += 1) {}
        const word = src[start..pos.*];
        const tag = classifyWord(word);
        return .{ .tag = tag, .start = start, .len = @intCast(pos.* - start) };
    }

    pos.* += 1;
    return .{ .tag = .err, .start = start, .len = 1 };
}

fn classifyWord(word: []const u8) TTag {
    var buf: [32]u8 = undefined;
    const wlen = @min(word.len, buf.len);
    for (0..wlen) |i| buf[i] = toLower(word[i]);
    const w = buf[0..wlen];

    if (std.mem.eql(u8, w, "@item")) return .var_item;
    if (std.mem.eql(u8, w, "@i")) return .var_index;
    if (std.mem.eql(u8, w, "@accumulator")) return .var_accum;
    if (std.mem.eql(u8, w, "@value")) return .var_accum;
    if (std.mem.eql(u8, w, "@numberofitems")) return .var_count;
    if (std.mem.eql(u8, w, "@char")) return .var_char;
    if (std.mem.eql(u8, w, "true")) return .kw_true;
    if (std.mem.eql(u8, w, "false")) return .kw_false;
    if (std.mem.eql(u8, w, "and")) return .kw_and;
    if (std.mem.eql(u8, w, "or")) return .kw_or;
    if (std.mem.eql(u8, w, "not")) return .kw_not;
    if (std.mem.eql(u8, w, "isstring")) return .fn_is_string;
    if (std.mem.eql(u8, w, "isnumber")) return .fn_is_number;
    if (std.mem.eql(u8, w, "islist")) return .fn_is_list;
    if (std.mem.eql(u8, w, "isbool")) return .fn_is_bool;
    if (std.mem.eql(u8, w, "isnull")) return .fn_is_null;
    if (std.mem.eql(u8, w, "len")) return .fn_len;
    if (std.mem.eql(u8, w, "lower")) return .fn_lower;
    if (std.mem.eql(u8, w, "upper")) return .fn_upper;
    if (std.mem.eql(u8, w, "abs")) return .fn_abs;
    if (std.mem.eql(u8, w, "type")) return .fn_type;
    if (std.mem.eql(u8, w, "sqrt")) return .fn_sqrt;
    if (std.mem.eql(u8, w, "floor")) return .fn_floor;
    if (std.mem.eql(u8, w, "ceil")) return .fn_ceil;
    if (std.mem.eql(u8, w, "round")) return .fn_round;
    if (std.mem.eql(u8, w, "trim")) return .fn_trim;
    if (std.mem.eql(u8, w, "reversed")) return .fn_reversed;
    if (std.mem.eql(u8, w, "number")) return .fn_number;
    if (std.mem.eql(u8, w, "string")) return .fn_string;
    if (std.mem.eql(u8, w, "min")) return .fn_min;
    if (std.mem.eql(u8, w, "max")) return .fn_max;
    if (std.mem.eql(u8, w, "contains")) return .fn_contains;
    if (std.mem.eql(u8, w, "startswith")) return .fn_startswith;
    if (std.mem.eql(u8, w, "endswith")) return .fn_endswith;
    if (std.mem.eql(u8, w, "left")) return .fn_left;
    if (std.mem.eql(u8, w, "right")) return .fn_right;
    if (std.mem.eql(u8, w, "substr")) return .fn_substr;
    if (std.mem.eql(u8, w, "if")) return .fn_if;
    if (std.mem.eql(u8, w, "replace")) return .fn_replace;
    if (std.mem.eql(u8, w, "repeat")) return .fn_repeat;
    if (std.mem.eql(u8, w, "indexof")) return .fn_indexof;
    return .err;
}

// ─── Compiler (recursive descent -> bytecode) ───

const Compiler = struct {
    src: []const u8,
    pos: usize,
    cur: Token,
    code: std.ArrayList(Inst),
    had_error: bool,

    fn init(src: []const u8) Compiler {
        var c = Compiler{
            .src = src,
            .pos = 0,
            .cur = undefined,
            .code = .{},
            .had_error = false,
        };
        c.advance();
        return c;
    }

    fn advance(self: *Compiler) void {
        self.cur = tokenize(self.src, &self.pos);
    }

    fn emit(self: *Compiler, inst: Inst) void {
        self.code.append(alloc, inst) catch {
            self.had_error = true;
        };
    }

    fn check(self: *Compiler, tag: TTag) bool {
        return self.cur.tag == tag;
    }

    fn match(self: *Compiler, tag: TTag) bool {
        if (self.cur.tag == tag) {
            self.advance();
            return true;
        }
        return false;
    }

    fn expect(self: *Compiler, tag: TTag) void {
        if (!self.match(tag)) self.had_error = true;
    }

    // ─ Grammar ─
    // expr       = or_expr
    // or_expr    = and_expr ('or' and_expr)*
    // and_expr   = not_expr ('and' not_expr)*
    // not_expr   = 'not' not_expr | comparison
    // comparison = addition (('='|'!='|'<'|'>'|'<='|'>=') addition)?
    // addition   = multiply (('+'|'-') multiply)*
    // multiply   = unary (('*'|'/'|'%') unary)*
    // unary      = '-' unary | call
    // call       = FUNC '(' expr ')' | primary
    // primary    = NUMBER | STRING | 'true' | 'false' | VAR | '(' expr ')'

    fn parseExpr(self: *Compiler) void {
        self.parseOr();
    }

    fn parseOr(self: *Compiler) void {
        self.parseAnd();
        while (self.match(.kw_or)) {
            self.parseAnd();
            self.emit(.{ .op = .lor });
        }
    }

    fn parseAnd(self: *Compiler) void {
        self.parseNot();
        while (self.match(.kw_and)) {
            self.parseNot();
            self.emit(.{ .op = .land });
        }
    }

    fn parseNot(self: *Compiler) void {
        if (self.match(.kw_not)) {
            self.parseNot();
            self.emit(.{ .op = .lnot });
            return;
        }
        self.parseComparison();
    }

    fn parseComparison(self: *Compiler) void {
        self.parseAddition();
        const op: ?Op = if (self.check(.eq)) .eq else if (self.check(.neq)) .neq else if (self.check(.lt)) .lt else if (self.check(.gt)) .gt else if (self.check(.lte)) .lte else if (self.check(.gte)) .gte else null;
        if (op) |o| {
            self.advance();
            self.parseAddition();
            self.emit(.{ .op = o });
        }
    }

    fn parseAddition(self: *Compiler) void {
        self.parseMultiply();
        while (true) {
            if (self.check(.plus)) {
                self.advance();
                self.parseMultiply();
                self.emit(.{ .op = .add });
            } else if (self.check(.minus)) {
                self.advance();
                self.parseMultiply();
                self.emit(.{ .op = .sub });
            } else break;
        }
    }

    fn parseMultiply(self: *Compiler) void {
        self.parseUnary();
        while (true) {
            if (self.check(.star)) {
                self.advance();
                self.parseUnary();
                self.emit(.{ .op = .mul });
            } else if (self.check(.slash)) {
                self.advance();
                self.parseUnary();
                self.emit(.{ .op = .div });
            } else if (self.check(.percent)) {
                self.advance();
                self.parseUnary();
                self.emit(.{ .op = .mod });
            } else break;
        }
    }

    fn parseUnary(self: *Compiler) void {
        if (self.match(.minus)) {
            self.parseUnary();
            self.emit(.{ .op = .neg });
            return;
        }
        self.parseCall();
    }

    fn parseCall(self: *Compiler) void {
        const fn_op: ?Op = switch (self.cur.tag) {
            .fn_is_string => .fn_is_string,
            .fn_is_number => .fn_is_number,
            .fn_is_list => .fn_is_list,
            .fn_is_bool => .fn_is_bool,
            .fn_is_null => .fn_is_null,
            .fn_len => .fn_len,
            .fn_lower => .fn_lower,
            .fn_upper => .fn_upper,
            .fn_abs => .fn_abs,
            .fn_type => .fn_type,
            .fn_sqrt => .fn_sqrt,
            .fn_floor => .fn_floor,
            .fn_ceil => .fn_ceil,
            .fn_round => .fn_round,
            .fn_trim => .fn_trim,
            .fn_reversed => .fn_reversed,
            .fn_number => .fn_number,
            .fn_string => .fn_string,
            else => null,
        };

        if (fn_op) |op| {
            self.advance();
            self.expect(.lparen);
            self.parseExpr();
            self.expect(.rparen);
            self.emit(.{ .op = op });
            return;
        }

        // Two-arg functions: min(a,b), max(a,b), contains(s,sub), startswith(s,pre), endswith(s,suf), left(s,n), right(s,n)
        const fn2_op: ?Op = switch (self.cur.tag) {
            .fn_min => .fn_min,
            .fn_max => .fn_max,
            .fn_contains => .fn_contains,
            .fn_startswith => .fn_startswith,
            .fn_endswith => .fn_endswith,
            .fn_left => .fn_left,
            .fn_right => .fn_right,
            .fn_repeat => .fn_repeat,
            .fn_indexof => .fn_indexof,
            else => null,
        };

        if (fn2_op) |op| {
            self.advance();
            self.expect(.lparen);
            self.parseExpr();
            self.expect(.comma);
            self.parseExpr();
            self.expect(.rparen);
            self.emit(.{ .op = op });
            return;
        }

        // Three-arg functions: substr(s, start, len), if(cond, then, else), replace(s, old, new)
        const fn3_op: ?Op = switch (self.cur.tag) {
            .fn_substr => .fn_substr,
            .fn_if => .fn_if,
            .fn_replace => .fn_replace,
            else => null,
        };

        if (fn3_op) |op| {
            self.advance();
            self.expect(.lparen);
            self.parseExpr();
            self.expect(.comma);
            self.parseExpr();
            self.expect(.comma);
            self.parseExpr();
            self.expect(.rparen);
            self.emit(.{ .op = op });
            return;
        }

        self.parsePrimary();
    }

    fn parsePrimary(self: *Compiler) void {
        switch (self.cur.tag) {
            .int_lit => {
                self.emit(.{ .op = .push_int, .int_val = self.cur.int_val });
                self.advance();
            },
            .float_lit => {
                self.emit(.{ .op = .push_float, .float_val = self.cur.float_val });
                self.advance();
            },
            .string_lit => {
                self.emit(.{ .op = .push_str, .str_start = self.cur.start, .str_len = self.cur.len });
                self.advance();
            },
            .kw_true => {
                self.emit(.{ .op = .push_true });
                self.advance();
            },
            .kw_false => {
                self.emit(.{ .op = .push_false });
                self.advance();
            },
            .var_item => {
                self.emit(.{ .op = .load_item });
                self.advance();
            },
            .var_index => {
                self.emit(.{ .op = .load_index });
                self.advance();
            },
            .var_accum => {
                self.emit(.{ .op = .load_accum });
                self.advance();
            },
            .var_count => {
                self.emit(.{ .op = .load_count });
                self.advance();
            },
            .var_char => {
                self.emit(.{ .op = .load_char });
                self.advance();
            },
            .lparen => {
                self.advance();
                self.parseExpr();
                self.expect(.rparen);
            },
            else => {
                self.had_error = true;
            },
        }
    }
};

// ─── Public: compile ───

fn stripBraces(src: []const u8) []const u8 {
    var s = src;
    while (s.len > 0 and (s[0] == ' ' or s[0] == '\t' or s[0] == '{')) s = s[1..];
    while (s.len > 0 and (s[s.len - 1] == ' ' or s[s.len - 1] == '\t' or s[s.len - 1] == '}')) s = s[0 .. s.len - 1];
    return s;
}

pub fn compile(src_ptr: [*]const u8, src_len: usize) ?*Program {
    if (src_len == 0) return null;
    const raw = src_ptr[0..src_len];
    const stripped = stripBraces(raw);
    if (stripped.len == 0) return null;

    const source_copy = alloc.alloc(u8, stripped.len) catch return null;
    @memcpy(source_copy, stripped);

    var comp = Compiler.init(source_copy);
    comp.parseExpr();
    if (comp.had_error or comp.cur.tag != .eof) {
        comp.code.deinit(alloc);
        alloc.free(source_copy);
        return null;
    }

    const code = comp.code.toOwnedSlice(alloc) catch {
        comp.code.deinit(alloc);
        alloc.free(source_copy);
        return null;
    };

    const prog = alloc.create(Program) catch {
        alloc.free(code);
        alloc.free(source_copy);
        return null;
    };
    prog.* = .{ .code = code, .source = source_copy };
    return prog;
}

// ─── Evaluator ───

pub const EvalCtx = struct {
    item: Val = Val.initNull(),
    index: i64 = 0,
    count: i64 = 0,
    accum: Val = Val.initNull(),
    char_val: Val = Val.initNull(),
    scratch: [8192]u8 = undefined,
    scratch_pos: usize = 0,

    fn allocScratch(self: *EvalCtx, n: usize) ?[]u8 {
        if (self.scratch_pos + n > self.scratch.len) return null;
        const result = self.scratch[self.scratch_pos .. self.scratch_pos + n];
        self.scratch_pos += n;
        return result;
    }
};

const STACK_MAX = 64;

pub fn eval(prog: *const Program, ctx: *EvalCtx) Val {
    var stack: [STACK_MAX]Val = undefined;
    var sp: usize = 0;

    const push = struct {
        fn f(s: *[STACK_MAX]Val, p: *usize, v: Val) void {
            if (p.* < STACK_MAX) {
                s[p.*] = v;
                p.* += 1;
            }
        }
    }.f;

    const pop = struct {
        fn f(s: *[STACK_MAX]Val, p: *usize) Val {
            if (p.* > 0) {
                p.* -= 1;
                return s[p.*];
            }
            return Val.initNull();
        }
    }.f;

    for (prog.code) |inst| {
        switch (inst.op) {
            .push_int => push(&stack, &sp, Val.initInt(inst.int_val)),
            .push_float => push(&stack, &sp, Val.initFloat(inst.float_val)),
            .push_str => {
                const s = inst.str_start;
                const l = inst.str_len;
                if (s + l <= prog.source.len)
                    push(&stack, &sp, Val.initStr(prog.source[s..].ptr, l))
                else
                    push(&stack, &sp, Val.initStr("".ptr, 0));
            },
            .push_true => push(&stack, &sp, Val.initBool(true)),
            .push_false => push(&stack, &sp, Val.initBool(false)),
            .push_null => push(&stack, &sp, Val.initNull()),
            .load_item => push(&stack, &sp, ctx.item),
            .load_index => push(&stack, &sp, Val.initInt(ctx.index)),
            .load_accum => push(&stack, &sp, ctx.accum),
            .load_count => push(&stack, &sp, Val.initInt(ctx.count)),
            .load_char => push(&stack, &sp, ctx.char_val),

            .add => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, valAdd(a, b));
            },
            .sub => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, valSub(a, b));
            },
            .mul => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, valMul(a, b));
            },
            .div => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, valDiv(a, b));
            },
            .mod => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, valMod(a, b));
            },
            .neg => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, valNeg(a));
            },

            .eq => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(valEq(a, b)));
            },
            .neq => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(!valEq(a, b)));
            },
            .lt => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(valCmp(a, b) < 0));
            },
            .gt => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(valCmp(a, b) > 0));
            },
            .lte => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(valCmp(a, b) <= 0));
            },
            .gte => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(valCmp(a, b) >= 0));
            },

            .land => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(a.isTruthy() and b.isTruthy()));
            },
            .lor => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(a.isTruthy() or b.isTruthy()));
            },
            .lnot => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(!a.isTruthy()));
            },

            .fn_is_string => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(a.tag == .str_v));
            },
            .fn_is_number => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(a.tag == .int_v or a.tag == .float_v));
            },
            .fn_is_list => {
                const a = pop(&stack, &sp);
                _ = a;
                push(&stack, &sp, Val.initBool(false));
            },
            .fn_len => {
                const a = pop(&stack, &sp);
                if (a.tag == .str_v)
                    push(&stack, &sp, Val.initInt(@intCast(a.data.s.len)))
                else
                    push(&stack, &sp, Val.initInt(0));
            },
            .fn_lower => {
                const a = pop(&stack, &sp);
                if (a.tag == .str_v) {
                    const s = a.data.s;
                    if (ctx.allocScratch(s.len)) |buf| {
                        for (0..s.len) |j| buf[j] = toLower(s.ptr[j]);
                        push(&stack, &sp, Val.initStr(buf.ptr, buf.len));
                    } else push(&stack, &sp, a);
                } else push(&stack, &sp, a);
            },
            .fn_upper => {
                const a = pop(&stack, &sp);
                if (a.tag == .str_v) {
                    const s = a.data.s;
                    if (ctx.allocScratch(s.len)) |buf| {
                        for (0..s.len) |j| {
                            buf[j] = if (s.ptr[j] >= 'a' and s.ptr[j] <= 'z') s.ptr[j] - 32 else s.ptr[j];
                        }
                        push(&stack, &sp, Val.initStr(buf.ptr, buf.len));
                    } else push(&stack, &sp, a);
                } else push(&stack, &sp, a);
            },
            .fn_abs => {
                const a = pop(&stack, &sp);
                if (a.tag == .int_v)
                    push(&stack, &sp, Val.initInt(if (a.data.i < 0) -a.data.i else a.data.i))
                else if (a.tag == .float_v)
                    push(&stack, &sp, Val.initFloat(@abs(a.data.f)))
                else
                    push(&stack, &sp, Val.initInt(0));
            },
            .fn_type => {
                const a = pop(&stack, &sp);
                const name: []const u8 = switch (a.tag) {
                    .null_v => "null",
                    .bool_v => "bool",
                    .int_v => "number",
                    .float_v => "number",
                    .str_v => "string",
                };
                push(&stack, &sp, Val.initStr(name.ptr, name.len));
            },
            .fn_sqrt => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initFloat(@sqrt(a.asFloat())));
            },
            .fn_is_bool => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(a.tag == .bool_v));
            },
            .fn_is_null => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initBool(a.tag == .null_v));
            },
            .fn_floor => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initInt(@intFromFloat(@floor(a.asFloat()))));
            },
            .fn_ceil => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initInt(@intFromFloat(@ceil(a.asFloat()))));
            },
            .fn_round => {
                const a = pop(&stack, &sp);
                push(&stack, &sp, Val.initInt(@intFromFloat(@round(a.asFloat()))));
            },
            .fn_trim => {
                const a = pop(&stack, &sp);
                if (a.tag == .str_v) {
                    const s = a.data.s;
                    var start: usize = 0;
                    var end: usize = s.len;
                    while (start < end and (s.ptr[start] == ' ' or s.ptr[start] == '\t')) start += 1;
                    while (end > start and (s.ptr[end - 1] == ' ' or s.ptr[end - 1] == '\t')) end -= 1;
                    push(&stack, &sp, Val.initStr(s.ptr + start, end - start));
                } else push(&stack, &sp, a);
            },
            .fn_reversed => {
                const a = pop(&stack, &sp);
                if (a.tag == .str_v) {
                    const s = a.data.s;
                    if (ctx.allocScratch(s.len)) |buf| {
                        for (0..s.len) |j| buf[j] = s.ptr[s.len - 1 - j];
                        push(&stack, &sp, Val.initStr(buf.ptr, buf.len));
                    } else push(&stack, &sp, a);
                } else push(&stack, &sp, a);
            },
            .fn_number => {
                const a = pop(&stack, &sp);
                if (a.tag == .int_v or a.tag == .float_v) {
                    push(&stack, &sp, a);
                } else if (a.tag == .str_v) {
                    const s = a.data.s.ptr[0..a.data.s.len];
                    if (std.fmt.parseInt(i64, s, 10)) |iv| {
                        push(&stack, &sp, Val.initInt(iv));
                    } else |_| {
                        if (std.fmt.parseFloat(f64, s)) |fv| {
                            push(&stack, &sp, Val.initFloat(fv));
                        } else |_| {
                            push(&stack, &sp, Val.initInt(0));
                        }
                    }
                } else if (a.tag == .bool_v) {
                    push(&stack, &sp, Val.initInt(if (a.data.b) 1 else 0));
                } else push(&stack, &sp, Val.initInt(0));
            },
            .fn_string => {
                const a = pop(&stack, &sp);
                switch (a.tag) {
                    .str_v => push(&stack, &sp, a),
                    .int_v => {
                        if (ctx.allocScratch(20)) |buf| {
                            const s = std.fmt.bufPrint(buf, "{d}", .{a.data.i}) catch "";
                            push(&stack, &sp, Val.initStr(s.ptr, s.len));
                        } else push(&stack, &sp, Val.initStr("".ptr, 0));
                    },
                    .float_v => {
                        if (ctx.allocScratch(32)) |buf| {
                            const s = std.fmt.bufPrint(buf, "{d}", .{a.data.f}) catch "";
                            push(&stack, &sp, Val.initStr(s.ptr, s.len));
                        } else push(&stack, &sp, Val.initStr("".ptr, 0));
                    },
                    .bool_v => {
                        const s: []const u8 = if (a.data.b) "true" else "false";
                        push(&stack, &sp, Val.initStr(s.ptr, s.len));
                    },
                    .null_v => push(&stack, &sp, Val.initStr("null".ptr, 4)),
                }
            },
            .fn_min => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, if (valCmp(a, b) <= 0) a else b);
            },
            .fn_max => {
                const b = pop(&stack, &sp);
                const a = pop(&stack, &sp);
                push(&stack, &sp, if (valCmp(a, b) >= 0) a else b);
            },
            .fn_contains => {
                const sub = pop(&stack, &sp);
                const haystack = pop(&stack, &sp);
                if (haystack.tag == .str_v and sub.tag == .str_v) {
                    const h = haystack.data.s;
                    const n = sub.data.s;
                    if (n.len == 0 or n.len > h.len) {
                        push(&stack, &sp, Val.initBool(n.len == 0));
                    } else {
                        var found = false;
                        var j: usize = 0;
                        while (j + n.len <= h.len) : (j += 1) {
                            if (std.mem.eql(u8, h.ptr[j .. j + n.len], n.ptr[0..n.len])) {
                                found = true;
                                break;
                            }
                        }
                        push(&stack, &sp, Val.initBool(found));
                    }
                } else push(&stack, &sp, Val.initBool(false));
            },
            .fn_startswith => {
                const pre = pop(&stack, &sp);
                const s = pop(&stack, &sp);
                if (s.tag == .str_v and pre.tag == .str_v) {
                    if (pre.data.s.len <= s.data.s.len) {
                        push(&stack, &sp, Val.initBool(std.mem.eql(u8, s.data.s.ptr[0..pre.data.s.len], pre.data.s.ptr[0..pre.data.s.len])));
                    } else push(&stack, &sp, Val.initBool(false));
                } else push(&stack, &sp, Val.initBool(false));
            },
            .fn_endswith => {
                const suf = pop(&stack, &sp);
                const s = pop(&stack, &sp);
                if (s.tag == .str_v and suf.tag == .str_v) {
                    if (suf.data.s.len <= s.data.s.len) {
                        const offset = s.data.s.len - suf.data.s.len;
                        push(&stack, &sp, Val.initBool(std.mem.eql(u8, s.data.s.ptr[offset .. offset + suf.data.s.len], suf.data.s.ptr[0..suf.data.s.len])));
                    } else push(&stack, &sp, Val.initBool(false));
                } else push(&stack, &sp, Val.initBool(false));
            },
            .fn_left => {
                const n = pop(&stack, &sp);
                const s = pop(&stack, &sp);
                if (s.tag == .str_v) {
                    const take = @min(@as(usize, @intCast(@max(n.asInt(), 0))), s.data.s.len);
                    push(&stack, &sp, Val.initStr(s.data.s.ptr, take));
                } else push(&stack, &sp, Val.initStr("".ptr, 0));
            },
            .fn_right => {
                const n = pop(&stack, &sp);
                const s = pop(&stack, &sp);
                if (s.tag == .str_v) {
                    const take = @min(@as(usize, @intCast(@max(n.asInt(), 0))), s.data.s.len);
                    push(&stack, &sp, Val.initStr(s.data.s.ptr + s.data.s.len - take, take));
                } else push(&stack, &sp, Val.initStr("".ptr, 0));
            },
            .fn_substr => {
                const len_val = pop(&stack, &sp);
                const start_val = pop(&stack, &sp);
                const s = pop(&stack, &sp);
                if (s.tag == .str_v) {
                    const slen = s.data.s.len;
                    const raw_start = start_val.asInt();
                    const start_1 = if (raw_start < 1) @as(usize, 0) else @as(usize, @intCast(raw_start - 1));
                    const start_clamped = @min(start_1, slen);
                    const take = @min(@as(usize, @intCast(@max(len_val.asInt(), 0))), slen - start_clamped);
                    push(&stack, &sp, Val.initStr(s.data.s.ptr + start_clamped, take));
                } else push(&stack, &sp, Val.initStr("".ptr, 0));
            },
            .fn_if => {
                const else_val = pop(&stack, &sp);
                const then_val = pop(&stack, &sp);
                const cond = pop(&stack, &sp);
                push(&stack, &sp, if (cond.isTruthy()) then_val else else_val);
            },
            .fn_replace => {
                const new_val = pop(&stack, &sp);
                const old_val = pop(&stack, &sp);
                const str_val = pop(&stack, &sp);
                if (str_val.tag == .str_v and old_val.tag == .str_v and new_val.tag == .str_v) {
                    const s = str_val.data.s;
                    const old = old_val.data.s;
                    const new = new_val.data.s;
                    if (old.len == 0 or s.len == 0) {
                        push(&stack, &sp, str_val);
                    } else {
                        var result_len: usize = 0;
                        var pos: usize = 0;
                        while (pos <= s.len -| old.len) {
                            if (std.mem.eql(u8, s.ptr[pos..][0..old.len], old.ptr[0..old.len])) {
                                result_len += new.len;
                                pos += old.len;
                            } else {
                                result_len += 1;
                                pos += 1;
                            }
                        }
                        result_len += s.len - pos;

                        if (ctx.allocScratch(result_len)) |buf| {
                            var wp: usize = 0;
                            pos = 0;
                            while (pos <= s.len -| old.len) {
                                if (std.mem.eql(u8, s.ptr[pos..][0..old.len], old.ptr[0..old.len])) {
                                    if (new.len > 0) {
                                        @memcpy(buf[wp..][0..new.len], new.ptr[0..new.len]);
                                        wp += new.len;
                                    }
                                    pos += old.len;
                                } else {
                                    buf[wp] = s.ptr[pos];
                                    wp += 1;
                                    pos += 1;
                                }
                            }
                            while (pos < s.len) : (pos += 1) {
                                buf[wp] = s.ptr[pos];
                                wp += 1;
                            }
                            push(&stack, &sp, Val.initStr(buf.ptr, wp));
                        } else push(&stack, &sp, str_val);
                    }
                } else push(&stack, &sp, Val.initNull());
            },
            .fn_repeat => {
                const n_val = pop(&stack, &sp);
                const s_val = pop(&stack, &sp);
                if (s_val.tag == .str_v) {
                    const s = s_val.data.s;
                    const n: usize = @intCast(@max(n_val.asInt(), 0));
                    const total = s.len * n;
                    if (total == 0) {
                        push(&stack, &sp, Val.initStr(s.ptr, 0));
                    } else if (ctx.allocScratch(total)) |buf| {
                        for (0..n) |j| {
                            @memcpy(buf[j * s.len ..][0..s.len], s.ptr[0..s.len]);
                        }
                        push(&stack, &sp, Val.initStr(buf.ptr, total));
                    } else push(&stack, &sp, s_val);
                } else push(&stack, &sp, Val.initNull());
            },
            .fn_indexof => {
                const sub = pop(&stack, &sp);
                const haystack = pop(&stack, &sp);
                if (haystack.tag == .str_v and sub.tag == .str_v) {
                    const h = haystack.data.s;
                    const s = sub.data.s;
                    if (s.len == 0 or s.len > h.len) {
                        push(&stack, &sp, Val.initInt(0));
                    } else {
                        var found: i64 = 0;
                        for (0..h.len - s.len + 1) |j| {
                            if (std.mem.eql(u8, h.ptr[j..][0..s.len], s.ptr[0..s.len])) {
                                found = @as(i64, @intCast(j)) + 1;
                                break;
                            }
                        }
                        push(&stack, &sp, Val.initInt(found));
                    }
                } else push(&stack, &sp, Val.initInt(0));
            },
        }
    }

    return if (sp > 0) stack[sp - 1] else Val.initNull();
}

// ─── Value operations ───

fn valAdd(a: Val, b: Val) Val {
    if (a.tag == .int_v and b.tag == .int_v) return Val.initInt(a.data.i +% b.data.i);
    if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v))
        return Val.initFloat(a.asFloat() + b.asFloat());
    if (a.tag == .str_v and b.tag == .str_v) {
        const total = a.data.s.len + b.data.s.len;
        const buf = alloc.alloc(u8, total) catch return Val.initNull();
        if (a.data.s.len > 0) @memcpy(buf[0..a.data.s.len], a.data.s.ptr[0..a.data.s.len]);
        if (b.data.s.len > 0) @memcpy(buf[a.data.s.len..], b.data.s.ptr[0..b.data.s.len]);
        return Val.initStr(buf.ptr, total);
    }
    return Val.initNull();
}

fn valSub(a: Val, b: Val) Val {
    if (a.tag == .int_v and b.tag == .int_v) return Val.initInt(a.data.i -% b.data.i);
    if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v))
        return Val.initFloat(a.asFloat() - b.asFloat());
    return Val.initNull();
}

fn valMul(a: Val, b: Val) Val {
    if (a.tag == .int_v and b.tag == .int_v) return Val.initInt(a.data.i *% b.data.i);
    if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v))
        return Val.initFloat(a.asFloat() * b.asFloat());
    return Val.initNull();
}

fn valDiv(a: Val, b: Val) Val {
    if (a.tag == .int_v and b.tag == .int_v) {
        if (b.data.i == 0) return Val.initNull();
        return Val.initInt(@divTrunc(a.data.i, b.data.i));
    }
    if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v)) {
        const bf = b.asFloat();
        if (bf == 0.0) return Val.initNull();
        return Val.initFloat(a.asFloat() / bf);
    }
    return Val.initNull();
}

fn valMod(a: Val, b: Val) Val {
    if (a.tag == .int_v and b.tag == .int_v) {
        if (b.data.i == 0) return Val.initNull();
        return Val.initInt(@mod(a.data.i, b.data.i));
    }
    return Val.initNull();
}

fn valNeg(a: Val) Val {
    if (a.tag == .int_v) return Val.initInt(-%a.data.i);
    if (a.tag == .float_v) return Val.initFloat(-a.data.f);
    return Val.initNull();
}

fn valEq(a: Val, b: Val) bool {
    if (a.tag != b.tag) {
        if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v))
            return a.asFloat() == b.asFloat();
        return false;
    }
    return switch (a.tag) {
        .null_v => true,
        .bool_v => a.data.b == b.data.b,
        .int_v => a.data.i == b.data.i,
        .float_v => a.data.f == b.data.f,
        .str_v => blk: {
            if (a.data.s.len != b.data.s.len) break :blk false;
            if (a.data.s.len == 0) break :blk true;
            break :blk std.mem.eql(u8, a.data.s.ptr[0..a.data.s.len], b.data.s.ptr[0..b.data.s.len]);
        },
    };
}

fn valCmp(a: Val, b: Val) i32 {
    if ((a.tag == .int_v or a.tag == .float_v) and (b.tag == .int_v or b.tag == .float_v)) {
        const af = a.asFloat();
        const bf = b.asFloat();
        if (af < bf) return -1;
        if (af > bf) return 1;
        return 0;
    }
    if (a.tag == .str_v and b.tag == .str_v) {
        const sa = a.data.s;
        const sb = b.data.s;
        const min_len = @min(sa.len, sb.len);
        if (min_len > 0) {
            const ord = std.mem.order(u8, sa.ptr[0..min_len], sb.ptr[0..min_len]);
            if (ord != .eq) return if (ord == .lt) @as(i32, -1) else @as(i32, 1);
        }
        if (sa.len < sb.len) return -1;
        if (sa.len > sb.len) return 1;
        return 0;
    }
    return 0;
}

// ─── C ABI ───

pub fn stz_expr_compile(src: [*]const u8, len: usize) callconv(.c) ?*Program {
    return compile(src, len);
}

pub fn stz_expr_free(prog: ?*Program) callconv(.c) void {
    if (prog) |p| p.deinit();
}

// ─── Tests ───

var test_str_buf: [4096]u8 = undefined;

fn compileAndEval(expr_str: []const u8, item: Val, index: i64, count: i64) Val {
    const prog = compile(expr_str.ptr, expr_str.len) orelse return Val.initNull();
    var ctx = EvalCtx{
        .item = item,
        .index = index,
        .count = count,
    };
    const result = eval(prog, &ctx);
    if (result.tag == .str_v and result.data.s.len > 0) {
        const n = @min(result.data.s.len, test_str_buf.len);
        @memcpy(test_str_buf[0..n], result.data.s.ptr[0..n]);
        prog.deinit();
        return Val.initStr(&test_str_buf, n);
    }
    prog.deinit();
    return result;
}

fn compileAndEvalReduce(expr_str: []const u8, item: Val, accum: Val) Val {
    const prog = compile(expr_str.ptr, expr_str.len) orelse return Val.initNull();
    var ctx = EvalCtx{
        .item = item,
        .accum = accum,
    };
    const result = eval(prog, &ctx);
    if (result.tag == .str_v and result.data.s.len > 0) {
        const n = @min(result.data.s.len, test_str_buf.len);
        @memcpy(test_str_buf[0..n], result.data.s.ptr[0..n]);
        prog.deinit();
        return Val.initStr(&test_str_buf, n);
    }
    prog.deinit();
    return result;
}

test "expr: integer arithmetic" {
    const r1 = compileAndEval("@item + 1", Val.initInt(5), 1, 1);
    try std.testing.expectEqual(Val.Tag.int_v, r1.tag);
    try std.testing.expectEqual(@as(i64, 6), r1.data.i);

    const r2 = compileAndEval("@item * 3", Val.initInt(4), 1, 1);
    try std.testing.expectEqual(@as(i64, 12), r2.data.i);

    const r3 = compileAndEval("@item / 2", Val.initInt(10), 1, 1);
    try std.testing.expectEqual(@as(i64, 5), r3.data.i);

    const r4 = compileAndEval("@item % 3", Val.initInt(7), 1, 1);
    try std.testing.expectEqual(@as(i64, 1), r4.data.i);
}

test "expr: float arithmetic" {
    const r1 = compileAndEval("@item + 0.5", Val.initFloat(1.5), 1, 1);
    try std.testing.expectEqual(Val.Tag.float_v, r1.tag);
    try std.testing.expectApproxEqAbs(@as(f64, 2.0), r1.data.f, 0.001);

    const r2 = compileAndEval("@item * 2", Val.initFloat(3.14), 1, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 6.28), r2.data.f, 0.001);
}

test "expr: int-float promotion" {
    const r = compileAndEval("@item + 0.5", Val.initInt(3), 1, 1);
    try std.testing.expectEqual(Val.Tag.float_v, r.tag);
    try std.testing.expectApproxEqAbs(@as(f64, 3.5), r.data.f, 0.001);
}

test "expr: negation" {
    const r = compileAndEval("-@item", Val.initInt(5), 1, 1);
    try std.testing.expectEqual(@as(i64, -5), r.data.i);
}

test "expr: comparison" {
    const r1 = compileAndEval("@item > 3", Val.initInt(5), 1, 1);
    try std.testing.expect(r1.data.b);

    const r2 = compileAndEval("@item > 3", Val.initInt(2), 1, 1);
    try std.testing.expect(!r2.data.b);

    const r3 = compileAndEval("@item = 42", Val.initInt(42), 1, 1);
    try std.testing.expect(r3.data.b);

    const r4 = compileAndEval("@item != 42", Val.initInt(99), 1, 1);
    try std.testing.expect(r4.data.b);

    const r5 = compileAndEval("@item <= 5", Val.initInt(5), 1, 1);
    try std.testing.expect(r5.data.b);

    const r6 = compileAndEval("@item >= 10", Val.initInt(8), 1, 1);
    try std.testing.expect(!r6.data.b);
}

test "expr: string comparison" {
    const r = compileAndEval(
        "{ @item = \"hello\" }",
        Val.initStr("hello", 5),
        1,
        1,
    );
    try std.testing.expect(r.data.b);
}

test "expr: logical operators" {
    const r1 = compileAndEval("@item > 0 and @item < 10", Val.initInt(5), 1, 1);
    try std.testing.expect(r1.data.b);

    const r2 = compileAndEval("@item > 0 and @item < 10", Val.initInt(15), 1, 1);
    try std.testing.expect(!r2.data.b);

    const r3 = compileAndEval("@item > 10 or @item < 0", Val.initInt(15), 1, 1);
    try std.testing.expect(r3.data.b);

    const r4 = compileAndEval("not (@item > 5)", Val.initInt(3), 1, 1);
    try std.testing.expect(r4.data.b);
}

test "expr: built-in functions" {
    const r1 = compileAndEval("isString(@item)", Val.initStr("hi", 2), 1, 1);
    try std.testing.expect(r1.data.b);

    const r2 = compileAndEval("isNumber(@item)", Val.initInt(42), 1, 1);
    try std.testing.expect(r2.data.b);

    const r3 = compileAndEval("isNumber(@item)", Val.initStr("hi", 2), 1, 1);
    try std.testing.expect(!r3.data.b);

    const r4 = compileAndEval("len(@item)", Val.initStr("hello", 5), 1, 1);
    try std.testing.expectEqual(@as(i64, 5), r4.data.i);

    const r5 = compileAndEval("abs(@item)", Val.initInt(-7), 1, 1);
    try std.testing.expectEqual(@as(i64, 7), r5.data.i);
}

test "expr: type function" {
    const r = compileAndEval("type(@item)", Val.initInt(42), 1, 1);
    try std.testing.expectEqual(Val.Tag.str_v, r.tag);
    try std.testing.expectEqualStrings("number", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: variables @i and @numberofitems" {
    const r1 = compileAndEval("@i", Val.initNull(), 7, 10);
    try std.testing.expectEqual(@as(i64, 7), r1.data.i);

    const r2 = compileAndEval("@numberofitems", Val.initNull(), 1, 42);
    try std.testing.expectEqual(@as(i64, 42), r2.data.i);
}

test "expr: accumulator for reduce" {
    const r = compileAndEvalReduce("@accumulator + @item", Val.initInt(3), Val.initInt(10));
    try std.testing.expectEqual(@as(i64, 13), r.data.i);
}

test "expr: @value alias for accumulator" {
    const r = compileAndEvalReduce("@value + @item", Val.initInt(3), Val.initInt(10));
    try std.testing.expectEqual(@as(i64, 13), r.data.i);
}

test "expr: complex expression" {
    const r = compileAndEval("(@item * 2) + 1 > 10 and @i <= 5", Val.initInt(6), 3, 10);
    try std.testing.expect(r.data.b);
}

test "expr: division by zero" {
    const r = compileAndEval("@item / 0", Val.initInt(5), 1, 1);
    try std.testing.expectEqual(Val.Tag.null_v, r.tag);
}

test "expr: brace stripping" {
    const r = compileAndEval("  { @item + 1 }  ", Val.initInt(5), 1, 1);
    try std.testing.expectEqual(@as(i64, 6), r.data.i);
}

test "expr: lower/upper" {
    const r1 = compileAndEval("lower(@item)", Val.initStr("HELLO", 5), 1, 1);
    try std.testing.expectEqual(Val.Tag.str_v, r1.tag);
    try std.testing.expectEqualStrings("hello", r1.data.s.ptr[0..r1.data.s.len]);

    const r2 = compileAndEval("upper(@item)", Val.initStr("hello", 5), 1, 1);
    try std.testing.expectEqualStrings("HELLO", r2.data.s.ptr[0..r2.data.s.len]);
}

test "expr: precedence" {
    const r = compileAndEval("2 + 3 * 4", Val.initNull(), 1, 1);
    try std.testing.expectEqual(@as(i64, 14), r.data.i);
}

test "expr: nested parentheses" {
    const r = compileAndEval("(2 + 3) * (4 - 1)", Val.initNull(), 1, 1);
    try std.testing.expectEqual(@as(i64, 15), r.data.i);
}

test "expr: boolean literals" {
    const r = compileAndEval("true and not false", Val.initNull(), 1, 1);
    try std.testing.expect(r.data.b);
}

test "expr: Softanza <> inequality" {
    const r = compileAndEval("@item <> 5", Val.initInt(3), 1, 1);
    try std.testing.expect(r.data.b);
}

test "expr: sqrt" {
    const r = compileAndEval("sqrt(@item)", Val.initInt(16), 1, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 4.0), r.data.f, 0.001);
}

test "expr: string concatenation" {
    const r = compileAndEval("@item + \" world\"", Val.initStr("hello", 5), 1, 1);
    try std.testing.expectEqual(Val.Tag.str_v, r.tag);
    try std.testing.expectEqualStrings("hello world", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: isBool and isNull" {
    const r1 = compileAndEval("isBool(@item)", Val.initBool(true), 1, 1);
    try std.testing.expect(r1.data.b);

    const r2 = compileAndEval("isBool(@item)", Val.initInt(1), 1, 1);
    try std.testing.expect(!r2.data.b);

    const r3 = compileAndEval("isNull(@item)", Val.initNull(), 1, 1);
    try std.testing.expect(r3.data.b);

    const r4 = compileAndEval("isNull(@item)", Val.initInt(0), 1, 1);
    try std.testing.expect(!r4.data.b);
}

test "expr: floor/ceil/round" {
    const r1 = compileAndEval("floor(@item)", Val.initFloat(3.7), 1, 1);
    try std.testing.expectEqual(@as(i64, 3), r1.data.i);

    const r2 = compileAndEval("ceil(@item)", Val.initFloat(3.2), 1, 1);
    try std.testing.expectEqual(@as(i64, 4), r2.data.i);

    const r3 = compileAndEval("round(@item)", Val.initFloat(3.5), 1, 1);
    try std.testing.expectEqual(@as(i64, 4), r3.data.i);

    const r4 = compileAndEval("round(@item)", Val.initFloat(3.4), 1, 1);
    try std.testing.expectEqual(@as(i64, 3), r4.data.i);
}

test "expr: trim" {
    const r = compileAndEval("trim(@item)", Val.initStr("  hello  ", 9), 1, 1);
    try std.testing.expectEqualStrings("hello", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: reversed" {
    const r = compileAndEval("reversed(@item)", Val.initStr("abcd", 4), 1, 1);
    try std.testing.expectEqualStrings("dcba", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: number conversion" {
    const r1 = compileAndEval("number(@item)", Val.initStr("42", 2), 1, 1);
    try std.testing.expectEqual(@as(i64, 42), r1.data.i);

    const r2 = compileAndEval("number(@item)", Val.initStr("3.14", 4), 1, 1);
    try std.testing.expectApproxEqAbs(@as(f64, 3.14), r2.data.f, 0.001);

    const r3 = compileAndEval("number(@item)", Val.initBool(true), 1, 1);
    try std.testing.expectEqual(@as(i64, 1), r3.data.i);
}

test "expr: string conversion" {
    const r1 = compileAndEval("string(@item)", Val.initInt(42), 1, 1);
    try std.testing.expectEqualStrings("42", r1.data.s.ptr[0..r1.data.s.len]);

    const r2 = compileAndEval("string(@item)", Val.initBool(true), 1, 1);
    try std.testing.expectEqualStrings("true", r2.data.s.ptr[0..r2.data.s.len]);
}

test "expr: min and max" {
    const r1 = compileAndEval("min(@item, 10)", Val.initInt(5), 1, 1);
    try std.testing.expectEqual(@as(i64, 5), r1.data.i);

    const r2 = compileAndEval("max(@item, 10)", Val.initInt(5), 1, 1);
    try std.testing.expectEqual(@as(i64, 10), r2.data.i);
}

test "expr: contains" {
    const r1 = compileAndEval("contains(@item, \"ell\")", Val.initStr("hello", 5), 1, 1);
    try std.testing.expect(r1.data.b);

    const r2 = compileAndEval("contains(@item, \"xyz\")", Val.initStr("hello", 5), 1, 1);
    try std.testing.expect(!r2.data.b);
}

test "expr: startswith and endswith" {
    const r1 = compileAndEval("startswith(@item, \"hel\")", Val.initStr("hello", 5), 1, 1);
    try std.testing.expect(r1.data.b);

    const r2 = compileAndEval("endswith(@item, \"llo\")", Val.initStr("hello", 5), 1, 1);
    try std.testing.expect(r2.data.b);

    const r3 = compileAndEval("startswith(@item, \"xyz\")", Val.initStr("hello", 5), 1, 1);
    try std.testing.expect(!r3.data.b);
}

test "expr: left and right" {
    const r1 = compileAndEval("left(@item, 3)", Val.initStr("hello", 5), 1, 1);
    try std.testing.expectEqualStrings("hel", r1.data.s.ptr[0..r1.data.s.len]);

    const r2 = compileAndEval("right(@item, 3)", Val.initStr("hello", 5), 1, 1);
    try std.testing.expectEqualStrings("llo", r2.data.s.ptr[0..r2.data.s.len]);
}

test "expr: substr (1-based)" {
    const r = compileAndEval("substr(@item, 2, 3)", Val.initStr("hello", 5), 1, 1);
    try std.testing.expectEqualStrings("ell", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: if conditional" {
    const r1 = compileAndEval("if(@item > 5, \"big\", \"small\")", Val.initInt(10), 1, 1);
    try std.testing.expectEqualStrings("big", r1.data.s.ptr[0..r1.data.s.len]);

    const r2 = compileAndEval("if(@item > 5, \"big\", \"small\")", Val.initInt(3), 1, 1);
    try std.testing.expectEqualStrings("small", r2.data.s.ptr[0..r2.data.s.len]);
}

test "expr: @char variable" {
    const prog = compile("@char = \"a\"".ptr, "@char = \"a\"".len) orelse return error.CompileFailed;
    defer prog.deinit();
    var ctx = EvalCtx{ .char_val = Val.initStr("a", 1) };
    const r = eval(prog, &ctx);
    try std.testing.expect(r.data.b);
}

test "expr: complex string expression" {
    const r = compileAndEval(
        "if(contains(@item, \"@\"), left(@item, 3), upper(@item))",
        Val.initStr("abc@def", 7),
        1,
        1,
    );
    try std.testing.expectEqualStrings("abc", r.data.s.ptr[0..r.data.s.len]);

    const r2 = compileAndEval(
        "if(contains(@item, \"@\"), left(@item, 3), upper(@item))",
        Val.initStr("hello", 5),
        1,
        1,
    );
    try std.testing.expectEqualStrings("HELLO", r2.data.s.ptr[0..r2.data.s.len]);
}

test "expr: replace function" {
    const r = compileAndEval(
        "replace(@item, \"world\", \"zig\")",
        Val.initStr("hello world", 11),
        1,
        1,
    );
    try std.testing.expectEqualStrings("hello zig", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: replace multiple occurrences" {
    const r = compileAndEval(
        "replace(@item, \"a\", \"x\")",
        Val.initStr("banana", 6),
        1,
        1,
    );
    try std.testing.expectEqualStrings("bxnxnx", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: replace no match" {
    const r = compileAndEval(
        "replace(@item, \"z\", \"x\")",
        Val.initStr("hello", 5),
        1,
        1,
    );
    try std.testing.expectEqualStrings("hello", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: repeat function" {
    const r = compileAndEval(
        "repeat(@item, 3)",
        Val.initStr("ab", 2),
        1,
        1,
    );
    try std.testing.expectEqualStrings("ababab", r.data.s.ptr[0..r.data.s.len]);
}

test "expr: repeat zero times" {
    const r = compileAndEval("repeat(@item, 0)", Val.initStr("x", 1), 1, 1);
    try std.testing.expectEqual(@as(usize, 0), r.data.s.len);
}

test "expr: indexof found" {
    const r = compileAndEval(
        "indexof(@item, \"world\")",
        Val.initStr("hello world", 11),
        1,
        1,
    );
    try std.testing.expectEqual(@as(i64, 7), r.data.i);
}

test "expr: indexof not found" {
    const r = compileAndEval(
        "indexof(@item, \"xyz\")",
        Val.initStr("hello", 5),
        1,
        1,
    );
    try std.testing.expectEqual(@as(i64, 0), r.data.i);
}
