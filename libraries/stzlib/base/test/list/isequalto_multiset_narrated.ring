# IsEqualTo -- the same items, each as many times, in any order.
#
# stzList.IsEqualTo is documented as a MULTISET comparison: order does
# not matter, repeats do. Until 2026-11-08 it compared the lengths and
# a subset each way, which ignores repeats, so [1,1,2] read equal to
# [1,2,2]. Found by the stzlib-testoor desk with a property over
# generated lists (TESTOOR_ZIG_CORE.md, "List domains"): the law
# "IsEqualTo agrees with comparing the sorted lists" failed at seeds
# 5, 6 and 7.
#
# The fix sorts a COPY of each side in the engine, under the case rule,
# and compares the sorted copies position by position. This guard pins
# the repeats, the order, the case dial, nested lists, text in several
# scripts, the comparator's faces and the = operator, and checks that
# the list's own cached engine handle is not the one sorted.
#
# The properties judge IsEqualTo against an oracle that does NOT sort:
# it counts each value on both sides in a Ring loop over numbers. An
# oracle built from Sorted() and IsStrictlyEqualTo would share the fix's
# own mechanism and could agree with it by coincidence. A false law
# beside them (the old set rule) must fail, so the properties cannot
# pass vacuously.
#
# Ends on Summary() then shutdown($_zst_fail): the exit code is the
# number of failed assertions.

load "../../stzBase.ring"
load "../_narrated.ring"

nIeqAll = clock()

#============================================================================
nIeqSec = clock()
Scenario("Repeats count")
	Given("[1,1,2] and [1,2,2]: the same length, the same distinct items")
	Then("[1,1,2] is not equal to [1,2,2]", new stzList([ 1, 1, 2 ]).IsEqualTo([ 1, 2, 2 ]), 0)
	Then("and [1,2,2] is not equal to [1,1,2]", new stzList([ 1, 2, 2 ]).IsEqualTo([ 1, 1, 2 ]), 0)
	Then("[a,a,b] is not equal to [a,b,b]", new stzList([ "a", "a", "b" ]).IsEqualTo([ "a", "b", "b" ]), 0)
	Then("[1,1,2] is equal to [2,1,1]: the same repeats, another order",
		new stzList([ 1, 1, 2 ]).IsEqualTo([ 2, 1, 1 ]), 1)
	Then("[1,2] is not equal to [1,2,2]: the lengths differ", new stzList([ 1, 2 ]).IsEqualTo([ 1, 2, 2 ]), 0)
EndScenario()

Scenario("Order does not matter")
	Then("[1,0] is equal to [0,1]", new stzList([ 1, 0 ]).IsEqualTo([ 0, 1 ]), 1)
	Then("[3,1,2] is equal to [1,2,3]", new stzList([ 3, 1, 2 ]).IsEqualTo([ 1, 2, 3 ]), 1)
	Then("[] is equal to []", new stzList([]).IsEqualTo([]), 1)
	Then("a value that is not a list answers 0", new stzList([ "a" ]).IsEqualTo("a"), 0)
	Then("[1,'1'] is equal to ['1',1]", new stzList([ 1, "1" ]).IsEqualTo([ "1", 1 ]), 1)
	Then("[1,1] is not equal to [1,'1']: a number and a text are two items",
		new stzList([ 1, 1 ]).IsEqualTo([ 1, "1" ]), 0)
EndScenario()

Scenario("The case dial")
	Given("[a,B,b] and [A,b,B]")
	Then("with case they differ", new stzList([ "a", "B", "b" ]).IsEqualTo([ "A", "b", "B" ]), 0)
	Then("ignoring case they are equal", new stzList([ "a", "B", "b" ]).IsEqualToCS([ "A", "b", "B" ], 0), 1)
	Then("the named form [ :CaseSensitive, 0 ] says the same",
		new stzList([ "a", "B", "b" ]).IsEqualToCS([ "A", "b", "B" ], [ :CaseSensitive, 0 ]), 1)
	Then("and [ :CaseSensitive, 1 ] compares with case",
		new stzList([ "a", "B", "b" ]).IsEqualToCS([ "A", "b", "B" ], [ :CaseSensitive, 1 ]), 0)
	Then("ignoring case, repeats still count: [a,a,b] is not [A,b,B]",
		new stzList([ "a", "a", "b" ]).IsEqualToCS([ "A", "b", "B" ], 0), 0)
