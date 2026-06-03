# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #6.

load "../../stzBase.ring"


aList = [
	[ "salem", 67, "" ],
	[ "mourad", 18, "" ],
	[ "amer", 34, "" ],
	[ "abir", "", "" ],
	[ "amer", 20, "" ]
]

? @@NL( ring_sort2(alist, 1) )
#--> [
#	[ "abir", "", "" ],
#	[ "amer", 20, "" ],
#	[ "amer", 34, "" ],
#	[ "mourad", 18, "" ],
#	[ "salem", 67, "" ]
# ]

pf()
# Executed in almost 0 second(s).
