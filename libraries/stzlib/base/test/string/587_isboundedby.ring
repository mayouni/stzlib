# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #587.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("<<word>>")

? o1.IsBoundedBy(["<<", ">>"])
#--> TRUE

o1.RemoveTheseBounds("<<",">>")
? o1.Content()
#--> word

pf()
# Executed in 0.04 second(s)
