# Narrative
# --------
# Building a positional INDEX of a list, then counting occurrences.
#
# Inside a StzListQ { } block the methods read like a fluent script
# operating on "this list". We first Flatten the ranges ("1":"3" etc.
# expand to their members) and Sort, then:
#   - FindItems()                  -> each distinct item with its positions
#   - NumberOfOccurrenceOfEachItem -> each distinct item with its count
# Both group by a type-aware key, so "2" appears at positions 3 and 4
# (count 2) while "10" is its own bucket -- never confused with "1".
#
# Extracted from stzlisttest.ring, block #19.

load "../../stzBase.ring"

pr()

StzListQ([ "1":"3", "2":"7", "10":"12" ]) {
	Flatten()
	Sort()

	Show() + NL
	#--> [ "1", "10", "2", "2", "3", "3", "4", "5", "6", "7" ]

	? @@( FindItems() ) + NL # Or ItemsAndTheirPositions() or ItemsZ()
	#--> [ [ "1", [ 1 ] ], [ "10", [ 2 ] ], [ "2", [ 3, 4 ] ], [ "3", [ 5, 6 ] ], [ "4", [ 7 ] ], [ "5", [ 8 ] ], [ "6", [ 9 ] ], [ "7", [ 10 ] ] ]

	? @@( NumberOfOccurrenceOfEachItem() ) # Or ItemsCount()
	#--> [ [ "1", 1 ], [ "10", 1 ], [ "2", 2 ], [ "3", 2 ], [ "4", 1 ], [ "5", 1 ], [ "6", 1 ], [ "7", 1 ] ]
}

pf()
# Executed in 0.04 second(s)
