# Narrative
# --------
# Removing entities
#
# Extracted from stzentitytest.ring, block #11.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

aEntities = [
    [ :name = "alice", :type = "person", :age = 30 ],
    [ :name = "bob", :type = "person", :age = 25 ],
    [ :name = "ferrari", :type = "car", :brand = "ferrari" ],
    [ :name = "laptop", :type = "device", :brand = "dell" ]
]

oList = new stzListOfEntities(aEntities)



oList.RemoveEntity("ferrari")
? oList.NumberOfEntities()
#--> 4

? oList.ContainsName("ferrari")
#--> 0

pf()
