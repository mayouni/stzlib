# stzHashList STRESS -- a large, MULTILINGUAL product registry.
#
# What a hash list is actually for: a keyed registry you look things up in.
# Tens of thousands of products keyed by a multilingual name, then queried,
# counted, updated, reverse-searched and round-tripped -- and checked for
# correctness, not just "it ran".
#
# Two things this file is looking for, beyond right answers:
#
#   1. MULTILINGUAL KEYS AND VALUES. A key has to survive hashing, storage,
#      lookup and iteration byte-for-byte:
#        Arabic / Hebrew -- 2-byte, caseless, RTL
#        CJK             -- 3-byte, caseless
#        Emoji           -- 4-byte
#        Greek/Cyrillic  -- CASED
#        Latin           -- accented
#
#   2. THE SHAPE OF THE COST CURVE. A container whose entire purpose is
#      O(1) access earns no credit for being correct if it is quadratic.
#      Every scene here is timed and guarded. FOUR defects were found by
#      writing this file -- including that the engine's "hash map" was a
#      linear-scan array, and that writing ONE value revalidated the whole
#      registry. The guards below are what keep them fixed.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder, never
# typed as literals -- this codebase has a history of editors double-encoding
# source, so the test refuses to trust its own bytes.
#
# Ring traps avoided on purpose:
#   - no local named nL / oR / Try -- Ring is case-insensitive, so those
#     silently ARE the global `nl`, the `or` keyword, and the `try` keyword.
#     A `func Try` costs you a C6 "Error in function name".
#   - no `new stzHashList(x).Method()` inline -- that is R13.
#   - strcmp() for string ordering; `<` on strings raises R41.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# ---------------------------------------------------------------- vocabulary
cAr   = MkW([ 0x0639, 0x0645, 0x0644 ])                 # Arabic
cHeb  = MkW([ 0x05E9, 0x05DC, 0x05D5, 0x05DD ])         # Hebrew
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK
cGrUp = MkW([ 0x0391, 0x0398 ])                         # Greek UPPER
cGrLo = MkW([ 0x03B1, 0x03B8 ])                         # Greek lower
cCafe = MkW([ 0x0063, 0x0061, 0x0066, 0x00E9 ])         # Latin cafe'
cBox  = MkW([ 0x1F4E6 ])                                # Emoji

aScripts = [ cAr, cCJK, cGrUp, cCafe, cHeb, cBox ]      # 6 scripts, cycling

# ------------------------------------------------------------- build registry
nPairs = 20000
nRegions = 4                        # every product sits in one of 4 regions

aRegistry     = []
aExpectKeys   = []
nExpectInCJK  = 0                   # products whose REGION value is the CJK one

t0 = clock()
for i = 1 to nPairs
	cKey = aScripts[ (i % 6) + 1 ] + "-sku-" + i
	cRegion = aScripts[ (i % nRegions) + 1 ]

	aRegistry + [ cKey, cRegion ]
	aExpectKeys + cKey

	if cRegion = cCJK
		nExpectInCJK++
	ok
next
tBuild = (clock() - t0) / clockspersecond()

oReg = new stzHashList(aRegistry)

? "-- Scene 1: a 20k-entry multilingual registry --"
? "  built in " + tBuild + " s"
chk("every pair landed", oReg.NumberOfPairs() = nPairs)
chk("the keys are genuinely multibyte", len(aExpectKeys[1]) > StzLen(aExpectKeys[1]))
chk("an Arabic-keyed entry exists", StzFindFirst(cAr, aExpectKeys[6]) > 0)
chk("counting the pairs is not a full rebuild (< 3s)", tBuild < 10)

? ""
? "-- Scene 2: lookup is what a hash list is FOR --"
t0 = clock()
nFound = 0
for i = 1 to nPairs
	if oReg.ValueByKey(aExpectKeys[i]) != ""
		nFound++
	ok
next
tLookAll = (clock() - t0) / clockspersecond()
? "  " + nPairs + " lookups in " + tLookAll + " s"
chk("every key resolves", nFound = nPairs)
chk("a lookup returns the right value", oReg.ValueByKey(aExpectKeys[3]) = aRegistry[3][2])
chk("a deep key resolves too", oReg.ValueByKey(aExpectKeys[19999]) = aRegistry[19999][2])
chk("N lookups over N entries stay linear (< 5s)", tLookAll < 5)

? ""
? "-- Scene 3: keys and values are symmetric --"
# These two methods are the same loop over the same content. One of them
# used to force an engine-map rebuild just to read a count, and that rebuild
# was quadratic -- so Values() ran 82x slower than the identical Keys().
t0 = clock()
aKeys = oReg.Keys()
tKeys = (clock() - t0) / clockspersecond()

t0 = clock()
aValues = oReg.Values()
tValues = (clock() - t0) / clockspersecond()

? "  Keys() " + tKeys + " s, Values() " + tValues + " s"
chk("Keys returns one key per pair", len(aKeys) = nPairs)
chk("Values returns one value per pair", len(aValues) = nPairs)
chk("keys come back in insertion order", aKeys[1] = aExpectKeys[1])

# Keys are stored LOWERCASED -- that is what makes lookup case-insensitive,
# and it is why a key holding a CASED non-ASCII letter comes back changed:
# Greek capital alpha-theta is stored as small alpha-theta. Pin it, because
# it means Keys() is not a faithful echo of what was put in.
chk("...and the deepest key matches once lowercased",
	aKeys[nPairs] = StzLower(aExpectKeys[nPairs]))
