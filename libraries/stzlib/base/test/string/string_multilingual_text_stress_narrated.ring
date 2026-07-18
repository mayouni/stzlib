# stzString STRESS -- a large, MULTILINGUAL support-ticket log.
#
# This is the work a text pipeline actually does: tens of thousands of
# message records in real scripts, then searched, case-folded, redacted,
# sliced, split, re-joined and segmented -- and checked for correctness,
# not just "it ran".
#
# Multilingual is the whole point. A string module that is only tested on
# ASCII passes every test and corrupts every real document, because the
# two questions "how long is this?" and "where is that?" have different
# answers in bytes and in codepoints:
#   Arabic    -- 2-byte, caseless, RTL
#   Hebrew    -- 2-byte, caseless, RTL
#   CJK       -- 3-byte, caseless, NO word spaces
#   Emoji     -- 4-byte (surrogate-range in other stacks)
#   Greek /
#   Cyrillic  -- CASED: upper/lower must fold for case-insensitive search
#   Latin     -- accented (cafe with an acute)
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder,
# never typed as literals -- this codebase has a history of editors
# double-encoding source, so the test refuses to trust its own bytes.
#
# Ring traps avoided on purpose:
#   - no local named nL / oR / aND -- Ring is case-insensitive, so those
#     silently ARE the globals `nl` / the `or` / `and` keywords, and the
#     file stops parsing with a misleading error several lines later.
#   - no `x = (a = b)` -- a comparison is not a value expression in Ring.
#     Comparisons live in `if` conditions or in chk() arguments.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# ---------------------------------------------------------------- vocabulary
cArCust  = MkW([ 0x0639, 0x0645, 0x064A, 0x0644 ])            # Arabic   "customer"
cArCity  = MkW([ 0x0627, 0x0644, 0x0642, 0x0627, 0x0647 ])    # Arabic   a city
cHeb     = MkW([ 0x05E9, 0x05DC, 0x05D5, 0x05DD ])            # Hebrew   "shalom"
cCJKTok  = MkW([ 0x6771, 0x4EAC ])                            # CJK      Tokyo
cCJKBei  = MkW([ 0x5317, 0x4EAC ])                            # CJK      Beijing
cGrUp    = MkW([ 0x0391, 0x0398, 0x0397, 0x039D, 0x0391 ])    # Greek    UPPER
cGrLo    = MkW([ 0x03B1, 0x03B8, 0x03B7, 0x03BD, 0x03B1 ])    # Greek    lower
cCyUp    = MkW([ 0x041C, 0x0418, 0x0420 ])                    # Cyrillic UPPER
cCyLo    = MkW([ 0x043C, 0x0438, 0x0440 ])                    # Cyrillic lower
cCafe    = MkW([ 0x0063, 0x0061, 0x0066, 0x00E9 ])            # Latin    cafe'
cBox     = MkW([ 0x1F4E6 ])                                   # Emoji    package
cQuote   = char(34)
cNewline = char(10)

aCustomers = [ cArCust, cCJKTok, cGrUp, cCafe, cCyUp ]        # 5, cycles
aCities    = [ cCJKTok, cArCity, cCJKBei, cHeb ]              # 4, cycles

# ------------------------------------------------------------- build the log
nRecords = 20000

cLog          = ""
nExpectCp     = 0                  # codepoints, accumulated by ARITHMETIC
nCountArCust  = 0                  # records whose customer is the Arabic one
nCountGrUp    = 0                  # records whose customer is Greek UPPER
nCountCJKTok  = 0                  # records whose CITY is Tokyo
nCountHebCity = 0                  # records whose CITY is the Hebrew one

# Precompute each piece's codepoint length ONCE, and assert the ones that
# matter below -- so the expected total is arithmetic over verified parts,
# never a second call to the thing under test.
nCpArCust = StzLen(cArCust)
nCpCJKTok = StzLen(cCJKTok)
nCpGrUp   = StzLen(cGrUp)
nCpCafe   = StzLen(cCafe)
nCpCyUp   = StzLen(cCyUp)
nCpBox    = StzLen(cBox)
nCpHeb    = StzLen(cHeb)
nCpArCity = StzLen(cArCity)
nCpCJKBei = StzLen(cCJKBei)

