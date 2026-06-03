# Narrative
# --------
# Getting specific entities
#
# Extracted from stzentitytest.ring, block #9.
#ERR Error (R24) : Using uninitialized variable: olist

load "../../stzBase.ring"

pr()

? oList.FirstEntity()[:name]
#--> alice

? oList.LastEntity()[:name]
#--> laptop

aPersons = oList.EntitiesOfType("person")
? len(aPersons)
#--> 2

pf()
