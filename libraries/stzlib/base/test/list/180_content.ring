# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #180.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:299_000)
o1.RemoveSection(73_900, 120_010)
? len( o1.Content() )
#--> 252889

pf()
# Executed in 0.21 second(s).
# Executed in 0.99 second(s) in Ring 1.19
