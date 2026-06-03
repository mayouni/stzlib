# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #501.

load "../../stzBase.ring"


# Softanza knows about the list of cards

o1 = new stzList( Cards() )

# Here is their list

? @@NL( o1.Content() ) + NL
#--> [
#	"🂡",
#	"🂢",
#	"🂣",
#	"🂤",
#	"🂥",
#	"🂦",
#	"🂧",
#	"🂨",
#	"🂩",
#	"🂪",
#	"🂫",
#	"🂭",
#	"🂮"
# ]

# We can get random cards

? @@( o1.rndItems() )
#--> [ "🂫" ]

? @@( o1.rndItems() ) + NL
#--> [ "🂨", "🂥", "🂡", "🂧" ]

# Or a specifed numbers of random cards

? @@( o1.rndNItems(3) )
#--> [ "🂤", "🂨", "🂧" ]

? @@( o1.rndNItems(3) ) + NL
#--> [ "🂧", "🂨", "🂡" ]

# And we can rmoved a random number of them

o1.rndRemoveItems()
? @@( o1.Content() )
#--> [ "🂡", "🂢", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂮" ]

o1.rndRemoveItems()
? @@( o1.Content() )
#--> [ "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂮" ]

o1.rndRemoveItems()
? @@( o1.Content() ) + NL
#--> [ "🂥", "🂧", "🂨", "🂩", "🂮" ]

# Or we can remove a givan number of random cards

o1.rndRemoveNItems(3) + NL
? @@( o1.Content() )
#--> [ "🂩", "🂪" ]

#NOT: You can play the game with cards names by using CardsXT()

o1 = new stzList( CardsXT() )
? @@NL( o1.Content() )
#--> [
#	[ "ace", "🂡" ],
#	[ "two", "🂢" ],
#	[ "three", "🂣" ],
#	[ "four", "🂤" ],
#	[ "five", "🂥" ],
#	[ "six", "🂦" ],
#	[ "seven", "🂧" ],
#	[ "eight", "🂨" ],
#	[ "nine", "🂩" ],
#	[ "ten", "🂪" ],
#	[ "jack", "🂫" ],
#	[ "queen", "🂭" ],
#	[ "king", "🂮" ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
