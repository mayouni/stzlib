# Narrative
# --------
# THE RING GLOBAL-CAPTURE TRAP, guarded forever. Ring binds plain
# method/function assignments to an EXISTING GLOBAL of the same name
# (for-loop counters stay local; plain assignments do not). So any
# library routine using a bare common temporary -- nLen, aResult, i as
# a while-counter -- is silently coupled to whatever the USER's script
# defined at top level: the library corrupts the user's variables, and
# the user's variables corrupt the library's loops (Array Access
# crashes far from the cause, as happened in the natural engine).
#
# The cure is the _x_ naming convention on every plain-assigned
# temporary (swept across stzNatural, stzList, stzString, and the hot
# common/ modules). This suite IS the hostile caller: it defines the
# most plausible user globals at top level, exercises hot paths, and
# asserts both correct results AND that the globals come back intact.

load "../../stzBase.ring"
load "../_narrated.ring"

# -- the hostile environment a real user script plausibly creates
engine = "MY OWN VALUE"
nLen = 5
i = 2
j = 3
n = 44
aResult = [ "mine" ]
acResult = [ "mine" ]
anResult = [ 99 ]
cResult = "mine"
cCode = "mine"
nPos = 7
nCount = 9
aItems = [ "mine" ]
cStr = "mine"
cItem = "mine"
value = "mine"

Scenario("String hot paths stay correct under hostile globals")
	Then("uppercase", StzStringQ("hello").UppercaseQ().Content(), "HELLO")
	Then("find", @@( StzFind("l", "hello") ), @@([ 3, 4 ]))
	Then("replace", StzReplace("a.b.c", ".", "-"), "a-b-c")
	Then("split", @@( StzSplit("a,b,c", ",") ), @@([ "a", "b", "c" ]))
	Then("section", StzStringQ("softanza").Section(1, 4), "soft")
	Then("reverse", StzStringQ("ring").ReverseQ().Content(), "gnir")
EndScenario()

Scenario("List hot paths stay correct under hostile globals")
	Then("find", @@( StzListQ([ 3, 1, 3 ]).Find(3) ), @@([ 1, 3 ]))
	Then("sort", @@( StzListQ([ 3, 1, 2 ]).SortQ().Content() ), @@([ 1, 2, 3 ]))
	Then("dedup", @@( StzListQ([ 3, 1, 3, 2 ]).RemoveDuplicatesQ().Content() ), @@([ 3, 1, 2 ]))
	Then("nlastitems (bare-nLen site, now guarded)",
		@@( StzListQ([ 1, 2, 3, 4 ]).NLastItems(2) ), @@([ 3, 4 ]))
	Then("allitemsexcept", @@( StzListQ([ "a", "b", 3 ]).AllItemsExcept(3) ), @@([ "a", "b" ]))
	Then("removesection", @@( StzListQ([ 1, 2, 3, 4 ]).RemoveSectionQ(2, 3).Content() ), @@([ 1, 4 ]))
	Then("ishashlist", IsHashList([ :a = 1, :b = 2 ]), TRUE)
	Then("intersection", @@( StzListQ([ 3, 1, 3, 2 ]).IntersectionWith([ 3, 2, 9 ]) ), @@([ 3, 2 ]))
EndScenario()

Scenario("The natural engine stays correct under hostile globals")
	oNat = Naturally("Create a list with [ 3, 1, 3 ] and Remove its duplicates")
	Then("natural dedup", @@( oNat.Result() ), @@([ 3, 1 ]))
EndScenario()

# THE PATHS THAT ACTUALLY LEAKED (found 2026-08-01). The suite used to
# reach these only through Naturally(), whose parse path varies with the
# input -- so the capture surfaced as an intermittent "n intact" failure
# that vanished on re-run. Calling them DIRECTLY turns a 1-in-5 flake
# into a deterministic assertion, which is the whole point of a guard.
Scenario("The range-parser helpers keep their hands off the caller's globals")
	Then("quoted-token check", _IsQuotedToken('"hi"'), TRUE)
	Then("unquote", _Unquote('"hello"'), "hello")
	Then("split trailing digits", @@( _SplitTrailingDigits("item42") ), @@([ "item", "42" ]))
	Then("numeric token", _IsNumericToken("12.5"), TRUE)
	oHgApp = StzAppQ("hostile-probe")
	oHgApp.AddThing(:dish)
	Then("app thing added", @@( oHgApp.Things() ), @@([ [ "dish", [ ] ] ]))
EndScenario()

