
load "stzlib.ring"


/*=============

pron()

o1 = new stzList([ ["03", "04"], 3, ["01","02"], 1, "Two", 2, "One" ])
? @@( o1.Sorted() ) # Or o1.SortedInAscending()
#--> [ 1, 2, 3, "One", "Two", [ "01", "02" ], [ "03", "04" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "03", "04" ], [ "01", "02" ], "Two", "One", 3, 2, 1 ]

proff()
# Executed in 0.06 second(s)

/*------------

pron()

o1 = new stzListOfLists([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() )
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

proff()

/*------------

pron()

o1 = new stzListOfPairs([ ["01","02"], ["16", "17"], ["23", "25"], ["08", "10"] ])

? @@( o1.SortedInAscending() ) + NL
#--> [ [ "01", "02" ], [ "08", "10" ], [ "16", "17" ], [ "23", "25" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "23", "25" ], [ "16", "17" ], [ "08", "10" ], [ "01", "02" ] ]

proff()
# Executed in 0.05 second(s)

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

/*------

pron()

o1 = new stzListOfPairs([ [1.0, 2.0], [16.0, 17.34], [23.0, 25], [8.20, 10.0] ])

? @@( o1.SortedInAscending() ) + NL
#--> [ [ 1, 2 ], [ 8.20, 10 ], [ 16, 17.34 ], [ 23, 25 ] ]

? @@( o1.SortedInDescending() )
#--> [ [ 23, 25 ], [ 16, 17.34 ], [ 8.20, 10 ], [ 1, 2 ] ]

proff()

/*-----

pron()

o1 = new stzListOfPairs([ [1,2], [8, 10], [16, 17], [23, 25] ])

? @@( o1.SortedInAscending() )
#--> [ [ 1, 2 ], [ 8, 10 ], [ 16, 17 ], [ 23, 25 ] ]

? @@( o1.SortedInDescending() )
#--> [ [ 23, 25 ], [ 16, 17 ], [ 8, 10 ], [ 1, 2 ] ]

proff()
# Executed in 0.20 second(s)

/*=====

pron()

	o1 = new stzString("**word1***word2**word3***")
	? o1.Sections([ [1,2], [8, 10], [16, 17], [23, 25] ])
	#--> [ "**", "***", "**", "***" ]
		
	o1.RemoveManySections([
		[1,2], [8, 10], [16, 17], [23, 25]
	])
		
	? o1.Content() #--> "word1word2word3"

proff()
#--> Executed in 0.17 second(s)

/*-----

pron()

o1 = new stzString("1♥♥456♥♥901♥♥4")
o1.RemoveSections([ 2:3, 7:8, 12:13 ])
? o1.Content()
#--> 14569014

proff()
# Executed in 0.14 second(s)

/*-----

pron()

o1 = new stzString("1♥♥456♥♥901♥♥4")

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
		#--> 14569014
	
}

proff()

/*-----
*/
pron()

o1 = new stzList(Q("1♥♥456♥♥901♥♥4").Chars())

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
		#--> 14569014
	
}

proff()
