# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #588.

load "../../stzBase.ring"

pr()

o1 = new stzString("word")
o1.AddBounds(["<<",">>"]) # or BoundWith(["<<",">>"])
? o1.Content()
#--> <<word>>

pf()
# Executed in 0.01 second(s) in Ring 1.22
