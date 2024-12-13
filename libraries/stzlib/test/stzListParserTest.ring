load "../max/stzmax.ring"

/*------------------

profon

# This class allows us to define a system of parsing by
# providing theree values: start, end, and number of steps.

# Hence, it generates for us the list of positions to be parsed,
# and helps us move for one position to another in many ways, while
# maintaining the state of parsing (current position).

# To start parsing, we just feed the class with a list...


StzListParserQ("A":"L") {

	? @@( List() ) + NL
	#--> [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L" ]

	# Default values of the parser

	? StartPosition()		#--> 1
	? EndPosition()			#--> 12
	? NumberOfSteps()		#--> 1
	? CurrentPosition() + NL	#--> 1

	? @@( ParsedPositions() ) + NL	#--> 1:12
	#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ]

	# Let's change the system of parsing

	Parse( :From = 3, :To = 9, :Step = 3)

	? ParsedPositions()
	#--> [ 3, 6, 9 ]
	
	# Or we can change its params one by one

	SetStartPosition(4)
	SetEndPosition(8)
	SetNumberOfSteps(2)

	? ParsedPositions()
	#--> [ 4, 6, 8 ]

	# By default, the parser head is positioned at the 1st
	# parsed position defined by ParsedPositions()

	? CurrentPosition() + NL	#--> 4

	# Let's change the current position (must be one of the
	# values of the list ParsedPositions())

	SetCurrentPosition(6)
	? CurrentPosition() + NL	#--> 6

	# Or we can set the current position on its default value
	SetCurrentPosition(:Default)
	? CurrentPosition() + NL	#--> 1

	# And change this default value if we want
	SetDefaultCurrentPosition(5)
	SetCurrentPosition(:Default)
	? CurrentPosition() + NL	#--> 5

	# Now, let's reset the parser to its default state
	Reset()
	? @@( ParsedPositions() ) + NL	#--> 1:12
	? @@( CurrentPosition() )	#--> 1
}

proff()
# Executed in 0.05 second(s) in Ring 1.21

/*------------------

profon

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

proff()
# Executed in 0.04 second(s) in Ring 1.21

/*------------------
*/
profon

StzListParserQ("A":"L") {

	Parse( :From = 3, :To = 9, :Step = 3 )

	? ParsedPositions()	#--> [ 3,   6,   9   ]
	? ParsedItems()		#--> [ "C", "F", "I" ]

	? CurrentPosition()	#--> 3

	? NextNthPosition(2)	#--> 9
	? CurrentPosition()	#--> 9

}

proff()
# Executed in 0.04 second(s) in Ring 1.21
