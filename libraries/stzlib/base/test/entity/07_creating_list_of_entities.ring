# Narrative
# --------
# Creating list of entities
#
# Extracted from stzentitytest.ring, block #7.
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

? oList.NumberOfEntities()
#--> 4

? @@(oList.Names())
#--> ["alice", "bob", "ferrari", "laptop"]

? @@(oList.Types())
#--> ["person", "person", "car", "device"]

pf()
# Executed in 0.01 second(s) in Ring 1.24
