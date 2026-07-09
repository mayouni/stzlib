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
