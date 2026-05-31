# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #501.

load "../../../stzBase.ring"


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
# Executed in 0.01 second(s).
