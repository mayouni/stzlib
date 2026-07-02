# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #426.
#
# NOTE (audit, 2026-07-02): DEFERRED. stzList.SplitWXT is RETIRED by design
# (WXT disqualification; precedent #84, #219-#221, #412). The W replacement
# (SplitW) is asserted in test 424.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])

o1.SplitWXT('@CurrentItem = "*"')

? @@( o1.Content() )
#--> [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ]

pf()
# Executed in 0.09 second(s) in Ring 1.21