# NL IS A GLOBAL TOO, and Ring's own split() reads it (found 2026-11-05).
# Ring is case-insensitive, so a caller writing `nL = len(aLines)` -- the
# exact line in image_quality_narrated.ring -- turned NL into a number,
# and every later split() in the library raised "Bad parameter type"
# inside substr(), far from that line. The library calls ring_split()
# now: the same function with char(10) where split() reads NL. Each
# answer is taken while NL is a number and again once NL is restored --
# the narration itself prints with NL -- and the two must agree.
Scenario("A caller's nL does not break the library's splitting")
	nL = 3
	bHgRaised = 0
	try
		split("a:b", ":")
	catch
		bHgRaised = 1
	done
	aHgSplit1 = ring_split("a:b" + char(10) + "c", ":")
	aHgKeys1 = StzJsonKeys('{"a":1,"b":2}')
	nHgTime1 = StzIsTime("17:04:05")
	cHgDt1 = new stzDateTime("2026-11-05T17:04:00").ToString()
	aHgKnow1 = StzKnowSplit("a|b|c")
	nL = char(10)

	aHgSplit2 = ring_split("a:b" + char(10) + "c", ":")
	aHgKeys2 = StzJsonKeys('{"a":1,"b":2}')
	nHgTime2 = StzIsTime("17:04:05")
	cHgDt2 = new stzDateTime("2026-11-05T17:04:00").ToString()
	aHgKnow2 = StzKnowSplit("a|b|c")

	Then("the hostility is real: Ring's own split() raises while NL is a number", bHgRaised, 1)
	Then("ring_split answers as split() does, a newline splitting too", @@( aHgSplit1 ), @@([ "a", "b", "c" ]))
	Then("...and the same with NL restored", @@( aHgSplit2 ), @@( aHgSplit1 ))
	Then("json keys (stzJson)", @@( aHgKeys1 ), @@([ "a", "b" ]))
	Then("...and the same with NL restored", @@( aHgKeys2 ), @@( aHgKeys1 ))
	Then("a time is recognised (stzTime)", nHgTime1, 1)
	Then("...and the same with NL restored", nHgTime2, nHgTime1)
	Then("a date-time with a T parses (stzDateTime)", StzFindFirst("17:04", cHgDt1) > 0, TRUE)
	Then("...and the same with NL restored", cHgDt2, cHgDt1)
	Then("a knowledge line splits (stzKnowledgeGraph)", len(aHgKnow1), 3)
	Then("...and the same with NL restored", @@( aHgKnow2 ), @@( aHgKnow1 ))
EndScenario()

# THE LIBRARY'S OWN NL READS (NL-RESWEEP-01, 2026-11-05). New code had
# brought back 457 bare reads of NL in 53 loaded files; each is char(10)
# now. A bare read does not raise when NL is a number -- "a" + 3 is "a3"
# -- so the wound is a newline silently replaced by a digit. Each swept
# path below answers while NL is 3, and again once NL is restored.
Scenario("A caller's nL does not leak into the library's text")
	nL = 3
	cHgBare1 = "a" + nl
	cHgList1 = StzListQ([ 1, 2 ]).ToString()
	cHgCsv1 = ListToCSVXT([ [ "a", [ "1", "2" ] ], [ "b", [ "3", "4" ] ] ], ",")
	oHgG = new stzGraph("hg")
	oHgG.AddNode("x")
	oHgG.AddNode("y")
	oHgG.AddEdge("x", "y")
	cHgDot1 = oHgG.ExportToDOT()
	cHgMan1 = _StzWebManifest("hg", [ "a.wasm" ], "a.wasm")
	nL = char(10)

	cHgList2 = StzListQ([ 1, 2 ]).ToString()
	cHgCsv2 = ListToCSVXT([ [ "a", [ "1", "2" ] ], [ "b", [ "3", "4" ] ] ], ",")
	cHgDot2 = oHgG.ExportToDOT()
	cHgMan2 = _StzWebManifest("hg", [ "a.wasm" ], "a.wasm")

	Then("the hostility is real: a bare read of NL gives a digit, not a newline", cHgBare1, "a3")
	Then("a list prints one item per line (stzList.ToString)", StzFindFirst(char(10), cHgList1) > 0, TRUE)
	Then("...and the same with NL restored", cHgList2, cHgList1)
	Then("a CSV breaks its rows on a newline (ListToCSVXT)", cHgCsv1, "a,b" + char(10) + "1,3" + char(10) + "2,4")
	Then("...and the same with NL restored", cHgCsv2, cHgCsv1)
	Then("a DOT export keeps its edge line (stzGraph)", StzFindFirst("  x -> y;" + char(10), cHgDot1) > 0, TRUE)
	Then("...and the same with NL restored", cHgDot2, cHgDot1)
	Then("a web manifest keeps its lines (stzWebBundle)", StzFindFirst('"main": "a.wasm",' + char(10), cHgMan1) > 0, TRUE)
	Then("...and the same with NL restored", cHgMan2, cHgMan1)
EndScenario()

