# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #963.

load "../../stzBase.ring"

pr()

o1 = new stzString('123--67--')
o1.ReplaceSection(1, 3, "~")
? o1.Content()
#--> ~--67--

pf()
# Executed in 0.01 second(s).
