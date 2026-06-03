# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #42.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

o1.ExtendToXT( :Position = 6, :ByRepeatingItems ) # or :Using = :RepeatedItems

? @@( o1.Content() )
#--> [
#	[ "A", "B", "A", "B", "A", "B" ],
#	[ "C", "D", "E", "F", "C", "D" ],
#	[ "I", "I", "I", "I", "I", "I" ]
# ]

pf()
#--> Executed in 0.07 second(s)
