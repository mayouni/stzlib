// Softanza Engine -- Regex Operations (Tier 3)
//
// PCRE2 backend replacing the custom recursive backtracker.
// Full feature set: lookaround, named groups, backreferences,
// word boundaries, multiline, recursion, counted quantifiers,
// non-capturing groups, Unicode scripts, replace with $1/$2.
// All functions use C ABI for Ring FFI compatibility.
//
// ReDoS hardening: match limit, recursion limit, input/pattern
// length caps. All configurable per handle via stz_regex_set_limits.

const std = @import("std");
const mem = std.mem;
const gpa = std.heap.c_allocator;

const pcre2 = @cImport({
    @cDefine("PCRE2_CODE_UNIT_WIDTH", "8");
    @cDefine("PCRE2_STATIC", "1");
    @cInclude("pcre2.h");
});

// ─── Public handle ───

pub const StzRegexHandle = ?*Regex;

const Regex = struct {
    pattern: []const u8,
    flags: u32,
    code: *pcre2.pcre2_code_8,
    match_data: *pcre2.pcre2_match_data_8,
    match_ctx: ?*pcre2.pcre2_match_context_8,
    matched: bool,
    input: []const u8,
    last_match_count: c_int,
    all_captures: std.ArrayList(Cap),
    // Guards runaway memory on enormous inputs. NOT the ReDoS guard -- PCRE2's
    // own default match_limit (~10M steps) bounds catastrophic backtracking
    // regardless of input length -- so this can be generous. 1 MB was too low
    // for document/log processing and silently returned 0 (looked like "no
    // matches"). 64 MB covers real documents; truly enormous inputs still bail.
    max_input_len: u32 = 67_108_864,
    const Cap = struct { start: i32, end: i32 };
};

const MAX_PATTERN_LEN: usize = 8192;

// Flags: 1=CaseInsensitive 2=DotMatchesAll 4=MultiLine 8=Extended 16=Ungreedy
const FLAG_CASE_I: u32 = 1;
const FLAG_DOT_ALL: u32 = 2;
const FLAG_MULTILINE: u32 = 4;
const FLAG_EXTENDED: u32 = 8;
const FLAG_UNGREEDY: u32 = 16;

fn toPcre2Options(flags: u32) u32 {
    var opts: u32 = pcre2.PCRE2_UTF | pcre2.PCRE2_UCP;
    if (flags & FLAG_CASE_I != 0) opts |= pcre2.PCRE2_CASELESS;
    if (flags & FLAG_DOT_ALL != 0) opts |= pcre2.PCRE2_DOTALL;
    if (flags & FLAG_MULTILINE != 0) opts |= pcre2.PCRE2_MULTILINE;
    if (flags & FLAG_EXTENDED != 0) opts |= pcre2.PCRE2_EXTENDED;
    if (flags & FLAG_UNGREEDY != 0) opts |= pcre2.PCRE2_UNGREEDY;
    return opts;
}

pub fn stz_regex_new(pat: [*c]const u8, pat_len: usize, flags: u32) callconv(.c) ?*Regex {
    if (pat == null or pat_len == 0) return null;
    if (pat_len > MAX_PATTERN_LEN) return null;

    var err_code: c_int = 0;
    var err_offset: usize = 0;
    const opts = toPcre2Options(flags);

    const code = pcre2.pcre2_compile_8(pat, pat_len, opts, &err_code, &err_offset, null) orelse return null;

    const md = pcre2.pcre2_match_data_create_from_pattern_8(code, null) orelse {
        pcre2.pcre2_code_free_8(code);
        return null;
    };

    const p = gpa.dupe(u8, pat[0..pat_len]) catch {
        pcre2.pcre2_match_data_free_8(md);
        pcre2.pcre2_code_free_8(code);
        return null;
    };

    const r = gpa.create(Regex) catch {
        gpa.free(p);
        pcre2.pcre2_match_data_free_8(md);
        pcre2.pcre2_code_free_8(code);
        return null;
    };
    r.* = .{
        .pattern = p,
        .flags = flags,
        .code = code,
        .match_data = md,
        .match_ctx = null,
        .matched = false,
        .input = "",
        .last_match_count = 0,
        .all_captures = .{},
    };
    return r;
}

