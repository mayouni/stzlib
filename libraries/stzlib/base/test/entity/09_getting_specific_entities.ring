# Narrative
# --------
# Getting specific entities
#
# Extracted from stzentitytest.ring, block #9.

load "../../stzBase.ring"

pr()

aEntities = [
    [ :name = "alice", :type = "person", :age = 30 ],
    [ :name = "bob", :type = "person", :age = 25 ],
    [ :name = "ferrari", :type = "car", :brand = "ferrari" ],
    [ :name = "laptop", :type = "device", :brand = "dell" ]
]

oList = new stzListOfEntities(aEntities)



? oList.FirstEntity()[:name]
#--> alice

? oList.LastEntity()[:name]
#--> laptop

aPersons = oList.EntitiesOfType("person")
? len(aPersons)
#--> 2

pf()
