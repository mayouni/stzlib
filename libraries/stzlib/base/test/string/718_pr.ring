# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #718.

load "../../stzBase.ring"


? StzStringQ("G").IsLetter()
#--> TRUE

? UppercaseOf("b")
#--> B

? LowercaseOf("B")
#--> b

//? FoldcaseOf("sinus")		# !!! Undefined function #TODO

pf()
# Executed in 0.01 second(s).
