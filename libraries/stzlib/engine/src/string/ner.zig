// Softanza Engine -- Named-entity recognition (POS-driven, gazetteer + rules)
//
// Extracts PERSON / ORGANIZATION / LOCATION / (generic) ENTITY mentions. This is
// the CLASSICAL rule-based NER that composes the layers already built: it POS-
// tags (pos.zig), chunks maximal proper-noun (NNP/NNPS) runs, then classifies
// each chunk from gazetteers (embedded first-names + place names) and contextual
// rules (person titles, org keywords). Deterministic, self-contained, no ML
// model. A statistical/neural NER (CRF / transformer) is the modern-tier upgrade;
// this is the practical, zero-dependency baseline.
//
// Gazetteers (src/string/data, @embedFile): ner_firstnames.txt (NLTK names,
// public domain), ner_places.txt (countries/capitals + major cities).

const std = @import("std");
const core = @import("core.zig");
const wb = @import("word_break.zig");
const pos = @import("pos.zig");
const mem = core.mem;
const gpa = core.gpa;
const StzStringHandle = core.StzStringHandle;
const str_new = core.str_new;

const firstnames_data = @embedFile("data/ner_firstnames.txt");
const places_data = @embedFile("data/ner_places.txt");

var g_built = false;
var g_firstnames: std.StringHashMap(void) = undefined;
var g_places: std.StringHashMap(void) = undefined;

fn buildSets() void {
    if (g_built) return;
    g_firstnames = std.StringHashMap(void).init(gpa);
    g_places = std.StringHashMap(void).init(gpa);
    var fi = std.mem.splitScalar(u8, firstnames_data, '\n');
    while (fi.next()) |raw| {
        const w = std.mem.trimRight(u8, raw, "\r");
        if (w.len > 0) g_firstnames.put(w, {}) catch {};
    }
    var pi = std.mem.splitScalar(u8, places_data, '\n');
    while (pi.next()) |raw| {
        const w = std.mem.trimRight(u8, raw, "\r");
        if (w.len > 0) g_places.put(w, {}) catch {};
    }
    g_built = true;
}

fn eqAny(w: []const u8, comptime list: []const []const u8) bool {
    inline for (list) |x| {
        if (mem.eql(u8, w, x)) return true;
    }
    return false;
}

fn isTitle(w: []const u8) bool {
    return eqAny(w, &.{ "mr", "mrs", "ms", "miss", "mister", "sir", "madam", "madame", "dr", "prof", "professor", "president", "vice-president", "senator", "governor", "mayor", "king", "queen", "prince", "princess", "lady", "lord", "duke", "duchess", "captain", "colonel", "general", "major", "sergeant", "lieutenant", "admiral", "rev", "reverend", "father", "saint", "st", "pope", "emperor", "chancellor", "premier", "minister", "secretary", "judge", "justice", "chairman", "ceo" });
}

fn isOrgKeyword(w: []const u8) bool {
    return eqAny(w, &.{ "inc", "corp", "corporation", "ltd", "limited", "llc", "co", "company", "group", "holdings", "university", "college", "institute", "school", "academy", "association", "foundation", "society", "club", "council", "committee", "ministry", "department", "bureau", "agency", "commission", "party", "bank", "airlines", "airways", "motors", "systems", "technologies", "partners", "associates", "industries", "enterprises", "international", "national", "federation", "union", "league", "organization", "organisation" });
}

// Name particles / "of" only -- NOT "and"/"&"/"the" (those over-merge separate
// entities, e.g. "Microsoft and Apple").
fn isConnector(w: []const u8) bool {
    return eqAny(w, &.{ "of", "de", "van", "der", "di", "da", "la", "le", "bin", "al" });
}

fn isProper(tag: []const u8) bool {
    return mem.eql(u8, tag, "NNP") or mem.eql(u8, tag, "NNPS");
}

// lowercase ASCII into buf
fn lower(w: []const u8, buf: []u8) []const u8 {
    if (w.len > buf.len) return w;
    for (w, 0..) |c, i| buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    return buf[0..w.len];
}

