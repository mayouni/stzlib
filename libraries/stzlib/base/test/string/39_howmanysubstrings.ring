# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #39.
#ERR Error (R14) : Calling Method without definition: howmanysubstrings

load "../../stzBase.ring"

pr()

o1 = new stzString( "one two one three two one four five" )

? o1.HowManySubStrings()
#--> 630

? @@( SomeXT( o1.SubStrings(), 1/100 ) ) + NL # 1% of all the substrings
#--> [ " four", "e three two", "hree t", "one th", "one three two o", "th", "wo on" ]

# can also be written direcltly:
//? @@( OnePercentOf( o1.SubStrings() ) ) # or just 1Percent()

? @@( o1.SubStringsOccuringNTimes(3) ) + NL #NOTE // "occuring" is mispelled (one r instead of two)
#--> [ "o", "on", "one", "one ", "n", "ne", "ne ", "e", "e ", "e t", " ", " t", "t" ]

? @@( o1.SubStringsOccurringExactlyNtimes(3) ) + NL
#--> [ "on", "one", "one ", "n", "ne", "ne ", "e t", " t", "t" ]

? @@( o1.SubStringsOccurringNoMoreThanNTimes(1) )
#--> [ ]

pf()
# Executed in 0.90 second(s) in Ring 1.21
# Executed in 4.46 second(s) in Ring 1.19
