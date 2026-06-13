// Pragmatic HTML tokenizer + flat element index.
//
// Goal: cover ~80% of stzHtml.ring usage (text extraction, find-by-tag,
// attribute lookup) without depending on the lexbor-based html.ring
// extension. NOT a spec-compliant HTML5 parser -- enough for typical
// well-formed input.
//
// Supported:
// * <tag attr="val" attr='val' attr=bare attr-only> ... </tag>
// * <tag .../>            self-closing
// * <!-- comment -->      skipped
// * <!DOCTYPE ...>        skipped
// * <script>...</script>  body kept as raw text
// * <style>...</style>    body kept as raw text
// * Text content between tags
//
// NOT supported (yet):
// * CSS selectors (only find-by-tag, find-by-id, find-by-class)
// * Nested DOM tree (flat element list only; depth recorded)
// * Mutation API
// * Entity decoding inside text (consumer can call html_decode on the
//   extracted text if needed)

const std = @import("std");

const gpa = std.heap.c_allocator;

pub const Attr = struct {
    name_off: u32,
    name_len: u32,
    val_off: u32,
    val_len: u32,
};

pub const Element = struct {
    tag_off: u32,
    tag_len: u32,
    content_off: u32,     // first byte after the `>` of the start tag
    content_len: u32,     // bytes until the `<` of the end tag (or 0 if self-closing)
    depth: u32,
    attrs_off: u32,       // index into doc.attrs
    attrs_count: u32,
};

pub const Doc = struct {
    source: []u8,
    elements: []Element,
    attrs: []Attr,
};

// ── public C ABI ─────────────────────────────────────────────

/// Parse src[0..len] and return an opaque handle (owned by Zig).
/// Returns null on OOM / empty input.
pub fn html_parse(src_ptr: [*]const u8, src_len: usize) callconv(.c) ?*Doc {
    if (src_len == 0) return null;
    return parseInner(src_ptr[0..src_len]) catch null;
}

pub fn html_free(doc_opt: ?*Doc) callconv(.c) void {
    const doc = doc_opt orelse return;
    gpa.free(doc.source);
    gpa.free(doc.elements);
    gpa.free(doc.attrs);
    gpa.destroy(doc);
}

/// Total element count.
pub fn html_count(doc_opt: ?*Doc) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    return @intCast(doc.elements.len);
}

/// Count elements with a given tag (case-insensitive).
pub fn html_count_by_tag(
    doc_opt: ?*Doc,
    tag_ptr: [*]const u8,
    tag_len: usize,
) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    if (tag_len == 0) return 0;
    const tag = tag_ptr[0..tag_len];
    var n: i32 = 0;
    for (doc.elements) |e| {
        if (eqIgnoreCase(doc.source[e.tag_off .. e.tag_off + e.tag_len], tag)) n += 1;
    }
    return n;
}

/// Get inner text of the n-th (1-based) occurrence of `tag`.
/// Writes up to `max` bytes into `out`; returns bytes written or -1 on overflow.
pub fn html_text_of_tag(
    doc_opt: ?*Doc,
    tag_ptr: [*]const u8,
    tag_len: usize,
    n: i32,
    out: [*]u8,
    max: usize,
) callconv(.c) i32 {
    const doc = doc_opt orelse return -1;
    if (tag_len == 0 or n < 1) return -1;
    const tag = tag_ptr[0..tag_len];
    var hit: i32 = 0;
    for (doc.elements) |e| {
        if (eqIgnoreCase(doc.source[e.tag_off .. e.tag_off + e.tag_len], tag)) {
            hit += 1;
            if (hit == n) {
                const content = doc.source[e.content_off .. e.content_off + e.content_len];
                return extractText(content, out, max);
            }
        }
    }
    return -1;
}

