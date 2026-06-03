# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #160.

load "../../stzBase.ring"

o1 = new stzString("ring php ringoria")

# Are there any duplicated substrings in this string?

? o1.ContainsDuplicates()
#--> TRUE

# The number of duplicates is 5:

? o1.NumberOfDuplicates()
#--> 5

# But, if we check their positions we get only 4 !

? @@( o1.FindDuplicates() )
#--> [ 6, 7, 10, 11 ]

# The dupicates are effectively 5:
? @@( o1.Duplicates() )
#--> [ "R", "RI", "I", "A", "N" ]

# To find an explication, let's use the DuplicatesAndTheirPositions()
# function, or use its short form DuplicatesZ()

? @@( o1.DuplicatesZ() )
#--> [ [ "R", 6 ], [ "RI", 6 ], [ "I", 7 ], [ "A", 10 ], [ "N", 11 ] ]

# Hence we see that position 6 corresponds to 2 duplicated substrings: "R" and "RI"                                                                                                                             

pf()
# Executed in 0.95 second(s) in Ring 1.22
# Executed in 2.20 second(s) in Ring 1.19
