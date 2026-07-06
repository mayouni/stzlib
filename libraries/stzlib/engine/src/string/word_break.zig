// UAX#29 word segmentation for Softanza -- the tokenization SEAM.
//
// Every text-analytics consumer (word/n-gram frequency, collocations, cosine,
// whole-word count, Words()) tokenizes through this module instead of the old
// inline "run of ASCII letters or any high byte" rule. That rule glued digits
// off words ("word2vec" -> "word"), glued CJK punctuation/emoji onto words, and
// made every non-Latin script one blob.
//
// This implements the Unicode Text Segmentation (UAX#29) WORD boundary rules
// (WB3..WB999). Like Qt's QUnicodeTools, we run the rule state machine ourselves;
// the per-codepoint Word_Break CLASS is derived from utf8proc's General_Category
// plus a small set of targeted codepoint ranges (the classes UAX#29 assigns that
// category alone can't express: CJK ideographs, kana, ZWJ, the Mid* punctuation).
//
// Deliberate, documented deviations from the letter of UAX#29, chosen for good
// NLP tokens rather than editor cursor movement:
//   * CJK ideographs + kana + Hiragana break PER CODEPOINT (UAX#29 default). True
//     semantic CJK/Thai/Khmer word segmentation needs a dictionary (libthai/ICU
//     dictionary) -- that is the documented future vendor step, exactly as Qt
//     links libthai for Thai. Scriptio-continua scripts (Thai/Lao/Khmer/Myanmar)
//     currently follow UAX#29 and form space-delimited runs.
//   * U+003A COLON is treated as a separator (Other), not MidLetter, so "foo:bar"
//     and "12:30" split -- desirable for prose/log tokenization.
//
// A "word token" is a maximal WB run whose first codepoint is a letter, a digit,
// kana, or a CJK ideograph; runs of pure punctuation / symbols / whitespace are
// separators and are skipped. That is what WordIter yields.

const std = @import("std");
const unicode = @import("../unicode.zig");

// utf8proc General_Category integer values (mirror of unicode.zig's CAT_*).
const LU = 1;
const LL = 2;
const LT = 3;
const LM = 4;
const LO = 5;
const MN = 6;
const MC = 7;
const ME = 8;
const ND = 9;
const NL = 10;
const NO = 11;
const PC = 12;
const CF = 27;
const ZS = 23;

pub const Class = enum {
    other,
    cr,
    lf,
    newline,
    extend,
    zwj,
    format,
    aletter, // ALetter + Hebrew_Letter folded in
    numeric,
    katakana,
    extnumlet, // Connector punctuation (e.g. underscore)
    midletter,
    midnum,
    midnumlet,
    squote, // '
    dquote, // "
    ideo, // CJK ideographs + Hiragana + kana we break per-codepoint
    wsegspace,
};

// ASCII (0..127) Word_Break class, precomputed at comptime so the hot path is a
// single array read rather than a branch cascade.
const ascii_class: [128]Class = blk: {
    var t: [128]Class = [_]Class{.other} ** 128;
    var i: usize = 0;
    while (i < 128) : (i += 1) {
        const b: u8 = @intCast(i);
        if ((b >= 'a' and b <= 'z') or (b >= 'A' and b <= 'Z')) {
            t[i] = .aletter;
        } else if (b >= '0' and b <= '9') {
            t[i] = .numeric;
        } else t[i] = switch (b) {
            0x0D => .cr,
            0x0A => .lf,
            0x0B, 0x0C => .newline,
            0x27 => .squote, // '
            0x22 => .dquote, // "
            0x2E => .midnumlet, // .
            0x2C => .midnum, // ,
            0x3B => .midnum, // ;
            0x5F => .extnumlet, // _
            0x20 => .wsegspace, // space
            else => .other, // tab, ':', '/', all other ASCII punctuation -> separator
        };
    }
    break :blk t;
};

