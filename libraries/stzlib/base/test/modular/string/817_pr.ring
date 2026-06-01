# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #817.

load "../../../stzBase.ring"


o1 = new stzString("سلسبيل")

? o1.IsMadeOf([ "ب", "ل", "س", "ي" ])
#--> TRUE

? o1.IsMadeOf([ "ب", "ل", "س", "ي", "ج" ])
#--> FALSE

? o1.IsMadeOfSome([ "ب", "ل", "س", "ي", "m" ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
