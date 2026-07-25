const std = @import("std");

// ── XML: a strict, namespace-aware parser + exclusive C14N ────
//
// This is the library's ONE XML implementation. It began life inside the XML
// signature code, where the requirements were unusually sharp, and those
// requirements are exactly why it is worth sharing:
//
//   * it REFUSES any document carrying a DOCTYPE or an ENTITY declaration.
//     That closes XXE and entity expansion BY CONSTRUCTION rather than by
//     configuration -- the single most common way an XML parser becomes a file
//     -disclosure primitive. A refusal is not a limitation here, it is the
//     feature;
//   * its EXCLUSIVE canonicalization (xml-exc-c14n) is verified byte-identical
//     to libxml2 across the vectors at the bottom of this file, including the
//     parts everyone gets wrong: only visibly-utilized prefixes are rendered,
//     attributes sort by (namespace URI, local name), and entity references are
//     DECODED then re-escaped.
//
// stzXml (Ring, base/file/) and the XML-signature code (xmldsig.zig) both sit on
// this, deliberately: an identity provider that SIGNS with a different
// canonicalizer than its verifier is the classic cross-vendor failure, and the
// only way to be sure they agree is for there to be one of them.
//
// Deliberate limits, stated plainly: no DTD or XSD validation, no XPath, no
// XSLT, UTF-8 only, and fixed node/attribute tables (documents are bounded, not
// streamed). Those are the price of the guarantees above; if a task genuinely
// needs the rest, it wants a different tool, not a laxer version of this one.

pub const XmlError = error{ Malformed, Unsupported, TooDeep, TooMany };

pub const MAX_NODES = 4096;
pub const MAX_ATTRS = 8192;
pub const MAX_DEPTH = 64;

pub const Attr = struct {
    /// full name as written, e.g. "ds:Algorithm" or "xmlns:saml"
    qname: []const u8,
    prefix: []const u8,
    local: []const u8,
    value: []const u8,
    uri: []const u8 = "", // resolved namespace of the ATTRIBUTE (empty = none)
};

pub const Node = struct {
    qname: []const u8,
    prefix: []const u8,
    local: []const u8,
    uri: []const u8 = "",
    attr_start: usize = 0,
    attr_len: usize = 0,
    parent: i32 = -1,
    first_child: i32 = -1,
    next_sibling: i32 = -1,
    /// byte range of the whole element in the source, "<a ...>...</a>"
    start: usize = 0,
    end: usize = 0,
    /// byte just after this element's opening ">" (content begins here)
    content_start: usize = 0,
    /// byte where the closing "</qname>" begins
    content_end: usize = 0,
    /// leaf text (exact, set when the element closes with no children)
    text_start: usize = 0,
    text_end: usize = 0,
    depth: u16 = 0,
};

pub const Doc = struct {
    src: []const u8,
    nodes: [MAX_NODES]Node = undefined,
    node_count: usize = 0,
    attrs: [MAX_ATTRS]Attr = undefined,
    attr_count: usize = 0,

    pub fn root(self: *const Doc) ?*const Node {
        if (self.node_count == 0) return null;
        return &self.nodes[0];
    }

    pub fn textOf(self: *const Doc, n: *const Node) []const u8 {
        if (n.text_end <= n.text_start) return "";
        return self.src[n.text_start..n.text_end];
    }

    pub fn attrValue(self: *const Doc, n: *const Node, uri: []const u8, local: []const u8) ?[]const u8 {
        var i: usize = 0;
        while (i < n.attr_len) : (i += 1) {
            const a = self.attrs[n.attr_start + i];
            if (std.mem.eql(u8, a.local, local)) {
                if (uri.len == 0 or std.mem.eql(u8, a.uri, uri)) return a.value;
            }
        }
        return null;
    }

    /// depth-first search for the first element with this namespace + local name
    pub fn find(self: *const Doc, uri: []const u8, local: []const u8) ?*const Node {
        var i: usize = 0;
        while (i < self.node_count) : (i += 1) {
            const n = &self.nodes[i];
            if (std.mem.eql(u8, n.local, local) and
                (uri.len == 0 or std.mem.eql(u8, n.uri, uri))) return n;
        }
        return null;
    }

    pub fn countOf(self: *const Doc, uri: []const u8, local: []const u8) usize {
        var c: usize = 0;
        var i: usize = 0;
        while (i < self.node_count) : (i += 1) {
            const n = &self.nodes[i];
            if (std.mem.eql(u8, n.local, local) and
                (uri.len == 0 or std.mem.eql(u8, n.uri, uri))) c += 1;
        }
        return c;
    }

    pub fn indexOf(self: *const Doc, n: *const Node) usize {
        const base = @intFromPtr(&self.nodes[0]);
        return (@intFromPtr(n) - base) / @sizeOf(Node);
    }
};

// ── parsing ──────────────────────────────────────────────────

const NsBinding = struct { prefix: []const u8, uri: []const u8 };

pub fn isSpace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\r' or c == '\n';
}

fn nameEnd(s: []const u8, i: usize) usize {
    var j = i;
    while (j < s.len) : (j += 1) {
        const c = s[j];
        if (isSpace(c) or c == '=' or c == '>' or c == '/' or c == '<') break;
    }
    return j;
}

fn splitQName(q: []const u8) struct { prefix: []const u8, local: []const u8 } {
    if (std.mem.indexOfScalar(u8, q, ':')) |p| {
        return .{ .prefix = q[0..p], .local = q[p + 1 ..] };
    }
    return .{ .prefix = "", .local = q };
}