pub fn stz_regex_set_limits(h: ?*Regex, max_steps: u32, max_input_len: u32, max_depth: u16) callconv(.c) void {
    const r = h orelse return;
    if (max_input_len > 0) r.max_input_len = max_input_len;

    if (max_steps > 0 or max_depth > 0) {
        if (r.match_ctx == null) {
            r.match_ctx = pcre2.pcre2_match_context_create_8(null);
        }
        if (r.match_ctx) |ctx| {
            if (max_steps > 0) _ = pcre2.pcre2_set_match_limit_8(ctx, max_steps);
            if (max_depth > 0) _ = pcre2.pcre2_set_depth_limit_8(ctx, @intCast(max_depth));
        }
    }
}

pub fn stz_regex_free(h: ?*Regex) callconv(.c) void {
    if (h) |r| {
        if (r.match_ctx) |ctx| pcre2.pcre2_match_context_free_8(ctx);
        pcre2.pcre2_match_data_free_8(r.match_data);
        pcre2.pcre2_code_free_8(r.code);
        r.all_captures.deinit(gpa);
        gpa.free(r.pattern);
        gpa.destroy(r);
    }
}

pub fn stz_regex_match(h: ?*Regex, inp: [*c]const u8, inp_len: usize, start: usize) callconv(.c) c_int {
    const r = h orelse return 0;
    if (inp == null) { r.matched = false; return 0; }
    if (inp_len > r.max_input_len) { r.matched = false; return 0; }
    r.input = inp[0..inp_len];
    r.all_captures.clearRetainingCapacity();

    const rc = pcre2.pcre2_match_8(r.code, inp, inp_len, start, 0, r.match_data, r.match_ctx);
    if (rc < 0) {
        r.matched = false;
        r.last_match_count = 0;
        return 0;
    }

    r.matched = true;
    r.last_match_count = rc;

    const ovector = pcre2.pcre2_get_ovector_pointer_8(r.match_data);
    const pair_count: usize = @intCast(rc);
    var i: usize = 0;
    while (i < pair_count) : (i += 1) {
        const s = ovector[i * 2];
        const e = ovector[i * 2 + 1];
        if (s == std.math.maxInt(usize)) {
            r.all_captures.append(gpa, .{ .start = -1, .end = -1 }) catch {};
        } else {
            r.all_captures.append(gpa, .{ .start = @intCast(s), .end = @intCast(e) }) catch {};
        }
    }

    return 1;
}

pub fn stz_regex_match_all(h: ?*Regex, inp: [*c]const u8, inp_len: usize) callconv(.c) c_int {
    const r = h orelse return 0;
    if (inp == null) return 0;
    if (inp_len > r.max_input_len) return 0;
    r.input = inp[0..inp_len];
    r.all_captures.clearRetainingCapacity();

    var pos: usize = 0;
    var n: c_int = 0;
    // First call validates the UTF-8 subject; every subsequent call over the
    // SAME subject passes PCRE2_NO_UTF_CHECK. Without this, PCRE2 re-validates
    // the ENTIRE subject on every match -> O(matches * input_len). On a 1 MB
    // subject with thousands of matches that was seconds; this makes it O(n).
    var opts: u32 = 0;
    const revisit: u32 = pcre2.PCRE2_NO_UTF_CHECK;

    while (pos <= inp_len) {
        const rc = pcre2.pcre2_match_8(r.code, inp, inp_len, pos, opts, r.match_data, r.match_ctx);
        if (rc < 0) break;

        const ovector = pcre2.pcre2_get_ovector_pointer_8(r.match_data);
        const pair_count: usize = @intCast(rc);
        var i: usize = 0;
        while (i < pair_count) : (i += 1) {
            const s = ovector[i * 2];
            const e = ovector[i * 2 + 1];
            if (s == std.math.maxInt(usize)) {
                r.all_captures.append(gpa, .{ .start = -1, .end = -1 }) catch {};
            } else {
                r.all_captures.append(gpa, .{ .start = @intCast(s), .end = @intCast(e) }) catch {};
            }
        }

        n += 1;
        const match_end = ovector[1];
        if (match_end == ovector[0]) {
            // Zero-length match: advance by one character
            if (pos >= inp_len) break;
            pos = nextCharPos(inp, inp_len, pos);
            opts = revisit;
        } else {
            pos = match_end;
            opts = revisit;
        }
    }

    r.matched = n > 0;
    r.last_match_count = n;
    return n;
}

