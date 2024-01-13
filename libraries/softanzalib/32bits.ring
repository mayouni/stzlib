
load "stzlib.ring"


pron()

o1 = new stzList(Q("1♥♥456♥♥901♥♥4").Chars())

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

proff()


/*=====

pron()

? Q(2.5).RoundedToXT(3)
#--> '2.500'

? Q(2.75).RoundedToXT(0)
#--> '3'

? Q(2).RoundedTo(3)
#--> '2'

? Q(2).RoundedToXT(3)
#--> '2.000'

? Q(12).RoundedToXT(0)
#--> "12"

proff()
# Executed in 0.05 second(s)
