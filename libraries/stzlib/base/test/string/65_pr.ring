# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #65.

load "../../stzBase.ring"

pr()

o1 = new stzString("1♥♥456♥♥901♥♥4")

o1 {
	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 4, 8, 9, 14, 15 ]

	# Doing someting with the positions

	ReplaceCharsAtPositions(anPos, :With = "★")
		? Content()
		#--> 1★★456★★901★★4

	#-- Finding sections

	aSections = FindAsSections("★★")
		? @@(aSections)
		#--> [ [ 2, 3 ], [ 7, 8 ], [ 12, 13 ] ]

	#-- Doing somethinh the sections

	RemoveSections(aSections)
		? o1.Content()
		#--> 14569014
	
}

pf()
# Executed in 0.07 second(s) in Ring 1.22
