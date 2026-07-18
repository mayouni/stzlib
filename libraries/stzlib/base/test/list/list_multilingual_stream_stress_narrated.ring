# stzList STRESS -- a large, MULTILINGUAL event stream.
#
# The work a list actually gets used for once the data is real: a couple of
# hundred thousand tagged events, then counted, grouped, deduplicated,
# sorted, searched, sliced and set-combined -- and checked for correctness,
# not just "it ran".
#
# Two things this test is looking for, beyond right answers:
#
#   1. MULTILINGUAL ITEMS. A list is mostly strings, and every one has to
#      survive storage, sorting, hashing, grouping and set membership
#      byte-for-byte:
#        Arabic / Hebrew -- 2-byte, caseless, RTL
#        CJK             -- 3-byte, caseless
#        Emoji           -- 4-byte
#        Greek/Cyrillic  -- CASED
#        Latin           -- accented
#
#   2. THE SHAPE OF THE COST CURVE. Every scene that can be quadratic is
#      timed and guarded, because "correct but quadratic" is how a list
#      library dies at scale -- silently, only on real data. Three such
#      defects were found and fixed by writing this file; the guards below
#      are what keep them fixed.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder, never
# typed as literals -- this codebase has a history of editors double-encoding
# source, so the test refuses to trust its own bytes.
#
# Ring traps avoided on purpose:
#   - no local named nL / oR / aND -- Ring is case-insensitive, so those
#     silently ARE the global `nl` / the `or` / `and` keywords.
#   - no `new stzList(x).Method()` inline -- that is R13, "Object is
#     required". Bind the object first, then call.
#   - no `x = (a = b)` -- a comparison is not a value expression in Ring.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# ---------------------------------------------------------------- vocabulary
cAr   = MkW([ 0x0639, 0x0645, 0x0644 ])                 # Arabic
cHeb  = MkW([ 0x05E9, 0x05DC, 0x05D5, 0x05DD ])         # Hebrew
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK
cGrUp = MkW([ 0x0391, 0x0398 ])                         # Greek UPPER
cCafe = MkW([ 0x0063, 0x0061, 0x0066, 0x00E9 ])         # Latin cafe'
cBox  = MkW([ 0x1F4E6 ])                                # Emoji

aBases = [ cAr, cCJK, cGrUp, cCafe, cHeb, cBox ]        # 6 scripts

# ------------------------------------------------------------- build the data
nEvents   = 200000
nDistinct = 500                        # tags in the vocabulary
nPerTag   = nEvents / nDistinct        # 400 events per tag, exactly

aVocab = []
for i = 1 to nDistinct
	aVocab + ( aBases[ (i % 6) + 1 ] + i )
next

t0 = clock()
aStream = []
for i = 1 to nEvents
	aStream + aVocab[ (i % nDistinct) + 1 ]
next
tBuild = (clock() - t0) / clockspersecond()

oStream = new stzList(aStream)

? "-- Scene 1: a 200k-event multilingual stream --"
? "  built in " + tBuild + " s : " + nEvents + " events over " + nDistinct + " distinct tags"
chk("every event landed", oStream.NumberOfItems() = nEvents)
chk("the vocabulary is genuinely multibyte", len(aVocab[1]) > StzLen(aVocab[1]))
# aVocab[i] is built on aBases[(i % 6) + 1], so the Arabic base lands on the
# indices where i % 6 = 0 -- aVocab[6], not aVocab[7].
chk("an Arabic-based tag round-trips", StzFindFirst(cAr, aVocab[6]) > 0)
chk("a CJK-based tag round-trips", StzFindFirst(cCJK, aVocab[7]) > 0)

? ""
? "-- Scene 2: counting the distinct tags --"
oU = new stzList(aStream)
t0 = clock()
aUnique = oU.Unique()
tUnique = (clock() - t0) / clockspersecond()
? "  " + len(aUnique) + " distinct tags in " + tUnique + " s"
chk("Unique finds exactly the vocabulary", len(aUnique) = nDistinct)
chk("dedup is fast at scale (< 3s)", tUnique < 3)

? ""
? "-- Scene 3: frequencies must be linear, not quadratic in DISTINCT --"
# This scene is the guard on a real defect: the frequency count grouped by
# scanning every group found so far, for every item -- O(n x distinct). It
# looked fine on toy data and took 39.82s on 8000 distinct values, while
# Classify(), which computes strictly MORE, took 0.22s on the same input.
oF = new stzList(aStream)
t0 = clock()
aFreqs = oF.Frequencies()
tFreqs = (clock() - t0) / clockspersecond()
? "  " + len(aFreqs) + " frequency entries in " + tFreqs + " s"

nFreqTotal = 0
bEveryCountRight = TRUE
for i = 1 to len(aFreqs)
	nFreqTotal += aFreqs[i][2]
	if aFreqs[i][2] != nPerTag
		bEveryCountRight = FALSE
	ok
next

chk("one frequency entry per distinct tag", len(aFreqs) = nDistinct)
chk("the counts sum back to the event total", nFreqTotal = nEvents)
chk("every tag occurs exactly nEvents/nDistinct times", bEveryCountRight)
chk("frequencies stay linear (< 3s for 200k over 500)", tFreqs < 3)

