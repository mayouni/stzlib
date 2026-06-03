# Narrative
# --------
# EMPTY VALUE PROTECTION
#
# Extracted from stznaturaltest.ring, block #27.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"


pr()

o1 = Naturally("
    Create a string with ''
    Uppercase it
    Show it
")
#--> ""

? o1.Code()
# oStr = StzStringQ("")
# ? oStr.Content()
'
oStr = StzStringQ("")
oStr.Uppercase()
? oStr.Content()
@result = oStr.Content()
'

pf()
