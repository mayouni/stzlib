# Narrative
# --------
# Replacing a value everywhere in a list, however deeply it is nested.
#
# DeepReplace("me", :By = "you") walks the list recursively and swaps
# every occurrence of "me" for "you" -- at the top level, inside the
# inner sublist, and inside the innermost sublist [ "me" ] alike.
# A plain Replace would only touch the top-level items; DeepReplace
# descends through every level of nesting. The original five elements
# are preserved in count and order, with only the matching leaves
# rewritten.
#
# Extracted from stzlisttest.ring, block #360.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.DeepReplace("me", :By = "you")
? @@NL( o1.Content() )

#--> [
#	"you",
#	"other",
#	[ "other", "you", [ "you" ], "other" ],
#	"other"
#    ]

pf()
# Executed in 0.01 second(s).
