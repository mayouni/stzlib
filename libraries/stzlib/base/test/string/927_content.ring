load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceManyByMany pairs by OCCURRENCE: a repeated old maps its
# successive occurrences to successive news; extras on either side
# are ignored. Archive block #927.

Scenario("Four pairs over five blocks")
	o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
	o1.ReplaceManyByMany(
		[ "[...]", "[...]", "[~~~]", "[~~~]" ],
		[ "ONE",    "TWO",   "THREE", "FOUR" ]
	)
	Then("third dots block untouched",
		o1.Content(), "--ONE---TWO---[...]---THREE--FOUR--")
EndScenario()

Scenario("More news than olds")
	o2 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
	o2.ReplaceManyByMany(
		[ "[...]", "[...]", "[~~~]" ],
		[ "ONE",    "TWO",   "THREE", "FOUR" ]
	)
	Then("the extra FOUR is ignored",
		o2.Content(), "--ONE---TWO---[...]---THREE--[~~~]--")
EndScenario()

Scenario("More olds than news")
	o3 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
	o3.ReplaceManyByMany(
		[ "[...]", "[...]", "[~~~]", "[~~~]" ],
		[ "ONE",    "TWO",   "THREE" ]
	)
	Then("the extra old is ignored",
		o3.Content(), "--ONE---TWO---[...]---THREE--[~~~]--")
EndScenario()

Summary()
