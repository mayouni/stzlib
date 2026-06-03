# Narrative
# --------
# #narration SEMANTIC PRECISION
#
# Extracted from stzlisttest.ring, block #370.

load "../../stzBase.ring"


pr()

? Q("SFTANZA").IsLargerThan("RING")
#--> TRUE

# or if you want to be precise:
? Q("SFTANZA").HasMoreChars(:Than = "RING")
#--> TRUE

#--

? Q("RING").IsSmaller(:Than = "SFTANZA")
#--> TRUE

# or if you want to precise:

? Q("RING").HasLessChars(:Than = "SFTANZA")
#--> TRUE

pf()
# Executed in 0.01 second(s).
