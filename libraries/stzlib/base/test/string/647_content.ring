# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #647.

load "../../stzBase.ring"

pr()

o1 = new stzString( "----@@--@@-------@@----@@---")

o1.ReplacePreviousNthOccurrence(2, :Of = "@@", :StartingAt = 22, :With = "##")
? o1.Content()
#--> ----@@--##-------@@----@@---

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18
