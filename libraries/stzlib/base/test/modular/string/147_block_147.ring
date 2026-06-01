# Narrative
# --------
# */
#
# Extracted from stzStringTest.ring, block #147.

load "../../../stzBase.ring"

pr()
#                     3  6  9  2
o1 = new stzString("..♥^^♥..^♥♥^..")

? @@( o1.SubStringsWXT('

	Q(@SubString).NumberOfChars() = 4 and
	Q(@SubString).ContainsXT( 2, "♥") and
	Q(@SubString).ContainsXT( :MoreThen = 1, "^")

') )

#--> [ "♥^^♥", "^♥♥^" ]

pf()
# Executed in 0.42 second(s) in Ring 1.21
# Executed in 1.98 second(s) in Ring 1.19