// Word_Break class of a codepoint. ASCII is a table lookup (no utf8proc);
// CJK/kana via range checks; everything else falls back to General_Category.
pub fn classOf(cp: u21) Class {
    if (cp < 0x80) return ascii_class[cp];

    // Specific codepoints that UAX#29 assigns non-category-derivable classes.
    switch (cp) {
        0x200D => return .zwj,
        0x0085, 0x2028, 0x2029 => return .newline,
        0x00B7, 0x0387, 0x05F4, 0x2027 => return .midletter,
        0x055F, 0x066C, 0xFE50, 0xFE54, 0xFF0C, 0xFF1B => return .midnum,
        0x2018, 0x2019, 0x2024, 0xFE52, 0xFF07, 0xFF0E => return .midnumlet,
        0x00A0, 0x200E, 0x200F => return .format, // NBSP-ish / bidi marks kept out of words
        else => {},
    }

    // Kana: Katakana forms runs (WB13); Hiragana + CJK ideographs break per cp.
    if ((cp >= 0x30A1 and cp <= 0x30FA) or (cp >= 0x30FD and cp <= 0x30FF) or
        (cp >= 0x31F0 and cp <= 0x31FF) or (cp >= 0xFF66 and cp <= 0xFF9D)) return .katakana;
    if ((cp >= 0x3040 and cp <= 0x309F) or // Hiragana
        (cp >= 0x3400 and cp <= 0x4DBF) or // CJK Ext A
        (cp >= 0x4E00 and cp <= 0x9FFF) or // CJK Unified
        (cp >= 0xF900 and cp <= 0xFAFF) or // CJK Compat Ideographs
        (cp >= 0x20000 and cp <= 0x2FA1F)) return .ideo; // CJK Ext B..F + compat suppl

    // Regional indicators + emoji pictographs: treat as separators (not words).
    if (cp >= 0x1F000 and cp <= 0x1FAFF) return .other;

    const cat = unicode.stz_unicode_category(@intCast(cp));
    return switch (cat) {
        LU, LL, LT, LM, LO, NL => .aletter,
        MN, MC, ME => .extend,
        ND => .numeric,
        PC => .extnumlet,
        CF => .format,
        ZS => .wsegspace,
        NO => .other,
        else => .other,
    };
}

fn isWordStart(cls: Class) bool {
    return cls == .aletter or cls == .numeric or cls == .katakana or cls == .ideo;
}

fn isMid(cls: Class) bool {
    return cls == .midletter or cls == .midnum or cls == .midnumlet or cls == .squote or cls == .dquote;
}

// WB5/8/9/10/13/13a/13b: classes that join directly (no mid, no lookahead).
fn joinsDirect(prev: Class, cur: Class) bool {
    return switch (prev) {
        .aletter => cur == .aletter or cur == .numeric or cur == .extnumlet,
        .numeric => cur == .numeric or cur == .aletter or cur == .extnumlet,
        .katakana => cur == .katakana or cur == .extnumlet,
        .extnumlet => cur == .aletter or cur == .numeric or cur == .katakana or cur == .extnumlet,
        else => false,
    };
}

// WB6/7 (ALetter MidLetter/MidNumLet/' ALetter) and WB11/12 (Numeric
// MidNum/MidNumLet/' Numeric): join across the mid iff the char after it matches.
fn midJoins(prev: Class, mid: Class, after: Class) bool {
    if (prev == .aletter and after == .aletter) {
        return mid == .midletter or mid == .midnumlet or mid == .squote;
    }
    if (prev == .numeric and after == .numeric) {
        return mid == .midnum or mid == .midnumlet or mid == .squote;
    }
    return false;
}

const Decoded = struct { cp: u21, len: usize };

fn decodeAt(src: []const u8, i: usize) Decoded {
    const b = src[i];
    if (b < 0x80) return .{ .cp = b, .len = 1 }; // ASCII fast path (the common case)
    const l = std.unicode.utf8ByteSequenceLength(b) catch return .{ .cp = b, .len = 1 };
    if (i + l > src.len) return .{ .cp = b, .len = 1 };
    const cp = std.unicode.utf8Decode(src[i .. i + l]) catch return .{ .cp = b, .len = 1 };
    return .{ .cp = cp, .len = l };
}

