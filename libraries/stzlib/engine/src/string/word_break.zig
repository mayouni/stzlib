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

// ─── Sentence segmentation (UAX#29 Sentence_Break) ───
//
// Full UAX#29 Sentence_Break rule engine (SB3..SB11) over a Sentence_Break class
// derived from General_Category + the specific ATerm/STerm/SContinue/Sep/Close
// codepoints -- same approach as the word segmentation above. Handles decimals
// (SB6), initialisms like U.S.A (SB7), lowercase continuation after "etc."
// (SB8), SContinue/quotes/paragraph separators, and the many Unicode sentence
// terminators (。 ！ ？ ؟ । ...). ONE enhancement beyond the spec: UAX#29 does
// not detect abbreviations ("Dr. Smith" would split), so a break placed right
// after an ATerm following a known abbreviation / single initial is suppressed.

// Sentence_Break property class (UAX#29), derived from General_Category + the
// specific codepoints UAX#29 assigns (ATerm/STerm/SContinue/Sep...).
const SB = enum { other, cr, lf, sep, sp, extend, format, lower, upper, oletter, numeric, aterm, scontinue, sterm, close };

const PS = 14;
const PE = 15;
const PI = 16;
const PF = 17;

fn sbClass(cp: u21) SB {
    switch (cp) {
        0x000D => return .cr,
        0x000A => return .lf,
        0x0085, 0x2028, 0x2029 => return .sep,
        0x0009, 0x000B, 0x000C => return .sp, // tab / VT / FF (White_Space, not Sep)
        '.', 0x2024, 0xFE52, 0xFF0E => return .aterm,
        0x002C, 0x002D, 0x003A, 0x055D, 0x060C, 0x060D, 0x07F8, 0x1802, 0x1808, 0x2013, 0x2014, 0x3001, 0xFE50, 0xFE51, 0xFE55, 0xFF0C, 0xFF0D, 0xFF1A, 0xFF64 => return .scontinue,
        '!', '?', 0x0589, 0x061F, 0x06D4, 0x0700, 0x0701, 0x0702, 0x07F9, 0x0964, 0x0965, 0x104A, 0x104B, 0x1362, 0x1367, 0x1368, 0x166E, 0x1803, 0x1809, 0x1944, 0x1945, 0x1AA8, 0x1AA9, 0x1AAA, 0x1AAB, 0x1B5A, 0x1B5B, 0x1B5E, 0x1B5F, 0x1C3B, 0x1C3C, 0x1C7E, 0x1C7F, 0x203C, 0x203D, 0x2047, 0x2048, 0x2049, 0x2E2E, 0x2E3C, 0x3002, 0xA60E, 0xA60F, 0xA6F3, 0xA6F7, 0xA9C8, 0xA9C9, 0xAA5D, 0xAA5E, 0xAA5F, 0xAAF0, 0xAAF1, 0xABEB, 0xFE56, 0xFE57, 0xFF01, 0xFF1F, 0xFF61 => return .sterm,
        0x0022, 0x0027 => return .close, // straight quotes
        else => {},
    }
    if (cp < 0x80) {
        if (cp >= 'a' and cp <= 'z') return .lower;
        if (cp >= 'A' and cp <= 'Z') return .upper;
        if (cp >= '0' and cp <= '9') return .numeric;
        if (cp == ' ') return .sp;
        return switch (cp) {
            '(', ')', '[', ']', '{', '}' => .close,
            else => .other,
        };
    }
    const cat = unicode.stz_unicode_category(@intCast(cp));
    return switch (cat) {
        LL => .lower,
        LU, LT => .upper,
        LO, LM, NL => .oletter,
        ND => .numeric,
        MN, MC, ME => .extend,
        CF => .format,
        ZS => .sp,
        PS, PE, PI, PF => .close,
        else => .other,
    };
}

