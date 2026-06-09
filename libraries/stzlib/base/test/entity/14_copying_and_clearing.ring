# Narrative
# --------
# Copying and clearing
#
# Extracted from stzentitytest.ring, block #14.
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



oListCopy = oList.Copy()
? oListCopy.NumberOfEntities()
#--> 4

oList.Clear()
? oList.IsEmpty()
#--> 1

? oListCopy.IsEmpty()
#--> 0

pf()
