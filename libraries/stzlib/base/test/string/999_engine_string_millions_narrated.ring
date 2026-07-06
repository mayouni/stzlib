load "../../stzBase.ring"
load "../_narrated.ring"

# Engine STRESS suite for the string module at LARGE scale (hundreds of
# thousands to a few million CODEPOINTS), across the LINEAR-complexity engine
# ops: length, occurrence-count, find-all, replace, case-transform, reverse,
# split, chars, and the single-pass dup-consecutive scanners. Deterministic --
# asserts results, not timing.
#
# Large strings are built ENGINE-SIDE with Repeated() (StzEngineStringRepeat),
# then wrapped once -- so each op marshals a real multi-million-char buffer.
# It guards:
#   * NumberOfOccurrences / FindAll return ALL matches when there are > 65536
#     of them (a fixed-buffer bridge would cap / overflow),
#   * case transforms do NOT truncate long strings (the old 64-byte fast-path
#     silently cut every string past 64 bytes -- see feedback_engine_first),
#   * Unicode is codepoint-correct at scale (Arabic + emoji: length, count,
#     reverse all count CODEPOINTS, not bytes),
#   * Split is one-pass linear (was O(n^2): 50k separators took 60s).
#
# The O(n^2)-by-design substring-ENUMERATION family (SubStrings, DuplicatesCS,
# ConsecutiveSubStrings, occurrence, ...) is stressed at MODERATE length in
# 998_engine_string_largedata_narrated.ring -- enumerating all substrings of an
# n-char string is inherently Theta(n^2) OUTPUT and cannot run at millions.
#
# NOTE: literal counts are used in assertions on purpose -- a numeric global
# like `n`/`N` is clobbered by shared engine globals (Ring is case-insensitive).

# --- shared big string, built once, engine-side: "abab..." 2,000,000 chars ---
oAB  = new stzString("ab")
big  = new stzString( oAB.Repeated(1000000) )

Scenario("Multi-million-char string: length, membership, boundaries")
    Then("NumberOfChars is 2,000,000", big.NumberOfChars(), 2000000)
    Then("Contains 'ab' is TRUE", big.Contains("ab"), TRUE)
    Then("FindFirst 'ab' is 1", big.FindFirst("ab"), 1)
    Then("FindLast 'ab' is 1,999,999", big.FindLast("ab"), 1999999)
EndScenario()

Scenario("Occurrence count & find-all beyond the 65536 buffer")
    Then("NumberOfOccurrences('a') is 1,000,000 (> 65536)", big.NumberOfOccurrences("a"), 1000000)
    Then("FindAll('a') returns all 1,000,000 positions", len(big.FindAll("a")), 1000000)
    Then("NumberOfOccurrences('ab') is 1,000,000", big.NumberOfOccurrences("ab"), 1000000)
EndScenario()

Scenario("Case transform does NOT truncate long strings (64-byte regression)")
    oUp = new stzString( big.Uppercased() )
    Then("Uppercased keeps full 2,000,000 length", oUp.NumberOfChars(), 2000000)
    Then("Uppercased head is 'ABAB'", oUp.Section(1, 4), "ABAB")
    Then("Uppercased has 1,000,000 'A'", oUp.NumberOfOccurrences("A"), 1000000)
    Then("Uppercased has zero 'a'", oUp.NumberOfOccurrences("a"), 0)
EndScenario()

Scenario("Reverse at scale (codepoint-correct)")
    oRev = new stzString( big.Reversed() )
    Then("Reversed keeps full length", oRev.NumberOfChars(), 2000000)
    Then("Reversed head is 'ba'", oRev.Section(1, 2), "ba")
EndScenario()

Scenario("Replace at scale (a -> X over a million occurrences)")
    oRep = new stzString( oAB.Repeated(500000) )   # 1,000,000 chars
    oRep.Replace("a", "X")
    Then("after Replace, 'a' is gone", oRep.NumberOfOccurrences("a"), 0)
    Then("after Replace, 'X' is 500,000", oRep.NumberOfOccurrences("X"), 500000)
    Then("'b' is untouched at 500,000", oRep.NumberOfOccurrences("b"), 500000)
EndScenario()

Scenario("Split is one-pass linear (was O(n^2))")
    oXC = new stzString("x,")
    oCSV = new stzString( oXC.Repeated(200000) )  # 200,000 "x," pairs
    Then("Split(',') yields 200,000 parts", len(oCSV.Split(",")), 200000)
EndScenario()

Scenario("Chars() at scale")
    oA = new stzString("a")
    oBigA = new stzString( oA.Repeated(200000) )
    Then("Chars() returns 200,000 single chars", len(oBigA.Chars()), 200000)
EndScenario()

Scenario("Single-pass dup-consecutive scanners at scale (with CS)")
    oaA = new stzString("aA")
    mBig = new stzString( oaA.Repeated(500000) )  # "aAaA..." 1,000,000 chars
    Then("FindDupSecutiveCharsCS(1) is 0 (a <> A)", len(mBig.FindDupSecutiveCharsCS(1)), 0)
    Then("FindDupSecutiveCharsCS(0) is 999,999 (a == A folded)", len(mBig.FindDupSecutiveCharsCS(0)), 999999)
    oAB2 = new stzString("ab")
    bigab = new stzString( oAB2.Repeated(100000) )  # "abab..." 200,000 chars
    Then("FindDupSecutiveSubString('ab') is 99,999", len(bigab.FindDupSecutiveSubString("ab")), 99999)
EndScenario()

Scenario("Unicode at scale -- Arabic (codepoint, not byte)")
    Given("the 4-codepoint word 'سلام' repeated 100,000 times (400,000 cp)")
    oAr = new stzString("سلام")
    ar  = new stzString( oAr.Repeated(100000) )
    Then("NumberOfChars is 400,000 codepoints", ar.NumberOfChars(), 400000)
    Then("NumberOfOccurrences('سلام') is 100,000", ar.NumberOfOccurrences("سلام"), 100000)
    Then("Contains inner 'لا' is TRUE", ar.Contains("لا"), TRUE)
    Then("Reversed keeps 400,000 codepoints", StzLen(ar.Reversed()), 400000)
EndScenario()

Scenario("Unicode at scale -- emoji (surrogate-safe codepoints)")
    Given("'😀🎉' repeated 50,000 times (100,000 cp / 400,000 bytes)")
    oE = new stzString("😀🎉")
    e  = new stzString( oE.Repeated(50000) )
    Then("NumberOfChars is 100,000 codepoints", e.NumberOfChars(), 100000)
    Then("NumberOfOccurrences('😀') is 50,000", e.NumberOfOccurrences("😀"), 50000)
    Then("Reversed keeps 100,000 codepoints", StzLen(e.Reversed()), 100000)
EndScenario()

Summary()