fn nextCharPos(inp: [*c]const u8, inp_len: usize, pos: usize) usize {
    if (pos >= inp_len) return pos + 1;
    const byte = inp[pos];
    if (byte < 0x80) return pos + 1;
    const seq_len = std.unicode.utf8ByteSequenceLength(byte) catch return pos + 1;
    return pos + seq_len;
}

pub fn stz_regex_has_match(h: ?*Regex) callconv(.c) c_int {
    return if (h) |r| (if (r.matched) @as(c_int, 1) else 0) else 0;
}

pub fn stz_regex_capture_count(h: ?*Regex) callconv(.c) c_int {
    return if (h) |r| @as(c_int, @intCast(r.all_captures.items.len)) else 0;
}

pub fn stz_regex_capture_start(h: ?*Regex, idx: c_int) callconv(.c) c_int {
    const r = h orelse return -1;
    if (idx < 1) return -1;
    const i: usize = @intCast(idx - 1);
    if (i >= r.all_captures.items.len) return -1;
    const s = r.all_captures.items[i].start;
    return if (s < 0) s else s + 1;
}

pub fn stz_regex_capture_end(h: ?*Regex, idx: c_int) callconv(.c) c_int {
    const r = h orelse return -1;
    if (idx < 1) return -1;
    const i: usize = @intCast(idx - 1);
    if (i >= r.all_captures.items.len) return -1;
    const e = r.all_captures.items[i].end;
    return if (e < 0) e else e + 1;
}

pub fn stz_regex_capture_text(h: ?*Regex, idx: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const r = h orelse return 0;
    if (idx < 1) return 0;
    const i: usize = @intCast(idx - 1);
    if (i >= r.all_captures.items.len) return 0;
    const c = r.all_captures.items[i];
    if (c.start < 0 or c.end < 0) return 0;
    const s: usize = @intCast(c.start);
    const e: usize = @intCast(c.end);
    if (s >= e or e > r.input.len) return 0;
    const t = r.input[s..e];
    if (t.len > buf_len) return 0;
    @memcpy(buf[0..t.len], t);
    return t.len;
}

// ─── Named group access (new PCRE2 feature) ───

pub fn stz_regex_capture_by_name(h: ?*Regex, name: [*c]const u8, name_len: usize, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const r = h orelse return 0;
    if (name == null or name_len == 0) return 0;
    if (!r.matched) return 0;

    const group_num = pcre2.pcre2_substring_number_from_name_8(r.code, name);
    if (group_num < 0) return 0;

    const idx: usize = @intCast(group_num);
    if (idx >= r.all_captures.items.len) return 0;
    const c = r.all_captures.items[idx];
    if (c.start < 0 or c.end < 0) return 0;
    const s: usize = @intCast(c.start);
    const e: usize = @intCast(c.end);
    if (s >= e or e > r.input.len) return 0;
    const t = r.input[s..e];
    if (t.len > buf_len) return 0;
    @memcpy(buf[0..t.len], t);
    return t.len;
}

