# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #644.

load "../../stzBase.ring"

pr()

aList = [ 12,
	[ "A", [ 1, 2, 3] ], 		# 1st sublist
	[ "B", [ 3, 5, 3 ] ], 		# 2nd sublist
	[ "C", [ 1, 4, [1,2,3], 4] ] 	# 3rd sublist
]

? StzListQ(aList).ContainsOneOrMoreLists()

pf()
