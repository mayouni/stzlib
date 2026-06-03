# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #156.
#ERR Error (R14) : Calling Method without definition: simplifyexcept

load "../../stzBase.ring"

pr()

o1 = new stzString(' this code:   txt1  =   "    withspaces    " and txt2  =  "nospaces"  ')
o1.SimplifyExcept( o1.FindAnyBoundedByAsSections('"') )

? o1.Content()

#--> 'this code: txt1 = "    withspaces    " and txt2 = "nospaces"'

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.08 second(s) in Ring 1.20
