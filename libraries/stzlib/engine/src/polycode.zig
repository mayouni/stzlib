const std = @import("std");

// ─── Polycode Multi-Representation ───
// Store same concept in multiple code representations (Ring, Zig, Python, etc).

const MAX_CONCEPTS: usize = 128;
const MAX_LANGS_PER_CONCEPT: usize = 16;
const MAX_KEY: usize = 64;
const MAX_CODE: usize = 512;

const CodeRep = struct {
    lang: [MAX_KEY]u8 = undefined,
    lang_len: usize = 0,
    code: [MAX_CODE]u8 = undefined,
    code_len: usize = 0,
};

const Concept = struct {
    key: [MAX_KEY]u8 = undefined,
    key_len: usize = 0,
    representations: [MAX_LANGS_PER_CONCEPT]CodeRep = [_]CodeRep{.{}} ** MAX_LANGS_PER_CONCEPT,
    lang_count: usize = 0,
    active: bool = false,
};

var concepts: [MAX_CONCEPTS]Concept = [_]Concept{.{}} ** MAX_CONCEPTS;
var concept_count: usize = 0;

fn findConcept(key: []const u8) ?usize {
    for (0..MAX_CONCEPTS) |i| {
        if (concepts[i].active and concepts[i].key_len == key.len and
            std.mem.eql(u8, concepts[i].key[0..concepts[i].key_len], key))
            return i;
    }
    return null;
}

fn findOrCreateConcept(key: []const u8) ?usize {
    if (findConcept(key)) |idx| return idx;
    if (concept_count >= MAX_CONCEPTS) return null;
    for (0..MAX_CONCEPTS) |i| {
        if (!concepts[i].active) {
            const kl = @min(key.len, MAX_KEY);
            @memcpy(concepts[i].key[0..kl], key[0..kl]);
            concepts[i].key_len = kl;
            concepts[i].lang_count = 0;
            concepts[i].active = true;
            concept_count += 1;
            return i;
        }
    }
    return null;
}

// ─── C ABI ───

pub export fn stz_pc_register(concept: [*]const u8, con_len: usize, lang: [*]const u8, lang_len: usize, code: [*]const u8, code_len: usize) i32 {
    const ci = findOrCreateConcept(concept[0..con_len]) orelse return -1;
    // update if lang already exists
    for (0..concepts[ci].lang_count) |j| {
        if (concepts[ci].representations[j].lang_len == lang_len and
            std.mem.eql(u8, concepts[ci].representations[j].lang[0..concepts[ci].representations[j].lang_len], lang[0..lang_len]))
        {
            const cl = @min(code_len, MAX_CODE);
            @memcpy(concepts[ci].representations[j].code[0..cl], code[0..cl]);
            concepts[ci].representations[j].code_len = cl;
            return 0;
        }
    }
    if (concepts[ci].lang_count >= MAX_LANGS_PER_CONCEPT) return -1;
    const slot = concepts[ci].lang_count;
    const ll = @min(lang_len, MAX_KEY);
    @memcpy(concepts[ci].representations[slot].lang[0..ll], lang[0..ll]);
    concepts[ci].representations[slot].lang_len = ll;
    const cl = @min(code_len, MAX_CODE);
    @memcpy(concepts[ci].representations[slot].code[0..cl], code[0..cl]);
    concepts[ci].representations[slot].code_len = cl;
    concepts[ci].lang_count += 1;
    return 0;
}

pub export fn stz_pc_get_code(concept: [*]const u8, con_len: usize, lang: [*]const u8, lang_len: usize, out: [*]u8) i32 {
    const ci = findConcept(concept[0..con_len]) orelse return 0;
    for (0..concepts[ci].lang_count) |j| {
        if (concepts[ci].representations[j].lang_len == lang_len and
            std.mem.eql(u8, concepts[ci].representations[j].lang[0..concepts[ci].representations[j].lang_len], lang[0..lang_len]))
        {
            const len = concepts[ci].representations[j].code_len;
            @memcpy(out[0..len], concepts[ci].representations[j].code[0..len]);
            return @intCast(len);
        }
    }
    return 0;
}

pub export fn stz_pc_has_concept(concept: [*]const u8, con_len: usize) i32 {
    if (findConcept(concept[0..con_len])) |_| return 1;
    return 0;
}

pub export fn stz_pc_lang_count(concept: [*]const u8, con_len: usize) i32 {
    const ci = findConcept(concept[0..con_len]) orelse return 0;
    return @intCast(concepts[ci].lang_count);
}

pub export fn stz_pc_concept_count() i32 {
    return @intCast(concept_count);
}

pub export fn stz_pc_clear() void {
    for (0..MAX_CONCEPTS) |i| {
        concepts[i].active = false;
        concepts[i].lang_count = 0;
    }
    concept_count = 0;
}

// ─── Tests ───

test "register and get code" {
    stz_pc_clear();
    const code_ring = "? 'Hello'";
    const code_zig = "std.debug.print(\"Hello\", .{});";
    _ = stz_pc_register("print_hello", 11, "ring", 4, code_ring, code_ring.len);
    _ = stz_pc_register("print_hello", 11, "zig", 3, code_zig, code_zig.len);
    var buf: [512]u8 = undefined;
    const len = stz_pc_get_code("print_hello", 11, "ring", 4, &buf);
    try std.testing.expectEqual(@as(i32, @intCast(code_ring.len)), len);
    try std.testing.expectEqualSlices(u8, code_ring, buf[0..@intCast(len)]);
    stz_pc_clear();
}

test "has concept" {
    stz_pc_clear();
    _ = stz_pc_register("loop", 4, "py", 2, "for i in range(10):", 19);
    try std.testing.expectEqual(@as(i32, 1), stz_pc_has_concept("loop", 4));
    try std.testing.expectEqual(@as(i32, 0), stz_pc_has_concept("xyz", 3));
    stz_pc_clear();
}

test "lang count" {
    stz_pc_clear();
    _ = stz_pc_register("add", 3, "ring", 4, "x+y", 3);
    _ = stz_pc_register("add", 3, "zig", 3, "x+y", 3);
    _ = stz_pc_register("add", 3, "py", 2, "x+y", 3);
    try std.testing.expectEqual(@as(i32, 3), stz_pc_lang_count("add", 3));
    stz_pc_clear();
}

test "concept count" {
    stz_pc_clear();
    _ = stz_pc_register("a", 1, "en", 2, "x", 1);
    _ = stz_pc_register("b", 1, "en", 2, "y", 1);
    try std.testing.expectEqual(@as(i32, 2), stz_pc_concept_count());
    stz_pc_clear();
}

test "get code missing returns 0" {
    stz_pc_clear();
    var buf: [512]u8 = undefined;
    const len = stz_pc_get_code("none", 4, "en", 2, &buf);
    try std.testing.expectEqual(@as(i32, 0), len);
}