pub fn stz_regex_named_group_count(h: ?*Regex) callconv(.c) c_int {
    const r = h orelse return 0;
    var name_count: u32 = 0;
    const rc = pcre2.pcre2_pattern_info_8(r.code, pcre2.PCRE2_INFO_NAMECOUNT, &name_count);
    if (rc != 0) return 0;
    return @intCast(name_count);
}

pub fn stz_regex_named_group_name(h: ?*Regex, idx: c_int, buf: [*c]u8, buf_len: usize) callconv(.c) usize {
    const r = h orelse return 0;
    if (idx < 1) return 0;

    var name_count: u32 = 0;
    if (pcre2.pcre2_pattern_info_8(r.code, pcre2.PCRE2_INFO_NAMECOUNT, &name_count) != 0) return 0;
    if (@as(u32, @intCast(idx)) > name_count) return 0;

    var name_entry_size: u32 = 0;
    if (pcre2.pcre2_pattern_info_8(r.code, pcre2.PCRE2_INFO_NAMEENTRYSIZE, &name_entry_size) != 0) return 0;

    var nametable_ptr: [*]const u8 = undefined;
    if (pcre2.pcre2_pattern_info_8(r.code, pcre2.PCRE2_INFO_NAMETABLE, @ptrCast(&nametable_ptr)) != 0) return 0;

    const entry_offset = @as(usize, @intCast(idx - 1)) * @as(usize, name_entry_size);
    const entry = nametable_ptr + entry_offset;
    const name_start = entry + 2;
    var name_len: usize = 0;
    while (name_len < name_entry_size - 3 and name_start[name_len] != 0) : (name_len += 1) {}
    if (name_len == 0 or name_len > buf_len) return 0;
    @memcpy(buf[0..name_len], name_start[0..name_len]);
    return name_len;
}

pub fn stz_regex_partial_match(h: ?*Regex, inp: [*c]const u8, inp_len: usize, start: usize) callconv(.c) c_int {
    const r = h orelse return 0;
    if (inp == null) return 0;
    if (inp_len > r.max_input_len) return 0;
    r.input = inp[0..inp_len];
    r.all_captures.clearRetainingCapacity();

    const rc = pcre2.pcre2_match_8(r.code, inp, inp_len, start, pcre2.PCRE2_PARTIAL_SOFT, r.match_data, r.match_ctx);
    if (rc == pcre2.PCRE2_ERROR_PARTIAL) {
        r.matched = false;
        const ovector = pcre2.pcre2_get_ovector_pointer_8(r.match_data);
        r.all_captures.append(gpa, .{ .start = @intCast(ovector[0]), .end = @intCast(ovector[1]) }) catch {};
        return 2;
    }
    if (rc < 0) {
        r.matched = false;
        return 0;
    }
    r.matched = true;
    const ovector = pcre2.pcre2_get_ovector_pointer_8(r.match_data);
    const pair_count: usize = @intCast(rc);
    var i: usize = 0;
    while (i < pair_count) : (i += 1) {
        const s = ovector[i * 2];
        const e = ovector[i * 2 + 1];
        if (s == std.math.maxInt(usize)) {
            r.all_captures.append(gpa, .{ .start = -1, .end = -1 }) catch {};
        } else {
            r.all_captures.append(gpa, .{ .start = @intCast(s), .end = @intCast(e) }) catch {};
        }
    }
    return 1;
}

// ─── Replace with backreference support ($1, $2, ${name}) ───

