# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #959.

load "../../stzBase.ring"

pr()

o1 = new stzString("---456----123--67---")
? @@( o1.Sections([ [ 1, 3], [ 7, 10], [ 14, 15], [18, 20] ]) )
#--> [ "---", "----", "--", "---" ]

pf()
# Executed in 0.01 second(s).
