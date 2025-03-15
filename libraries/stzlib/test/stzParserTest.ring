load "../max/stzmax.ring"

/*---

pr()

StzParserQ([ "_", "A", "_" , "_", "B", "_", "_", "C", "_", "D" ]) {

	SetCurrentPosition(5)

	? PreviousItem() 	#--> "_"
	? CurrentPosition() 	#--> 5

	? PreviousNthItem(4) 	#--> "A"
	? CurrentPosition() 	#--> 5

	? NextNthItem(4) 	#--> "C"
	? CurrentPosition() 	#--> 5

	? LastItem()		#--> "D"
	? CurrentPosition()	#--> 5
}

pf()
# Executed in 0.03 second(s) in Ring 1.21

/*----
*/
pr()

StzParserQ(["a", "_", "b", "_", "c"]) {
	SetCurrentPosition(2)
	? NextNthItem(3)
	#--> "_"
}

pf()
# Executed in 0.03 second(s) in Ring 1.21
