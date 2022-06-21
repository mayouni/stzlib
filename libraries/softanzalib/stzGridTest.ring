load "stzlib.ring"

StzGridQ( [ 7, 7 ] ) { Show() }

/*-------------------

StzGridQ( [ 7, 7 ] ) {

	@bShowCenter = TRUE
	//@bShowRanks = TRUE # ERROR in case: TRUE (occurs in stzCounter)

	SetNode(1, 1, "1")
	SetNode(7, 1, "2")
	SetNode(7, 7, "3")
	SetNode(1, 7, "4")
	Show() 	# --> 	1 . . . . . 2
		# 	. . . . . . .
		# 	. . . . . . .
		# 	. . . + . . .
		# 	. . . . . . .
		# 	. . . . . . .
		# 	4 . . . . . 3

	ReverseHLines()
	Show() 	# --> 	4 . . . . . 3
		# 	. . . . . . .
		# 	. . . . . . .
		# 	. . . + . . .
		# 	. . . . . . .
		# 	. . . . . . .
		# 	1 . . . . . 2

}

/*-------------------

aGrid = [
	[ "+", "-", "-", "-", "-", "-", "+" ],
	[ "|", ".", "1", ".", ".", ".", "|" ],
	[ "|", "1", "2", "3", "4", "5", "|" ],
	[ "|", ".", "3", ".", ".", ".", "|" ],
	[ "|", ".", "4", ".", ".", ".", "|" ],
	[ "|", ".", "5", ".", ".", ".", "|" ],
	[ "+", "-", "-", "-", "-", "-", "+" ]
]

StzGridQ(aGrid) {
	Show()	# -->	+ - - - - - +
		# 	| . 1 . . . |
		# 	| 1 2 3 4 5 |
		# 	| . 3 . . . |
		# 	| . 4 . . . |
		# 	| . 5 . . . |
		# 	+ - - - - - +

	SwapLines()
	Show()  # --> 	+ | | | | | +
		# 	- . 1 . . . -
		# 	- 1 2 3 4 5 -
		# 	- . 3 . . . -
		# 	- . 4 . . . -
		# 	- . 5 . . . -
		# 	+ | | | | | +
}

/*-------------------------

/* TODO: defining a grid in a string
cGrid = "
+ - - - - - +
| . 1 . . . |
| 1 2 3 4 5 |
| . 3 . . . |
| . 4 . . . |
| . 5 . . . |
+ - - - - - +
"

/*-------------------------

StzGridQ(aGrid) {
	Show()
	//ReverseHLines()
	ReverseVLines()
	Show()
#	SwapLines()
#	Show()

#	ReverseHLines()
#	Show()

	//? VLines()[3]
	//Show()

#	ReverseNodes()
#	Show()

#	? Diagonal1()
#	? Diagonal2()

}

/*-------------------------

StzGridQ(9) {

	# Showing the grid of 9 nodes
	Show()

	# Setting the grid vline by Vline
	SetVLine(1, "A":"C")
	SetVLine(2, "1":"3")
	SetVLine(3, "E":"G")
	Show()

	# Swapping VLines and HLines
	SwapLines()
	Show()
}

