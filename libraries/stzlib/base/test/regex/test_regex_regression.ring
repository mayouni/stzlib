# Integration regression suite for stzRegex.
# stzRegex has no dedicated test/ dir; the narrative tutorial at
# base/test/stzRegexTest.ring uses pr()/pf() profiler markers that
# raise STOPPED. This suite is profiler-free and covers the most-used
# surface: init/pattern, Match/HasMatch, Matches (all matches),
# IsValid, common pattern shapes (email, digits, anchors).
#
# Run from base/regex/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzRegex regression suite ==="

# ------------------------------------------------------------
# Init / Pattern / IsValid
# ------------------------------------------------------------
? ""
? "--- Init & Pattern ---"

oRx = new stzRegex("[0-9]+")
chk("Pattern() preserved",          oRx.Pattern() = "[0-9]+")
chk("IsValid() on simple pattern",  oRx.IsValid() = 1)

# Invalid pattern -- unclosed bracket
oRbad = new stzRegex("[0-9")
chk("IsValid() on broken pattern",  oRbad.IsValid() = 0)

# ------------------------------------------------------------
# Match / HasMatch
# ------------------------------------------------------------
? ""
? "--- Match / HasMatch ---"

oRn = new stzRegex("[0-9]+")
oRn.Match("abc123def")
chk("HasMatch() after Match()",     oRn.HasMatch() = 1)

oRn2 = new stzRegex("[0-9]+")
oRn2.Match("abcdef")
chk("HasMatch() on no-match",       oRn2.HasMatch() = 0)

# ------------------------------------------------------------
# Matches() (all matches)
# ------------------------------------------------------------
? ""
? "--- Matches() ---"

oRa = new stzRegex("[0-9]+")
oRa.Match("a1 b22 c333 d4")
aM = oRa.Matches()
chk("Matches() returns list",       isList(aM))
chk("Matches() count = 4",          len(aM) = 4)

# ------------------------------------------------------------
# Anchors
# ------------------------------------------------------------
? ""
? "--- Anchors ---"

oRanc = new stzRegex("^abc")
oRanc.Match("abcdef")
chk("^abc matches at start",        oRanc.HasMatch() = 1)

oRanc2 = new stzRegex("^abc")
oRanc2.Match("xyzabc")
chk("^abc does NOT match mid",      oRanc2.HasMatch() = 0)

oRanc3 = new stzRegex("xyz$")
oRanc3.Match("abcxyz")
chk("xyz$ matches at end",          oRanc3.HasMatch() = 1)

# ------------------------------------------------------------
# Character classes
# ------------------------------------------------------------
? ""
? "--- Character classes ---"

oRw = new stzRegex("\w+")
oRw.Match("Hello, World!")
chk("\\w+ matches words",           oRw.HasMatch() = 1)
aW = oRw.Matches()
chk("\\w+ finds 2 words",           len(aW) = 2)

oRd = new stzRegex("\d{3}")
oRd.Match("abc 123 456 78")
chk("\\d{3} matches 3-digit runs",  oRd.HasMatch() = 1)
aD = oRd.Matches()
chk("\\d{3} finds 2 groups",        len(aD) = 2)

# ------------------------------------------------------------
# Common shapes: email + URL fragments
# ------------------------------------------------------------
? ""
? "--- Real-world shapes ---"

cEmail = "Contact alice@x.com or bob@y.org for info"
oRe = new stzRegex("[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+")
oRe.Match(cEmail)
aE = oRe.Matches()
chk("email regex finds 2 addresses", len(aE) = 2 and aE[1] = "alice@x.com" and aE[2] = "bob@y.org")

cHex = "color #ff00aa and #123abc"
oRh = new stzRegex("#[0-9a-fA-F]{6}")
oRh.Match(cHex)
aH = oRh.Matches()
chk("hex color regex finds 2",      len(aH) = 2)

# ------------------------------------------------------------
# Empty / edge inputs
# ------------------------------------------------------------
? ""
? "--- Edges ---"

oRe2 = new stzRegex("[0-9]+")
oRe2.Match("")
chk("Match on empty string",        oRe2.HasMatch() = 0)

oRsingle = new stzRegex("a")
oRsingle.Match("a")
chk("Single-char pattern + input",  oRsingle.HasMatch() = 1)
aS = oRsingle.Matches()
chk("Single-char Matches() len=1",  len(aS) = 1 and aS[1] = "a")

# ------------------------------------------------------------
# Unicode-aware patterns
# ------------------------------------------------------------
? ""
? "--- Unicode ---"

cFr = "café résumé"
oRu = new stzRegex("[a-zé]+")
oRu.Match(cFr)
chk("Pattern with accent literal",  oRu.HasMatch() = 1)

# ------------------------------------------------------------
# Pattern reset
# ------------------------------------------------------------
? ""
? "--- SetPattern ---"

oRsp = new stzRegex("[0-9]+")
oRsp.Match("abc123")
chk("Pre-reset HasMatch",           oRsp.HasMatch() = 1)
oRsp.SetPattern("[a-z]+")
chk("Pattern after SetPattern",     oRsp.Pattern() = "[a-z]+")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzRegex CHECKS PASSED!"
else
	? "SOME stzRegex CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
