# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #783.

load "../../stzBase.ring"

pr()

o1 = new stzString("oooTunisia")
o1.RemoveThisLeadingChar("O")
? o1.Content()
#--> oooTunisia

o1.RemoveThisLeadingCharCS("O", :CS=FALSE)
? o1.Content()
#--> Tunisia

pf()
# Executed in 0.02 second(s).
