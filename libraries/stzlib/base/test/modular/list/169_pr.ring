# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #169.

load "../../../stzBase.ring"


o1 = new stzList([ "a", "bcd", "♥", 5, "b", "♥♥♥", [1, 2] ])

#--

? o1.NumberOfChars()
#--> 3

? @@( o1.Chars() )
#--> [ "a", "♥" , "b" ]

? @@( o1.CharsZ() ) # Or CharsAndTheirPositions()

#--

? o1.NumberOfLetters()
#--> 2

? @@( o1.Letters() )
#--> [ "a", "b" ]

? @@( o1.LettersZ() )

#--

? o1.NumberOfNumbers()
#--> 1

? @@( o1.Numbers() )
#--> [ 5 ]

? @@( o1.NumbersZ() )

#--

? o1.NumberOfStrings()
#--> 5

? @@( o1.Strings() )
#--> [ "a", "bcd", "♥", "b", "♥♥♥" ]

? @@( o1.StringsZ() )

#--

? o1.NumberOfLists()
#--> 1

? @@( o1.Lists() )
#--> [ [ 1, 2 ] ]

? @@( o1.ListsZ() )

#--

? o1.NumberOfPairs()
#--> 1

? @@( o1.Pairs() )
#--> [ [ 1, 2 ] ]

? @@( o1.PairsZ() )

#--

? o1.NumberOfObjects()
#--> 0

? @@( o1.Objects() )
#--> []

? @@( o1.ObjectsZ() )

pf()
# Executed in 0.12 second(s) in Ring 1.20