# stzNumber leaked the same way, in eleven places: Factorial, Fibonacci,
# Absolute, IsADigit, IsBetween(IB), PrimeFactors(XT), MultiplesUntil,
# IsRGBColor and the [] operator all assigned a bare `n`. The sibling
# methods that take an `n` PARAMETER were always safe -- a parameter is a
# real local -- and two are exercised here so the distinction stays
# visible rather than being re-litigated every time someone greps.
Scenario("Number hot paths keep their hands off the caller's globals")
	Then("factorial", StzNumberQ(5).Factorial(), "120")
	Then("fibonacci", StzNumberQ(10).Fibonacci(), "55")
	Then("absolute", StzNumberQ(-3).Absolute(), 3)
	Then("is-a-digit", StzNumberQ(7).IsADigit(), 1)
	Then("is-between", StzNumberQ(5).IsBetween(2, 9), 1)
	Then("prime factors", @@( StzNumberQ(12).PrimeFactors() ), @@([ 2, 3 ]))
	Then("multiples until", @@( StzNumberQ(3).MultiplesUntil(9) ), @@([ 3, 6, 9 ]))
	# ...and up to a limit written as text: that branch read a bare `n` where it
	# meant the limit -- the caller's n = 44 on Ring, a refusal on rnxc (2026-11-05)
	Then("multiples until a limit written as text", @@( StzNumberQ(3).MultiplesUntil("9") ), @@([ 3, 6, 9 ]))
	Then("rgb check", IsRGBColor([ 10, 20, 30 ]), 1)
	Then("floor-divide operator", Q(345)['// 100'], 3)
	Then("param-named-n sibling is unaffected", StzNumberQ(8).IsDoubleOf(4), 1)
EndScenario()

# A BARE CLASS ATTRIBUTE IS A DIFFERENT WOUND from a bare assignment,
# and a worse one. At `new`, a user global of the attribute's name is
# BOUND instead of the attribute being created -- so the attribute never
# exists and the first `this.name` dies R12 "property not found". The
# whole reactive module was unusable to any script holding a variable
# called `engine`: `new stzReactive()` itself raised (fixed 2026-08-02).
Scenario("A hostile global does not stop an object being BUILT")
	oHgRx = new stzReactive()
	Then("the reactive engine constructs at all", isObject(oHgRx), TRUE)
	oHgS = oHgRx.CreateStream("hg-s1")
	Then("...and hands out a stream", isObject(oHgS), TRUE)
	oHgT = oHgRx.CreateTimer("hg-t1", 50, func { return 1 })
	Then("...and a timer", isObject(oHgT), TRUE)
	oHgF = oHgRx.Reactivate(func x { return x * 2 })
	Then("...and a reactive function", isObject(oHgF), TRUE)
EndScenario()

# The last three hostile names that still had bare assignments in the
# library: nLen (stzDelivery, stzReactor), value (stzPivotTable,
# stzList) and cCode (stzChainOfTruth, stzCCode). cCode is the sharpest
# of them -- it holds the STRING handed to eval(), so a user script
# using that name had its own variable replaced by library source code.
Scenario("The last three hostile names: nLen, value and cCode")
	oHgDel = new stzDelivery("hostile-probe")
	oHgDel.AddBackend("api", "linux")
	oHgDel.NeedsIn("api", [ :graph ])
	Then("delivery planned a part", oHgDel.NumberOfParts(), 1)

	oHgList = new stzList([ 1, 2 ])
	oHgList.ExtendToPosition(4)
	Then("list extended with a default", @@( oHgList.Content() ), @@([ 1, 2, 0, 0 ]))

	# Exercises the eval() path that assigns cCode. Deliberately asserts
	# only that it RETURNS -- `_("Ring").Is("String")` answers 0, which
	# looks wrong but is unchanged by this fix (verified against the
	# pre-rename file). Blessing that 0 here would turn a suspected
	# defect into a pinned expectation.
	bHgIs = _("Ring").Is("String")._
	Then("chain-of-truth's eval path returns a verdict", isNumber(bHgIs), TRUE)
EndScenario()

Scenario("THE POINT: the library never clobbers the user's variables")
	Then("nLen intact", nLen, 5)
	Then("i intact", i, 2)
	Then("j intact", j, 3)
	Then("n intact", n, 44)
	Then("engine intact", engine, "MY OWN VALUE")
	Then("aResult intact", @@( aResult ), @@([ "mine" ]))
	Then("acResult intact", @@( acResult ), @@([ "mine" ]))
	Then("anResult intact", @@( anResult ), @@([ 99 ]))
	Then("cResult intact", cResult, "mine")
	Then("cCode intact", cCode, "mine")
	Then("nPos intact", nPos, 7)
	Then("cItem intact", cItem, "mine")
	Then("value intact", value, "mine")
EndScenario()

Summary()