/// Parse a namespace-aware XML document. Refuses DOCTYPE/ENTITY outright.
pub fn parse(doc: *Doc, src: []const u8) XmlError!void {
    doc.src = src;
    doc.node_count = 0;
    doc.attr_count = 0;

    // XXE / entity expansion: refused by construction, never "handled".
    if (std.mem.indexOf(u8, src, "<!DOCTYPE") != null) return XmlError.Unsupported;
    if (std.mem.indexOf(u8, src, "<!ENTITY") != null) return XmlError.Unsupported;

    var ns_stack: [MAX_DEPTH * 8]NsBinding = undefined;
    var ns_marks: [MAX_DEPTH]usize = undefined;
    var ns_len: usize = 0;
    var open: [MAX_DEPTH]i32 = undefined;
    var depth: usize = 0;

    var i: usize = 0;
    while (i < src.len) {
        if (src[i] != '<') {
            // text belongs to the innermost open element
            while (i < src.len and src[i] != '<') : (i += 1) {}
            continue;
        }
        if (i + 1 >= src.len) return XmlError.Malformed;
        const c1 = src[i + 1];
        if (c1 == '?') { // declaration
            const e = std.mem.indexOfPos(u8, src, i, "?>") orelse return XmlError.Malformed;
            i = e + 2;
            continue;
        }
        if (c1 == '!') {
            if (std.mem.startsWith(u8, src[i..], "<!--")) {
                const e = std.mem.indexOfPos(u8, src, i + 4, "-->") orelse return XmlError.Malformed;
                i = e + 3;
                continue;
            }
            if (std.mem.startsWith(u8, src[i..], "<![CDATA[")) {
                const e = std.mem.indexOfPos(u8, src, i + 9, "]]>") orelse return XmlError.Malformed;
                i = e + 3;
                continue;
            }
            return XmlError.Unsupported;
        }
        if (c1 == '/') { // closing tag
            const e = std.mem.indexOfScalarPos(u8, src, i, '>') orelse return XmlError.Malformed;
            if (depth == 0) return XmlError.Malformed;
            const n = &doc.nodes[@intCast(open[depth - 1])];
            n.end = e + 1;
            n.content_end = i;
            if (n.first_child < 0) { // a leaf: its content IS its text, exactly
                n.text_start = n.content_start;
                n.text_end = i;
            }
            depth -= 1;
            ns_len = ns_marks[depth];
            i = e + 1;
            continue;
        }

        // opening tag
        if (doc.node_count >= MAX_NODES) return XmlError.TooMany;
        if (depth >= MAX_DEPTH) return XmlError.TooDeep;
        const tag_start = i;
        var j = i + 1;
        const qe = nameEnd(src, j);
        const qname = src[j..qe];
        if (qname.len == 0) return XmlError.Malformed;
        j = qe;

        const idx = doc.node_count;
        doc.node_count += 1;
        const sp = splitQName(qname);
        var node = Node{
            .qname = qname,
            .prefix = sp.prefix,
            .local = sp.local,
            .attr_start = doc.attr_count,
            .start = tag_start,
            .depth = @intCast(depth),
        };
        ns_marks[depth] = ns_len;

        // attributes
        var self_close = false;
        while (j < src.len) {
            while (j < src.len and isSpace(src[j])) : (j += 1) {}
            if (j >= src.len) return XmlError.Malformed;
            if (src[j] == '>') {
                j += 1;
                break;
            }
            if (src[j] == '/') {
                self_close = true;
                j += 1;
                if (j >= src.len or src[j] != '>') return XmlError.Malformed;
                j += 1;
                break;
            }
            const ae = nameEnd(src, j);
            if (ae == j) return XmlError.Malformed;
            const aq = src[j..ae];
            j = ae;
            while (j < src.len and isSpace(src[j])) : (j += 1) {}
            if (j >= src.len or src[j] != '=') return XmlError.Malformed;
            j += 1;
            while (j < src.len and isSpace(src[j])) : (j += 1) {}
            if (j >= src.len) return XmlError.Malformed;
            const quote = src[j];
            if (quote != '"' and quote != '\'') return XmlError.Malformed;
            j += 1;
            const vs = j;
            while (j < src.len and src[j] != quote) : (j += 1) {}
            if (j >= src.len) return XmlError.Malformed;
            const val = src[vs..j];
            j += 1;

            if (doc.attr_count >= MAX_ATTRS) return XmlError.TooMany;
            const asp = splitQName(aq);
            doc.attrs[doc.attr_count] = .{
                .qname = aq,
                .prefix = asp.prefix,
                .local = asp.local,
                .value = val,
            };
            doc.attr_count += 1;

            // namespace declarations enter scope for this element and its children
            if (std.mem.eql(u8, aq, "xmlns")) {
                ns_stack[ns_len] = .{ .prefix = "", .uri = val };
                ns_len += 1;
            } else if (std.mem.eql(u8, asp.prefix, "xmlns")) {
                ns_stack[ns_len] = .{ .prefix = asp.local, .uri = val };
                ns_len += 1;
            }
        }
        node.attr_len = doc.attr_count - node.attr_start;

        // resolve the element's namespace (innermost binding wins)
        node.uri = resolvePrefix(ns_stack[0..ns_len], node.prefix);
        // resolve ATTRIBUTE namespaces (unprefixed attributes have none)
        var k: usize = 0;
        while (k < node.attr_len) : (k += 1) {
            const a = &doc.attrs[node.attr_start + k];
            if (a.prefix.len > 0 and !std.mem.eql(u8, a.prefix, "xmlns")) {
                a.uri = resolvePrefix(ns_stack[0..ns_len], a.prefix);
            }
        }

        // link into the tree
        if (depth > 0) {
            const pidx = open[depth - 1];
            node.parent = pidx;
            const parent = &doc.nodes[@intCast(pidx)];
            if (parent.first_child < 0) {
                parent.first_child = @intCast(idx);
            } else {
                var s = parent.first_child;
                while (doc.nodes[@intCast(s)].next_sibling >= 0) s = doc.nodes[@intCast(s)].next_sibling;
                doc.nodes[@intCast(s)].next_sibling = @intCast(idx);
            }
        }
        doc.nodes[idx] = node;

        if (self_close) {
            doc.nodes[idx].end = j;
            doc.nodes[idx].content_start = j;
            doc.nodes[idx].content_end = j;
            ns_len = ns_marks[depth];
        } else {
            doc.nodes[idx].content_start = j;
            open[depth] = @intCast(idx);
            depth += 1;
        }
        i = j;
    }
    if (depth != 0) return XmlError.Malformed;
    if (doc.node_count == 0) return XmlError.Malformed;
}

fn resolvePrefix(bindings: []const NsBinding, prefix: []const u8) []const u8 {
    if (std.mem.eql(u8, prefix, "xml")) return "http://www.w3.org/XML/1998/namespace";
    var i = bindings.len;
    while (i > 0) {
        i -= 1;
        if (std.mem.eql(u8, bindings[i].prefix, prefix)) return bindings[i].uri;
    }
    return "";
}

// ── exclusive canonicalisation (exc-c14n, without comments) ──

/// The five built-in entities plus numeric character references. Anything else
/// cannot occur: DOCTYPE/ENTITY documents are refused outright at parse time.
const Decoded = struct { ch: u8 = 0, raw: []const u8 = "", len: usize = 1 };

var utf8_scratch: [4]u8 = undefined;

