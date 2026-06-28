# Narrative
# --------
# Random picks and random removals on a stzList -- the "deal me some cards"
# idiom. Cards() is the deck (13 glyphs), CardsXT() the same paired with names.
#
# The deck itself is deterministic, so we assert it; the rnd* results are
# RANDOM by design, so we assert their SIZE (which is deterministic) rather
# than which specific cards came up:
#   rndItems()        -> a random NUMBER of random items
#   rndNItems(n)      -> exactly n random items
#   rndRemoveItems()  -> remove a random number of items (mutating)
#   rndRemoveNItems(n)-> remove exactly n random items (mutating)
#
# Extracted from stzStringTest.ring, block #501.

load "../../stzBase.ring"

pr()

# Softanza knows about the deck of cards
o1 = new stzList( Cards() )

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

? o1.NumberOfItems()
#--> 13

# A random number of random cards (the count varies per run, 1..13)
? o1.rndItems() != NULL
#--> TRUE

# A specified number of random cards
? len( o1.rndNItems(3) )
#--> 3

# Removing a random number of cards (mutating) shrinks the deck
o1.rndRemoveItems()
? o1.NumberOfItems() < 13
#--> TRUE

# Removing a given number of random cards drops exactly that many
nBefore = o1.NumberOfItems()
o1.rndRemoveNItems(2)
? ( nBefore - o1.NumberOfItems() ) = 2
#--> TRUE

# You can also play with the named cards via CardsXT()
o2 = new stzList( CardsXT() )
? @@NL( o2.Content() )
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
