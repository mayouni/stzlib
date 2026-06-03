# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #230.

load "../../stzBase.ring"

pr()

o1 = new stzString("emm +   12  456.50 emm 11. and -   4.12_")
? @@( o1.Numbers() )
#--> [ "12", "456.50", "11.", "-4.12" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.19 second(s) in Ring 1.18
