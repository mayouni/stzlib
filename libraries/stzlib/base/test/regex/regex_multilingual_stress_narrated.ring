# stzRegex STRESS -- matching under load, and in real scripts.
#
# Regex is where multibyte text usually breaks: a library that counts BYTES
# reports `.` as matching half a character, and match positions land mid
# codepoint. This checks that first, and it passes -- PCRE2 runs in UTF mode
# here, so `.` counts codepoints and \p{Arabic} resolves.
#
# What it also pins is a defect the module has NOT had fixed, because fixing
# it is a semantic decision rather than a repair: MatchXT VALIDATES its match
# TYPE and then ignores it. All four types produce the identical unanchored
# search, including :ReturnFalseForAnyMatch, whose own name promises the
# opposite. The assertions below record what the code ACTUALLY does, so the
# gap is visible rather than folklore.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder.
#
# Ring traps avoided: no local named oR (it IS the `or` keyword -- C27 several
# lines away from the real line), none named nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cAr   = MkW([ 0x0639, 0x0645 ])                 # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC ])                 # CJK
cGr   = MkW([ 0x03B1, 0x03B2 ])                 # Greek lower
cHeb  = MkW([ 0x05E9, 0x05DC ])                 # Hebrew

? "-- Scene 1: matching, on answers we can read off --"
oDig = new stzRegex("[0-9]+")
chk("digits are found in mixed text", oDig.Match("abc123"))
chk("...and absent when absent", oDig.Match("abc") = 0)
chk("HasMatch agrees with Match", oDig.HasMatch() = oDig.Match("abc"))

oAnch = new stzRegex("^[0-9]+$")
chk("an ANCHORED pattern rejects a partial match", oAnch.Match("abc123") = 0)
chk("...and accepts a whole one", oAnch.Match("123"))

? ""
? "-- Scene 2: the match TYPE is validated and then ignored --"
# MatchXT raises on an unknown type, so the parameter is clearly meant to
# mean something -- but nothing branches on it. All four give the same
# unanchored search. :ReturnFalseForAnyMatch is the plainest case: it
# returns TRUE on a match.
oT1 = new stzRegex("[0-9]+")
nEntire = oT1.MatchXT("abc123", 1, :MatchEntireContent, [])

oT2 = new stzRegex("[0-9]+")
nPartial = oT2.MatchXT("abc123", 1, :MatchEntireContentIfNotGoPartial, [])

oT3 = new stzRegex("[0-9]+")
nFirst = oT3.MatchXT("abc123", 1, :MatchFirstOccurrenceIfNotGoPartial, [])

oT4 = new stzRegex("[0-9]+")
nNever = oT4.MatchXT("abc123", 1, :ReturnFalseForAnyMatch, [])

? "  entire=" + nEntire + " partial=" + nPartial + " first=" + nFirst + " returnfalse=" + nNever
chk("all four match types return the SAME answer (they are inert)",
	nEntire = nPartial and nPartial = nFirst and nFirst = nNever)
chk(":MatchEntireContent does NOT anchor -- it finds a substring", nEntire = 1)
chk(":ReturnFalseForAnyMatch returns TRUE on a match, contradicting its name",
	nNever = 1)

# the parameter IS checked, which is what makes the silence surprising
bRaised = FALSE
try
	oT5 = new stzRegex("[0-9]+")
	oT5.MatchXT("abc123", 1, :NoSuchMatchType, [])
catch
	bRaised = TRUE
done
chk("an unknown match type is REJECTED, so the parameter is not decorative", bRaised)

? ""
? "-- Scene 3: multibyte subjects and patterns --"
oM1 = new stzRegex("[0-9]+")
chk("digits are found between Arabic runs", oM1.Match(cAr + "123" + cAr))
oM2 = new stzRegex("[0-9]+")
chk("...and not found when there are none", oM2.Match(cAr + cCJK) = 0)

