# Narrative
# --------
# cName = "Gary"
#
# Extracted from stzStringTest.ring, block #111.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? $("It's been a real pleasure meeting you, {cName}!") # Or Interpolate()
#--> It's been a real pleasure meeting you, Gary!

pf()