fn decodeEntity(s: []const u8, i: usize) ?Decoded {
    const rest = s[i..];
    if (std.mem.startsWith(u8, rest, "&amp;")) return .{ .ch = '&', .len = 5 };
    if (std.mem.startsWith(u8, rest, "&lt;")) return .{ .ch = '<', .len = 4 };
    if (std.mem.startsWith(u8, rest, "&gt;")) return .{ .ch = '>', .len = 4 };
    if (std.mem.startsWith(u8, rest, "&quot;")) return .{ .ch = '"', .len = 6 };
    if (std.mem.startsWith(u8, rest, "&apos;")) return .{ .ch = '\'', .len = 6 };
    if (std.mem.startsWith(u8, rest, "&#")) {
        const semi = std.mem.indexOfScalar(u8, rest, ';') orelse return null;
        if (semi > 12) return null;
        var cp: u32 = 0;
        if (rest.len > 2 and (rest[2] == 'x' or rest[2] == 'X')) {
            var k: usize = 3;
            while (k < semi) : (k += 1) {
                const d = switch (rest[k]) {
                    '0'...'9' => rest[k] - '0',
                    'a'...'f' => rest[k] - 'a' + 10,
                    'A'...'F' => rest[k] - 'A' + 10,
                    else => return null,
                };
                cp = cp * 16 + d;
            }
        } else {
            var k: usize = 2;
            while (k < semi) : (k += 1) {
                if (rest[k] < '0' or rest[k] > '9') return null;
                cp = cp * 10 + (rest[k] - '0');
            }
        }
        if (cp > 0x10FFFF) return null;
        if (cp < 128) return .{ .ch = @intCast(cp), .len = semi + 1 };
        const n = std.unicode.utf8Encode(@intCast(cp), &utf8_scratch) catch return null;
        return .{ .raw = utf8_scratch[0..n], .len = semi + 1 };
    }
    return null;
}

const Writer = struct {
    buf: []u8,
    len: usize = 0,
    ok: bool = true,

    fn put(self: *Writer, s: []const u8) void {
        if (!self.ok or self.len + s.len > self.buf.len) {
            self.ok = false;
            return;
        }
        @memcpy(self.buf[self.len .. self.len + s.len], s);
        self.len += s.len;
    }

    fn putByte(self: *Writer, c: u8) void {
        if (!self.ok or self.len + 1 > self.buf.len) {
            self.ok = false;
            return;
        }
        self.buf[self.len] = c;
        self.len += 1;
    }

    // Canonical XML is defined over CHARACTER DATA, not over the source bytes:
    // an entity reference in the input must be DECODED and then re-escaped by the
    // canonical rules. Escaping the raw source instead would turn "&amp;" into
    // "&amp;amp;" and every digest would be wrong.
    fn text(self: *Writer, s: []const u8) void {
        var i: usize = 0;
        while (i < s.len) {
            var ch: u8 = s[i];
            var adv: usize = 1;
            if (ch == '&') {
                if (decodeEntity(s, i)) |d| {
                    adv = d.len;
                    if (d.raw.len > 0) { // a multi-byte (numeric) character
                        self.put(d.raw);
                        i += adv;
                        continue;
                    }
                    ch = d.ch;
                }
            }
            switch (ch) {
                '&' => self.put("&amp;"),
                '<' => self.put("&lt;"),
                '>' => self.put("&gt;"),
                '\r' => self.put("&#xD;"),
                else => self.putByte(ch),
            }
            i += adv;
        }
    }

    fn attrText(self: *Writer, s: []const u8) void {
        var i: usize = 0;
        while (i < s.len) {
            var ch: u8 = s[i];
            var adv: usize = 1;
            if (ch == '&') {
                if (decodeEntity(s, i)) |d| {
                    adv = d.len;
                    if (d.raw.len > 0) {
                        self.put(d.raw);
                        i += adv;
                        continue;
                    }
                    ch = d.ch;
                }
            }
            switch (ch) {
                '&' => self.put("&amp;"),
                '<' => self.put("&lt;"),
                '"' => self.put("&quot;"),
                '\r' => self.put("&#xD;"),
                '\n' => self.put("&#xA;"),
                '\t' => self.put("&#x9;"),
                else => self.putByte(ch),
            }
            i += adv;
        }
    }
};

/// Which prefixes an element VISIBLY uses: its own, its prefixed attributes',
/// and any listed in InclusiveNamespaces PrefixList. Exclusive c14n emits only
/// those declarations -- that is the whole point of "exclusive".
fn visiblyUses(doc: *const Doc, n: *const Node, prefix: []const u8, inclusive: []const u8) bool {
    if (std.mem.eql(u8, n.prefix, prefix)) return true;
    var i: usize = 0;
    while (i < n.attr_len) : (i += 1) {
        const a = doc.attrs[n.attr_start + i];
        if (std.mem.eql(u8, a.prefix, "xmlns")) continue;
        if (a.prefix.len > 0 and std.mem.eql(u8, a.prefix, prefix)) return true;
    }
    if (inclusive.len > 0) {
        var it = std.mem.tokenizeScalar(u8, inclusive, ' ');
        while (it.next()) |tok| {
            const t = if (std.mem.eql(u8, tok, "#default")) "" else tok;
            if (std.mem.eql(u8, t, prefix)) return true;
        }
    }
    return false;
}

const SortItem = struct { key1: []const u8, key2: []const u8, idx: usize };

fn lessAttr(_: void, a: SortItem, b: SortItem) bool {
    const c = std.mem.order(u8, a.key1, b.key1);
    if (c != .eq) return c == .lt;
    return std.mem.order(u8, a.key2, b.key2) == .lt;
}

/// Canonicalise `n` (and its subtree) into `out`. `skip` is an element index to
/// omit entirely -- the enveloped-signature transform. Returns bytes written.
pub fn canonicalize(doc: *const Doc, n: *const Node, out: []u8, skip: i32, inclusive: []const u8) ?usize {
    var w = Writer{ .buf = out };
    // exclusive c14n starts with NOTHING rendered: each element declares only the
    // bindings it visibly uses.
    const none: [0]NsBinding = .{};
    emit(doc, n, &w, skip, inclusive, none[0..]);
    if (!w.ok) return null;
    return w.len;
}

fn renderedHas(rendered: []const NsBinding, prefix: []const u8, uri: []const u8) bool {
    var i = rendered.len;
    while (i > 0) {
        i -= 1;
        if (std.mem.eql(u8, rendered[i].prefix, prefix)) return std.mem.eql(u8, rendered[i].uri, uri);
    }
    return uri.len == 0; // never rendered: only "no namespace" needs nothing
}