EndScenario()

Scenario("Nested lists are items")
	Then("[[1,2],[1,2],3] is not equal to [[1,2],3,3]",
		new stzList([ [ 1, 2 ], [ 1, 2 ], 3 ]).IsEqualTo([ [ 1, 2 ], 3, 3 ]), 0)
	Then("[[1,2],3] is equal to [3,[1,2]]", new stzList([ [ 1, 2 ], 3 ]).IsEqualTo([ 3, [ 1, 2 ] ]), 1)
	Then("[[1,2],[2,1]] is equal to [[2,1],[1,2]]",
		new stzList([ [ 1, 2 ], [ 2, 1 ] ]).IsEqualTo([ [ 2, 1 ], [ 1, 2 ] ]), 1)
	Then("an inner list is one value: [[1,2]] is not equal to [[2,1]]",
		new stzList([ [ 1, 2 ] ]).IsEqualTo([ [ 2, 1 ] ]), 0)
EndScenario()

Scenario("Text in several scripts")
	Then("Hebrew and emoji, the same repeats in another order",
		new stzList([ "שלום", "😀", "שלום" ]).IsEqualTo([ "😀", "שלום", "שלום" ]), 1)
	Then("and with the repeat moved to the other item, not equal",
		new stzList([ "שלום", "😀", "שלום" ]).IsEqualTo([ "😀", "😀", "שלום" ]), 0)
	Then("Greek and Arabic, reordered",
		new stzList([ "αβγ", "سلام", "αβγ" ]).IsEqualTo([ "αβγ", "αβγ", "سلام" ]), 1)
EndScenario()

Scenario("The list itself is not sorted by the comparison")
	Given("o1 = [3,1,2], whose engine handle is cached by the first call")
	o1 = new stzList([ 3, 1, 2 ])
	Then("o1 is strictly equal to [3,1,2] before", o1.IsStrictlyEqualTo([ 3, 1, 2 ]), 1)
	When("o1.IsEqualTo([1,2,3]) sorts its copies")
	Then("the comparison answers 1", o1.IsEqualTo([ 1, 2, 3 ]), 1)
	Then("o1's cached handle still reads [3,1,2] (IsStrictlyEqualTo uses it)",
		o1.IsStrictlyEqualTo([ 3, 1, 2 ]), 1)
	Then("and o1's content is [3,1,2]", @@(o1.Content()), "[ 3, 1, 2 ]")
EndScenario()

Scenario("The other faces give the same answer")
	oIeqCmp = new stzListComparator([ 1, 1, 2 ])
	Then("stzListComparator.IsEqualTo([1,2,2]) is 0", oIeqCmp.IsEqualTo([ 1, 2, 2 ]), 0)
	Then("stzListComparator.IsNotEqualTo([1,2,2]) is 1", oIeqCmp.IsNotEqualTo([ 1, 2, 2 ]), 1)
	Then("[1,1,2] is not a permutation of [1,2,2]", oIeqCmp.IsPermutationOf([ 1, 2, 2 ]), 0)
	Then("[1,1,2] is a permutation of [2,1,1]", oIeqCmp.IsPermutationOf([ 2, 1, 1 ]), 1)
	Then("ListEquals([1,1,2], [1,2,2]) is 0", ListEquals([ 1, 1, 2 ], [ 1, 2, 2 ]), 0)
	Then("Q([1,1,2]) = [1,2,2] is 0", Q([ 1, 1, 2 ]) = [ 1, 2, 2 ], 0)
	Then("Q([1,1,2]) = [2,1,1] is 1", Q([ 1, 1, 2 ]) = [ 2, 1, 1 ], 1)
EndScenario()
? "        [section took " + ((clock() - nIeqSec) / clockspersecond()) + "s]"

