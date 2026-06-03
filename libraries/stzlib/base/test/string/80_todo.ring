# Narrative
# --------
# TODO
#
# Extracted from stzStringTest.ring, block #80.
#ERR Error (R14) : Calling Method without definition: replacewithmany

load "../../stzBase.ring"


pr()

o1 = new stzString("--Ring--Softanza--")

o1.ReplaceWithMany("--", ["1", "2", "3"])
? o1.Content()

pf()
