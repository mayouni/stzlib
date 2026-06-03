# Narrative
# --------
# TODO
#
# Extracted from stzlistofstringstest.ring, block #6.
#ERR Error (R14) : Calling Method without definition: findduplicates 

load "../../stzBase.ring"

pr()

StartProfiler()

o1 = new stzListOfStrings([ "_", "ONE", "_", "_", "TWO", "_", "THREE", "*", "*" ])
? @@( o1.FindDuplicates() )


StopProfiler()

pf()
