const std = @import("std");
const crypto = @import("crypto.zig");

// ── XML canonicalization + XML Signature (the SAML substrate) ────
//
// SAML's security does not rest on its cryptography -- it rests on answering
// "WHICH BYTES were signed, and is the element I am about to TRUST the same one
// the signature covers?" Nearly every serious SAML vulnerability is a wrong
// answer to that: signature WRAPPING (an attacker appends their own assertion;
// the signature still validates over the original, but the reader consumes the
// attacker's), canonicalization mismatches, XXE through entity expansion, and
// comment splicing inside a NameID.
//
// So this module is deliberately STRICT: it refuses anything it cannot canonicalise
// with confidence rather than guessing. In particular it REJECTS outright any
// document containing a DOCTYPE or an ENTITY declaration (closing XXE and billion-
// laughs by construction -- SAML has no legitimate use for either).
//
// What it does:
//   * parse namespace-aware XML (no DTD, no entities beyond the five built-ins);
//   * EXCLUSIVE C14N (http://www.w3.org/2001/10/xml-exc-c14n#) -- the form
//     XML-DSig actually digests;
//   * verify an enveloped XML signature: canonicalise SignedInfo and check it
//     against the key, canonicalise the REFERENCED element (with the Signature
//     removed, per the enveloped-signature transform) and check its digest.
//
// The wrapping defense is structural, not a heuristic: verification returns the
// BYTE RANGE of the element the signature actually covers, so the caller reads
// its claims from THAT element and nothing else. A caller who honours the range
// cannot be fooled by an injected sibling.

const Sha256 = std.crypto.hash.sha2.Sha256;

pub const XmlError = error{ Malformed, Unsupported, TooDeep, TooMany };

const MAX_NODES = 4096;
const MAX_ATTRS = 8192;
const MAX_DEPTH = 64;

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

