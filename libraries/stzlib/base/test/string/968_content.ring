# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #968.
#ERR Error (R14) : Calling Method without definition: replacesectionsbymany

load "../../stzBase.ring"

pr()

o1 = new stzString("--345--89--")
o1.ReplaceSectionsByMany([ [3, 5], [8,9] ], [ "*", "~" ] )
? o1.Content()
#--> --*--~--

pf()
# Executed in 0.01 second(s).
