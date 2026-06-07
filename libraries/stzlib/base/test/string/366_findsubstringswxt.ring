# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #366.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"


o1 = new stzString("...♥♥...♥♥...")

? @@( o1.FindSubStringsWXT('{ @SubString = "♥♥" }') )
#--> [ 4, 9 ]

? @@( o1.FindSubStringsWXTZZ('{ @SubString = "♥♥" }') )
#--> [ [ 4, 5 ], [ 9, 10 ] ]

pf()
# Executed in 0.77 second(s) in Ring 1.21
# Executed in 3.79 second(s) in Ring 1.18

#-----------

pr()

o1 = new stzString("..ONE..TWO..ONE..")

? o1.NumberOfSubStrings()
#--> 153

? o1.NumberOfUniqueSubStrings()
#--> 120

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.17

#---------

pr()

o1 = new stzString("ABA")

? @@( o1.SubStrings() )
#--> [ "A", "AB", "B", "ABA", "A", "BA" ]

? @@( o1.UniqueSubStrings() ) # Or SubStringsU()
#--> [ "A", "AB", "ABA", "B", "BA" ]

? @@( o1.SubStringsZ() )
#--> [
#	[ "A", 	 [ 1, 3 ] ],
#	[ "AB",  [ 1 ] ],
#	[ "ABA", [ 1 ] ],
#	[ "B", 	 [ 2 ] ],
#	[ "BA",  [ 2 ] ]
# ]

? @@( o1.SubStringsZZ() )
#--> [
#	"A"	= [ [ 1, 1 ], [ 3, 3 ] ],
#	"AB"	= [ [ 1, 2 ] ],
#	"ABA"	= [ [ 1, 3 ] ],
#	"B"	= [ [ 2, 2 ] ],
#	"BA"	= [ [ 2, 3 ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.19 second(s) in Ring 1.17

#========

pr()

? Q("one").IsEitherCS("ONE", :Or = "TWO", :CS = FALSE)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21

#=======

pr()

o1 = new stzString("<<<word>>>")

? o1.Bounds()
#--> [ "<<<", ">>>" ]

? o1.BoundsXT(:UpToNChars = 2)
#--> [ "<<", ">>" ]

? o1.BoundsXT([ 1, 2 ])
#--> [ "<", ">>" ]


? o1.BoundsUpToNChars(2)
#--> [ "<<", ">>" ]

? o1.BoundsUpToNChars([ 1, 2 ])
#--> [ "<", ">>" ]

pf()
# Executed in 0.04 second(s) in Ring 1.21
