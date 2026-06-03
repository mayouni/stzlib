# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #671.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


o1 = new stzString("12.4560000")

o1.RemoveThisTrailingChar("0")
? o1.Content()
#--> 12.456

pf()
# Executed in 0.06 second(s).

#------

pr()

? Q("12.45600").ThisTrailingCharRemoved("0")
#--> "12.456"

pf()
# Executed in 0.01 second(s).