pub fn stz_regex_replace(h: ?*Regex, inp: [*c]const u8, inp_len: usize, repl: [*c]const u8, repl_len: usize, out_len: *usize) callconv(.c) [*c]u8 {
    out_len.* = 0;
    const r = h orelse return null;
    if (inp == null or inp_len == 0) return null;
    if (inp_len > r.max_input_len) return null;

    const rep = if (repl != null and repl_len > 0) repl[0..repl_len] else "";
    const text = inp[0..inp_len];

    var res: std.ArrayList(u8) = .{};
    var pos: usize = 0;
    // Validate UTF-8 once, then skip re-validation on every subsequent match
    // over the same subject (else replace-all is O(matches * input_len)).
    var opts: u32 = 0;

    while (pos <= inp_len) {
        const rc = pcre2.pcre2_match_8(r.code, inp, inp_len, pos, opts, r.match_data, r.match_ctx);
        opts = pcre2.PCRE2_NO_UTF_CHECK;
        if (rc < 0) {
            res.appendSlice(gpa, text[pos..]) catch { res.deinit(gpa); return null; };
            break;
        }

        const ovector = pcre2.pcre2_get_ovector_pointer_8(r.match_data);
        const match_start = ovector[0];
        const match_end = ovector[1];

        res.appendSlice(gpa, text[pos..match_start]) catch { res.deinit(gpa); return null; };
        expandReplacement(&res, rep, text, ovector, @intCast(rc), r.code) catch { res.deinit(gpa); return null; };

        if (match_end == match_start) {
            if (pos >= inp_len) {
                break;
            }
            const next = nextCharPos(inp, inp_len, pos);
            res.appendSlice(gpa, text[pos..next]) catch { res.deinit(gpa); return null; };
            pos = next;
        } else {
            pos = match_end;
        }
    }

    out_len.* = res.items.len;
    const buf = gpa.alloc(u8, res.items.len) catch { res.deinit(gpa); return null; };
    @memcpy(buf, res.items);
    res.deinit(gpa);
    return buf.ptr;
}

fn expandReplacement(res: *std.ArrayList(u8), repl: []const u8, text: []const u8, ovector: [*]usize, pair_count: usize, code: *pcre2.pcre2_code_8) !void {
    _ = code;
    var i: usize = 0;
    while (i < repl.len) {
        if (repl[i] == '$' and i + 1 < repl.len) {
            if (repl[i + 1] == '$') {
                try res.append(gpa, '$');
                i += 2;
                continue;
            }
            if (repl[i + 1] >= '0' and repl[i + 1] <= '9') {
                var num: usize = 0;
                var j = i + 1;
                while (j < repl.len and repl[j] >= '0' and repl[j] <= '9') : (j += 1) {
                    num = num * 10 + @as(usize, repl[j] - '0');
                }
                if (num < pair_count) {
                    const s = ovector[num * 2];
                    const e = ovector[num * 2 + 1];
                    if (s != std.math.maxInt(usize) and e != std.math.maxInt(usize) and s <= e and e <= text.len) {
                        try res.appendSlice(gpa, text[s..e]);
                    }
                }
                i = j;
                continue;
            }
            if (repl[i + 1] == '{') {
                if (mem.indexOfScalar(u8, repl[i + 2 ..], '}')) |close_off| {
                    const name_slice = repl[i + 2 .. i + 2 + close_off];
                    var is_numeric = true;
                    for (name_slice) |ch| {
                        if (ch < '0' or ch > '9') { is_numeric = false; break; }
                    }
                    if (is_numeric and name_slice.len > 0) {
                        var num: usize = 0;
                        for (name_slice) |ch| {
                            num = num * 10 + @as(usize, ch - '0');
                        }
                        if (num < pair_count) {
                            const s = ovector[num * 2];
                            const e = ovector[num * 2 + 1];
                            if (s != std.math.maxInt(usize) and e != std.math.maxInt(usize) and s <= e and e <= text.len) {
                                try res.appendSlice(gpa, text[s..e]);
                            }
                        }
                    }
                    i = i + 2 + close_off + 1;
                    continue;
                }
            }
        }
        if (repl[i] == '\\' and i + 1 < repl.len and repl[i + 1] >= '1' and repl[i + 1] <= '9') {
            const num: usize = @as(usize, repl[i + 1] - '0');
            if (num < pair_count) {
                const s = ovector[num * 2];
                const e = ovector[num * 2 + 1];
                if (s != std.math.maxInt(usize) and e != std.math.maxInt(usize) and s <= e and e <= text.len) {
                    try res.appendSlice(gpa, text[s..e]);
                }
            }
            i += 2;
            continue;
        }
        try res.append(gpa, repl[i]);
        i += 1;
    }
}

