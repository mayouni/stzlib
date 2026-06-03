# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #927.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")

o1.ReplaceManyByMany(
	[ "[...]", "[...]", "[~~~]", "[~~~]" ],
	[ "ONE",    "TWO",   "THREE", "FOUR" ]
)

? o1.Content()
#--> --ONE---TWO---[...]---THREE--FOUR--

#--

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")

o1.ReplaceManyByMany(
	[ "[...]", "[...]", "[~~~]" ],
	[ "ONE",    "TWO",   "THREE", "FOUR" ]
)

? o1.Content()
#--> --ONE---TWO---[...]---THREE--[~~~]--

#--

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")

o1.ReplaceManyByMany(
	[ "[...]", "[...]", "[~~~]", "[~~~]" ],
	[ "ONE",    "TWO",   "THREE" ]
)

? o1.Content()
#--> --ONE---TWO---[...]---THREE--[~~~]--

pf()
# Executed in 0.05 second(s).