/// Get attribute value for the n-th (1-based) occurrence of `tag`.
pub fn html_attr_of_tag(
    doc_opt: ?*Doc,
    tag_ptr: [*]const u8,
    tag_len: usize,
    n: i32,
    attr_ptr: [*]const u8,
    attr_len: usize,
    out: [*]u8,
    max: usize,
) callconv(.c) i32 {
    const doc = doc_opt orelse return -1;
    if (tag_len == 0 or attr_len == 0 or n < 1) return -1;
    const tag = tag_ptr[0..tag_len];
    const attr = attr_ptr[0..attr_len];
    var hit: i32 = 0;
    for (doc.elements) |e| {
        if (eqIgnoreCase(doc.source[e.tag_off .. e.tag_off + e.tag_len], tag)) {
            hit += 1;
            if (hit == n) {
                var i: u32 = 0;
                while (i < e.attrs_count) : (i += 1) {
                    const a = doc.attrs[e.attrs_off + i];
                    if (eqIgnoreCase(doc.source[a.name_off .. a.name_off + a.name_len], attr)) {
                        if (a.val_len > max) return -1;
                        @memcpy(out[0..a.val_len], doc.source[a.val_off .. a.val_off + a.val_len]);
                        return @intCast(a.val_len);
                    }
                }
                return 0;
            }
        }
    }
    return -1;
}

/// All visible text in the document.
pub fn html_all_text(doc_opt: ?*Doc, out: [*]u8, max: usize) callconv(.c) i32 {
    const doc = doc_opt orelse return -1;
    return extractText(doc.source, out, max);
}

/// Tag of the n-th element (1-based).
pub fn html_tag_of(doc_opt: ?*Doc, n: i32, out: [*]u8, max: usize) callconv(.c) i32 {
    const doc = doc_opt orelse return -1;
    if (n < 1 or @as(usize, @intCast(n)) > doc.elements.len) return -1;
    const e = doc.elements[@intCast(n - 1)];
    if (e.tag_len > max) return -1;
    @memcpy(out[0..e.tag_len], doc.source[e.tag_off .. e.tag_off + e.tag_len]);
    return @intCast(e.tag_len);
}

/// Find the first element whose `id` attribute equals `cid` (case-sensitive,
/// per HTML5 spec). Returns 1-based element index, or 0 if not found.
pub fn html_find_by_id(
    doc_opt: ?*Doc,
    id_ptr: [*]const u8,
    id_len: usize,
) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    if (id_len == 0) return 0;
    const id = id_ptr[0..id_len];
    for (doc.elements, 0..) |e, idx| {
        var i: u32 = 0;
        while (i < e.attrs_count) : (i += 1) {
            const a = doc.attrs[e.attrs_off + i];
            if (eqIgnoreCase(doc.source[a.name_off .. a.name_off + a.name_len], "id")) {
                if (std.mem.eql(u8, doc.source[a.val_off .. a.val_off + a.val_len], id)) {
                    return @intCast(idx + 1);
                }
            }
        }
    }
    return 0;
}

/// Count elements whose `class` attribute's space-separated list contains
/// `cclass` (case-sensitive class token match).
pub fn html_count_by_class(
    doc_opt: ?*Doc,
    class_ptr: [*]const u8,
    class_len: usize,
) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    if (class_len == 0) return 0;
    const class = class_ptr[0..class_len];
    var n: i32 = 0;
    for (doc.elements) |e| {
        if (elementHasClass(doc, e, class)) n += 1;
    }
    return n;
}

/// 1-based index of the n-th element with the given class.
pub fn html_find_by_class(
    doc_opt: ?*Doc,
    class_ptr: [*]const u8,
    class_len: usize,
    n: i32,
) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    if (class_len == 0 or n < 1) return 0;
    const class = class_ptr[0..class_len];
    var hit: i32 = 0;
    for (doc.elements, 0..) |e, idx| {
        if (elementHasClass(doc, e, class)) {
            hit += 1;
            if (hit == n) return @intCast(idx + 1);
        }
    }
    return 0;
}

fn elementHasClass(doc: *Doc, e: Element, class: []const u8) bool {
    var i: u32 = 0;
    while (i < e.attrs_count) : (i += 1) {
        const a = doc.attrs[e.attrs_off + i];
        if (eqIgnoreCase(doc.source[a.name_off .. a.name_off + a.name_len], "class")) {
            const list = doc.source[a.val_off .. a.val_off + a.val_len];
            var it = std.mem.tokenizeAny(u8, list, " \t\n\r");
            while (it.next()) |tok| {
                if (std.mem.eql(u8, tok, class)) return true;
            }
        }
    }
    return false;
}

