# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #148.

load "../../stzBase.ring"

#                     3  6  9  2 
o1 = new stzString("..♥^^♥..^♥♥^..")

? @@( o1.FindSubStringsAsSectionsWXT('

	Q(@SubString).NumberOfChars() = 4 and
	Q(@SubString).ContainsXT( 2, "♥") and
	Q(@SubString).ContainsXT( :MoreThen = 1, "^")

') )

#--> [ [ 3, 6 ], [ 9, 12 ] ]

pf()
# Executed in 0.42 second(s) in Ring 1.21
# Executed in 1.92 second(s) in Ring 1.19
