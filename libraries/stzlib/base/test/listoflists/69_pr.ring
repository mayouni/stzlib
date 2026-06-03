# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #69.

load "../../stzBase.ring"


? 3Cards()
#--> [ "🂭", "🂡", "🂡" ]

o1 = new stzListOfLists([
	[ "A", "B" ],
	[ 1, 2, 3 , 4, 5 ],
	3Cards()
])

? @@NL( o1.Adjusted() ) + NL
#--> [
#	[ "A", "B",  "",  "", "" ],
#	[   1,   2,   3,   4,  5 ],
#	[ "🂡", "🂨", "🂨", "", "" ]
# ]

? @@NL( o1.AdjustedWith( AHeart() ) ) # Or AdjustedWith("♥")
#--> [
#	[ "A", "B",  "♥",  "♥", "♥" ],
#	[   1,   2,    3,   4,    5 ],
#	[ "🂡", "🂨",  "🂨", "♥", "♥" ]
# ]


? @@NL( o1.Stretched() ) + NL # Or Extended or Expanded
#--> [
#	[ "A", "B",  "",  "", "" ],
#	[   1,   2,   3,   4,  5 ],
#	[ "🂡", "🂨", "🂨", "", "" ]
# ]


? @@NL( o1.Shrinked() )
#--> [
#	[ "A", "B" ],
#	[ 1, 2 ],
#	[ "🂡", "🂥" ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