/// Number of direct children of the n-th element (1-based).
pub fn html_children_count(doc_opt: ?*Doc, n: i32) callconv(.c) i32 {
    const doc = doc_opt orelse return -1;
    if (n < 1 or @as(usize, @intCast(n)) > doc.elements.len) return -1;
    const parent_idx: usize = @intCast(n - 1);
    const p = doc.elements[parent_idx];
    const content_end = p.content_off + p.content_len;
    var count: i32 = 0;
    for (doc.elements[parent_idx + 1 ..]) |e| {
        if (e.tag_off >= content_end) break;
        if (e.depth == p.depth + 1) count += 1;
    }
    return count;
}

/// 1-based index of the k-th direct child of the n-th element.
pub fn html_child_at(doc_opt: ?*Doc, n: i32, k: i32) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    if (n < 1 or k < 1 or @as(usize, @intCast(n)) > doc.elements.len) return 0;
    const parent_idx: usize = @intCast(n - 1);
    const p = doc.elements[parent_idx];
    const content_end = p.content_off + p.content_len;
    var hit: i32 = 0;
    for (doc.elements[parent_idx + 1 ..], parent_idx + 1..) |e, abs_idx| {
        if (e.tag_off >= content_end) break;
        if (e.depth == p.depth + 1) {
            hit += 1;
            if (hit == k) return @intCast(abs_idx + 1);
        }
    }
    return 0;
}

/// 1-based parent index of the n-th element, or 0 if root.
pub fn html_parent_of(doc_opt: ?*Doc, n: i32) callconv(.c) i32 {
    const doc = doc_opt orelse return 0;
    if (n < 1 or @as(usize, @intCast(n)) > doc.elements.len) return 0;
    const target_idx: usize = @intCast(n - 1);
    const t = doc.elements[target_idx];
    if (t.depth == 0) return 0;
    // Walk backwards: the nearest preceding element with depth == t.depth - 1
    // and whose content range contains t is the parent.
    var i: usize = target_idx;
    while (i > 0) {
        i -= 1;
        const e = doc.elements[i];
        if (e.depth == t.depth - 1) {
            const content_end = e.content_off + e.content_len;
            if (t.tag_off >= e.content_off and t.tag_off < content_end) {
                return @intCast(i + 1);
            }
        }
    }
    return 0;
}

// ── parser internals ─────────────────────────────────────────