pub const Span = struct { start: usize, end: usize };

// Iterates the WORD tokens of a byte slice per the rules above. Separators
// (whitespace / punctuation / symbol runs) are skipped; each next() returns the
// next word span or null at end.
pub const WordIter = struct {
    src: []const u8,
    i: usize = 0,
    // When true, an ideographic (CJK) run yields OVERLAPPING CHARACTER BIGRAMS
    // instead of single codepoints -- the standard dictionary-free CJK tokenizer
    // for search recall (cf. Lucene CJKBigramFilter). Non-CJK is unaffected.
    // 日本語 -> [日本, 本語, 語]. True dictionary word segmentation (ICU) is the
    // future upgrade; this is the self-contained interim.
    bigram: bool = false,

    pub fn init(src: []const u8) WordIter {
        return .{ .src = src, .i = 0 };
    }

    pub fn initBigram(src: []const u8) WordIter {
        return .{ .src = src, .i = 0, .bigram = true };
    }

    // Skip Extend/Format/ZWJ at self.i (WB4: they attach to the preceding char).
    fn consumeExtend(self: *WordIter) void {
        while (self.i < self.src.len) {
            const d = decodeAt(self.src, self.i);
            const c = classOf(d.cp);
            if (c == .extend or c == .format or c == .zwj) {
                self.i += d.len;
            } else break;
        }
    }

    // Class of the next significant (non Extend/Format/ZWJ) codepoint at/after j.
    fn peekSignificant(self: *WordIter, j0: usize) Class {
        var j = j0;
        while (j < self.src.len) {
            const d = decodeAt(self.src, j);
            const c = classOf(d.cp);
            if (c == .extend or c == .format or c == .zwj) {
                j += d.len;
                continue;
            }
            return c;
        }
        return .other;
    }

    pub fn next(self: *WordIter) ?Span {
        const src = self.src;
        // Skip separators to the next word-start codepoint.
        while (self.i < src.len) {
            const d = decodeAt(src, self.i);
            if (isWordStart(classOf(d.cp))) break;
            self.i += d.len;
        }
        if (self.i >= src.len) return null;
        const start = self.i;

        const first = decodeAt(src, self.i);
        const firstcls = classOf(first.cp);
        self.i += first.len;
        self.consumeExtend();

        // Ideographs break per codepoint (UAX#29 default). In bigram mode a CJK
        // run yields overlapping bigrams: pair this ideograph with the next one
        // (if any) but advance only past THIS one, so the next call starts on the
        // 2nd char -- 日本語 -> 日本, 本語, then 語 alone at the run's end.
        if (firstcls == .ideo) {
            if (self.bigram and self.i < src.len) {
                const d2 = decodeAt(src, self.i);
                if (classOf(d2.cp) == .ideo) return .{ .start = start, .end = self.i + d2.len };
            }
            return .{ .start = start, .end = self.i };
        }

        var prev = firstcls;
        while (self.i < src.len) {
            const d = decodeAt(src, self.i);
            const cls = classOf(d.cp);
            if (cls == .extend or cls == .format or cls == .zwj) {
                self.i += d.len; // WB4
                continue;
            }
            if (joinsDirect(prev, cls)) {
                self.i += d.len;
                self.consumeExtend();
                prev = cls;
                continue;
            }
            if (isMid(cls)) {
                const after = self.peekSignificant(self.i + d.len);
                if (midJoins(prev, cls, after)) {
                    self.i += d.len; // consume mid
                    self.consumeExtend();
                    const d2 = decodeAt(src, self.i); // consume the following letter/number
                    self.i += d2.len;
                    self.consumeExtend();
                    prev = classOf(d2.cp);
                    continue;
                }
            }
            break;
        }
        return .{ .start = start, .end = self.i };
    }
};

