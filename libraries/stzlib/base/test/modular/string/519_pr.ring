# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #519.

load "../../../stzBase.ring"


o1 = new stzList([ "TWO", "ONE", "THREE" ])
o1.Swap("TWO", :And = "ONE")
? o1.Content()

pf()
# Executed in 0.02 second(s) in Ring 1.22