fn parseInner(input: []const u8) !*Doc {
    const doc = try gpa.create(Doc);
    errdefer gpa.destroy(doc);

    doc.source = try gpa.dupe(u8, input);
    errdefer gpa.free(doc.source);

    var elems = std.ArrayList(Element){};
    defer elems.deinit(gpa);
    var attrs = std.ArrayList(Attr){};
    defer attrs.deinit(gpa);

    var depth: u32 = 0;
    var i: usize = 0;
    while (i < doc.source.len) {
        if (doc.source[i] != '<') {
            i += 1;
            continue;
        }
        // Comment?
        if (startsWith(doc.source, i, "<!--")) {
            i = (std.mem.indexOfPos(u8, doc.source, i + 4, "-->") orelse doc.source.len) + 3;
            continue;
        }
        // DOCTYPE / processing-instruction?
        if (i + 1 < doc.source.len and doc.source[i + 1] == '!') {
            i = (std.mem.indexOfPos(u8, doc.source, i + 2, ">") orelse doc.source.len) + 1;
            continue;
        }
        if (i + 1 < doc.source.len and doc.source[i + 1] == '?') {
            i = (std.mem.indexOfPos(u8, doc.source, i + 2, "?>") orelse doc.source.len) + 2;
            continue;
        }
        // Closing tag?
        if (i + 1 < doc.source.len and doc.source[i + 1] == '/') {
            if (depth > 0) depth -= 1;
            i = (std.mem.indexOfScalarPos(u8, doc.source, i + 2, '>') orelse doc.source.len) + 1;
            continue;
        }
        // Opening / self-closing tag.
        const tag_start = i + 1;
        var p = tag_start;
        while (p < doc.source.len and isTagNameChar(doc.source[p])) p += 1;
        if (p == tag_start) {
            i += 1;
            continue;
        }
        const tag_end = p;

        // Attributes between tag_end and the closing '>'.
        const attrs_off_now: u32 = @intCast(attrs.items.len);
        var attrs_added: u32 = 0;
        var self_close = false;
        while (p < doc.source.len) {
            while (p < doc.source.len and isWhitespace(doc.source[p])) p += 1;
            if (p >= doc.source.len) break;
            if (doc.source[p] == '>') break;
            if (doc.source[p] == '/' and p + 1 < doc.source.len and doc.source[p + 1] == '>') {
                self_close = true;
                p += 2;
                break;
            }
            // attr name
            const name_start = p;
            while (p < doc.source.len and isAttrNameChar(doc.source[p])) p += 1;
            const name_end = p;
            if (name_end == name_start) {
                p += 1;
                continue;
            }
            while (p < doc.source.len and isWhitespace(doc.source[p])) p += 1;
            var val_off: u32 = 0;
            var val_len: u32 = 0;
            if (p < doc.source.len and doc.source[p] == '=') {
                p += 1;
                while (p < doc.source.len and isWhitespace(doc.source[p])) p += 1;
                if (p < doc.source.len and (doc.source[p] == '"' or doc.source[p] == '\'')) {
                    const q = doc.source[p];
                    p += 1;
                    val_off = @intCast(p);
                    while (p < doc.source.len and doc.source[p] != q) p += 1;
                    val_len = @intCast(p - @as(usize, @intCast(val_off)));
                    if (p < doc.source.len) p += 1;
                } else {
                    val_off = @intCast(p);
                    while (p < doc.source.len and !isWhitespace(doc.source[p]) and doc.source[p] != '>') p += 1;
                    val_len = @intCast(p - @as(usize, @intCast(val_off)));
                }
            }
            try attrs.append(gpa, .{
                .name_off = @intCast(name_start),
                .name_len = @intCast(name_end - name_start),
                .val_off = val_off,
                .val_len = val_len,
            });
            attrs_added += 1;
        }
        if (p < doc.source.len and doc.source[p] == '>') p += 1;
        const content_off: u32 = @intCast(p);

        // Find content end. For script/style consume raw until matching close tag.
        const tag_slice = doc.source[tag_start..tag_end];
        var content_end_idx: usize = p;
        if (self_close) {
            content_end_idx = p;
        } else if (eqIgnoreCase(tag_slice, "script") or eqIgnoreCase(tag_slice, "style")) {
            const close = if (eqIgnoreCase(tag_slice, "script")) "</script" else "</style";
            content_end_idx = std.mem.indexOfPos(u8, doc.source, p, close) orelse doc.source.len;
        } else if (isVoidTag(tag_slice)) {
            content_end_idx = p;
        } else {
            depth += 1;
            // For non-self-closing, content extends until we *would* see a matching </tag.
            // For the flat index we just locate the next </tag with same name (case-insensitive)
            // at the same depth; if not found, take until EOF.
            content_end_idx = findMatchingClose(doc.source, p, tag_slice);
        }

        try elems.append(gpa, .{
            .tag_off = @intCast(tag_start),
            .tag_len = @intCast(tag_end - tag_start),
            .content_off = content_off,
            .content_len = @intCast(content_end_idx - p),
            .depth = depth,
            .attrs_off = attrs_off_now,
            .attrs_count = attrs_added,
        });
        i = p;
    }

    doc.elements = try elems.toOwnedSlice(gpa);
    doc.attrs = try attrs.toOwnedSlice(gpa);
    return doc;
}

fn findMatchingClose(src: []const u8, start: usize, tag: []const u8) usize {
    // Best-effort: scan forward for a </tag with matching name. Doesn't
    // count nested same-name tags; consumers needing strict DOM should
    // pre-validate input. Sufficient for flat use cases.
    var i = start;
    while (i < src.len) {
        if (src[i] != '<') {
            i += 1;
            continue;
        }
        if (i + 1 < src.len and src[i + 1] == '/') {
            const name_start = i + 2;
            var p = name_start;
            while (p < src.len and isTagNameChar(src[p])) p += 1;
            if (eqIgnoreCase(src[name_start..p], tag)) return i;
        }
        i += 1;
    }
    return src.len;
}

