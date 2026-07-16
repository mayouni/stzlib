# Narrative
# --------
# Filtering and sorting
#
# Extracted from stzentitytest.ring, block #12.
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



oPersonsList = oList.FilterByTypeQ("person")
? oPersonsList.NumberOfEntities()
#--> 2

oList.SortByName()
? oList.Names()
#--> ["alice", "bob", "laptop", "truck"]

oList.SortByType()
? oList.Types()
#--> ["device", "person", "person", "vehicle"]

pf()
