# stzRegex STRESS -- matching under load, and in real scripts.
#
# Regex is where multibyte text usually breaks: a library that counts BYTES
# reports `.` as matching half a character, and match positions land mid
# codepoint. This checks that first, and it passes -- PCRE2 runs in UTF mode
# here, so `.` counts codepoints and \p{Arabic} resolves.
#
# The rest pins the MATCH TYPES, which are now honoured rather than merely
# validated. Match() ANCHORS -- it asks whether the pattern matches the whole
# string -- and MatchFirst() searches. An earlier version of this file
# recorded the opposite, because at the time MatchXT checked the type and
# then ran the same unanchored search whatever you passed.
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

? "-- Scene 1: Match ANCHORS, MatchFirst SEARCHES --"
oDig = new stzRegex("[0-9]+")
chk("Match is FALSE on 'abc123' -- that string is not a run of digits", oDig.Match("abc123") = 0)
chk("...and TRUE when the whole string IS digits", oDig.Match("123"))
oFnd = new stzRegex("[0-9]+")
chk("MatchFirst finds the digits inside 'abc123'", oFnd.MatchFirst("abc123"))
chk("...and reports none when there are none", oFnd.MatchFirst("abc") = 0)
oHm = new stzRegex("[0-9]+")
oHm.Match("abc")
chk("HasMatch agrees with the match that just ran", oHm.HasMatch() = 0)

oAnch = new stzRegex("^[0-9]+$")
chk("an explicitly anchored pattern rejects a partial match", oAnch.Match("abc123") = 0)
chk("...and accepts a whole one", oAnch.Match("123"))

? ""
? "-- Scene 2: the four match types each do something different --"
# Each type is a different question about the same subject and pattern.
oT1 = new stzRegex("[0-9]+")
nEntire = oT1.MatchXT("abc123", 1, :MatchEntireContent, [])

oT2 = new stzRegex("[0-9]+")
nFirst = oT2.MatchXT("abc123", 1, :MatchFirstOccurrenceIfNotGoPartial, [])

oT3 = new stzRegex("[0-9]+")
nNever = oT3.MatchXT("123", 1, :ReturnFalseForAnyMatch, [])

? "  entire(abc123)=" + nEntire + " first(abc123)=" + nFirst + " returnfalse(123)=" + nNever
chk(":MatchEntireContent says NO -- 'abc123' is not entirely digits", nEntire = 0)
chk(":MatchFirstOccurrence says YES -- there is a run in there", nFirst = 1)
chk("the two types DISAGREE on the same input, as they should", nEntire != nFirst)
chk(":ReturnFalseForAnyMatch returns false on a subject that matches entirely", nNever = 0)

oT4 = new stzRegex("[0-9]+")
chk("...and the same subject DOES match entirely when asked properly",
	oT4.MatchXT("123", 1, :MatchEntireContent, []) = 1)

# The partial types: 2 means "not yet, but on the way".
oP = new stzRegex("^\d{3}-\d{2}-\d{4}$")
nPart = oP.MatchXT("123-45", 1, :MatchEntireContentIfNotGoPartial, [])
oP2 = new stzRegex("^\d{3}-\d{2}-\d{4}$")
nDone = oP2.MatchXT("123-45-6789", 1, :MatchEntireContentIfNotGoPartial, [])
oP3 = new stzRegex("^\d{3}-\d{2}-\d{4}$")
nNope = oP3.MatchXT("abc", 1, :MatchEntireContentIfNotGoPartial, [])
? "  ssn: partial(123-45)=" + nPart + " complete(123-45-6789)=" + nDone + " hopeless(abc)=" + nNope
chk("a prefix of an SSN reports PARTIAL (2)", nPart = 2)
chk("a whole SSN reports COMPLETE (1)", nDone = 1)
chk("something that can never become one reports NOTHING (0)", nNope = 0)

# MatchAsYouType is the method these types exist for -- the exact sequence
# the paradigm-shift article documents, which never worked until now.
oTy = new stzRegex("^\d{3}-\d{2}-\d{4}$")
chk("MatchAsYouType accepts '123'", oTy.MatchAsYouType("123"))
chk("MatchAsYouType accepts '123-'", oTy.MatchAsYouType("123-"))
chk("MatchAsYouType accepts '123-45'", oTy.MatchAsYouType("123-45"))
chk("MatchAsYouType accepts the finished '123-45-6789'", oTy.MatchAsYouType("123-45-6789"))
chk("MatchAsYouType rejects 'abc'", oTy.MatchAsYouType("abc") = 0)

# the parameter is still checked
bRaised = FALSE
try
	oT5 = new stzRegex("[0-9]+")
	oT5.MatchXT("abc123", 1, :NoSuchMatchType, [])
catch
	bRaised = TRUE
done
chk("an unknown match type is still REJECTED", bRaised)

? ""
? "-- Scene 3: multibyte subjects and patterns --"
oM1 = new stzRegex("[0-9]+")
chk("digits are found between Arabic runs", oM1.MatchFirst(cAr + "123" + cAr))
oM2 = new stzRegex("[0-9]+")
chk("...and not found when there are none", oM2.MatchFirst(cAr + cCJK) = 0)

