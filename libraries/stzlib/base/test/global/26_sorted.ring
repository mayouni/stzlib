# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #26.
#ERR Error (R14) : Calling Method without definition: sorted

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "[ 4, 7 ]", "[ 1, 3 ]", "[ 8, 9 ]" ])
? o1.Sorted()

pf()
#--> Executed in 0.03 second(s)
