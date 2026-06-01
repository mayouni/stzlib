# Narrative
# --------
#
# Extracted from stzListOfEntitiesTest.ring, block #3.

load "../../../stzBase.ring"

o1 = new stzListOfEntities([]) {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Microsoft", :type = "Company" ])
	AddEntity([ :name = "Google", :type = "Company" ])

	Show()

	? FindEntityByName(:microsoft)
	? ContainsEntity(:google)
}
