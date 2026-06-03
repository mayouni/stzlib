# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #5.

load "../../stzBase.ring"


SetLastValue(3)

? Q("AnnIE").VowelNB() # ~> N: Number, B: Binary
#--> TRUE

SetLastValue(2)

? Q("AnnIE").VowelNB()
#--> FALSE

SetLastValue(["A", "I", "E"])
? Q("AnnIE").VowelsB()
#--> TRUE

pf()
# Executed in 0.03 second(s) on Ring 1.21
# Executed in 0.07 second(s) on Ring 1.20
