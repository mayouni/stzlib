# Narrative
# --------
# Adding entities
#
# Extracted from stzentitytest.ring, block #10.
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



oList.AddEntity([ :name = "truck", :type = "vehicle", :wheels = 6 ])

? oList.NumberOfEntities()
#--> 5

? oList.HasEntity("truck")
#--> 1

pf()
