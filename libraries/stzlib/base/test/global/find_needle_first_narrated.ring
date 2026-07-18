# The find family -- one convention: (substr/item TO FIND, container).
#
# StzFind / StzFindFirst / StzFindLast / StzFindNth (+ their CS variants) all
# take the substring-or-item to find FIRST and the container (a string or a
# list) SECOND. The container may also be written [ :In, container ].
#
# History: StzFindFirst's two-string form used to be haystack-first (the
# container first) -- a defect that made StzFindFirst('@(:a)', '@(:a) + @(:b)')
# return 0 and every multi-char / punctuation needle silently miss. Fixed
# 2026-07-18 together with a library-wide caller migration.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: StzFindFirst is needle-first for two strings --"
chk("the reported repro: @(:a) is found at 1", StzFindFirst('@(:a)', '@(:a) + @(:b)') = 1)
chk("a plain multi-char needle", StzFindFirst('abc', 'xabcx') = 2)
chk("a single-char needle mid-string", StzFindFirst('?', 'a?b') = 2)
chk("a needle absent from the container", StzFindFirst('zzz', 'abc') = 0)

? "-- Scene 2: case-insensitive multi-char (was broken by the same swap) --"
chk("insensitive multi-char match", StzFindFirstCS('abc', 'xABCx', FALSE) = 2)
chk("sensitive multi-char misses on case", StzFindFirstCS('abc', 'xABCx', TRUE) = 0)

? "-- Scene 3: item-in-list, same convention (polymorphic both ways) --"
chk("item first, list second", StzFindFirst('b', [ 'a', 'b', 'c' ]) = 2)
chk("list first still works (backward-compatible)", StzFindFirst([ 'a', 'b', 'c' ], 'b') = 2)

? "-- Scene 4: the [ :In, container ] expressive form --"
chk("substr in a string container via :In", StzFindFirst('b', [ :In, 'abc' ]) = 2)
chk("item in a list container via :In", StzFindFirst('c', [ :In, [ 'a', 'b', 'c' ] ]) = 3)

? "-- Scene 5: StzFindLast --"
chk("last occurrence in a string", StzFindLast('a', 'banana') = 6)
chk("last occurrence in a list", StzFindLast('b', [ 'a', 'b', 'c', 'b' ]) = 4)
chk("case-insensitive last", StzFindLastCS('A', 'aAaA', FALSE) = 4)
chk("no occurrence", StzFindLast('z', 'abc') = 0)

? "-- Scene 6: StzFindNth --"
chk("2nd 'a' in banana", StzFindNth('a', 'banana', 2) = 4)
chk("3rd 'x'", StzFindNth('x', 'xxxxx', 3) = 3)
chk("nth via :In", StzFindNth('a', [ :In, 'banana' ], 3) = 6)
chk("n out of range", StzFindNth('a', 'banana', 9) = 0)

? "-- Scene 7: StzFind returns ALL positions, needle-first --"
chk("all positions of a substr", @@(StzFind('a', 'banana')) = @@([ 2, 4, 6 ]))
chk("all positions of an item", @@(StzFind('b', [ 'b', 'a', 'b' ])) = @@([ 1, 3 ]))

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