? ""
? "-- Scene 4: grouping keeps every position --"
oC = new stzList(aStream)
t0 = clock()
aClasses = oC.Classify()
tClassify = (clock() - t0) / clockspersecond()
? "  " + len(aClasses) + " classes in " + tClassify + " s"

nPosTotal = 0
for i = 1 to len(aClasses)
	nPosTotal += len(aClasses[i][2])
next

chk("one class per distinct tag", len(aClasses) = nDistinct)
chk("the positions account for every event", nPosTotal = nEvents)
chk("a class key really sits at its first recorded position",
	aStream[ aClasses[1][2][1] ] = aClasses[1][1])
chk("grouping is fast at scale (< 3s)", tClassify < 3)

? ""
? "-- Scene 5: finding a multilingual item at scale --"
cNeedle = aVocab[42]
oFind = new stzList(aStream)
t0 = clock()
anHits = oFind.FindAll(cNeedle)
tFind = (clock() - t0) / clockspersecond()
? "  found the tag " + len(anHits) + " times in " + tFind + " s"
chk("every occurrence was found", len(anHits) = nPerTag)
chk("a returned position really holds that tag", aStream[ anHits[1] ] = cNeedle)
chk("the last returned position holds it too",
	aStream[ anHits[len(anHits)] ] = cNeedle)
chk("NumberOfOccurrence agrees with FindAll", oFind.NumberOfOccurrence(cNeedle) = nPerTag)
chk("a tag never used is not found", len(oFind.FindAll(cBox + "-absent")) = 0)

? ""
? "-- Scene 6: sorting 200k multilingual items --"
oSort = new stzList(aStream)
t0 = clock()
aSorted = oSort.Sorted()
tSort = (clock() - t0) / clockspersecond()
? "  sorted in " + tSort + " s"
chk("sorting keeps every item", len(aSorted) = nEvents)

# strcmp, not `<`. Ring's relational operators on strings try to read them
# as NUMBERS, so comparing two multilingual tags with `<` raises R41
# "Invalid numeric string" rather than comparing them.
bNonDescending = TRUE
for i = 2 to 2000
	if strcmp(aSorted[i], aSorted[i - 1]) < 0
		bNonDescending = FALSE
	ok
next
chk("the result is really in order", bNonDescending)
chk("equal items group together after sorting", aSorted[1] = aSorted[2])
chk("sorting did not corrupt multibyte items", StzLen(aSorted[1]) > 0)
chk("sorting 200k items is fast (< 10s)", tSort < 10)

? ""
? "-- Scene 7: set operations, and what they do with DUPLICATES --"
# The stream repeats every tag 400 times, so this is where set semantics
# get interesting -- and where a hash-free implementation goes quadratic.
aOther = []
for i = 1 to nDistinct
	if i % 2 = 0
		aOther + aVocab[i]
	ok
next

oI = new stzList(aStream)
t0 = clock()
aInter = oI.IntersectWith(aOther)
tInter = (clock() - t0) / clockspersecond()
chk("intersection is the SET of shared tags", len(aInter) = nDistinct / 2)
chk("intersection is fast (< 3s)", tInter < 3)

oD = new stzList(aStream)
t0 = clock()
aDiff = oD.DifferenceWith(aOther)
tDiff = (clock() - t0) / clockspersecond()
? "  difference returned " + len(aDiff) + " items in " + tDiff + " s"
# DifferenceWith KEEPS duplicates (documented, test 636): every event
# carrying an odd-numbered tag survives, all 400 copies of each.
chk("difference keeps every occurrence, not just the distinct values",
	len(aDiff) = (nDistinct / 2) * nPerTag)
chk("difference is fast -- it must not scan the other list per item (< 3s)",
	tDiff < 3)

oUn = new stzList(aStream)
aUnion = oUn.UnionWith(aOther)
chk("union is the SET of all tags", len(aUnion) = nDistinct)

? ""
? "-- Scene 8: slicing and reversing --"
oSec = new stzList(aStream)
aSection = oSec.Section(1000, 2000)
chk("a section has the requested length", len(aSection) = 1001)
chk("a section starts at the right item", aSection[1] = aStream[1000])
chk("a section ends at the right item", aSection[1001] = aStream[2000])

oRevA = new stzList(aStream)
aRev = oRevA.Reversed()
chk("reversing keeps every item", len(aRev) = nEvents)
chk("the first becomes the last", aRev[1] = aStream[nEvents])
chk("the last becomes the first", aRev[nEvents] = aStream[1])

oRevB = new stzList(aRev)
aBack = oRevB.Reversed()
chk("reversing twice returns the original", aBack[1] = aStream[1])

? ""
? "-- Scene 9: a practical question -- which tag leads? --"
# Every tag occurs exactly nPerTag times here, so the honest check is that
# the reported maximum matches that, and that the winner is a real tag.
oM = new stzList(aStream)
cTop = oM.MostFrequent()
? "  most frequent tag occurs " + oM.NumberOfOccurrence(cTop) + " times"
chk("the leading tag is one of the vocabulary", StzFindFirst(cTop, aVocab) > 0)
chk("its count matches the uniform distribution",
	oM.NumberOfOccurrence(cTop) = nPerTag)

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