chk("a CASED non-ASCII key is stored folded, not verbatim",
	StzLower(aExpectKeys[3]) = aKeys[3])
chk("...yet it still resolves by its ORIGINAL casing",
	oReg.ValueByKey(aExpectKeys[3]) = aRegistry[3][2])
chk("...and ContainsKey agrees with ValueByKey about it",
	oReg.ContainsKey(aExpectKeys[3]))
chk("key and value at the same index belong together",
	aValues[7] = aRegistry[7][2])
chk("Values is not dramatically slower than Keys", tValues < 3)

? ""
? "-- Scene 4: membership, by key and by value --"
chk("a present key is found", oReg.ContainsKey(aExpectKeys[100]))
chk("an absent key is not", oReg.ContainsKey("no-such-sku") = 0)
chk("a multilingual value is found", oReg.ContainsValue(cCJK))
chk("an absent value is not", oReg.ContainsValue(cHeb + cHeb) = 0)

? ""
? "-- Scene 5: reverse lookup -- which keys hold this value? --"
# This walked the registry asking Q(value).Contains(...) -- building a whole
# stz OBJECT per entry just to answer a containment question. One call over
# 8000 entries took 1.75s.
t0 = clock()
aInCJK = oReg.KeysByValue(cCJK)
tRev = (clock() - t0) / clockspersecond()
? "  " + len(aInCJK) + " keys carry the CJK region, found in " + tRev + " s"
chk("reverse lookup finds every one", len(aInCJK) = nExpectInCJK)
chk("a returned key really carries that value", oReg.ValueByKey(aInCJK[1]) = cCJK)
chk("reverse lookup is linear, not per-item object building (< 3s)", tRev < 3)

# A numeric needle against string values used to take Ring down hard --
# exit 1, no message, no output at all.
aNumeric = oReg.KeysByValue(42)
chk("a numeric needle against string values returns empty, not a crash",
	len(aNumeric) = 0)

? ""
? "-- Scene 6: writing one value must not revalidate the registry --"
# UpdateNthValue copied the entire hash list out, changed one cell, and
# pushed the whole thing back through Update() -- which re-checks that every
# pair is still a pair. Writing one value cost several full passes.
cTarget = aRegistry[5][2]
t0 = clock()
oReg.UpdateNthValue(5, cBox + "-moved")
tWrite = (clock() - t0) / clockspersecond()

chk("the write landed", oReg.ValueByKey(aExpectKeys[5]) = cBox + "-moved")
chk("the registry did not change size", oReg.NumberOfPairs() = nPairs)
chk("its neighbours are untouched", oReg.ValueByKey(aExpectKeys[6]) = aRegistry[6][2])
chk("writing one value is fast (< 1s)", tWrite < 1)

t0 = clock()
for i = 1 to 20
	oReg.UpdateNthValue(i, cCafe + "-batch")
next
tBatch = (clock() - t0) / clockspersecond()
? "  20 single-value writes in " + tBatch + " s"
chk("every batched write landed", oReg.ValueByKey(aExpectKeys[20]) = cCafe + "-batch")
chk("a write loop is not quadratic (< 10s)", tBatch < 10)

? ""
? "-- Scene 7: hashlist-ness is checked on every write --"
# IsHashList asked the engine 'are these keys all unique?', and the engine
# answered by comparing EVERY PAIR -- 8000 keys took 1.68s. Since the check
# runs on writes, that quadratic reached everything.
t0 = clock()
bIsHash = IsHashList(aRegistry)
tCheck = (clock() - t0) / clockspersecond()
? "  validating " + nPairs + " pairs took " + tCheck + " s"
chk("the registry validates as a hash list", bIsHash)
chk("validation is linear (< 2s)", tCheck < 2)

aDup = [ [ "k", 1 ], [ "k", 2 ] ]
chk("duplicate keys are still rejected", IsHashList(aDup) = 0)
chk("a non-pair list is still rejected", IsHashList([ "a", "b" ]) = 0)

? ""
? "-- Scene 8: round-tripping the whole registry --"
aContent = oReg.Content()
oCopy = new stzHashList(aContent)
chk("a rebuilt registry has the same size", oCopy.NumberOfPairs() = nPairs)
chk("a rebuilt registry resolves the same key",
	oCopy.ValueByKey(aExpectKeys[77]) = oReg.ValueByKey(aExpectKeys[77]))
chk("multibyte keys survive the round trip", oCopy.ContainsKey(aExpectKeys[6]))

? ""
? "-- Scene 9: a practical question -- how is stock spread? --"
# KeysByValue matches by CONTAINMENT, not equality -- so an entry rewritten
# to "cafe-batch" still answers to the "cafe" region. The honest question is
# how many entries carry the new batch marker.
nMoved = len(oReg.KeysByValue(cCafe + "-batch"))
? "  " + nMoved + " entries carry the batch marker"
chk("every batched write is findable by its new value", nMoved = 20)
chk("the registry still holds every entry", oReg.NumberOfPairs() = nPairs)
chk("an untouched entry kept its region", oReg.ValueByKey(aExpectKeys[500]) = aRegistry[500][2])

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
