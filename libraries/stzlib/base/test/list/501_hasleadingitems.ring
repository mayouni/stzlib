# Narrative
# --------
# Leading and trailing item RUNS -- detecting, counting, and replacing them.
#
# A "leading" run is the block of identical items at the START of the list,
# "trailing" the block at the END. Here "*","*","*" lead and "+","+" trail.
# You can ask whether they exist (HasLeadingItems / HasTrailingItems),
# count them, read them, and rewrite them: ReplaceRepeatedLeadingItem(:with)
# rewrites just the leading run, while ReplaceLeadingAndTrailingItems does
# both ends at once. All mutate in place.
#
# Extracted from stzlisttest.ring, block #501.

load "../../stzBase.ring"

pr()

StzListQ([ "*", "*", "*", "R", "i", "n", "g", "+", "+" ]) {

	? HasLeadingItems()
	#--> TRUE
	? NumberOfLeadingItems() + NL
	#--> 3

	? LeadingItems()
	#--> [ "*", "*", "*" ]

	? HasTrailingItems()
	#--> TRUE

	? NumberOfTrailingItems() + NL
	#--> 2

	? TrailingItems()
	#--> [ "+", "+" ]

	ReplaceRepeatedLeadingItem(:with = "+")
	? Content()
	#--> [ "+", "+", "+", "R", "i", "n", "g", "+", "+" ]

	ReplaceLeadingAndTrailingItems("*") # Or [ "*", "*" ]
	? Content() #--> [ "*", "*", "*", "R", "i", "n", "g", "*", "*" ]
}

pf()
# Executed in almost 0 second(s)
