# Narrative
# --------
# Getting specific entities
#
# Extracted from stzentitytest.ring, block #9.

load "../../stzBase.ring"


? oList.FirstEntity()[:name]
#--> alice

? oList.LastEntity()[:name]
#--> laptop

aPersons = oList.EntitiesOfType("person")
? len(aPersons)
#--> 2
