
load "stzlib.ring"





//////////////////////////////////////////////////////////////////


/*---
*/
pron()

o1 = new stzList([ 1, :♥, 3, 4, :♥, :♥ ])
anPos = o1.Find(:♥)
#--> [ 2, 5, 6 ]

o1.ReplaceByMany(:♥, [2, 5, 6]) # TODO: Add this function to stzList, based on
? o1.Content()			# its sister in stzString

proff()

/*---

pron()

o1 = new stzList(Q("1♥♥456♥♥901♥♥4").Chars())

o1 {
	# Finding chars / items

	anPos = Find("♥")
		? @@(anPos)
		#--> [ 2, 3, 4, 8, 9, 14, 15 ]

	# Doing someting with the positions

	ReplaceItemsAtPositions(anPos, :With = "★")
		? Content()
		#--> 1★★456★★901★★4
	
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
