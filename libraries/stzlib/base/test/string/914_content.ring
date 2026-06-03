# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #914.
#ERR Error (R14) : Calling Method without definition: replacebymany

load "../../stzBase.ring"

pr()

o1 = new stzString("--*--*--*--")
o1.ReplaceByMany("*", [ "ONE", "TWO", :And = "THREE" ])
? o1.Content()

pf()
# Executed in 0.01 second(s).
