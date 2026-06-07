# Narrative
# --------
# cName = "Gary"
#
# Extracted from stzStringTest.ring, block #111.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

cName = "Gary"

? $("It's been a real pleasure meeting you, {cName}!") # Or Interpolate()
#--> It's been a real pleasure meeting you, Gary!

pf()
