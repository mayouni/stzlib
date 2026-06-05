# Narrative
# --------
# */
#
# Extracted from stzListOfEntitiesTest.ring, block #4.

load "../../stzBase.ring"

pr()

o1 = new stzListOfEntities([])
o1 {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Jobs", :type = "People" ])
	AddEntity([ :name = "MacOS", :type = "Technology" ])

	? NumberOfEntities() #--> 3

	? Entity(2) #--> [ :name = "Jobs", :type = "People" ]

	? Names() #--> [ "Apple", "Jobs", "MacOS" ]
	? Types() #--> [ "Company", "People", "Technology" ]
}

pf()
