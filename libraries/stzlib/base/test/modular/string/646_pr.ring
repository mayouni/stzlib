# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #646.

load "../../../stzBase.ring"


o1 = new stzString( "----@@--@@-------@@----@@---")

o1.ReplaceNextNthOccurrence(2, :Of = "@@", :StartingAt = 12, :With = "##")
? o1.Content()
#--> ----@@--@@-------@@----##---

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.05 second(s) in Ring 1.17
