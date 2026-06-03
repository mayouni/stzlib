# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #49.

load "../../stzBase.ring"

pr()

# You can extend a list of lists to any number of items like this:

o1 = new stzLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? o1.IsHomolog()
#--> FALSE

o1.ExtendTo(4)
# By default, the items are extended using the NULL char
# Use ExtendToXT(n, char) to specify your own (next example)

? @@( o1.Content() )
#--> [
#	[ "A", "B",  "",  "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I",  "",  "",  "" ]
# ]

? o1.IsHomolog()
#--> TRUE

pf()
#--> Executed in 0.05 second(s)
