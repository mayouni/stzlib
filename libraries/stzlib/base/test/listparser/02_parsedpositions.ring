# Narrative
# --------
# pr()
#
# Extracted from stzListParserTest.ring, block #2.
#ERR Error (R15) : Error in parent class name, class not found: stzparser

load "../../stzBase.ring"

pr()

# Ususally the parser is used, not only to move over positions,
# but more interestingly, to get the parsed items themselves.
# Let's try it!

StzListParserQ("A":"L") {

	Parse( :From = 3, :To = 9, :Step = 3 )

	? ParsedPositions()	#--> [ 3,   6,   9   ]
	? ParsedItems()		#--> [ "C", "F", "I" ]

	? CurrentPosition()	#--> 3
	? CurrentItem()		#--> "C"

	//? NextPosition()	# !--> 6
	? NextItem()		# !--> "F"

	//? PreviousPosition()	# !--> 3	
	? PreviousItem()	# !--> "C"	

	? NextNthPosition(2)	# !--> 9
	//? NextNthItem(2)	# !--> "I"
}

pf()
# Executed in 0.04 second(s) in Ring 1.21