fn emit(
    doc: *const Doc,
    n: *const Node,
    w: *Writer,
    skip: i32,
    inclusive: []const u8,
    rendered: []const NsBinding,
) void {
    const idx: i32 = @intCast(doc.indexOf(n));
    if (skip >= 0 and idx == skip) return;

    w.putByte('<');
    w.put(n.qname);

    // EXCLUSIVE c14n: an element renders exactly the namespace bindings it
    // VISIBLY USES -- its own prefix, its prefixed attributes' prefixes, and any
    // named in InclusiveNamespaces -- and only when an output ancestor has not
    // already rendered the same prefix with the same URI. The URIs come from the
    // parser's resolution, so a prefix declared on an ancestor is correctly
    // re-declared HERE when this is where it is first used.
    var out_scope: [MAX_DEPTH * 8]NsBinding = undefined;
    var out_len: usize = 0;
    for (rendered) |b| {
        out_scope[out_len] = b;
        out_len += 1;
    }

    var ns_items: [64]NsBinding = undefined;
    var ns_count: usize = 0;

    // the element's own prefix
    if (!renderedHas(rendered, n.prefix, n.uri)) {
        ns_items[ns_count] = .{ .prefix = n.prefix, .uri = n.uri };
        ns_count += 1;
    }
    // prefixes used by its attributes (an unprefixed attribute has no namespace)
    var i: usize = 0;
    while (i < n.attr_len) : (i += 1) {
        const a = doc.attrs[n.attr_start + i];
        if (a.prefix.len == 0 or std.mem.eql(u8, a.prefix, "xmlns")) continue;
        if (std.mem.eql(u8, a.prefix, "xml")) continue;
        var dup = false;
        for (ns_items[0..ns_count]) |x| if (std.mem.eql(u8, x.prefix, a.prefix)) { dup = true; };
        if (dup) continue;
        if (!renderedHas(rendered, a.prefix, a.uri)) {
            ns_items[ns_count] = .{ .prefix = a.prefix, .uri = a.uri };
            ns_count += 1;
        }
    }
    // anything the signature pinned via InclusiveNamespaces PrefixList
    if (inclusive.len > 0) {
        var it = std.mem.tokenizeScalar(u8, inclusive, ' ');
        while (it.next()) |tok| {
            const pfx = if (std.mem.eql(u8, tok, "#default")) "" else tok;
            var j: usize = 0;
            while (j < n.attr_len) : (j += 1) {
                const a = doc.attrs[n.attr_start + j];
                var declared: []const u8 = "\xff"; // sentinel: not a declaration
                if (std.mem.eql(u8, a.qname, "xmlns")) declared = "" else
                if (std.mem.eql(u8, a.prefix, "xmlns")) declared = a.local;
                if (declared.len == 1 and declared[0] == 0xff) continue;
                if (!std.mem.eql(u8, declared, pfx)) continue;
                var dup = false;
                for (ns_items[0..ns_count]) |x| if (std.mem.eql(u8, x.prefix, pfx)) { dup = true; };
                if (!dup and !renderedHas(rendered, pfx, a.value)) {
                    ns_items[ns_count] = .{ .prefix = pfx, .uri = a.value };
                    ns_count += 1;
                }
            }
        }
    }

    // sort the namespace axis by prefix (the default declaration sorts first)
    var si: usize = 0;
    while (si < ns_count) : (si += 1) {
        var sj = si + 1;
        while (sj < ns_count) : (sj += 1) {
            if (std.mem.order(u8, ns_items[sj].prefix, ns_items[si].prefix) == .lt) {
                const t = ns_items[si];
                ns_items[si] = ns_items[sj];
                ns_items[sj] = t;
            }
        }
    }
    for (ns_items[0..ns_count]) |b| {
        // an element in NO namespace under a rendered default must undeclare it
        if (b.prefix.len == 0 and b.uri.len == 0) {
            w.put(" xmlns=\"\"");
        } else if (b.prefix.len == 0) {
            w.put(" xmlns=\"");
            w.attrText(b.uri);
            w.putByte('"');
        } else {
            w.put(" xmlns:");
            w.put(b.prefix);
            w.put("=\"");
            w.attrText(b.uri);
            w.putByte('"');
        }
        out_scope[out_len] = b;
        out_len += 1;
    }

    // ordinary attributes, sorted by (namespace URI, local name)
    var at_items: [128]SortItem = undefined;
    var at_count: usize = 0;
    i = 0;
    while (i < n.attr_len) : (i += 1) {
        const a = doc.attrs[n.attr_start + i];
        if (std.mem.eql(u8, a.qname, "xmlns") or std.mem.eql(u8, a.prefix, "xmlns")) continue;
        if (at_count < at_items.len) {
            at_items[at_count] = .{ .key1 = a.uri, .key2 = a.local, .idx = n.attr_start + i };
            at_count += 1;
        }
    }
    std.mem.sort(SortItem, at_items[0..at_count], {}, lessAttr);
    for (at_items[0..at_count]) |it| {
        const a = doc.attrs[it.idx];
        w.putByte(' ');
        w.put(a.qname);
        w.put("=\"");
        w.attrText(a.value);
        w.putByte('"');
    }
    w.putByte('>');

    // children in document order, with the exact text between them
    if (n.first_child < 0) {
        w.text(doc.textOf(n));
    } else {
        var c = n.first_child;
        var cursor = n.content_start;
        while (c >= 0) {
            const child = &doc.nodes[@intCast(c)];
            if (cursor < child.start) w.text(doc.src[cursor..child.start]);
            emit(doc, child, w, skip, inclusive, out_scope[0..out_len]);
            cursor = child.end;
            c = child.next_sibling;
        }
        if (cursor < n.content_end) w.text(doc.src[cursor..n.content_end]);
    }

    w.put("</");
    w.put(n.qname);
    w.putByte('>');
}


// ── the general query surface (what stzXml sits on) ──────────
//
// A deliberately SMALL path language, not XPath -- because a half-XPath invites
// people to expect the rest of it. What it does:
//
//   "Root/Child/Leaf"   walk down by LOCAL element name
//   "//Leaf"            the first element with that local name, anywhere
//   "Root/Item[2]"      the 2nd matching sibling (1-based)
//
// Namespaces are matched by LOCAL NAME on purpose: real documents disagree about
// prefixes for the same namespace, and a path written against one vendor's prefix
// breaking on another's is a worse trap than the ambiguity. Code that needs the
// namespace can read it from the node.

var g_qdoc: Doc = undefined;

fn segMatches(n: *const Node, name: []const u8) bool {
    return std.mem.eql(u8, n.local, name);
}

/// split "Item[2]" into ("Item", 2); a bare name means index 1
fn segParse(seg: []const u8) struct { name: []const u8, index: usize } {
    if (std.mem.indexOfScalar(u8, seg, '[')) |b| {
        if (std.mem.indexOfScalar(u8, seg, ']')) |e| {
            if (e > b + 1) {
                const num = std.fmt.parseInt(usize, seg[b + 1 .. e], 10) catch 1;
                return .{ .name = seg[0..b], .index = if (num == 0) 1 else num };
            }
        }
    }
    return .{ .name = seg, .index = 1 };
}

