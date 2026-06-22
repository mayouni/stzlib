# Narrative
# --------
# WalkWhere: the positions of the items satisfying a condition.
#
# WalkWhere(condition) "walks" the list and returns the POSITIONS where the
# W-condition holds -- it is the walker's view of FindW. To get the matching
# VALUES instead, use ItemsW; to read them in reverse, pipe through Reversed().
# W is the single performant + expressive conditional form (the old directional
# WalkWhereXT is retired -- compose with ItemsW / Reversed for the same result).
# Over [ 1, 2, "A", "B", 5, "C", 7 ] the numbers sit at positions 1, 2, 5, 7,
# and the non-numbers read backward are "C", "B", "A".
#
# Extracted from stzlisttest.ring, block #494.

load "../../stzBase.ring"

pr()

StzListQ([ 1, 2, "A", "B", 5, "C", 7 ]) {

	? WalkWhere(' isNumber(@item) ')
	#--> [ 1, 2, 5, 7 ]

	? ItemsW(' isNumber(@item) ')
	#--> [ 1, 2, 5, 7 ]

	? Q( ItemsW(' NOT isNumber(@item) ') ).Reversed()
	#--> [ "C", "B", "A" ]
}

pf()
# Executed in 0.20 second(s).
