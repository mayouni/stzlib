# Narrative
# --------
# Flattening a deeply nested list and then reading its content.
#
# Flatten() collapses an arbitrarily nested list into a single flat
# list, dropping empty sublists entirely and pulling every leaf value
# up to the top level in left-to-right order. Here the tangled input
# with empty brackets and triple-nested groups becomes the simple
# [ "a", "c", 1, 2, "b" ]. Once flat, Content() returns the items,
# NumberOfItems() counts them, and ItemAtPosition() reads a single
# 1-based slot -- showing the list is now a plain ordered sequence.
#
# Extracted from stzlisttest.ring, block #466.

load "../../stzBase.ring"

pr()

StzListQ([ "a",[ [ [], "c", [ 1, [] ], 2 ] ],"b" ]) {

	Flatten()

	? @@( Content() )
	#--> [ "a", "c", 1, 2, "b" ]

	? NumberOfItems()
	#--> 5

	? ItemAtPosition(3)
	#--> 1

	? ItemAtPosition(5)
	#--> b
	
}

pf()
# Executed in 0.01 second(s).
