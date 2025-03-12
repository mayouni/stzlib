load "../max/stzmax.ring"

/*---------

pr()

? Char(34)
#--> "

? @@( Char(34) )
#--> '"'

? @@( '"')
#--> '"'

? @@( "'" )
#--> "'"

? @@( "'ring'" )
#--> "'ring'"

? @@( '"ring"' )
#--> '"ring"'

? @@( '"""ring"' )
#--> '"""ring"'

proff()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString(@@( [ " ", "!", "'+ char(34) +'", "#", "y"] ))
o1.Replace( @@("'+ char(34) +'"), @@('"') )

?o1.Content()
#--> [ " ", "!", '"', "#", "y" ]

proff()
# Executed in 0.02 second(s)

/*---------

pr()

? Contig("ج","ر") # Or ContigList() or Contiguous() or ContiguousList()

proff()
# Executed in 0.06 second(s)

/*----------

pr()

o1 = new stzList(' "ج":"ر" ')
? o1.Content()

proff()
# Executed in 0.18 second(s)

/*----------

pr()

o1 = new stzListOfChars(' "ج":"ر" ')
? o1.Content()

proff()
# Executed in 0.18 second(s)

/*----------

pr()

? NumberOfCharsBetween("A", "B")
#--> 0

proff()
#--> Executed in 0.03 second(s)

/*=======

pr()

? @@( CharsBetween("A", :And = "E") )
#--> [ "A", "B", "C", "D", "E" ]

proff()
# Executed in 0.05 second(s).

/*----- #TODO fix it!
*/
pr()

o1 = new stzGrid(CharsBetween(" ", :And = "z") )
? o1.HowManyHLines()
#--> 11

o1.Show()

proff()
#--> Executed in 0.02 second(s)

/*---------------

pr()

? @@( CharsBetween("!", "p") )
#--> [
#	"!", '"', "#", "$", "%", "&", "'", "(", ")", "*",
#	"+", ",", "-", ".", "/", "0", "1", "2", "3", "4",
#	"5", "6", "7", "8", "9", ":", ";", "<", "=", ">",
#	"?", "@", "A", "B", "C", "D", "E", "F", "G", "H",
#	"I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
#	"S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\",
#	"]", "^", "_", "`", "a", "b", "c", "d", "e", "f",
#	"g", "h", "i", "j", "k", "l", "m", "n", "o", "p"
# ]

proff()
# Executed in 0.04 second(s)

/*=============

pr()

aList = [
	[ "!", '"', "#", "$", "%", "&", "'", "(", ")", "*" ],
	[ "+", ",", "-", ".", "/", "0", "1", "2", "3", "4" ],
	[ "5", "6", "7", "8", "9", ":", ";", "<", "=", ">" ],
	[ "?", "@", "A", "B", "C", "D", "E", "F", "G", "H" ],
	[ "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R" ],
	[ "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\" ],
	[ "]", "^", "_", "`", "a", "b", "c", "d", "e", "f" ],
	[ "g", "h", "i", "j", "k", "l", "m", "n", "o", "p" ]
]

? IsListOfListsOfStrings(aList)
#--> TRUE

? StzListOfListsQ(aList).ListsHaveSameNumberOfItems()
#--> TRUE

proff()
# Executed in 0.03 second(s)

/*---------------
*/
pr()

# Showing the chars between "!" and "p" in a grid of 10 by 8

StzGridQ([10, 8]).FillWithQ( CharsBetween("!", "p") ).Show()
#-->
#   ! " # $ % & ' ( ) *
#   + , - . / 0 1 2 3 4
#   5 6 7 8 9 : ; < = >
#   ? @ A B C D E F G H
#   I J K L M N O P Q R
#   S T U V W X Y Z [ \
#   ] ^ _ ` a b c d e f
#   g h i j k l m n o p

# Note that if you provide a large grid, say 10X10, the supplementary
# lines are left empty, as you can observe it here:

StzGridQ([10, 10]).FillWithQ( CharsBetween("!", "p") ).Show()
#-->
#   ! " # $ % & ' ( ) *
#   + , - . / 0 1 2 3 4
#   5 6 7 8 9 : ; < = >
#   ? @ A B C D E F G H
#   I J K L M N O P Q R
#   S T U V W X Y Z [ \
#   ] ^ _ ` a b c d e f
#   g h i j k l m n o p
#                      
#                      

proff()
# Executed in 0.10 second(s)

/*---------------

# Create a grid of 10 by 10 nodes
StzGridQ([ :Of = 10, :By = 10 ]) {

	# Fill the grid with the chars between " " and "z"
	FillWith( CharsBetween(" ", :And = "z") )

	# Show the grid
	Show()
}

#-->
#   ! " # $ % & ' ( ) *
#   + , - . / 0 1 2 3 4
#   5 6 7 8 9 : ; < = >
#   ? @ A B C D E F G H
#   I J K L M N O P Q R
#   S T U V W X Y Z [ \
#   ] ^ _ ` a b c d e f
#   g h i j k l m n o p

proff()
#--> Executed in 0.15 second(s)

/*----------
*/
pr()

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

proff()
# Executed in 0.02 second(s)

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
	//@bShowRanks = TRUE #ERROR in case: TRUE (occurs in stzCounter)

	SetNode(1, 1, "1")
	SetNode(7, 1, "2")
	SetNode(7, 7, "3")
	SetNode(1, 7, "4")
	Show() 	#--> 	1 . . . . . 2
		# 	. . . . . . .
		# 	. . . . . . .
		# 	. . . + . . .
		# 	. . . . . . .
		# 	. . . . . . .
		# 	4 . . . . . 3

	ReverseHLines()
	Show() 	#--> 	4 . . . . . 3
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
	Show()	#-->	+ - - - - - +
		# 	| . 1 . . . |
		# 	| 1 2 3 4 5 |
		# 	| . 3 . . . |
		# 	| . 4 . . . |
		# 	| . 5 . . . |
		# 	+ - - - - - +

	SwapLines()
	Show()  #--> 	+ | | | | | +
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

	? @@( Diagonal1() )
	#--> [ "A", "2", "G" ]

	? @@( Diagonal2() )
	#--> [ "C", "2", E" ]

}