// Emit "text\x01TYPE" for one entity into `out` (NUL-separated across entities).
fn emit(out: *std.ArrayList(u8), first: *bool, text: []const u8, typ: []const u8) void {
    if (!first.*) out.append(gpa, 0) catch return;
    out.appendSlice(gpa, text) catch return;
    out.append(gpa, 0x01) catch return;
    out.appendSlice(gpa, typ) catch return;
    first.* = false;
}

const Span = struct { start: usize, end: usize };

// Named entities packed as "text\x01TYPE", entities NUL-delimited.
pub fn str_named_entities(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    const s = handle orelse return result;
    buildSets();
    const src = s.slice();

    var toks: std.ArrayList([]const u8) = .{};
    defer toks.deinit(gpa);
    var spans: std.ArrayList(Span) = .{};
    defer spans.deinit(gpa);
    {
        var wit = wb.WordIter.init(src);
        while (wit.next()) |sp| {
            toks.append(gpa, src[sp.start..sp.end]) catch {};
            spans.append(gpa, .{ .start = sp.start, .end = sp.end }) catch {};
        }
    }
    const n = toks.items.len;
    if (n == 0) return result;

    const tags = pos.tagTokens(toks.items) orelse return result;
    defer gpa.free(tags);

    var lbuf: [128]u8 = undefined;
    var tbuf: [256]u8 = undefined;
    var first = true;
    var i: usize = 0;
    while (i < n) {
        if (!isProper(tags[i])) {
            i += 1;
            continue;
        }
        // extend the proper-noun chunk, allowing connectors between NNPs
        var last = i;
        var j = i;
        while (j + 1 < n) {
            if (isProper(tags[j + 1])) {
                j += 1;
                last = j;
            } else if (isConnector(lower(toks.items[j + 1], &lbuf)) and j + 2 < n and isProper(tags[j + 2])) {
                j += 2;
                last = j;
            } else break;
        }
        // A title before the chunk ("met President Macron") OR absorbed as the
        // chunk's leading token(s) ("President" tagged NNP) => PERSON; strip the
        // title from the entity text.
        var was_title = i > 0 and isTitle(lower(toks.items[i - 1], &lbuf));
        var estart = i;
        while (estart <= last and isTitle(lower(toks.items[estart], &lbuf))) {
            estart += 1;
            was_title = true;
        }
        if (estart > last) { // chunk was only titles, no actual name
            i = last + 1;
            continue;
        }
        const text = src[spans.items[estart].start..spans.items[last].end];

        // classify
        var typ: []const u8 = "ENTITY";
        if (was_title) {
            typ = "PERSON";
        } else blk: {
            // org keyword anywhere in the chunk?
            var k = estart;
            while (k <= last) : (k += 1) {
                if (isOrgKeyword(lower(toks.items[k], &lbuf))) {
                    typ = "ORGANIZATION";
                    break :blk;
                }
            }
            // whole entity text a known place?
            if (g_places.contains(lower(text, &tbuf))) {
                typ = "LOCATION";
                break :blk;
            }
            // head token a known first name -> person
            if (g_firstnames.contains(lower(toks.items[estart], &lbuf))) {
                typ = "PERSON";
                break :blk;
            }
        }
        emit(&result.data, &first, text, typ);
        i = last + 1;
    }
    return result;
}

const testing = std.testing;
const str_from = core.str_from;
const str_free = core.str_free;

test "ner classifies person/org/location" {
    const s = str_from("Barack Obama visited Google in France", 37) orelse return error.SkipZigTest;
    defer str_free(s);
    const r = str_named_entities(s) orelse return error.SkipZigTest;
    defer str_free(r);
    try testing.expect(mem.indexOf(u8, r.slice(), "Barack Obama\x01PERSON") != null);
    try testing.expect(mem.indexOf(u8, r.slice(), "France\x01LOCATION") != null);
}
