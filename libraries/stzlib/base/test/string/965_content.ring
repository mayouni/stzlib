# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #965.

load "../../stzBase.ring"

pr()

o1 = new stzString("--345--89---")
o1.ReplaceSectionsByMany([ [3, 5], [8, 9] ], [ "^^^", "^^" ])
? o1.Content()
#--> --^^^--^^---

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.19