// SB8: after "ATerm Close* Sp*", scanning over chars that are none of
// {OLetter,Upper,Sep,CR,LF,STerm,ATerm}, do we reach a Lower first? Then the
// ATerm did NOT end a sentence (e.g. "etc. and ..." lowercase continuation).
fn sb8Lookahead(src: []const u8, from: usize) bool {
    var j = from;
    while (j < src.len) {
        const d = decodeAt(src, j);
        const c = sbClass(d.cp);
        switch (c) {
            .extend, .format => {},
            .oletter, .upper, .sep, .cr, .lf, .sterm, .aterm => return false,
            .lower => return true,
            else => {}, // numeric, close, sp, scontinue, other -> skip
        }
        j += d.len;
    }
    return false;
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

    // UAX#29 Sentence_Break (rules SB3..SB11) with one practical enhancement:
    // a break that SB would place right after an ATerm ('.') is suppressed when
    // the preceding token is a known abbreviation or a single initial (UAX#29
    // itself does NOT do abbreviation detection -- "Dr. Smith" would split --
    // so production tokenizers layer this on, as we do).
    pub fn next(self: *SentenceIter) ?Span {
        const src = self.src;
        if (self.i >= src.len) return null;
        const start = self.i;
        var i = self.i;
        var prev: SB = .sep; // class of the previous significant codepoint
        var term: SB = .other; // .aterm/.sterm once a terminator region is open
        var aterm_prev: SB = .other; // class right before the ATerm (SB7)
        var term_pos: usize = 0; // byte pos of the terminator (abbrev check)
        var saw_close_sp = false; // Close/Sp seen since the terminator (SB6/7 need immediacy)

        while (i < src.len) {
            const d = decodeAt(src, i);
            const cls = sbClass(d.cp);
            if (cls == .extend or cls == .format) { // SB5
                i += d.len;
                continue;
            }

            if (term != .other) {
                if (cls == .close) { // SB9
                    saw_close_sp = true;
                    prev = cls;
                    i += d.len;
                    continue;
                }
                if (cls == .sp) { // SB10
                    saw_close_sp = true;
                    prev = cls;
                    i += d.len;
                    continue;
                }
                if (cls == .scontinue or cls == .sterm or cls == .aterm) { // SB8a
                    if (cls == .aterm) {
                        term = .aterm;
                        aterm_prev = prev;
                        term_pos = i;
                        saw_close_sp = false;
                    } else if (cls == .sterm) {
                        term = .sterm;
                    }
                    prev = cls;
                    i += d.len;
                    continue;
                }
                if (cls == .sep or cls == .cr or cls == .lf) { // SB4: break AFTER
                    i += d.len;
                    if (cls == .cr and i < src.len and src[i] == 0x0A) i += 1;
                    self.i = i;
                    return .{ .start = start, .end = i };
                }
                if (term == .aterm and !saw_close_sp and cls == .numeric) { // SB6
                    term = .other;
                    prev = cls;
                    i += d.len;
                    continue;
                }
                if (term == .aterm and !saw_close_sp and cls == .upper and
                    (aterm_prev == .upper or aterm_prev == .lower)) // SB7
                {
                    term = .other;
                    prev = cls;
                    i += d.len;
                    continue;
                }
                if (term == .aterm and sb8Lookahead(src, i)) { // SB8
                    term = .other;
                    prev = cls;
                    i += d.len;
                    continue;
                }
                // Enhancement: suppress the break if the ATerm follows a known
                // abbreviation / single initial ("Dr.", "e.g.", "J.").
                if (term == .aterm and isAbbrevBefore(src, term_pos)) {
                    term = .other;
                    prev = cls;
                    i += d.len;
                    continue;
                }
                self.i = i; // SB11: break before this codepoint
                return .{ .start = start, .end = i };
            }

            if (cls == .sep or cls == .cr or cls == .lf) { // SB4
                i += d.len;
                if (cls == .cr and i < src.len and src[i] == 0x0A) i += 1;
                self.i = i;
                return .{ .start = start, .end = i };
            }
            if (cls == .aterm) {
                term = .aterm;
                aterm_prev = prev;
                term_pos = i;
                saw_close_sp = false;
                prev = cls;
                i += d.len;
                continue;
            }
            if (cls == .sterm) {
                term = .sterm;
                saw_close_sp = false;
                prev = cls;
                i += d.len;
                continue;
            }
            prev = cls;
            i += d.len;
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
