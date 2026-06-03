# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #718.

load "../../stzBase.ring"

pr()

? StzStringQ("G").IsLetter()
#--> TRUE

? UppercaseOf("b")
#--> B

? LowercaseOf("B")
#--> b

//? FoldcaseOf("sinus")		# !!! Undefined function #TODO

pf()
# Executed in 0.01 second(s).
