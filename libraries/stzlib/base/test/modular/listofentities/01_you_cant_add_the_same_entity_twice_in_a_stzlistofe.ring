# Narrative
# --------
# # You can't add the same entity twice in a stzListOfEntities
#
# Extracted from stzListOfEntitiesTest.ring, block #1.

load "../../../stzBase.ring"

# An entity is defined by the pair :name/:type

# The following raises an error because the entity
# :apple/:company is add twice
o1 = new stzListOfEntities([]) {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Apple", :type = "Company" ])

	Show()

}
