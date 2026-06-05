# Narrative
# --------
# o1 = new stzListOfStrings(  [ "Tunis", "gafsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
#
# Extracted from stzlistofstringstest.ring, block #106.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings(  [ "Tunis", "gafsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])

? o1.ConcatenateUsing(" ")
#--> Tunis gafsa tunis gabes tunis regueb tuta regueb

pf()