fn extractText(slice: []const u8, out: [*]u8, max: usize) i32 {
    var pos: usize = 0;
    var in_tag = false;
    var skip_script_or_style = false;
    var i: usize = 0;
    while (i < slice.len) : (i += 1) {
        const c = slice[i];
        if (c == '<') {
            // Detect script / style entry to suppress their bodies.
            if (startsWithIgnoreCase(slice, i, "<script")) {
                skip_script_or_style = true;
                in_tag = true;
                continue;
            }
            if (startsWithIgnoreCase(slice, i, "<style")) {
                skip_script_or_style = true;
                in_tag = true;
                continue;
            }
            if (startsWithIgnoreCase(slice, i, "</script") or
                startsWithIgnoreCase(slice, i, "</style"))
            {
                skip_script_or_style = false;
            }
            in_tag = true;
            continue;
        }
        if (c == '>') {
            in_tag = false;
            continue;
        }
        if (in_tag or skip_script_or_style) continue;
        if (pos >= max) return -1;
        out[pos] = c;
        pos += 1;
    }
    return @intCast(pos);
}

fn startsWith(haystack: []const u8, off: usize, needle: []const u8) bool {
    if (off + needle.len > haystack.len) return false;
    return std.mem.eql(u8, haystack[off .. off + needle.len], needle);
}

fn startsWithIgnoreCase(haystack: []const u8, off: usize, needle: []const u8) bool {
    if (off + needle.len > haystack.len) return false;
    return eqIgnoreCase(haystack[off .. off + needle.len], needle);
}

fn eqIgnoreCase(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    for (a, b) |x, y| {
        if (toLower(x) != toLower(y)) return false;
    }
    return true;
}

fn toLower(c: u8) u8 {
    return if (c >= 'A' and c <= 'Z') c + 32 else c;
}

fn isTagNameChar(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or
        (c >= '0' and c <= '9') or c == '-' or c == '_';
}

fn isAttrNameChar(c: u8) bool {
    return isTagNameChar(c) or c == ':';
}

fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

fn isVoidTag(name: []const u8) bool {
    const voids = [_][]const u8{
        "area", "base",  "br",    "col",   "embed", "hr",
        "img",  "input", "link",  "meta",  "param", "source",
        "track", "wbr",
    };
    inline for (voids) |v| {
        if (eqIgnoreCase(name, v)) return true;
    }
    return false;
}

// ── tests ────────────────────────────────────────────────────

test "html_dom: count by tag" {
    const src = "<html><body><p>one</p><p>two</p></body></html>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    try std.testing.expectEqual(@as(i32, 2), html_count_by_tag(doc, "p", 1));
    try std.testing.expectEqual(@as(i32, 1), html_count_by_tag(doc, "body", 4));
    try std.testing.expectEqual(@as(i32, 1), html_count_by_tag(doc, "BODY", 4));
    try std.testing.expectEqual(@as(i32, 0), html_count_by_tag(doc, "span", 4));
}

test "html_dom: text of nth tag" {
    const src = "<html><body><p>alpha</p><p>beta</p></body></html>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    var buf: [64]u8 = undefined;
    const a = html_text_of_tag(doc, "p", 1, 1, &buf, 64);
    try std.testing.expectEqualStrings("alpha", buf[0..@intCast(a)]);
    const b = html_text_of_tag(doc, "p", 1, 2, &buf, 64);
    try std.testing.expectEqualStrings("beta", buf[0..@intCast(b)]);
}

test "html_dom: attr of nth tag" {
    const src = "<a href=\"x\">one</a><a href='y'>two</a>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    var buf: [64]u8 = undefined;
    const n1 = html_attr_of_tag(doc, "a", 1, 1, "href", 4, &buf, 64);
    try std.testing.expectEqualStrings("x", buf[0..@intCast(n1)]);
    const n2 = html_attr_of_tag(doc, "a", 1, 2, "href", 4, &buf, 64);
    try std.testing.expectEqualStrings("y", buf[0..@intCast(n2)]);
}