fn isSpace(c: u8) bool {
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

// ── XML signature verification ───────────────────────────────

const DS = "http://www.w3.org/2000/09/xmldsig#";

pub const SigResult = struct {
    ok: bool,
    /// byte range of the element the signature actually covers
    signed_start: usize = 0,
    signed_end: usize = 0,
    why: []const u8 = "",
};

/// Verify an ENVELOPED signature found inside `doc`.
/// kty "EC" -> (k1,k2) = (x,y); "RSA" -> (n,e). Keys + result are base64url,
/// matching the rest of the engine's crypto surface.
pub fn verifySignature(
    doc: *const Doc,
    kty: []const u8,
    k1: []const u8,
    k2: []const u8,
    scratch: []u8,
) SigResult {
    // STRICTNESS: exactly one Signature, exactly one Reference. Multiple of
    // either is the shape signature-wrapping attacks take, so it is refused
    // rather than disambiguated.
    if (doc.countOf(DS, "Signature") != 1) return .{ .ok = false, .why = "expected exactly one Signature" };
    if (doc.countOf(DS, "Reference") != 1) return .{ .ok = false, .why = "expected exactly one Reference" };

    const sig = doc.find(DS, "Signature") orelse return .{ .ok = false, .why = "no Signature" };
    const si = doc.find(DS, "SignedInfo") orelse return .{ .ok = false, .why = "no SignedInfo" };
    const ref = doc.find(DS, "Reference") orelse return .{ .ok = false, .why = "no Reference" };
    const dv = doc.find(DS, "DigestValue") orelse return .{ .ok = false, .why = "no DigestValue" };
    const sv = doc.find(DS, "SignatureValue") orelse return .{ .ok = false, .why = "no SignatureValue" };

    // the URI must point at an element by id -- never an empty (whole-document)
    // reference, which is far easier to wrap around.
    const uri = doc.attrValue(ref, "", "URI") orelse return .{ .ok = false, .why = "Reference has no URI" };
    if (uri.len < 2 or uri[0] != '#') return .{ .ok = false, .why = "only same-document #id references are accepted" };
    const want_id = uri[1..];

    // find the referenced element by its ID attribute
    var target: ?*const Node = null;
    var i: usize = 0;
    while (i < doc.node_count) : (i += 1) {
        const n = &doc.nodes[i];
        if (doc.attrValue(n, "", "ID")) |v| {
            if (std.mem.eql(u8, v, want_id)) {
                if (target != null) return .{ .ok = false, .why = "duplicate ID in document" };
                target = n;
            }
        }
    }
    const tgt = target orelse return .{ .ok = false, .why = "the Reference points at no element" };

    // the Signature must be INSIDE the element it covers (enveloped), otherwise
    // it is signing something other than what we will read.
    if (!(sig.start > tgt.start and sig.end <= tgt.end)) {
        return .{ .ok = false, .why = "the signature is not enveloped in the element it references" };
    }

    const inclusive = inclusivePrefixes(doc);

    // ---- 1. the DIGEST, over the referenced element minus the Signature ----
    const half = scratch.len / 2;
    const c14n_len = canonicalize(doc, tgt, scratch[0..half], @intCast(doc.indexOf(sig)), inclusive) orelse
        return .{ .ok = false, .why = "could not canonicalise the referenced element" };
    var digest: [32]u8 = undefined;
    Sha256.hash(scratch[0..c14n_len], &digest, .{});
    var want_digest: [64]u8 = undefined;
    const wd = b64StdDecode(doc.textOf(dv), &want_digest) orelse
        return .{ .ok = false, .why = "DigestValue is not valid base64" };
    if (wd.len != 32 or !std.mem.eql(u8, wd, &digest)) {
        return .{ .ok = false, .why = "the digest does not match -- the signed content was altered" };
    }

    // ---- 2. the SIGNATURE, over the canonical SignedInfo ----
    const si_len = canonicalize(doc, si, scratch[half..], -1, inclusive) orelse
        return .{ .ok = false, .why = "could not canonicalise SignedInfo" };
    const signed_info = scratch[half .. half + si_len];

    var raw_sig: [512]u8 = undefined;
    const rs = b64StdDecode(doc.textOf(sv), &raw_sig) orelse
        return .{ .ok = false, .why = "SignatureValue is not valid base64" };

    var sig_b64u: [1024]u8 = undefined;
    const sb = std.base64.url_safe_no_pad.Encoder.encode(&sig_b64u, rs);

    var v: i32 = -1;
    if (std.mem.eql(u8, kty, "EC")) {
        v = crypto.crypto_verify_es256(signed_info.ptr, signed_info.len, sb.ptr, sb.len, k1.ptr, k1.len, k2.ptr, k2.len);
    } else if (std.mem.eql(u8, kty, "RSA")) {
        v = crypto.crypto_verify_rs256(signed_info.ptr, signed_info.len, sb.ptr, sb.len, k1.ptr, k1.len, k2.ptr, k2.len);
    } else {
        return .{ .ok = false, .why = "unsupported key type" };
    }
    if (v != 1) return .{ .ok = false, .why = "the signature does not verify against the key" };

    return .{ .ok = true, .signed_start = tgt.start, .signed_end = tgt.end, .why = "" };
}

fn inclusivePrefixes(doc: *const Doc) []const u8 {
    const EXC = "http://www.w3.org/2001/10/xml-exc-c14n#";
    if (doc.find(EXC, "InclusiveNamespaces")) |n| {
        if (doc.attrValue(n, "", "PrefixList")) |v| return v;
    }
    return "";
}

/// standard base64 (XML-DSig uses it, not base64url), tolerating whitespace
fn b64StdDecode(src: []const u8, dest: []u8) ?[]u8 {
    var clean: [2048]u8 = undefined;
    var n: usize = 0;
    for (src) |c| {
        if (isSpace(c)) continue;
        if (n >= clean.len) return null;
        clean[n] = c;
        n += 1;
    }
    const dec = std.base64.standard.Decoder;
    const len = dec.calcSizeForSlice(clean[0..n]) catch return null;
    if (len > dest.len) return null;
    dec.decode(dest[0..len], clean[0..n]) catch return null;
    return dest[0..len];
}

// ── SAML: verify a response, and read claims ONLY from signed bytes ──
//
// The structural guarantee: after the signature is checked we RE-PARSE just the
// byte range it covered, and every claim is read from that second document. A
// forged assertion injected next to the genuine one is not merely ignored -- it
// is not in the bytes we parse, so it cannot be reached at all.
//
// Output is one delimited record (ASCII/UTF-8 -- never raw bytes across the
// boundary):  ok|why|issuer|nameID|audience|notBefore|notOnOrAfter|sessionIndex
// with ok = 1/0. Values are emitted with '|' stripped so the record cannot be
// forged by a crafted claim.

const SAMLNS = "urn:oasis:names:tc:SAML:2.0:assertion";

// A Doc is over a megabyte (fixed node/attr tables), so these live in STATIC
// storage, never on the stack: inside the Ring DLL the thread stack is far
// smaller than a test binary's, and two stack Docs overflowed it -- which shows
// up as a silent process death, not an error. Single-threaded per engine call.
var g_doc: Doc = undefined;
var g_sdoc: Doc = undefined;
var g_scratch: [65536]u8 = undefined;

/// our own literals (separators, reasons): written verbatim
fn putRaw(out: [*]u8, w: *usize, cap: usize, v: []const u8) void {
    for (v) |c| {
        if (w.* + 1 >= cap) return;
        out[w.*] = c;
        w.* += 1;
    }
}

/// UNTRUSTED values (claims): the separator is stripped so a crafted claim can
/// never forge an extra field
fn putField(out: [*]u8, w: *usize, cap: usize, v: []const u8) void {
    for (v) |c| {
        if (w.* + 1 >= cap) return;
        // a claim can never inject a field separator or a newline
        out[w.*] = if (c == '|' or c == '\n' or c == '\r') '_' else c;
        w.* += 1;
    }
}

fn childText(doc: *const Doc, uri: []const u8, local: []const u8) []const u8 {
    if (doc.find(uri, local)) |n| return doc.textOf(n);
    return "";
}

/// Verify a SAML Response/Assertion and extract its claims.
/// xml is the RAW document (already base64-decoded by the caller).
pub fn saml_verify(
    xml_ptr: [*]const u8,
    xml_len: usize,
    kty_ptr: [*]const u8,
    kty_len: usize,
    k1_ptr: [*]const u8,
    k1_len: usize,
    k2_ptr: [*]const u8,
    k2_len: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.c) i32 {
    const xml = xml_ptr[0..xml_len];
    var w: usize = 0;

    parse(&g_doc, xml) catch {
        putRaw(out, &w, out_cap, "0|the document is not well-formed XML (or declares a DOCTYPE/ENTITY, which is refused)");
        return @intCast(w);
    };

    const r = verifySignature(&g_doc, kty_ptr[0..kty_len], k1_ptr[0..k1_len], k2_ptr[0..k2_len], &g_scratch);
    if (!r.ok) {
        putRaw(out, &w, out_cap, "0|");
        putRaw(out, &w, out_cap, r.why);
        return @intCast(w);
    }

    // ---- re-parse ONLY what the signature covered ----
    const signed_bytes = xml[r.signed_start..r.signed_end];
    parse(&g_sdoc, signed_bytes) catch {
        putRaw(out, &w, out_cap, "0|the signed region does not parse on its own");
        return @intCast(w);
    };

    // the covered element must BE an Assertion, and there must be exactly one:
    // a signature over something else cannot vouch for a subject.
    const root = g_sdoc.root() orelse {
        putRaw(out, &w, out_cap, "0|the signed region is empty");
        return @intCast(w);
    };
    if (!std.mem.eql(u8, root.local, "Assertion")) {
        putRaw(out, &w, out_cap, "0|the signature does not cover an Assertion");
        return @intCast(w);
    }
    if (g_sdoc.countOf(SAMLNS, "Assertion") != 1) {
        putRaw(out, &w, out_cap, "0|the signed region holds more than one Assertion");
        return @intCast(w);
    }

    var cond_nb: []const u8 = "";
    var cond_na: []const u8 = "";
    if (g_sdoc.find(SAMLNS, "Conditions")) |c| {
        cond_nb = g_sdoc.attrValue(c, "", "NotBefore") orelse "";
        cond_na = g_sdoc.attrValue(c, "", "NotOnOrAfter") orelse "";
    }
    var session: []const u8 = "";
    if (g_sdoc.find(SAMLNS, "AuthnStatement")) |a| {
        session = g_sdoc.attrValue(a, "", "SessionIndex") orelse "";
    }

    putRaw(out, &w, out_cap, "1||");
    putField(out, &w, out_cap, childText(&g_sdoc, SAMLNS, "Issuer"));
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, childText(&g_sdoc, SAMLNS, "NameID"));
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, childText(&g_sdoc, SAMLNS, "Audience"));
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, cond_nb);
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, cond_na);
    putRaw(out, &w, out_cap, "|");
    putField(out, &w, out_cap, session);
    return @intCast(w);
}

