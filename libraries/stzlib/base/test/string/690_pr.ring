# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #690.

load "../../stzBase.ring"


# Operators on stzString

o1 = new stzString("SOFTANZA")

# Getting a char by position

? o1[5]
#--> "A"

# Finding the occurrences of a substring in the string

? o1["A"]
#--> [ 5, 8 ]

? @@(o1["NZA"])
#--> [ 6 ]

# Comparing the string with other strings

? o1 = StringUppercase("softanza")
#--> TRUE

#TODO // Complete the other operators when COMPARAISON methods are made in stzString

pf()
# Executed in 0.02 second(s).
