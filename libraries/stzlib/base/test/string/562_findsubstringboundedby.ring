# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #562.

load "../../stzBase.ring"

pr()

o1 = new stzString("my **word** and your **word**")

? o1.FindSubStringBoundedBy("word", [ "**", "**" ])
#--> [6, 24]

pf()
# Executed in 0.03 second(s) in Ring 1.22