#============================================================================
nIeqSec = clock()
Scenario("The law, over generated lists")
	cIeqDom = "xs list 0..5 of int 0..3; ys list 0..5 of int 0..3"
	Given("two lists of up to five numbers from 0 to 3: " + cIeqDom)
	When("IsEqualTo is judged against counting each value on both sides")
	for nIeqSeed = 5 to 7
		aIeqP = TestoorProperty("LIST-ISEQUALTO-COUNTS", cIeqDom, "_IeqCountsLaw",
			[ :tries = 200, :seed = nIeqSeed, :print = 0 ])
		Then("it holds at seed " + nIeqSeed + " (it failed there before the fix)", aIeqP[:held], 1)
		Then("over 200 generated inputs", aIeqP[:tried], 200)
	next
	for nIeqSeed = 5 to 7
		aIeqP = TestoorProperty("LIST-ISEQUALTO-SORTED", cIeqDom, "_IeqSortedLaw",
			[ :tries = 200, :seed = nIeqSeed, :print = 0 ])
		Then("the testoor desk's law (equal to comparing the sorted lists) holds at seed " + nIeqSeed,
			aIeqP[:held], 1)
	next

	When("the other side is a permutation of the first, over text in every alphabet")
	aIeqP = TestoorProperty("LIST-ISEQUALTO-PERMUTED", "ws list 0..8 of text 0..4 of mixed; k int 0..9",
		"_IeqPermutedLaw", [ :tries = 200, :seed = 5, :print = 0 ])
	Then("a list is equal to any permutation of itself", aIeqP[:held], 1)
	Then("over 200 generated inputs", aIeqP[:tried], 200)

	Given("a law that is false: IsEqualTo is the old set rule (same length, same distinct items)")
	aIeqP = TestoorProperty("LIST-ISEQUALTO-IS-SET", cIeqDom, "_IeqSetLaw",
		[ :tries = 200, :seed = 5, :print = 0 ])
	Then("it fails: repeats count", aIeqP[:held], 0)
	? "    counterexample: " + aIeqP[:counterexample]
EndScenario()
? "        [section took " + ((clock() - nIeqSec) / clockspersecond()) + "s]"

? "        [guard took " + ((clock() - nIeqAll) / clockspersecond()) + "s]"
Summary()
shutdown($_zst_fail)

#============================================================================
# The checks. Each takes one generated input, a hash list, and answers 1
# when the law holds for it.

# IsEqualTo agrees with an oracle that counts each value 0..3 on both sides
func _IeqCountsLaw(paIn)
	_xs_ = paIn[:xs]
	_ys_ = paIn[:ys]
	_bOracle_ = 1
	if len(_xs_) != len(_ys_)
		_bOracle_ = 0
	else
		for _v_ = 0 to 3
			if _IeqCount(_xs_, _v_) != _IeqCount(_ys_, _v_)
				_bOracle_ = 0
				exit
			ok
		next
	ok
	_bGot_ = new stzList(_xs_).IsEqualTo(_ys_)
	return _bGot_ = _bOracle_

# the testoor desk's law: IsEqualTo agrees with comparing the sorted lists
func _IeqSortedLaw(paIn)
	_aXs_ = new stzList(paIn[:xs]).Sorted()
	_bSorted_ = new stzList(_aXs_).IsStrictlyEqualTo(new stzList(paIn[:ys]).Sorted())
	_bGot_ = new stzList(paIn[:xs]).IsEqualTo(paIn[:ys])
	return _bGot_ = _bSorted_

# a list is equal to itself rotated by k and reversed
func _IeqPermutedLaw(paIn)
	_xs_ = paIn[:ws]
	_n_ = len(_xs_)
	_ys_ = []
	if _n_ > 0
		_k_ = paIn[:k]
		for _i_ = _n_ to 1 step -1
			_ys_ + _xs_[ ((_i_ + _k_ - 1) % _n_) + 1 ]
		next
	ok
	return new stzList(_xs_).IsEqualTo(_ys_)

# the false law: IsEqualTo agrees with the set rule
func _IeqSetLaw(paIn)
	_xs_ = paIn[:xs]
	_ys_ = paIn[:ys]
	_bSet_ = 1
	if len(_xs_) != len(_ys_)
		_bSet_ = 0
	else
		for _v_ = 0 to 3
			if (_IeqCount(_xs_, _v_) > 0) != (_IeqCount(_ys_, _v_) > 0)
				_bSet_ = 0
				exit
			ok
		next
	ok
	_bGot_ = new stzList(_xs_).IsEqualTo(_ys_)
	return _bGot_ = _bSet_

# how many times the number pn is in the list of numbers paList
func _IeqCount(paList, pn)
	_nC_ = 0
	_nLen_ = len(paList)
	for _j_ = 1 to _nLen_
		if paList[_j_] = pn
			_nC_++
		ok
	next
	return _nC_
