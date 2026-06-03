# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #55.
#ERR Error (R3) : Calling Function without definition: maxnumbers

load "../../stzBase.ring"

pr()

StzListOfNumbersQ([ 2, 10, 7, 4, 19, 7, 19 ]) {

	# Let's play with max numbers in the list

	? Max() + NL 	#--> 19
	? FindMax() 	#--> [ 5, 7 ]

	? MaxNumbers(3) #--> [ 19, 10, 7 ]
	# You can alos say: ? Top(3)


	? FindMaxNumbers(3) #--> [ 2, 3, 5, 6, 7 ]
	# You can also say: ? FindTop(3)

	? @@( MaxNumbersZ(3) )
	#--> [ "19" = [ 5, 7 ], "10" = [ 2 ], "7" = [ 3, 6 ] ]
	# You can also say: ? TopZ(3)

	# Let's do the same with the min numbers

	? Min() + NL	#--> 2
	? FindMin()	#--> [ 1 ]

	? MinNumbers(3)     #--> [ 2, 4, 7 ]
	? FindMinNumbers(3) #--> [ 1, 3, 4, 6 ]

}

pf()
# Executed in 0.55 second(s)