oM3 = new stzRegex(cAr)
chk("an Arabic literal pattern finds itself", oM3.Match("x" + cAr + "y"))
oM4 = new stzRegex(cCJK)
chk("a CJK literal pattern finds itself", oM4.Match("x" + cCJK + "y"))
oM5 = new stzRegex(cHeb)
chk("a Hebrew literal pattern finds itself", oM5.Match("x" + cHeb + "y"))
oM6 = new stzRegex(cAr)
chk("a multibyte pattern is not found when absent", oM6.Match("xyz") = 0)

? ""
? "-- Scene 4: UTF mode -- does '.' count codepoints or bytes? --"
# Two Arabic letters are 2 codepoints and 4 bytes. If the engine were in
# byte mode, /^..$/ would fail and /^....$/ would succeed. This is the
# single check that separates a Unicode regex from a byte regex.
oU1 = new stzRegex("^..$")
chk("'.' counts CODEPOINTS: /^..$/ matches two Arabic letters", oU1.Match(cAr))
oU2 = new stzRegex("^....$")
chk("...and does NOT count bytes: /^....$/ does not", oU2.Match(cAr) = 0)

? ""
? "-- Scene 5: Unicode property classes --"
# These resolve against PCRE2's UCD -- the same script data the string layer
# now reads for Scripts().
oP1 = new stzRegex("^\p{Arabic}+$")
chk("\p{Arabic} matches Arabic", oP1.Match(cAr))
oP2 = new stzRegex("^\p{Greek}+$")
chk("\p{Greek} matches Greek", oP2.Match(cGr))
oP3 = new stzRegex("^\p{L}+$")
chk("\p{L} matches CJK letters", oP3.Match(cCJK))
oP4 = new stzRegex("^\p{Arabic}+$")
chk("\p{Arabic} does NOT match Greek", oP4.Match(cGr) = 0)

? ""
? "-- Scene 6: matching at scale --"
# The engine compiles AND matches in about no time; what used to cost was
# Ring-side validation on every call -- an options check that built a whole
# stzList object per match.
cSubj = ""
for i = 1 to 400
	cSubj += "line " + i + " with value " + (i * 7) + " ; "
next

oS = new stzRegex("[0-9]+")
t0 = clock()
for k = 1 to 400
	v = oS.MatchXT(cSubj, 1, :MatchEntireContent, [])
next
tMatch = (clock() - t0) / clockspersecond()
? "  400 matches over a " + len(cSubj) + "-byte subject in " + tMatch + " s"
chk("matching at scale stays fast (< 5s)", tMatch < 5)
chk("the match still succeeds", v = 1)

oBig = new stzRegex(cAr)
t0 = clock()
for k = 1 to 200
	v2 = oBig.MatchXT(cAr + cSubj, 1, :MatchEntireContent, [])
next
tML = (clock() - t0) / clockspersecond()
chk("multibyte matching at scale is fast too (< 5s)", tML < 5)
chk("...and still correct", v2 = 1)

? ""
? "-- Scene 7: options are checked, and bad ones refused --"
oO1 = new stzRegex("ABC")
chk("case-insensitive option is honoured",
	oO1.MatchXT("xxabcxx", 1, :MatchEntireContent, [ :CaseInsensitive ]) = 1)
oO2 = new stzRegex("ABC")
chk("...and without it the match fails",
	oO2.MatchXT("xxabcxx", 1, :MatchEntireContent, []) = 0)

bBadOpt = FALSE
try
	oO3 = new stzRegex("abc")
	oO3.MatchXT("abc", 1, :MatchEntireContent, [ :NoSuchOption ])
catch
	bBadOpt = TRUE
done
chk("an unknown option is refused", bBadOpt)

oO4 = new stzRegex("abc")
chk("an EMPTY option list is accepted",
	oO4.MatchXT("abc", 1, :MatchEntireContent, []) = 1)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
