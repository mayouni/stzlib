# Narrative
# --------
# o1 = new stzListOfStrings(  [ "Tunis", "gafsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
#
# Extracted from stzlistofstringstest.ring, block #106.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.ConcatenateUsing(" ")
#--> Tunis gafsa tunis gabes tunis regueb tuta regueb

pf()
