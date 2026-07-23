load "../../stzBase.ring"
load "../_narrated.ring"

# StzLeft / StzRight / StzMid / StzMidToEnd -- the codepoint contract.
#
# These four are the library's "codepoint-aware" substring primitives, and for
# a long time they were nothing of the sort: each took a CODEPOINT count from
# StzEngineStringCount() and handed it to the engine's BYTE-addressed slice
# (str_left / str_right / str_mid). On ASCII that is the same number, so every
# test passed. On anything else the byte slice either cut mid-character -- and
# the engine's utf-8 validation returned "" -- or landed on a boundary by luck
# and returned a SILENTLY TRUNCATED string.
#
# The engine always had the right family (str_left_cp / str_right_cp /
# str_mid_cp, INDEX_BASE=1, codepoint counts); the wrappers simply called the
# wrong one. The archived monolithic stzString even used the *Cp bridges. The
# fix is to call them -- no engine change, no rebuild.
#
# This guard pins the contract in four alphabets plus the degenerate inputs,
# so the byte/codepoint confusion cannot come back unnoticed.

cAscii  = "abcdef"
cLatin  = "café-naïve"          # accented latin: 10 codepoints, 12 bytes
cArabic = "كسكس"                # 4 codepoints, 8 bytes
cMixed  = "a-كسكس"              # 6 codepoints, 10 bytes
cCJK    = "日本語テキスト"        # 7 codepoints, 21 bytes
cEmoji  = "a😀b😀c"              # 5 codepoints, 11 bytes (emoji are 4 bytes each)

Scenario("the counts themselves: codepoints, not bytes")
	Then("StzLen counts codepoints for latin", StzLen(cLatin), 10)
	Then("...and len() still counts BYTES (both are wanted, by intent)", len(cLatin), 12)
	Then("StzLen counts codepoints for arabic", StzLen(cArabic), 4)
	Then("...emoji count as one codepoint each", StzLen(cEmoji), 5)
EndScenario()

Scenario("StzLeft takes N CHARACTERS from the left")
	Then("ascii is unchanged (bytes == codepoints here)", StzLeft(cAscii, 3), "abc")
	Then("accented latin", StzLeft(cLatin, 4), "café")
	Then("arabic", StzLeft(cArabic, 2), "كس")
	Then("CJK", StzLeft(cCJK, 3), "日本語")
	Then("emoji", StzLeft(cEmoji, 2), "a😀")
	# was "": 4 BYTES of "café" cuts the é in half -> invalid utf-8 -> empty
	Then("REGRESSION: the byte slice used to return empty here", StzLeft("café-كسكس", 4), "café")
EndScenario()

Scenario("StzRight takes N CHARACTERS from the right")
	Then("ascii", StzRight(cAscii, 3), "def")
	Then("accented latin", StzRight(cLatin, 5), "naïve")
	Then("arabic", StzRight(cArabic, 2), "كس")
	Then("emoji", StzRight(cEmoji, 2), "😀c")
	# was "كس": 4 BYTES from the right is only 2 arabic characters
	Then("REGRESSION: the byte slice used to return half of this", StzRight("café-كسكس", 4), "كسكس")
EndScenario()

Scenario("StzMid takes a 1-based START and a CHARACTER count")
	Then("ascii", StzMid(cAscii, 2, 3), "bcd")
	Then("accented latin", StzMid(cLatin, 5, 2), "-n")
	Then("arabic", StzMid(cArabic, 2, 2), "سك")
	Then("emoji spanning both sides", StzMid(cEmoji, 2, 3), "😀b😀")
	Then("CJK", StzMid(cCJK, 4, 3), "テキス")
EndScenario()

Scenario("StzMidToEnd takes everything from a 1-based START")
	Then("ascii", StzMidToEnd(cAscii, 3), "cdef")
	Then("accented latin", StzMidToEnd(cLatin, 6), "naïve")
	# was "": count-in-codepoints applied as a byte length ran off the end
	Then("REGRESSION: arabic used to come back empty", StzMidToEnd(cArabic, 2), "سكس")
	# was "كس": the classic half-truncation that corrupted POSTed form values
	Then("REGRESSION: mixed used to come back half-length", StzMidToEnd(cMixed, 3), "كسكس")
	Then("emoji", StzMidToEnd(cEmoji, 4), "😀c")
EndScenario()

Scenario("round trips: left + right, and mid over the whole string")
	Then("left(2)+midToEnd(3) reassembles arabic",
	     StzLeft(cArabic, 2) + StzMidToEnd(cArabic, 3), cArabic)
	Then("...and mixed", StzLeft(cMixed, 2) + StzMidToEnd(cMixed, 3), cMixed)
	Then("mid over the full span is identity", StzMid(cEmoji, 1, StzLen(cEmoji)), cEmoji)
	Then("left(all) is identity", StzLeft(cCJK, StzLen(cCJK)), cCJK)
	Then("right(all) is identity", StzRight(cCJK, StzLen(cCJK)), cCJK)
EndScenario()

Scenario("degenerate input is lenient, never a panic")
	# StzLeft(x, -1) USED TO PANIC the engine: the byte bridge casts the count
	# to usize with @intFromFloat, and -1 is out of bounds for an unsigned int.
	# The Cp family takes a signed count and clamps <= 0 to zero.
	Then("a NEGATIVE count returns empty instead of killing the process",
	     StzLeft(cLatin, -1), "")
	Then("...on StzRight too", StzRight(cLatin, -5), "")
	Then("...and StzMid", StzMid(cLatin, 2, -3), "")
	Then("a zero count is empty", StzLeft(cAscii, 0), "")
	Then("an over-long count clamps to the end", StzMid("abc", 2, 99), "bc")
	Then("...on multibyte too", StzLeft(cArabic, 99), cArabic)
	Then("a start past the end is empty", StzMid("abc", 9, 2), "")
	Then("...for MidToEnd as well", StzMidToEnd(cArabic, 99), "")
	Then("a start below 1 is clamped to 1", StzMid("abc", 0, 2), "ab")
	Then("the empty string survives every call", StzMidToEnd("", 1) + StzLeft("", 3), "")
EndScenario()

Summary()