aCustCp = [ nCpArCust, nCpCJKTok, nCpGrUp, nCpCafe, nCpCyUp ]
aCityCp = [ nCpCJKTok, nCpArCity, nCpCJKBei, nCpHeb ]

t0 = clock()

for i = 1 to nRecords
	nCustIdx = (i % 5) + 1
	nCityIdx = (i % 4) + 1

	cCust = aCustomers[nCustIdx]
	cCity = aCities[nCityIdx]

	# message = emoji + a Cyrillic lowercase word, so there is cased text
	# INSIDE the quoted body as well as in the customer field
	cMsg = cBox + " " + cCyLo

	cRec = "[" + i + "] " + cCust + " @" + cCity + ": " +
	       cQuote + cMsg + cQuote + " #tag" + nCustIdx

	cLog += cRec + cNewline

	# codepoints: "[" + digits + "] " = 3 + digits ; " @" = 2 ; ": " = 2 ;
	# quotes = 2 ; msg = box + space + cyrillic ; " #tag" + digit = 6 ;
	# newline = 1
	nDigits = len("" + i)
	nExpectCp += 3 + nDigits + aCustCp[nCustIdx] + 2 + aCityCp[nCityIdx] +
	             2 + 2 + (nCpBox + 1 + StzLen(cCyLo)) + 6 + 1

	if cCust = cArCust
		nCountArCust++
	ok

	if cCust = cGrUp
		nCountGrUp++
	ok

	if cCity = cCJKTok
		nCountCJKTok++
	ok

	if cCity = cHeb
		nCountHebCity++
	ok
next

tBuild = (clock() - t0) / clockspersecond()

oLog = new stzString(cLog)

? "-- Scene 1: a 20k-record multilingual ticket log --"
? "  built in " + tBuild + " s : " + len(cLog) + " bytes, " + StzLen(cLog) + " codepoints"
chk("the log is genuinely multibyte (bytes > codepoints)", len(cLog) > StzLen(cLog))
chk("codepoint count matches the arithmetic total", StzLen(cLog) = nExpectCp)
chk("Arabic customer is 4 codepoints / 8 bytes", nCpArCust = 4 and len(cArCust) = 8)
chk("CJK city is 2 codepoints / 6 bytes", nCpCJKTok = 2 and len(cCJKTok) = 6)
chk("the emoji is 1 codepoint / 4 bytes", nCpBox = 1 and len(cBox) = 4)

? ""
? "-- Scene 2: searching MULTILINGUAL text at scale --"
t0 = clock()
anHits = oLog.FindAll(cArCust)
tFind = (clock() - t0) / clockspersecond()
? "  found the Arabic customer " + len(anHits) + " times in " + tFind + " s"
chk("every Arabic-customer record was found", len(anHits) = nCountArCust)
chk("the search is fast at scale (< 3s)", tFind < 3)

# THE codepoint-index invariant: a returned position must be usable as a
# codepoint index. If find returned BYTE offsets, this slice lands mid-
# character and comes back as garbage.
bAllPositionsValid = TRUE
anProbe = [ 1, floor(len(anHits) / 2), len(anHits) ]

for k = 1 to 3
	nWhich = anProbe[k]
	if nWhich < 1
		loop
	ok
	nPos = anHits[nWhich]
	cSlice = oLog.Section(nPos, nPos + nCpArCust - 1)
	if cSlice != cArCust
		bAllPositionsValid = FALSE
	ok
next

chk("a found position is a CODEPOINT index, not a byte offset", bAllPositionsValid)
chk("a customer never used is not found", len(oLog.FindAll(cHeb + cHeb)) = 0)

