# Narrative
# --------
# #ring
#
# Extracted from stztabletest.ring, block #102.
#ERR Error (R7) : Can't assign to a string letter more than one character

load "../../stzBase.ring"


pr()

str = "ring"
str[1] = "R"
? str
#--> Ring

str[3] = "nnn"
#--> Ring error message:
# Error (R7) : Can't assign to a string letter more than one character

pf()
# Executed in 0.02 second(s)
