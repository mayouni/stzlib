load "../stzmax.ring"


/*==========

profon()

o1 = new stzString("   irum epsum     elo  n   ")

? @@( o1.FindOverSpaces() ) + NL
#--> [ 2, 3, 15, 16, 17, 18, 23, 26, 27 ]

? @@( o1.FindOverSpacesZZ() )
#--> [ [ 2, 3 ], [ 15, 18 ], [ 23, 27 ] ]

proff()
# Executed in 0.01 second(s).

/*------- #narration Simplify VS RemoveOverSpaces

profon()

# Simplify: string is trimmed and redundant spaces are removed
# ~> QtBased

o1 = new stzString("   irum epsum     elo  n   ")

o1.Simplify() + NL
? @@( o1.Content() )
#--> "irum epsum elo n"

# RemoveOverSpaces : redundant spaces are removed but string is not trimmed

o1 = new stzString("   irum epsum     elo  n   ")

o1.RemoveOverSpaces()
? @@( o1.Content() )
#--> " irum epsum elo "

proff()
# Executed in 0.06 second(s) in Ring 1.22

/*-------

profon()

o1 = new stzString("   irum epsum     elo  n   ")
o1.ReplaceOverSpaces(:With = "~")
? @@( o1.Content() )
#--> " ~~irum epsum ~~elo ~~"

proff()
# Executed in 0.04 second(s).

/*=======

profon()

o1 = new stzString("CAIRO")
o1.BoxEachChar()
? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┐
# │ C │ A │ I │ R │ O │
# └───┴───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*------

profon()

o1 = new stzString("CAIRO")
o1.BoxEachCharXT([ :rounded = TRUE ])
? o1.Content()
#-->
# ╭───┬───┬───┬───┬───╮
# │ C │ A │ I │ R │ O │
# ╰───┴───┴───┴───┴───╯

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzListOfChars([ "C", "A", "I", "R", "O" ])
? o1.BoxXT([
	[ "rounded", 1 ],
	[ "positionchar", "♥" ],
	[ "hilighted", [ 3, 3 ] ], # Duplication is managed internally
	[ "casesensitive", 1 ]
])
#-->
# ╭───┬───┬───┬───┬───╮
# │ C │ A │ I │ R │ O │
# ╰───┴───┴─♥─┴───┴───╯

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*---------

profon()

? Q("CAIRO").VizFindBoxedXT("I", [
	[ "rounded", 1 ], [ "positionchar", "♥" ] ] )
#-->
# ╭───┬───┬───┬───┬───╮
# │ C │ A │ I │ R │ O │
# ╰───┴───┴─♥─┴───┴───╯

proff()

# Executed in 0.09 second(s) in Ring 1.22
/*---------

profon()

? Q("RINGORIALAND").vizFind("I") + NL
#--> RINGORIALAND
#    -^----^-----

? Q("CAIRO").vizFindBoxedXT("I", []) + NL
#-->
# ┌───┬───┬───┬───┬───┐
# │ C │ A │ I │ R │ O │
# └───┴───┴─•─┴───┴───┘

? Q("CAIRO").vizFindXT("I", [
	:Boxed = TRUE,
	:Rounded = TRUE,
	:PositionChar = "♥"]
)
#-->
#    ╭───┬───┬───┬───┬───╮
#--> │ C │ A │ I │ R │ O │
#    ╰───┴───┴─♥─┴───┴───╯

proff()
# Executed in 0.15 second(s) in Ring 1.22

/*------

profon()

SetStringArtStyle(:geo)

? StringArtXT("R", :flower)
#-->
# .-------.    
# |  _ _   \   
# | ( ' )  |   
# |(_ o _) /   
# | (_,_).' __ 
# |  |\ \  |  |
# |  | \ `'   /
# |  |  \    / 
# ''-'   `'-' 


? StringArtStyle()
#--> geo

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*====

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

pf()
# Executed in 0.02 second(s)

/*----------

pr()

o1 = new stzString(@@( [ " ", "!", "'+ char(34) +'", "#", "y"] ))
o1.Replace( @@("'+ char(34) +'"), @@('"') )

?o1.Content()
#--> [ " ", "!", '"', "#", "y" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.20

/*----------

pr()

? Rx(pat(:textWithNumberSuffix)).Match("day1")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----------

pr()

? @@( L("[1, 2, 3 ]") )
#--> [ 1, 2, 3 ]

? @@( L("1:3") )
#--> [ 1, 2, 3 ]

? @@( L("A:C") ) + NL
#--> [ "A", "B", "C"]

? @@( L("#1 : #3") )
#--> [ "#1", "#2", "#3" ]

? @@( L("day1 : day3") ) + nl
#--> [ "day1", "day2", "day3" ]

? @@( L("سامي1 : سامي3") )
#o--> [ "سامي1", "سامي2", "سامي3" ]

? @@( L('"A":"C"') )  + NL
#--> [ '"A":"C"' ]


? @@(  L(' "ا" : "ج" ') )
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

? @@(  L('ا:ج') )
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

pf()
# Executed in 0.33 second(s) in Ring 1.22

/*----------

pr()

? NumberOfCharsBetween("A", "B")
#--> 2

pf()
#--> Executed in 0.01 second(s) in Ring 1.22

/*=======

pr()

? @@( CharsBetween("A", :And = "E") )
#--> [ "A", "B", "C", "D", "E" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.20

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

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.20

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

pf()
# Executed in 0.02 second(s) in Ring 1.22