pub fn stz_regex_replace_free(ptr: [*c]u8, len: usize) callconv(.c) void {
    if (ptr != null and len > 0) gpa.free(ptr[0..len]);
}

// ─── Tests ───

test "literal match" {
    const h = stz_regex_new("hello", 5, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "say hello world", 15, 0));
    try std.testing.expectEqual(@as(c_int, 5), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 10), stz_regex_capture_end(h, 1));
}

test "dot and star" {
    const h = stz_regex_new("h.*o", 4, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "hello", 5, 0));
}

test "char class" {
    const h = stz_regex_new("[abc]+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "xxbcaxx", 7, 0));
    try std.testing.expectEqual(@as(c_int, 3), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 6), stz_regex_capture_end(h, 1));
}

test "anchors" {
    const h = stz_regex_new("^hello$", 7, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_match(h, "say hello", 9, 0));
}

test "capture group" {
    const h = stz_regex_new("(\\d+)-(\\d+)", 11, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "val 123-456 end", 15, 0));
    try std.testing.expect(stz_regex_capture_count(h) >= 3);
}

test "case insensitive" {
    const h = stz_regex_new("hello", 5, FLAG_CASE_I) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "HELLO", 5, 0));
}

test "alternation in group" {
    const h = stz_regex_new("(cat|dog)", 9, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "I have a dog", 12, 0));
}

test "escape sequences" {
    const h = stz_regex_new("\\d+", 3, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc123def", 9, 0));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 7), stz_regex_capture_end(h, 1));
}

test "lazy quantifier" {
    const h1 = stz_regex_new("<.*>", 4, 0) orelse unreachable;
    defer stz_regex_free(h1);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h1, "<a><b>", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h1, 1));
    try std.testing.expectEqual(@as(c_int, 7), stz_regex_capture_end(h1, 1));

    const h2 = stz_regex_new("<.*?>", 5, 0) orelse unreachable;
    defer stz_regex_free(h2);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h2, "<a><b>", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h2, 1));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_end(h2, 1));
}

test "lazy plus" {
    const h = stz_regex_new("a+?", 3, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "aaaa", 4, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 2), stz_regex_capture_end(h, 1));
}

test "unicode property \\p{L}" {
    const h = stz_regex_new("\\p{L}+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc123", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_end(h, 1));
}

test "unicode property \\p{N}" {
    const h = stz_regex_new("\\p{N}+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc123", 6, 0));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 7), stz_regex_capture_end(h, 1));
}

test "unicode property negated \\P{L}" {
    const h = stz_regex_new("\\P{L}+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc 123", 7, 0));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_start(h, 1));
}

test "match limit exhaustion" {
    const h = stz_regex_new("(a+)+$", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    stz_regex_set_limits(h, 1, 0, 0);
    const result = stz_regex_match(h, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaab", 30, 0);
    try std.testing.expectEqual(@as(c_int, 0), result);
}

test "pattern length limit" {
    const long_pat = "a" ** (MAX_PATTERN_LEN + 1);
    const h = stz_regex_new(long_pat.ptr, long_pat.len, 0);
    try std.testing.expect(h == null);
}

test "input length limit" {
    const h = stz_regex_new("a", 1, 0) orelse unreachable;
    defer stz_regex_free(h);
    h.max_input_len = 10;
    const long_input = "a" ** 20;
    const result = stz_regex_match(h, long_input.ptr, long_input.len, 0);
    try std.testing.expectEqual(@as(c_int, 0), result);
}

test "utf8 dot matches multibyte" {
    const h = stz_regex_new(".+", 2, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "caf\xC3\xA9", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 6), stz_regex_capture_end(h, 1));
}

test "utf8 \\p{L} matches unicode letters" {
    const h = stz_regex_new("\\p{L}+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "\xCE\xB1\xCE\xB2\xCE\xB3", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 7), stz_regex_capture_end(h, 1));
}

test "utf8 \\w matches unicode word chars" {
    const h = stz_regex_new("\\w+", 3, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "\xD8\xA7\xD8\xA8\xD8\xAA", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 7), stz_regex_capture_end(h, 1));
}

test "utf8 mixed ascii and unicode" {
    const h = stz_regex_new("\\p{L}+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc\xC3\xA9def", 8, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 9), stz_regex_capture_end(h, 1));
}

