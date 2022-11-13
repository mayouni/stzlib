load "stzlib.ring"

o1 = new stzGrid(9)
o1.Show()
#-->
# . . .
# . . .
# . . .

o1.ReplaceAll("*")
o1.Show()
#-->
# * * *
# * * *
# * * *

/*----------

? StzGridQ([
	[ ". ", " 1 ", " . ", " . ", " ." ],
	[ "1 ", " 2 ", " 3 ", " 4 ", " 5" ],
	[ ". ", " 3 ", " . ", " . ", " ." ],
	[ ". ", " 4 ", " . ", " . ", " ." ],
	[ ". ", " 5 ", " . ", " . ", " ." ]
]).Show()

/*-------

o1 = new stzGrid(12)
? o1.Size() #--> [4, 3]
? o1.NumberOfNodes() #--> 12
o1.Show()
#-->
# . . .
# . . .
# . . .
# . . .

/*-------

o1 = new stzGrid([3,4])
? o1.Size() #--> [4, 3]
? o1.NumberOfNodes() #--> 12

/*-------

o1 = new StzGrid([
	[ "A", "B", "C" ],
	[ "E", "F", "G" ],
	[ "H", "I", "J" ]
])

? o1.Size() #--> [3, 3]
? o1.NumberOfNodes()
#--> 9

o1.Show()
#-->
# A B C
# E F G
# H I J

? o1.ShowXT([ :ShowCenter, :ShowRanks ]) #--> TODO

/*-------

# ? GridSep()
#--> ":"

SetGridSep(" : ")

# ? GridSep()
#--> " : "

o1 = new stzGrid("
	. : 1 : . : . : .
	1 : 2 : 3 : 4 : 5
	. : 3 : . : . : .
	. : 4 : . : . : .
	. : 5 : . : . : .
")

? o1.Size() #--> [5, 5]
o1.Show()
#-->
# . 1 . . .
# 1 2 3 4 5
# . 3 . . .
# . 4 . . .
# . 5 . . .

/*-------------

StzGridQ( [ 7, 7 ] ) { Show() }
#-->
# . . . . . . .
# . . . . . . .
# . . . . . . .
# . . . . . . .
# . . . . . . .
# . . . . . . .
# . . . . . . .

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

StzGridQ(9) {

	# Showing the grid of 9 nodes
	Show()
	#--> . . .
	#    . . .
	#    . . .

	# Setting the grid vline by Vline
	SetVLine(1, "A":"C")
	SetVLine(2, "1":"3")
	SetVLine(3, "E":"G")
	Show()
	#--> A 1 E
	#    B 2 F
	#    C 3 G

	# Swapping VLines and HLines
	SwapLines()
	Show()
	#--> A B C
	#    1 2 3
	#    E F G

	? @@S( Diagonal1() )
	#--> [ "A", "2", "G" ]

	? @@S( Diagonal2() )
	#--> [ "C", "2", E" ]

}

