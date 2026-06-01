# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #784.

load "../../../stzBase.ring"


o1 = new stzString("oooTunisia")
o1.ReplaceLeadingChar("O", :With = "")
? o1.Content()
#--> oooTunisia

o1.ReplaceLeadingCharCS("O", :With = "", :CS=FALSE)
? o1.Content()
#--> Tunisia

pf()
# Executed in 0.02 second(s).