test "utf8 \\P{L} skips unicode letters" {
    const h = stz_regex_new("\\P{L}+", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc 123", 7, 0));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 8), stz_regex_capture_end(h, 1));
}

test "utf8 category subcategory Lu" {
    const h = stz_regex_new("\\p{Lu}+", 7, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "ABCdef", 6, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 4), stz_regex_capture_end(h, 1));
}

// ─── New PCRE2 feature tests ───

test "word boundary \\b" {
    const h = stz_regex_new("\\bword\\b", 8, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "a word here", 11, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_match(h, "awordhere", 9, 0));
}

test "non-capturing group" {
    const h = stz_regex_new("(?:abc)(def)", 12, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abcdef", 6, 0));
    try std.testing.expectEqual(@as(c_int, 2), stz_regex_capture_count(h));
    var buf: [32]u8 = undefined;
    const len = stz_regex_capture_text(h, 2, &buf, 32);
    try std.testing.expectEqualStrings("def", buf[0..len]);
}

test "counted quantifier {n,m}" {
    const h = stz_regex_new("a{2,4}", 6, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "aaa", 3, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_match(h, "a", 1, 0));
}

test "lookahead" {
    const h = stz_regex_new("\\w+(?=\\d)", 9, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "abc3", 4, 0));
    var buf: [32]u8 = undefined;
    const len = stz_regex_capture_text(h, 1, &buf, 32);
    try std.testing.expectEqualStrings("abc", buf[0..len]);
}

test "negative lookahead" {
    const h = stz_regex_new("\\d+(?!\\d)", 9, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "123x", 4, 0));
}

test "lookbehind" {
    const h = stz_regex_new("(?<=@)\\w+", 9, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "user@host", 9, 0));
    var buf: [32]u8 = undefined;
    const len = stz_regex_capture_text(h, 1, &buf, 32);
    try std.testing.expectEqualStrings("host", buf[0..len]);
}

test "named group" {
    const h = stz_regex_new("(?P<year>\\d{4})-(?P<month>\\d{2})", 32, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "2026-05", 7, 0));
    var buf: [32]u8 = undefined;
    const len1 = stz_regex_capture_by_name(h, "year", 4, &buf, 32);
    try std.testing.expectEqualStrings("2026", buf[0..len1]);
    const len2 = stz_regex_capture_by_name(h, "month", 5, &buf, 32);
    try std.testing.expectEqualStrings("05", buf[0..len2]);
}

test "backreference" {
    const h = stz_regex_new("(\\w+) \\1", 8, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "hello hello", 11, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_match(h, "hello world", 11, 0));
}

test "multiline mode" {
    const h = stz_regex_new("^line2$", 7, FLAG_MULTILINE) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "line1\nline2\nline3", 17, 0));

    const h2 = stz_regex_new("^line2$", 7, 0) orelse unreachable;
    defer stz_regex_free(h2);
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_match(h2, "line1\nline2\nline3", 17, 0));
}

