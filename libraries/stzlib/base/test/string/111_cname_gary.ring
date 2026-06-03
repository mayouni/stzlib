# Narrative
# --------
# cName = "Gary"
#
# Extracted from stzStringTest.ring, block #111.
#ERR Error (R14) : Calling Method without definition: interpolated

load "../../stzBase.ring"

pr()

? $("It's been a real pleasure meeting you, {cName}!") # Or Interpolate()
#--> It's been a real pleasure meeting you, Gary!

pf()