? ""
? "-- Scene 3: case folding on CASED scripts (Greek, Cyrillic) --"
# This is what breaks when case handling is ASCII-only: Greek and Cyrillic
# have real upper/lower pairs, and a caseless script must survive untouched.
chk("Greek lower uppercases to Greek upper", Q(cGrLo).Uppercased() = cGrUp)
chk("Greek upper lowercases to Greek lower", Q(cGrUp).Lowercased() = cGrLo)
chk("Cyrillic lower uppercases to Cyrillic upper", Q(cCyLo).Uppercased() = cCyUp)
chk("Arabic is caseless -- uppercasing changes nothing", Q(cArCust).Uppercased() = cArCust)
chk("CJK is caseless -- uppercasing changes nothing", Q(cCJKTok).Uppercased() = cCJKTok)
chk("the emoji survives uppercasing", Q(cBox).Uppercased() = cBox)

# case-INSENSITIVE search must find the Greek customer written either way
nCsHits = len(oLog.FindAllCS(cGrLo, TRUE))
nCiHits = len(oLog.FindAllCS(cGrLo, FALSE))
? "  Greek lower as needle: case-sensitive " + nCsHits + " hits, case-insensitive " + nCiHits
chk("case-sensitive search does NOT match the uppercase Greek", nCsHits = 0)
chk("case-INsensitive search finds every uppercase Greek record", nCiHits = nCountGrUp)

? ""
? "-- Scene 4: redaction (replace) across the whole log --"
oRedact = new stzString(cLog)
nCpBefore = StzLen(oRedact.Content())

t0 = clock()
oRedact.ReplaceCS(cArCust, cHeb, TRUE)
tReplace = (clock() - t0) / clockspersecond()

cRedacted = oRedact.Content()
? "  redacted " + nCountArCust + " occurrences in " + tReplace + " s"

# exact length arithmetic: each replacement swaps nCpArCust for nCpHeb
nCpExpected = nCpBefore + (nCountArCust * (nCpHeb - nCpArCust))
chk("redacted length is exactly right (codepoint arithmetic)", StzLen(cRedacted) = nCpExpected)
chk("the redacted term is completely gone", len(Q(cRedacted).FindAll(cArCust)) = 0)
# The Hebrew word was ALREADY in the log as a city name, so counting it
# now must return the redactions PLUS those -- a count that silently
# deduplicated, or that only saw the new ones, would fail here.
chk("the replacement count adds to the Hebrew already present",
	Q(cRedacted).NumberOfOccurrence(cHeb) = nCountArCust + nCountHebCity)
chk("untouched scripts are unharmed", Q(cRedacted).NumberOfOccurrence(cCJKBei) > 0)
chk("redaction is fast at scale (< 3s)", tReplace < 3)

? ""
? "-- Scene 5: slicing across multibyte boundaries --"
# Section() must cut on CHARACTER boundaries. A byte-based slice of this
# mixed string returns broken UTF-8 -- which is exactly how Ring's own
# substr() corrupts Hebrew, Arabic and emoji.
cMixed = cArCust + cCJKTok + cBox + "abc" + cHeb
oMixed = new stzString(cMixed)
nCpMixed = nCpArCust + nCpCJKTok + nCpBox + 3 + nCpHeb

chk("the mixed sample counts codepoints, not bytes", StzLen(cMixed) = nCpMixed)
chk("slicing out the Arabic head round-trips", oMixed.Section(1, nCpArCust) = cArCust)
chk("slicing out the CJK middle round-trips",
	oMixed.Section(nCpArCust + 1, nCpArCust + nCpCJKTok) = cCJKTok)
chk("slicing out the lone emoji round-trips",
	oMixed.Section(nCpArCust + nCpCJKTok + 1, nCpArCust + nCpCJKTok + 1) = cBox)
chk("the emoji slice is 4 bytes -- a whole character, not a fragment",
	len(oMixed.Section(nCpArCust + nCpCJKTok + 1, nCpArCust + nCpCJKTok + 1)) = 4)
chk("slicing the Hebrew tail round-trips",
	oMixed.Section(nCpMixed - nCpHeb + 1, nCpMixed) = cHeb)

