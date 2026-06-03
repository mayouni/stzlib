# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #640.
#ERR Error (R14) : Calling Method without definition: itemshavesameorderas

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "c" ])
? o1.ItemsHaveSameOrderAs([ "a", "c", "f" ])

pf()
# Executed in almost 0 second(s).