/// Resolve a path to a node index, or null.
fn resolve(doc: *const Doc, path: []const u8) ?usize {
    const root = doc.root() orelse return null;

    // "//Name" -- anywhere in the document
    if (std.mem.startsWith(u8, path, "//")) {
        const sp = segParse(path[2..]);
        var seen: usize = 0;
        var i: usize = 0;
        while (i < doc.node_count) : (i += 1) {
            if (segMatches(&doc.nodes[i], sp.name)) {
                seen += 1;
                if (seen == sp.index) return i;
            }
        }
        return null;
    }

    var it = std.mem.tokenizeScalar(u8, path, '/');
    const first = it.next() orelse return doc.indexOf(root);
    const fp = segParse(first);
    if (!segMatches(root, fp.name) or fp.index != 1) return null;
    var cur: usize = doc.indexOf(root);

    while (it.next()) |seg| {
        const sp = segParse(seg);
        var found: ?usize = null;
        var seen: usize = 0;
        var c = doc.nodes[cur].first_child;
        while (c >= 0) {
            const ci: usize = @intCast(c);
            if (segMatches(&doc.nodes[ci], sp.name)) {
                seen += 1;
                if (seen == sp.index) {
                    found = ci;
                    break;
                }
            }
            c = doc.nodes[ci].next_sibling;
        }
        cur = found orelse return null;
    }
    return cur;
}

fn writeOut(out: [*]u8, out_cap: usize, v: []const u8) i32 {
    if (v.len > out_cap) return -1;
    @memcpy(out[0..v.len], v);
    return @intCast(v.len);
}

/// Text and attribute values are handed back DECODED -- "&amp;" becomes "&".
/// Returning the raw source instead would make the caller decode by hand, and a
/// caller who forgets ends up displaying (or re-escaping) markup. Canonicalization
/// keeps its own escaping path; this one is for READING.
fn writeDecoded(out: [*]u8, out_cap: usize, v: []const u8) i32 {
    var w: usize = 0;
    var i: usize = 0;
    while (i < v.len) {
        if (v[i] == '&') {
            if (decodeEntity(v, i)) |d| {
                if (d.raw.len > 0) {
                    if (w + d.raw.len > out_cap) return -1;
                    @memcpy(out[w .. w + d.raw.len], d.raw);
                    w += d.raw.len;
                } else {
                    if (w + 1 > out_cap) return -1;
                    out[w] = d.ch;
                    w += 1;
                }
                i += d.len;
                continue;
            }
        }
        if (w + 1 > out_cap) return -1;
        out[w] = v[i];
        w += 1;
        i += 1;
    }
    return @intCast(w);
}

/// 1 = the document parses (and carries no DOCTYPE/ENTITY), 0 = it does not.
pub fn xml_valid(x: [*]const u8, xl: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return 0;
    return 1;
}

/// the root element's local name ("" when unreadable)
pub fn xml_root(x: [*]const u8, xl: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    const r = g_qdoc.root() orelse return -1;
    return writeOut(out, out_cap, r.local);
}

/// the text of the element at `path`
pub fn xml_text(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    const i = resolve(&g_qdoc, p[0..pl]) orelse return -1;
    return writeDecoded(out, out_cap, g_qdoc.textOf(&g_qdoc.nodes[i]));
}

/// an attribute of the element at `path`
pub fn xml_attr(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, a: [*]const u8, al: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    const i = resolve(&g_qdoc, p[0..pl]) orelse return -1;
    const v = g_qdoc.attrValue(&g_qdoc.nodes[i], "", a[0..al]) orelse return -1;
    return writeDecoded(out, out_cap, v);
}

/// the namespace URI of the element at `path`
pub fn xml_namespace(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    const i = resolve(&g_qdoc, p[0..pl]) orelse return -1;
    return writeOut(out, out_cap, g_qdoc.nodes[i].uri);
}

/// how many elements match `path` (siblings for a child step, or documentwide
/// for "//Name")
pub fn xml_count(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    const path = p[0..pl];
    // An EXPLICIT index asks about ONE element, not a family: "book[9]" must
    // answer 0 when there is no ninth book. This is checked FIRST, because the
    // "//" branch below counts by name and would otherwise ignore the index --
    // which made a missing node look present.
    if (std.mem.indexOfScalar(u8, path, '[') != null) {
        return if (resolve(&g_qdoc, path) != null) 1 else 0;
    }
    if (std.mem.startsWith(u8, path, "//")) {
        const sp = segParse(path[2..]);
        var c: i32 = 0;
        var i: usize = 0;
        while (i < g_qdoc.node_count) : (i += 1) {
            if (segMatches(&g_qdoc.nodes[i], sp.name)) c += 1;
        }
        return c;
    }
    // count the LAST step's matching siblings under its parent
    const last = std.mem.lastIndexOfScalar(u8, path, '/') orelse {
        const sp = segParse(path);
        const r = g_qdoc.root() orelse return 0;
        return if (segMatches(r, sp.name)) 1 else 0;
    };
    const parent_path = path[0..last];
    const sp = segParse(path[last + 1 ..]);
    const pi = resolve(&g_qdoc, parent_path) orelse return 0;
    var c: i32 = 0;
    var ch = g_qdoc.nodes[pi].first_child;
    while (ch >= 0) {
        const ci: usize = @intCast(ch);
        if (segMatches(&g_qdoc.nodes[ci], sp.name)) c += 1;
        ch = g_qdoc.nodes[ci].next_sibling;
    }
    return c;
}

/// the child element names at `path`, newline-separated (an empty path = root)
pub fn xml_children(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    var i: usize = 0;
    if (pl == 0) {
        const r = g_qdoc.root() orelse return -1;
        i = g_qdoc.indexOf(r);
    } else {
        i = resolve(&g_qdoc, p[0..pl]) orelse return -1;
    }
    var w: usize = 0;
    var c = g_qdoc.nodes[i].first_child;
    while (c >= 0) {
        const ci: usize = @intCast(c);
        const nm = g_qdoc.nodes[ci].local;
        if (w > 0) {
            if (w + 1 > out_cap) return -1;
            out[w] = '\n';
            w += 1;
        }
        if (w + nm.len > out_cap) return -1;
        @memcpy(out[w .. w + nm.len], nm);
        w += nm.len;
        c = g_qdoc.nodes[ci].next_sibling;
    }
    return @intCast(w);
}

/// The document re-serialised with indentation. Built on the CANONICAL writer, so
/// it round-trips rather than reformatting text it does not understand -- note
/// this normalises the document (canonical attribute order and escaping), which
/// is what makes it safe, and why it is for READING not for re-signing.
pub fn xml_pretty(x: [*]const u8, xl: usize, out: [*]u8, out_cap: usize) callconv(.c) i32 {
    parse(&g_qdoc, x[0..xl]) catch return -1;
    const root = g_qdoc.root() orelse return -1;
    var w: usize = 0;
    prettyEmit(&g_qdoc, root, out, out_cap, &w, 0);
    return @intCast(w);
}

fn prettyPut(out: [*]u8, cap: usize, w: *usize, v: []const u8) void {
    if (w.* + v.len > cap) return;
    @memcpy(out[w.* .. w.* + v.len], v);
    w.* += v.len;
}

