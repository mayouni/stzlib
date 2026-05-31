# Narrative
# --------
# Finding entities
#
# Extracted from stzentitytest.ring, block #8.

load "../../../stzBase.ring"

pr()

aEntities = [
    [ :name = "alice", :type = "person", :age = 30 ],
    [ :name = "bob", :type = "person", :age = 25 ],
    [ :name = "ferrari", :type = "car", :brand = "ferrari" ],
    [ :name = "laptop", :type = "device", :brand = "dell" ]
]

oList = new stzListOfEntities(aEntities)

? oList.FindEntityByName("alice")
#--> 1

? oList.ContainsType("car")
#--> 1

? oList.CountByType("person")
#--> 2

? oList.FindEntitiesByType("person")
#--> [1, 2]

pf()
