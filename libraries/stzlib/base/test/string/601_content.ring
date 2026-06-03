# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #601.
#ERR Error (R14) : Calling Method without definition: replacesubstringatposition

load "../../stzBase.ring"

pr()

o1 = new stzString("Softanza embraces ♥♥♥ simplicty and flexibility")

o1.ReplaceSubStringAtPosition(19, "♥♥♥", :With = "Ring")
? o1.Content()
#--> Softanza embraces Ring simplicty and flexibility

pf()
# Executed in 0.01 second(s) in Ring 1.22
