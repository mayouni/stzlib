# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #510.

load "../../stzBase.ring"


# Operators on stzString

o1 = new stzList([ "S","O","F","T","A","N","Z","A" ])

# Getting a char by position

? o1[5] + NL
#--> "A"

# Finding the occurrences of a substring in the string

? o1["A"]
#--> [ 5, 8 ]

# Getting occurrences of chars verifying a given condition

? o1[ '{ Q(@item).IsOneOfThese(["A", "T", "Z"]) }' ]
#--> [ 4, 5, 7, 8 ]

pf()
# Executed in 0.07 second(s).
