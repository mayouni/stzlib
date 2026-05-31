# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #538.

load "../../../stzBase.ring"


? @@( Merge([ [ 1, 2 ], [ 3 ] ]) )
#--> [ 1, 2, 3 ]

? @@( Merge([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
]) )
#--> [ [ 1, 2], [3, 4] ]

? @@( Flatten([
	[ [ 1, 2 ] ],
	[ [ 3, 4 ] ]
]) )
#--> [ 1, 2, 3, 4 ]

pf()
# Executed in almost 0 second(s).
