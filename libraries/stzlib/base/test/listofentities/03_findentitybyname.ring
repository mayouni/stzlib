# Narrative
# --------
# */
#
# Extracted from stzListOfEntitiesTest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzListOfEntities([])
o1 {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Microsoft", :type = "Company" ])
	AddEntity([ :name = "Google", :type = "Company" ])

	Show()

	? FindEntityByName(:microsoft)
	? ContainsEntity(:google)
}

pf()
