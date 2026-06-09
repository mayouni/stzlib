# Narrative
# --------
# List operations
#
# Extracted from stzentitytest.ring, block #13.
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



? oList.IsEmpty()
#--> 0

? oList.UniqueTypes()
#--> ["device", "person", "vehicle"]

oList.Show()
#-->
# List of Entities (4 entities):
# ================================================
# 1. laptop (device)
# 2. alice (person)
# 3. bob (person)
# 4. truck (vehicle)

pf()
