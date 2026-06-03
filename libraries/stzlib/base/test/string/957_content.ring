# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #957.

load "../../stzBase.ring"

pr()

o1 = new stzString("----^----------^----------^-----")

? o1.content()
#--> ----^----------^----------^-----

o1.ReplaceByMany("^", [ "A", "B", "C" ])
? o1.Content()
#--> ----A----------B----------C-----

pf()
# Executed in 0.01 second(s) in Ring 1.24
