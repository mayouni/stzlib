# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #960.

load "../../stzBase.ring"

pr()

o1 = new stzString("---456----123--67---")
? @@( o1.SplitAtSections([ [4, 6], [11, 13], [16, 17] ]) )
#--> [ "---", "----", "--", "---" ]

pf()
# Executed in 0.07 second(s).