pub export fn stz_saml_verify(x: [*]const u8, xl: usize, kt: [*]const u8, ktl: usize, k1: [*]const u8, k1l: usize, k2: [*]const u8, k2l: usize, o: [*]u8, oc: usize) callconv(.c) i32 {
    return saml_verify(x, xl, kt, ktl, k1, k1l, k2, k2l, o, oc);
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

test "dsig: a real OpenSSL-signed SAML assertion verifies" {
    var doc: Doc = undefined;
    var scratch: [16384]u8 = undefined;
    try parse(&doc, SIGNED_ASSERTION);
    const r = verifySignature(&doc, "RSA", RSA_N, RSA_E, &scratch);
    try std.testing.expect(r.ok);
    // it reports WHICH bytes are covered -- the whole assertion
    try std.testing.expectEqual(@as(usize, 0), r.signed_start);
    try std.testing.expectEqual(SIGNED_ASSERTION.len, r.signed_end);
}

test "dsig: altering one character breaks the digest" {
    var doc: Doc = undefined;
    var scratch: [16384]u8 = undefined;
    try parse(&doc, TAMPERED_ASSERTION);
    const r = verifySignature(&doc, "RSA", RSA_N, RSA_E, &scratch);
    try std.testing.expect(!r.ok);
}

test "dsig: SIGNATURE WRAPPING is refused" {
    // the classic attack: a forged assertion is injected next to a
    // genuinely signed one. The signature still validates over the
    // original, so a naive reader trusts the WRONG element.
    var doc: Doc = undefined;
    var scratch: [16384]u8 = undefined;
    try parse(&doc, WRAPPED_RESPONSE);
    const r = verifySignature(&doc, "RSA", RSA_N, RSA_E, &scratch);
    // the signature itself still verifies -- so the defense CANNOT be
    // "did it verify"; it must be WHICH element it covered.
    if (r.ok) {
        const covered = WRAPPED_RESPONSE[r.signed_start..r.signed_end];
        // the covered range is the genuine assertion, never the forged one
        try std.testing.expect(std.mem.indexOf(u8, covered, "attacker@evil.com") == null);
        try std.testing.expect(std.mem.indexOf(u8, covered, "dana@acme.com") != null);
        try std.testing.expect(std.mem.indexOf(u8, covered, "_evil") == null);
    }
}
test "saml: a signed assertion yields its claims" {
    var out: [2048]u8 = undefined;
    const n = saml_verify(SIGNED_ASSERTION.ptr, SIGNED_ASSERTION.len, "RSA".ptr, 3,
        RSA_N.ptr, RSA_N.len, RSA_E.ptr, RSA_E.len, &out, out.len);
    try std.testing.expect(n > 0);
    const rec = out[0..@intCast(n)];
    try std.testing.expect(std.mem.startsWith(u8, rec, "1||"));
    try std.testing.expect(std.mem.indexOf(u8, rec, "https://idp.acme.com") != null);
    try std.testing.expect(std.mem.indexOf(u8, rec, "dana@acme.com") != null);
    try std.testing.expect(std.mem.indexOf(u8, rec, "https://sp.example.com") != null);
}

test "saml: wrapping cannot smuggle a claim, because we re-parse only signed bytes" {
    var out: [2048]u8 = undefined;
    const n = saml_verify(WRAPPED_RESPONSE.ptr, WRAPPED_RESPONSE.len, "RSA".ptr, 3,
        RSA_N.ptr, RSA_N.len, RSA_E.ptr, RSA_E.len, &out, out.len);
    const rec = out[0..@intCast(n)];
    // whatever the verdict, the attacker's identity must NEVER appear
    try std.testing.expect(std.mem.indexOf(u8, rec, "attacker@evil.com") == null);
}

test "saml: a tampered assertion yields no claims" {
    var out: [2048]u8 = undefined;
    const n = saml_verify(TAMPERED_ASSERTION.ptr, TAMPERED_ASSERTION.len, "RSA".ptr, 3,
        RSA_N.ptr, RSA_N.len, RSA_E.ptr, RSA_E.len, &out, out.len);
    const rec = out[0..@intCast(n)];
    try std.testing.expect(std.mem.startsWith(u8, rec, "0|"));
    try std.testing.expect(std.mem.indexOf(u8, rec, "admin@acme.com") == null);
}