test "html_dom: all text" {
    const src = "<html><body>hello <b>world</b></body></html>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    var buf: [64]u8 = undefined;
    const n = html_all_text(doc, &buf, 64);
    try std.testing.expectEqualStrings("hello world", buf[0..@intCast(n)]);
}

test "html_dom: skip script body" {
    const src = "<p>top</p><script>var x = 1;</script><p>bottom</p>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    var buf: [64]u8 = undefined;
    const n = html_all_text(doc, &buf, 64);
    try std.testing.expectEqualStrings("topbottom", buf[0..@intCast(n)]);
}

test "html_dom: skip comments" {
    const src = "<p>before</p><!-- comment --><p>after</p>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    try std.testing.expectEqual(@as(i32, 2), html_count_by_tag(doc, "p", 1));
}

test "html_dom: self closing tag" {
    const src = "<p>x</p><br/><p>y</p>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    try std.testing.expectEqual(@as(i32, 2), html_count_by_tag(doc, "p", 1));
    try std.testing.expectEqual(@as(i32, 1), html_count_by_tag(doc, "br", 2));
}

test "html_dom: bare attribute" {
    const src = "<input disabled type=\"checkbox\">";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    var buf: [64]u8 = undefined;
    const n = html_attr_of_tag(doc, "input", 5, 1, "type", 4, &buf, 64);
    try std.testing.expectEqualStrings("checkbox", buf[0..@intCast(n)]);
}

test "html_dom: find by id" {
    const src = "<div id=\"a\">A</div><div id=\"b\">B</div>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    const ai = html_find_by_id(doc, "a", 1);
    const bi = html_find_by_id(doc, "b", 1);
    const mi = html_find_by_id(doc, "missing", 7);
    try std.testing.expect(ai > 0 and bi > 0);
    try std.testing.expect(ai != bi);
    try std.testing.expectEqual(@as(i32, 0), mi);
}

test "html_dom: find by class (single)" {
    const src = "<p class=\"foo\">one</p><p class=\"foo bar\">two</p><p>three</p>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    try std.testing.expectEqual(@as(i32, 2), html_count_by_class(doc, "foo", 3));
    try std.testing.expectEqual(@as(i32, 1), html_count_by_class(doc, "bar", 3));
    try std.testing.expectEqual(@as(i32, 0), html_count_by_class(doc, "baz", 3));
    var buf: [64]u8 = undefined;
    const first = html_find_by_class(doc, "foo", 3, 1);
    const len = html_text_of_tag(doc, "p", 1, 1, &buf, 64);
    try std.testing.expect(first > 0);
    try std.testing.expectEqualStrings("one", buf[0..@intCast(len)]);
}

test "html_dom: children count" {
    const src = "<ul><li>a</li><li>b</li><li>c</li></ul>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    try std.testing.expectEqual(@as(i32, 3), html_children_count(doc, 1));
    // a child <li> has 0 children of its own
    try std.testing.expectEqual(@as(i32, 0), html_children_count(doc, 2));
}

test "html_dom: child at" {
    const src = "<ul><li>a</li><li>b</li><li>c</li></ul>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    const c1 = html_child_at(doc, 1, 1);
    const c2 = html_child_at(doc, 1, 2);
    const c3 = html_child_at(doc, 1, 3);
    try std.testing.expect(c1 == 2 and c2 == 3 and c3 == 4);
    try std.testing.expectEqual(@as(i32, 0), html_child_at(doc, 1, 4));
}

test "html_dom: parent of" {
    const src = "<ul><li>a</li><li>b</li></ul>";
    const doc = html_parse(src.ptr, src.len).?;
    defer html_free(doc);
    // ul at index 1, first li at 2, second at 3.
    try std.testing.expectEqual(@as(i32, 0), html_parent_of(doc, 1)); // ul is root
    try std.testing.expectEqual(@as(i32, 1), html_parent_of(doc, 2));
    try std.testing.expectEqual(@as(i32, 1), html_parent_of(doc, 3));
}