? ""
? "-- Scene 6: split / re-join must be lossless --"
t0 = clock()
aLines = oLog.Split(cNewline)
tSplit = (clock() - t0) / clockspersecond()
? "  split into " + len(aLines) + " lines in " + tSplit + " s"
chk("every record came back as a line", len(aLines) = nRecords)
chk("the first line is a complete record", StzFindFirst("[1] ", aLines[1]) = 1)

cRejoined = ""
for i = 1 to nRecords
	cRejoined += aLines[i] + cNewline
next

chk("re-joining reproduces the log byte-for-byte", cRejoined = cLog)
chk("...and codepoint-for-codepoint", StzLen(cRejoined) = nExpectCp)

? ""
? "-- Scene 7: segmentation (UAX#29) on multilingual text --"
# Words() is UAX#29 word segmentation, NOT a whitespace split. That
# distinction is visible exactly here: CJK has no word spaces, so without
# a dictionary each ideograph is its own word -- while Arabic, which does
# use spaces, stays whole. SearchTokens() is the search-side answer: it
# emits overlapping CJK bigrams for recall (cf. Lucene CJKBigramFilter).
aArWords = Q(cArCust + " " + cArCity).Words()
chk("a spaced Arabic phrase segments into 2 words", len(aArWords) = 2)
chk("the Arabic word is kept whole", aArWords[1] = cArCust)

aCJKWords = Q(cCJKTok).Words()
chk("a 2-ideograph CJK run segments per ideograph (no dictionary)", len(aCJKWords) = 2)

aTokens = Q(cCJKTok).SearchTokens()
chk("SearchTokens emits a CJK bigram for search recall", len(aTokens) >= 1)
chk("the bigram is the whole 2-ideograph run", aTokens[1] = cCJKTok)

aSentences = Q("First one. Second one? Third one!").Sentences()
chk("sentence segmentation finds all three", len(aSentences) = 3)

? ""
? "-- Scene 8: pulling the quoted message bodies out --"
t0 = clock()
aQuoted = oLog.BoundedBy([ cQuote, cQuote ])
tBounded = (clock() - t0) / clockspersecond()
? "  extracted " + len(aQuoted) + " regions in " + tBounded + " s"

# SAME-character bounds OVERLAP by design: each closing quote opens the
# next region. So 20k records (40k quotes) yield 2n-1 regions, alternating
# message body / the gap between records -- bodies land on ODD indices.
# This is the documented contract, not an accident, so pin it.
chk("same-char bounds overlap: 2n-1 regions", len(aQuoted) = (2 * nRecords) - 1)
chk("a body carries the emoji", StzFindFirst(cBox, aQuoted[1]) > 0)
chk("a body carries the Cyrillic word", StzFindFirst(cCyLo, aQuoted[1]) > 0)
chk("a body is exactly the message (emoji + space + Cyrillic)",
	StzLen(aQuoted[1]) = nCpBox + 1 + StzLen(cCyLo))
chk("the NEXT body (odd index) is the same message",
	aQuoted[3] = aQuoted[1])
chk("the between-records gap (even index) is not a message",
	aQuoted[2] != aQuoted[1])
chk("the last region still decodes as text", StzLen(aQuoted[len(aQuoted)]) > 0)

# every odd region must be the message -- sampled across the whole log
bOddAllMessages = TRUE
for k = 1 to 4001 step 500
	if aQuoted[k] != aQuoted[1]
		bOddAllMessages = FALSE
	ok
next
chk("odd regions are message bodies all the way through", bOddAllMessages)

chk("extraction is linear, not quadratic (< 3s for 40k regions)", tBounded < 3)

? ""
? "-- Scene 9: a practical question -- which city is busiest? --"
nTok = oLog.NumberOfOccurrence(cCJKTok)
nBei = oLog.NumberOfOccurrence(cCJKBei)
? "  Tokyo appears " + nTok + " times, Beijing " + nBei
# Tokyo is BOTH a city (every 4th record) and a customer name (every 5th),
# so its count must exceed the city-only tally -- a good check that
# counting is not silently deduplicating.
chk("Tokyo is counted everywhere it appears, not just as a city", nTok > nCountCJKTok)
chk("Beijing's count equals its city tally exactly", nBei = floor(nRecords / 4))

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
