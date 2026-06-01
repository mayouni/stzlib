# Narrative
# --------
# #narration EXTENDED FORMS OF REPEATING OBJECTS IN SOFTANZA
#
# Extracted from stzStringTest.ring, block #487.

load "../../../stzBase.ring"


pr()

# Repeating "5" twice in a list

? @@( Q("5").RepeatedXT(:InA = :List, :OfSize = 2) )
#--> [ "5", "5" ]

# Creating a pair with "A" repeated

? Q("A").RepeatedInAPair()
#--> [ "A", "A" ]

# Repeating char "5" three times in a list of numbers

? @@( Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3) )
#--> [ 5, 5, 5 ]

# Repeating the number 5 three times in a string

? Q(5).RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

# Repeating number 5 three times in a string

? Q(5).RepeatedXT(:InA = :String, :OfSize = 3)
#--> "555"

# Repeating "5" three times in a list of numbers

? Q("5").RepeatedXT(:InA = :ListOfNumbers, :OfSize = 3)
#--> [ 5, 5, 5 ]

# Repeating number 5 three times in a list of strings

? @@( Q(5).RepeatedXT(:InA = :ListOfStrings, :OfSize = 3) )
#--> [ "5", "5", "5" ]

# Repeating "A" three times in a list of pairs

? @@( Q("A").RepeatedXT(:InA = :ListOfPairs, :OfSize = 3) ) + NL
#--> [ [ "A", "A" ], [ "A", "A" ], [ "A", "A" ] ]

# Repeating "A" three times in a list of lists

? @@( Q("A").RepeatedXT(:InA = :ListOfLists, :OfSize = 3) ) + NL
#--> [ [ "A" ], [ "A" ], [ "A" ] ]

# Repeating "A" three times in a list, then repeating that list three times

? @@( Q("A").
	RepeatXTQ(:InA = :List, :OfSize = 3).
	RepeatedXT(:InA = :List, :OfSize = 3)
) + NL
#--> [ [ "A", "A", "A" ], [ "A", "A", "A" ], [ "A", "A", "A" ] ]

# Creating a 3x3 grid filled with "A"

? @@( Q("A").RepeatedXT(:InA = :Grid, :OfSize = [3, 3]) ) + NL
#-->
# [
# [ "A", "A", "A" ],
# [ "A", "A", "A" ],
# [ "A", "A", "A" ]
# ]

# Creating a 3x3 table filled with "A"

? @@( Q("A").RepeatedXT(:InA = :Table, :OfSize = [3, 3]) ) + NL
#--> [
# [ "COL1", [ "A", "A", "A" ] ],
# [ "COL2", [ "A", "A", "A" ] ],
# [ "COL3", [ "A", "A", "A" ] ]
# ]

? Q("A").RepeatXTQ(:InA = :Table, :OfSize = [3, 3]).ToStzTable().Show()
#-->
# COL1   COL2   COL3
# ----- ------ -----
#   A      A      A
#   A      A      A
#   A      A      A

pf()
# Executed in 0.16 second(s) in Ring 1.22
