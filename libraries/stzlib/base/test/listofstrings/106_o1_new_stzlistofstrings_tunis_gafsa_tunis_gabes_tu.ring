# Narrative
# --------
# o1 = new stzListOfStrings(  [ "Tunis", "gafsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
#
# Extracted from stzlistofstringstest.ring, block #106.
#ERR Error (R14) : Calling Method without definition: concatenateusing

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings(  [ "Tunis", "gafsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])

? o1.ConcatenateUsing(" ")
#--> Tunis gafsa tunis gabes tunis regueb tuta regueb

pf()
