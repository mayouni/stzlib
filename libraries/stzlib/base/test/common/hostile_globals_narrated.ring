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
	Then("rgb check", IsRGBColor([ 10, 20, 30 ]), 1)
	Then("floor-divide operator", Q(345)['// 100'], 3)
	Then("param-named-n sibling is unaffected", StzNumberQ(8).IsDoubleOf(4), 1)
EndScenario()

Scenario("THE POINT: the library never clobbers the user's variables")
	Then("nLen intact", nLen, 5)
	Then("i intact", i, 2)
	Then("j intact", j, 3)
	Then("n intact", n, 44)
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