oM3 = new stzRegex(cAr)
chk("an Arabic literal pattern finds itself", oM3.MatchFirst("x" + cAr + "y"))
oM4 = new stzRegex(cCJK)
chk("a CJK literal pattern finds itself", oM4.MatchFirst("x" + cCJK + "y"))
oM5 = new stzRegex(cHeb)
chk("a Hebrew literal pattern finds itself", oM5.MatchFirst("x" + cHeb + "y"))
oM6 = new stzRegex(cAr)
chk("a multibyte pattern is not found when absent", oM6.MatchFirst("xyz") = 0)

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
	v = oS.MatchXT(cSubj, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
next
tMatch = (clock() - t0) / clockspersecond()
? "  400 matches over a " + len(cSubj) + "-byte subject in " + tMatch + " s"
chk("matching at scale stays fast (< 5s)", tMatch < 5)
chk("the match still succeeds", v = 1)

oBig = new stzRegex(cAr)
t0 = clock()
for k = 1 to 200
	v2 = oBig.MatchXT(cAr + cSubj, 1, :MatchFirstOccurrenceIfNotGoPartial, [])
next
tML = (clock() - t0) / clockspersecond()
chk("multibyte matching at scale is fast too (< 5s)", tML < 5)
chk("...and still correct", v2 = 1)

? ""
? "-- Scene 7: options are checked, and bad ones refused --"
oO1 = new stzRegex("ABC")
chk("case-insensitive option is honoured",
	oO1.MatchXT("xxabcxx", 1, :MatchFirstOccurrenceIfNotGoPartial, [ :CaseInsensitive ]) = 1)
oO2 = new stzRegex("ABC")
chk("...and without it the match fails",
	oO2.MatchXT("xxabcxx", 1, :MatchFirstOccurrenceIfNotGoPartial, []) = 0)

bBadOpt = FALSE
try
	oO3 = new stzRegex("abc")
	oO3.MatchXT("abc", 1, :MatchFirstOccurrenceIfNotGoPartial, [ :NoSuchOption ])
catch
	bBadOpt = TRUE
done
chk("an unknown option is refused", bBadOpt)

oO4 = new stzRegex("abc")
chk("an EMPTY option list is accepted",
	oO4.MatchXT("abc", 1, :MatchEntireContent, []) = 1)

? ""
? "-- Scene 8: literal text becomes a pattern that matches itself --"
# StzRegexEscape is what lets a builder say "starts with +" and mean a plus
# sign. IfStartsWith("+") used to emit (?=^+) -- a quantifier on ^ -- which
# does not compile, so that pattern silently matched nothing at all.
#
# The backslash is built with char(92) rather than written as a literal, for
# the same reason the Arabic above is built from codepoints: no escaping
# ambiguity, nothing for a lexer to reinterpret.
cBS = char(92)

chk("a plus sign is escaped", StzRegexEscape("+") = cBS + "+")
chk("a dot is escaped", StzRegexEscape(".edu") = cBS + ".edu")
chk("several metacharacters at once", StzRegexEscape("a.b*c") = "a" + cBS + ".b" + cBS + "*c")
chk("text with no metacharacters is returned untouched", StzRegexEscape("plain") = "plain")
chk("the empty string escapes to the empty string", StzRegexEscape("") = "")

# Multibyte must survive byte-for-byte: every metacharacter is ASCII, and no
# byte of a UTF-8 sequence is, so nothing inside a codepoint can be hit.
chk("Arabic round-trips unchanged", StzRegexEscape(cAr) = cAr)
chk("CJK round-trips unchanged", StzRegexEscape(cCJK) = cCJK)
chk("Hebrew round-trips unchanged", StzRegexEscape(cHeb) = cHeb)
chk("Arabic followed by a dot escapes only the dot",
	StzRegexEscape(cAr + ".") = cAr + cBS + ".")

# The escaped form must actually MATCH the text it came from.
oEsc = new stzRegex(StzRegexEscape("a.b*c"))
chk("the escaped pattern matches its own literal text", oEsc.Match("a.b*c"))
oEsc2 = new stzRegex(StzRegexEscape("a.b*c"))
chk("...and NOT what the unescaped metacharacters would have matched",
	oEsc2.Match("axbbbc") = 0)
oEscAr = new stzRegex(StzRegexEscape(cAr + "."))
chk("a multibyte literal matches itself after escaping", oEscAr.Match(cAr + "."))

# The builder end to end -- the phone-number sequence the article documents,
# which could not work while IfStartsWith("+") produced an uncompilable
# pattern.
cThen = cBS + "+1" + cBS + "d{10}"
cElse = cBS + "d{10}"

oPh = new stzRegex( wrxm().IfStartsWith("+").ThenMatch(cThen).ElseMatch(cElse).Pattern() )
chk("IfStartsWith('+') now COMPILES", oPh.IsValid())
oPh1 = new stzRegex( wrxm().IfStartsWith("+").ThenMatch(cThen).ElseMatch(cElse).Pattern() )
chk("...and matches the international format", oPh1.Match("+12345678901"))
oPh2 = new stzRegex( wrxm().IfStartsWith("+").ThenMatch(cThen).ElseMatch(cElse).Pattern() )
chk("...and the local one", oPh2.Match("1234567890"))
oPh3 = new stzRegex( wrxm().IfStartsWith("+").ThenMatch(cThen).ElseMatch(cElse).Pattern() )
chk("...and rejects a short one", oPh3.Match("+1234") = 0)

# StzFindFIRST, not StzFind -- StzFind returns ALL positions, so `> 0` on it
# is a list-vs-number comparison (R21).
chk("IfEndsWith('.edu') escapes the dot",
	StzFindFirst("(?=" + cBS + ".edu$)",
		wrxm().IfEndsWith(".edu").ThenMatch("x").ElseMatch("y").Pattern()) > 0)

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