// ─── Sentence segmentation ───
//
// A pragmatic sentence segmenter -- a large improvement on "split on any .!?"
// without the full UAX#29 Sentence_Break machinery (which, like Qt, is the
// documented ICU/BreakIterator upgrade path). It breaks after a terminator
// (. ! ? and common Unicode variants) + optional closing quotes/brackets, only
// when followed by whitespace/end, and suppresses two big false-positive
// sources: decimals ("3.14" -- the '.' is followed by a digit, not space) and
// abbreviations ('.' after a single-letter initial like "J." or a short known
// abbreviation like "Dr.", "e.g.").

fn isTerminator(cp: u21) bool {
    return switch (cp) {
        '.', '!', '?' => true,
        0x2026, // … horizontal ellipsis
        0x061F, // ؟ arabic question mark
        0x06D4, // ۔ arabic full stop
        0x3002, // 。 ideographic full stop
        0xFF01, // ！ fullwidth !
        0xFF1F, // ？ fullwidth ?
        0x0964, // । devanagari danda
        => true,
        else => false,
    };
}

fn isClosing(cp: u21) bool {
    return switch (cp) {
        ')', ']', '}', '"', '\'', 0x00BB, 0x201D, 0x2019 => true,
        else => false,
    };
}

// Is the ASCII lowercase of the letter-run ending just before `dot_start` a
// recognised abbreviation (or a single initial)? Then a following '.' does not
// end a sentence.
fn isAbbrevBefore(src: []const u8, dot_start: usize) bool {
    // Walk back over ASCII letters (abbreviations we handle are ASCII).
    var s = dot_start;
    var n: usize = 0;
    while (s > 0) {
        const b = src[s - 1];
        if ((b >= 'a' and b <= 'z') or (b >= 'A' and b <= 'Z')) {
            s -= 1;
            n += 1;
        } else break;
    }
    if (n == 0) return false;
    if (n == 1) return true; // single initial: "J." "R."
    if (n > 5) return false;
    var buf: [5]u8 = undefined;
    var k: usize = 0;
    while (k < n) : (k += 1) {
        const c = src[s + k];
        buf[k] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    const w = buf[0..n];
    const abbrevs = [_][]const u8{ "mr", "mrs", "ms", "dr", "prof", "st", "vs", "etc", "eg", "ie", "inc", "ltd", "no", "fig", "al", "jr", "sr" };
    for (abbrevs) |a| {
        if (std.mem.eql(u8, w, a)) return true;
    }
    return false;
}

pub const SentenceIter = struct {
    src: []const u8,
    i: usize = 0,

    pub fn init(src: []const u8) SentenceIter {
        return .{ .src = src, .i = 0 };
    }

    pub fn next(self: *SentenceIter) ?Span {
        const src = self.src;
        if (self.i >= src.len) return null;
        const start = self.i;
        var j = self.i;
        while (j < src.len) {
            const d = decodeAt(src, j);
            if (isTerminator(d.cp)) {
                const term_start = j;
                var k = j + d.len;
                // Skip trailing closing quotes/brackets.
                while (k < src.len) {
                    const cd = decodeAt(src, k);
                    if (isClosing(cd.cp)) {
                        k += cd.len;
                    } else break;
                }
                // Boundary only if what follows is whitespace or end-of-text.
                var follows_break = k >= src.len;
                if (!follows_break) {
                    const nd = decodeAt(src, k);
                    follows_break = classOf(nd.cp) == .wsegspace or nd.cp == '\n' or nd.cp == '\r' or nd.cp == '\t';
                }
                if (follows_break and !(d.cp == '.' and isAbbrevBefore(src, term_start))) {
                    self.i = k;
                    return .{ .start = start, .end = k };
                }
            }
            j += d.len;
        }
        self.i = src.len;
        return .{ .start = start, .end = src.len };
    }
};

// Count the word tokens in a byte slice (WordIter) -- shared by sentence stats.
pub fn countWords(src: []const u8) usize {
    var wit = WordIter.init(src);
    var n: usize = 0;
    while (wit.next()) |_| n += 1;
    return n;
}
