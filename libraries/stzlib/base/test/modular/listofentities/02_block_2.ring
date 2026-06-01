# Narrative
# --------
#
# Extracted from stzListOfEntitiesTest.ring, block #2.

load "../../../stzBase.ring"

# While this will work
o1 = new stzListOfEntities([]) {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Apple", :type = "Fruit" ])

	Show()
}

# In fact, the two entities share the same name but they aresult
# not of the same type (one is the name of a company and the other
# is the name of a fruit!)
