# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #425.
#
# NOTE (audit, 2026-07-02): DEFERRED. stzList.FindWXT is RETIRED by design
# (WXT disqualification; precedent #84, #219-#221, #412). The W replacement
# of this block's pipeline is asserted in tests 423/424.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

? o1.FindWXT('@CurrentItem = "*"')

o1.SplitAtPositions([ 4, 7 ])
? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

pf()
# Executed in 0.10 second(s) in Ring 1.21
# Executed in 0.44 second(s) in Ring 1.17
