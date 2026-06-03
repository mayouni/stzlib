# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #601.

load "../../stzBase.ring"


o1 = new stzList(1:12)
? @@NL( o1.DistributeOver([ "Mansour", "Teeba", "Haneen", "Hussein", "Sherihen" ]) )
#-->
# [
#	[ "Mansour",  [ 1, 2, 3 ] ],
#	[ "Teeba",    [ 4, 5, 6 ] ],
#	[ "Haneen",   [ 7, 8    ] ],
#	[ "Hussein",  [ 9, 10   ] ],
#	[ "Sherihen", [ 11, 12  ] ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.17
