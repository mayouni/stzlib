# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #88.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("..<<Hi>>..<<Ring!>>..")
? @@( o1.FindAnyBoundedByAsSections("<<", ">>") )
#--> [ [ 5, 6 ], [ 13, 17 ] ]

pf()
# Executed in 0.07 second(s)
