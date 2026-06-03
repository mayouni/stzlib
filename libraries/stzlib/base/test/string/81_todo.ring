# Narrative
# --------
# TODO
#
# Extracted from stzStringTest.ring, block #81.
#ERR Error (R14) : Calling Method without definition: replacemanywithmany

load "../../stzBase.ring"


pr()

o1 = new stzString("--Ring__Softanza..")

o1.ReplaceManyWithMany(["--", "__", ".."], ["1", "2", "3"])
? o1.Content()

pf()
