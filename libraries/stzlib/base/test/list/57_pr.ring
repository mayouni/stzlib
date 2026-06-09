# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #57.
#ERR exit 1: Line 98 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

o1 = new stzList( Q("1♥♥456♥♥901♥♥4").Chars() )

o1 {

	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 7, 8, 12, 13 ]

	# Doing someting with the positions

	ReplaceAnyItemsAtPositions(anPos, :With = "★")
		? Content()
		#--> [ "1","★","★","4","5","6","★","★","9","0","1","★","★","4" ]
	
}

pf()
# Executed in 0.06 second(s)
