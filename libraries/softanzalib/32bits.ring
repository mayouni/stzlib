load "stzlib.ring"

pron()

o1 = new stzListOfPairs([ ["01","02"], ["08", "10"], ["16", "17"], ["23", "25"] ])
? @@( o1.SortedInAscending() )

proff()

/*------

pron()

	o1 = new stzString("**word1***word2**word3***")
	? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
	#--> [ "**", "***", "**", "***" ]
		
	o1.RemoveManySections([
		[1,2], [8, 10], [16, 17], [23, 25]
	])
		
	? o1.Content() #--> "blablablablabla"

proff()

/*
o1 = new stzString("1♥♥456♥♥901♥♥4")
o1.RemoveSections([ 2:3, 7:8, 12:13 ])
? o1.Content()

/*
o1 {
	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 4, 8, 9, 14, 15 ]

	# Doing someting with the positions

	RepalceCharsAtPositions(anPos, :With = "★")
		? Content()
		#--> 1★★456★★901★★4

	#-- Finding sections

	aSections = FindAsSections("★★")
		? @@(aSections)
		#--> [ [ 2, 3 ], [ 7, 8 ], [ 12, 13 ] ]

	#-- Doing somethinh the sections

	RemoveSections(aSections)
	? o1.Content()

}