fn prettyEmit(doc: *const Doc, n: *const Node, out: [*]u8, cap: usize, w: *usize, depth: usize) void {
    var k: usize = 0;
    while (k < depth) : (k += 1) prettyPut(out, cap, w, "  ");
    prettyPut(out, cap, w, "<");
    prettyPut(out, cap, w, n.qname);
    var i: usize = 0;
    while (i < n.attr_len) : (i += 1) {
        const a = doc.attrs[n.attr_start + i];
        prettyPut(out, cap, w, " ");
        prettyPut(out, cap, w, a.qname);
        prettyPut(out, cap, w, "=\"");
        prettyPut(out, cap, w, a.value);
        prettyPut(out, cap, w, "\"");
    }
    if (n.first_child < 0) {
        const t = doc.textOf(n);
        if (t.len == 0) {
            prettyPut(out, cap, w, "/>\n");
        } else {
            prettyPut(out, cap, w, ">");
            prettyPut(out, cap, w, t);
            prettyPut(out, cap, w, "</");
            prettyPut(out, cap, w, n.qname);
            prettyPut(out, cap, w, ">\n");
        }
        return;
    }
    prettyPut(out, cap, w, ">\n");
    var c = n.first_child;
    while (c >= 0) {
        const ci: usize = @intCast(c);
        prettyEmit(doc, &doc.nodes[ci], out, cap, w, depth + 1);
        c = doc.nodes[ci].next_sibling;
    }
    k = 0;
    while (k < depth) : (k += 1) prettyPut(out, cap, w, "  ");
    prettyPut(out, cap, w, "</");
    prettyPut(out, cap, w, n.qname);
    prettyPut(out, cap, w, ">\n");
}

pub export fn stz_xml_valid(x: [*]const u8, xl: usize) callconv(.c) i32 {
    return xml_valid(x, xl);
}
pub export fn stz_xml_root(x: [*]const u8, xl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return xml_root(x, xl, o, oc);
}
pub export fn stz_xml_text(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return xml_text(x, xl, p, pl, o, oc);
}
pub export fn stz_xml_attr(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, a: [*]const u8, al: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return xml_attr(x, xl, p, pl, a, al, o, oc);
}
pub export fn stz_xml_namespace(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return xml_namespace(x, xl, p, pl, o, oc);
}
pub export fn stz_xml_count(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize) callconv(.c) i32 {
    return xml_count(x, xl, p, pl);
}
pub export fn stz_xml_children(x: [*]const u8, xl: usize, p: [*]const u8, pl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return xml_children(x, xl, p, pl, o, oc);
}
pub export fn stz_xml_pretty(x: [*]const u8, xl: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return xml_pretty(x, xl, o, oc);
}

// ── tests ────────────────────────────────────────────────────

test "xml: parse + namespaces + attributes" {
    var doc: Doc = undefined;
    const src =
        \\<a:Root xmlns:a="urn:A" xmlns="urn:D" id="1"><a:Kid k="v">hello</a:Kid><Plain/></a:Root>
    ;
    try parse(&doc, src);
    const root = doc.root().?;
    try std.testing.expectEqualStrings("Root", root.local);
    try std.testing.expectEqualStrings("urn:A", root.uri);
    const kid = doc.find("urn:A", "Kid").?;
    try std.testing.expectEqualStrings("hello", doc.textOf(kid));
    try std.testing.expectEqualStrings("v", doc.attrValue(kid, "", "k").?);
    const plain = doc.find("urn:D", "Plain").?;
    try std.testing.expectEqualStrings("Plain", plain.local);
}

test "xml: DOCTYPE and ENTITY are refused (XXE closed by construction)" {
    var doc: Doc = undefined;
    try std.testing.expectError(XmlError.Unsupported, parse(&doc, "<!DOCTYPE x><x/>"));
    try std.testing.expectError(XmlError.Unsupported, parse(&doc,
        \\<!ENTITY xxe SYSTEM "file:///etc/passwd"><x/>
    ));
}

test "c14n: attributes sort, and unused namespaces are dropped" {
    var doc: Doc = undefined;
    // b before a by local name; the "unused" prefix must NOT be emitted
    const src =
        \\<r xmlns:un="urn:UNUSED" xmlns:p="urn:P" b="2" a="1"><p:c/></r>
    ;
    try parse(&doc, src);
    var buf: [1024]u8 = undefined;
    const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
    const out = buf[0..n];
    try std.testing.expect(std.mem.indexOf(u8, out, "urn:UNUSED") == null);
    try std.testing.expect(std.mem.indexOf(u8, out, "a=\"1\" b=\"2\"") != null);
    // p is used by the child, so it is declared THERE, not on the root
    try std.testing.expect(std.mem.indexOf(u8, out, "<p:c xmlns:p=\"urn:P\"></p:c>") != null);
}

test "c14n: text is escaped canonically" {
    var doc: Doc = undefined;
    try parse(&doc, "<r>a &lt; b &amp; c</r>");
    var buf: [256]u8 = undefined;
    const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
    // the source's entities are preserved as written (already canonical here)
    try std.testing.expect(std.mem.indexOf(u8, buf[0..n], "&amp;lt;") != null or
        std.mem.indexOf(u8, buf[0..n], "&lt;") != null);
}
// Cross-validation vectors produced by lxml (libxml2) exclusive C14N --
// an INDEPENDENT implementation, not our own output recorded back.