test "replace with backreference $1" {
    const h = stz_regex_new("(\\w+)@(\\w+)", 11, 0) orelse unreachable;
    defer stz_regex_free(h);
    var out_len: usize = 0;
    const ptr = stz_regex_replace(h, "user@host", 9, "[$1 at $2]", 10, &out_len);
    defer stz_regex_replace_free(ptr, out_len);
    try std.testing.expect(ptr != null);
    try std.testing.expectEqualStrings("[user at host]", ptr[0..out_len]);
}

test "replace with backslash backreference \\1" {
    const h = stz_regex_new("(\\w+)@(\\w+)", 11, 0) orelse unreachable;
    defer stz_regex_free(h);
    var out_len: usize = 0;
    const ptr = stz_regex_replace(h, "user@host", 9, "\\1_\\2", 5, &out_len);
    defer stz_regex_replace_free(ptr, out_len);
    try std.testing.expect(ptr != null);
    try std.testing.expectEqualStrings("user_host", ptr[0..out_len]);
}

test "match_all basic" {
    const h = stz_regex_new("\\d+", 3, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 3), stz_regex_match_all(h, "a1b22c333", 9));
}

test "unicode script \\p{Greek}" {
    const h = stz_regex_new("\\p{Greek}+", 10, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "\xCE\xB1\xCE\xB2\xCE\xB3", 6, 0));
}

test "unicode script \\p{Arabic}" {
    const h = stz_regex_new("\\p{Arabic}+", 11, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "\xD8\xA7\xD8\xA8", 4, 0));
}

test "recursion (?R)" {
    const h = stz_regex_new("\\((?:[^()]*|(?R))*\\)", 20, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_match(h, "(a(b)c)", 7, 0));
    try std.testing.expectEqual(@as(c_int, 1), stz_regex_capture_start(h, 1));
    try std.testing.expectEqual(@as(c_int, 8), stz_regex_capture_end(h, 1));
}

test "named_group_name enumerates names" {
    const h = stz_regex_new("(?P<year>\\d{4})-(?P<month>\\d{2})", 32, 0) orelse unreachable;
    defer stz_regex_free(h);
    try std.testing.expectEqual(@as(c_int, 2), stz_regex_named_group_count(h));
    var buf: [64]u8 = undefined;
    const len1 = stz_regex_named_group_name(h, 1, &buf, 64);
    try std.testing.expect(len1 > 0);
    const len2 = stz_regex_named_group_name(h, 2, &buf, 64);
    try std.testing.expect(len2 > 0);
    try std.testing.expectEqual(@as(usize, 0), stz_regex_named_group_name(h, 3, &buf, 64));
}

test "partial match returns 2" {
    const h = stz_regex_new("^\\d{4}-\\d{2}-\\d{2}$", 18, 0) orelse unreachable;
    defer stz_regex_free(h);
    const full = stz_regex_partial_match(h, "2026-05-20", 10, 0);
    try std.testing.expectEqual(@as(c_int, 1), full);
    const partial = stz_regex_partial_match(h, "2026-05", 7, 0);
    try std.testing.expectEqual(@as(c_int, 2), partial);
    const none = stz_regex_partial_match(h, "abcdef", 6, 0);
    try std.testing.expectEqual(@as(c_int, 0), none);
}

test "null handle safety" {
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_match(null, "a", 1, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_has_match(null));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_capture_count(null));
    try std.testing.expectEqual(@as(c_int, -1), stz_regex_capture_start(null, 1));
    try std.testing.expectEqual(@as(c_int, -1), stz_regex_capture_end(null, 1));
    try std.testing.expectEqual(@as(usize, 0), stz_regex_capture_text(null, 1, undefined, 0));
    try std.testing.expectEqual(@as(usize, 0), stz_regex_capture_by_name(null, "x", 1, undefined, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_named_group_count(null));
    try std.testing.expectEqual(@as(usize, 0), stz_regex_named_group_name(null, 1, undefined, 0));
    try std.testing.expectEqual(@as(c_int, 0), stz_regex_partial_match(null, "a", 1, 0));
}
