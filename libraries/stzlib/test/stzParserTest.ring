load "../max/stzmax.ring"

pron()

StzParserQ([ "_", "A", "_" , "_", "B", "_", "_", "C", "_", "D" ]) {

	SetCurrentPosition(5)

	? PreviousItem() 	#--> "_"
	? CurrentPosition() 	#--> 4

	? PreviousNthItem(2) 	#--> "A"
	? CurrentPosition() 	#--> 2

	? NextNthItem(3) 	#--> "B"
	? CurrentPosition() 	#--> 5

	? LastItem()		#--> "D"
	? CurrentPosition()	#--> 10
}

proff()

/*----


StzParserQ(["a", "_", "b", "_", "c"]) {
	SetCurrentPosition(2)
	? NextNthItem(3)
}