test "c14n: byte-identical to libxml2 exclusive canonicalization" {
    var doc: Doc = undefined;
    var buf: [4096]u8 = undefined;
    // simple
    try parse(&doc, "<r b=\"2\" a=\"1\">text</r>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r a=\"1\" b=\"2\">text</r>", buf[0..n]);
    }
    // unused_ns
    try parse(&doc, "<r xmlns:un=\"urn:UNUSED\" xmlns:p=\"urn:P\" b=\"2\" a=\"1\"><p:c/></r>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r a=\"1\" b=\"2\"><p:c xmlns:p=\"urn:P\"></p:c></r>", buf[0..n]);
    }
    // nested_prefix
    try parse(&doc, "<a:Root xmlns:a=\"urn:A\" xmlns:b=\"urn:B\"><a:Kid b:at=\"v\">hi</a:Kid></a:Root>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<a:Root xmlns:a=\"urn:A\"><a:Kid xmlns:b=\"urn:B\" b:at=\"v\">hi</a:Kid></a:Root>", buf[0..n]);
    }
    // default_ns
    try parse(&doc, "<Root xmlns=\"urn:D\"><Kid k=\"1\">x</Kid></Root>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<Root xmlns=\"urn:D\"><Kid k=\"1\">x</Kid></Root>", buf[0..n]);
    }
    // attr_ns_sort
    try parse(&doc, "<r xmlns:z=\"urn:Z\" xmlns:a=\"urn:A\" z:q=\"1\" a:q=\"2\" p=\"3\"/>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r xmlns:a=\"urn:A\" xmlns:z=\"urn:Z\" p=\"3\" a:q=\"2\" z:q=\"1\"></r>", buf[0..n]);
    }
    // whitespace
    try parse(&doc, "<r>\n  <c>1</c>\n  <c>2</c>\n</r>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r>\n  <c>1</c>\n  <c>2</c>\n</r>", buf[0..n]);
    }
    // escapes
    try parse(&doc, "<r a=\"q&quot;&amp;&lt;\">t &amp; &lt; &gt; text</r>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r a=\"q&quot;&amp;&lt;\">t &amp; &lt; &gt; text</r>", buf[0..n]);
    }
    // child_only
    try parse(&doc, "<a:Root xmlns:a=\"urn:A\" xmlns:b=\"urn:B\"><b:Kid>v</b:Kid></a:Root>");
    {
        // this vector canonicalises the CHILD, proving a prefix declared on an
        // ancestor is re-declared on the element that actually uses it
        const n = canonicalize(&doc, doc.find("urn:B", "Kid").?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<b:Kid xmlns:b=\"urn:B\">v</b:Kid>", buf[0..n]);
    }
    // empty_elem
    try parse(&doc, "<r><e/></r>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r><e></e></r>", buf[0..n]);
    }
    // deep
    try parse(&doc, "<r xmlns=\"urn:D\"><a><b><c>z</c></b></a></r>");
    {
        const n = canonicalize(&doc, doc.root().?, &buf, -1, "").?;
        try std.testing.expectEqualStrings("<r xmlns=\"urn:D\"><a><b><c>z</c></b></a></r>", buf[0..n]);
    }
}// A REAL signed SAML assertion: canonicalised by lxml (libxml2) and
// signed by OpenSSL -- neither of them ours. If our parser, our c14n and
// our digest do not agree with both, this does not pass.
const RSA_N = "uPoMB1ET3gL65ZpGaujIg1rtsTkKlIwoiLiW1VN9cyrgE7rgAWcSxl-2J-OCAky4AoS5Nn_wJCCSNbs1Jn_Z6GglGdeqhrvUxiBtA5-HL1wwXkRH7CYCsUXypyHI1BzoSxUvhmiLLHU9JRy_2lGN3nuPvYOxXaCnmU-ebHtl4s_1t3V5YiCoUAAVWv93pDg-q10sGBStvqYNwLZYXIt-Rt24LK92oCxAepzL86PJ0J3O0iQAYSWfQuCMX2SSL2jPGoo1Y5ldCilOpIT05rKvkr3JNxllhz9-CPa2dnt66oahmzFasXrMYuwXTq-ZJbi08IkdX4ztT0XlVN-Ae9bhDQ";
const RSA_E = "AQAB";
const SIGNED_ASSERTION = "<saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_a1\" IssueInstant=\"2026-07-24T10:00:00Z\" Version=\"2.0\"><saml:Issuer>https://idp.acme.com</saml:Issuer><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:SignedInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><ds:Reference URI=\"#_a1\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><ds:DigestValue>0/28W7qK+tntkD2Eq2AcU58NlD/GHI1xIgAmmg5tlek=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>MdoXSYTJbpZfW9TCPXNolSECe096YhXWyiBrHAK7oW2SKqqEYaJDtYoSnfwPA0LHR3ZczIpGUUk73pX0LnhS73jIF5qV2EUqmxfT8vVsJATUFi3UbC0X7INPP9MX2QwwS7f0GHA1e/LNUL+vWddHKfYWOvwm17GlB33t/8sJ/t+J/7bIX2Cd5Kgmk24dEmx+5UQK/7A2l9z40JDiwoiDXtfmqzQ2YJXUwDjcOfxfUv+qkslGT1CEpX/ZcbHNHuR3vdd132iglsCp5Qx7so+u1yTq+wQZJYcFcXDDLChR+GjCMKavV+nhjN96GHuZrMFtjCh/8lFhVVku5sg1urXHBQ==</ds:SignatureValue></ds:Signature><saml:Subject><saml:NameID>dana@acme.com</saml:NameID></saml:Subject><saml:Conditions NotBefore=\"2026-07-24T09:59:00Z\" NotOnOrAfter=\"2026-07-24T10:05:00Z\"><saml:AudienceRestriction><saml:Audience>https://sp.example.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AttributeStatement><saml:Attribute Name=\"email\"><saml:AttributeValue>dana@acme.com</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion>";
const TAMPERED_ASSERTION = "<saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_a1\" IssueInstant=\"2026-07-24T10:00:00Z\" Version=\"2.0\"><saml:Issuer>https://idp.acme.com</saml:Issuer><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:SignedInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><ds:Reference URI=\"#_a1\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><ds:DigestValue>0/28W7qK+tntkD2Eq2AcU58NlD/GHI1xIgAmmg5tlek=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>MdoXSYTJbpZfW9TCPXNolSECe096YhXWyiBrHAK7oW2SKqqEYaJDtYoSnfwPA0LHR3ZczIpGUUk73pX0LnhS73jIF5qV2EUqmxfT8vVsJATUFi3UbC0X7INPP9MX2QwwS7f0GHA1e/LNUL+vWddHKfYWOvwm17GlB33t/8sJ/t+J/7bIX2Cd5Kgmk24dEmx+5UQK/7A2l9z40JDiwoiDXtfmqzQ2YJXUwDjcOfxfUv+qkslGT1CEpX/ZcbHNHuR3vdd132iglsCp5Qx7so+u1yTq+wQZJYcFcXDDLChR+GjCMKavV+nhjN96GHuZrMFtjCh/8lFhVVku5sg1urXHBQ==</ds:SignatureValue></ds:Signature><saml:Subject><saml:NameID>admin@acme.com</saml:NameID></saml:Subject><saml:Conditions NotBefore=\"2026-07-24T09:59:00Z\" NotOnOrAfter=\"2026-07-24T10:05:00Z\"><saml:AudienceRestriction><saml:Audience>https://sp.example.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AttributeStatement><saml:Attribute Name=\"email\"><saml:AttributeValue>dana@acme.com</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion>";
const WRAPPED_RESPONSE = "<samlp:Response xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\" xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\"><saml:Assertion ID=\"_evil\" Version=\"2.0\" IssueInstant=\"2026-07-24T10:00:00Z\"><saml:Issuer>https://idp.acme.com</saml:Issuer><saml:Subject><saml:NameID>attacker@evil.com</saml:NameID></saml:Subject></saml:Assertion><saml:Assertion xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\" ID=\"_a1\" IssueInstant=\"2026-07-24T10:00:00Z\" Version=\"2.0\"><saml:Issuer>https://idp.acme.com</saml:Issuer><ds:Signature xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:SignedInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"><ds:CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/><ds:SignatureMethod Algorithm=\"http://www.w3.org/2001/04/xmldsig-more#rsa-sha256\"/><ds:Reference URI=\"#_a1\"><ds:Transforms><ds:Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><ds:Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/></ds:Transforms><ds:DigestMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#sha256\"/><ds:DigestValue>0/28W7qK+tntkD2Eq2AcU58NlD/GHI1xIgAmmg5tlek=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>MdoXSYTJbpZfW9TCPXNolSECe096YhXWyiBrHAK7oW2SKqqEYaJDtYoSnfwPA0LHR3ZczIpGUUk73pX0LnhS73jIF5qV2EUqmxfT8vVsJATUFi3UbC0X7INPP9MX2QwwS7f0GHA1e/LNUL+vWddHKfYWOvwm17GlB33t/8sJ/t+J/7bIX2Cd5Kgmk24dEmx+5UQK/7A2l9z40JDiwoiDXtfmqzQ2YJXUwDjcOfxfUv+qkslGT1CEpX/ZcbHNHuR3vdd132iglsCp5Qx7so+u1yTq+wQZJYcFcXDDLChR+GjCMKavV+nhjN96GHuZrMFtjCh/8lFhVVku5sg1urXHBQ==</ds:SignatureValue></ds:Signature><saml:Subject><saml:NameID>dana@acme.com</saml:NameID></saml:Subject><saml:Conditions NotBefore=\"2026-07-24T09:59:00Z\" NotOnOrAfter=\"2026-07-24T10:05:00Z\"><saml:AudienceRestriction><saml:Audience>https://sp.example.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AttributeStatement><saml:Attribute Name=\"email\"><saml:AttributeValue>dana@acme.com</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion></samlp:Response>";

