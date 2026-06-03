# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #88.

load "../../stzBase.ring"

pr()

o1 = new stzString("..<<Hi>>..<<Ring!>>..")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 5, 6 ], [ 13, 17 ] ]

pf()
# Executed in 0.07 second(s)
