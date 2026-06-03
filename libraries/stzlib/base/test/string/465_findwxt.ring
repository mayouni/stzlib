# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #465.
#ERR Error (R14) : Calling Method without definition: findwxt

load "../../stzBase.ring"

pr()

? @@( Q("1 AA 6 B 0 CCC 6 DD 1 Z").FindWXT(' Q(@char).IsNumberInString() ') )
#--> [ 1, 6, 10, 16, 21 ]

pf()