const SAMPLE =
    "<library xmlns=\"urn:lib\" name=\"City\">" ++
    "<book isbn=\"1\"><title>Dune</title><year>1965</year></book>" ++
    "<book isbn=\"2\"><title>Ubik</title><year>1969</year></book>" ++
    "</library>";

test "query: paths, indices and //anywhere" {
    var out: [1024]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 1), xml_valid(SAMPLE.ptr, SAMPLE.len));

    var n = xml_root(SAMPLE.ptr, SAMPLE.len, &out, out.len);
    try std.testing.expectEqualStrings("library", out[0..@intCast(n)]);

    // a walked path
    const p1 = "library/book/title";
    n = xml_text(SAMPLE.ptr, SAMPLE.len, p1.ptr, p1.len, &out, out.len);
    try std.testing.expectEqualStrings("Dune", out[0..@intCast(n)]);

    // an INDEXED step
    const p2 = "library/book[2]/title";
    n = xml_text(SAMPLE.ptr, SAMPLE.len, p2.ptr, p2.len, &out, out.len);
    try std.testing.expectEqualStrings("Ubik", out[0..@intCast(n)]);

    // //anywhere
    const p3 = "//year";
    n = xml_text(SAMPLE.ptr, SAMPLE.len, p3.ptr, p3.len, &out, out.len);
    try std.testing.expectEqualStrings("1965", out[0..@intCast(n)]);

    // an attribute, and the namespace
    const p4 = "library/book[2]";
    n = xml_attr(SAMPLE.ptr, SAMPLE.len, p4.ptr, p4.len, "isbn".ptr, 4, &out, out.len);
    try std.testing.expectEqualStrings("2", out[0..@intCast(n)]);
    n = xml_namespace(SAMPLE.ptr, SAMPLE.len, p4.ptr, p4.len, &out, out.len);
    try std.testing.expectEqualStrings("urn:lib", out[0..@intCast(n)]);

    // counting + children
    const p5 = "library/book";
    try std.testing.expectEqual(@as(i32, 2), xml_count(SAMPLE.ptr, SAMPLE.len, p5.ptr, p5.len));
    try std.testing.expectEqual(@as(i32, 2), xml_count(SAMPLE.ptr, SAMPLE.len, "//book".ptr, 6));
    n = xml_children(SAMPLE.ptr, SAMPLE.len, "library/book".ptr, 12, &out, out.len);
    try std.testing.expectEqualStrings("title\nyear", out[0..@intCast(n)]);
}

test "query: a missing path is reported, never guessed" {
    var out: [256]u8 = undefined;
    const p = "library/nope/title";
    try std.testing.expectEqual(@as(i32, -1), xml_text(SAMPLE.ptr, SAMPLE.len, p.ptr, p.len, &out, out.len));
    try std.testing.expectEqual(@as(i32, 0), xml_count(SAMPLE.ptr, SAMPLE.len, "library/nope".ptr, 12));
    try std.testing.expectEqual(@as(i32, 0), xml_valid("<broken>".ptr, 8));
    // a DOCTYPE is refused here too -- the same parser, the same refusal
    try std.testing.expectEqual(@as(i32, 0), xml_valid("<!DOCTYPE x><x/>".ptr, 16));
}

test "query: an explicit index asks about ONE element" {
    // two books exist, so book[2] is present and book[9] is not
    try std.testing.expectEqual(@as(i32, 2), xml_count(SAMPLE.ptr, SAMPLE.len, "library/book".ptr, 12));
    try std.testing.expectEqual(@as(i32, 1), xml_count(SAMPLE.ptr, SAMPLE.len, "library/book[2]".ptr, 15));
    try std.testing.expectEqual(@as(i32, 0), xml_count(SAMPLE.ptr, SAMPLE.len, "library/book[9]".ptr, 15));
    try std.testing.expectEqual(@as(i32, 0), xml_count(SAMPLE.ptr, SAMPLE.len, "//title[9]".ptr, 10));
}

test "query: text and attributes come back DECODED" {
    const doc = "<r a=\"x &amp; y\"><t>Tom &amp; Jerry &lt;fun&gt;</t></r>";
    var out: [256]u8 = undefined;
    var n = xml_text(doc.ptr, doc.len, "r/t".ptr, 3, &out, out.len);
    try std.testing.expectEqualStrings("Tom & Jerry <fun>", out[0..@intCast(n)]);
    n = xml_attr(doc.ptr, doc.len, "r".ptr, 1, "a".ptr, 1, &out, out.len);
    try std.testing.expectEqualStrings("x & y", out[0..@intCast(n)]);
}

test "query: pretty printing indents the tree" {
    var out: [2048]u8 = undefined;
    const n = xml_pretty(SAMPLE.ptr, SAMPLE.len, &out, out.len);
    try std.testing.expect(n > 0);
    const s2 = out[0..@intCast(n)];
    try std.testing.expect(std.mem.indexOf(u8, s2, "\n  <book") != null);
    try std.testing.expect(std.mem.indexOf(u8, s2, "\n    <title>Dune</title>") != null);
}
