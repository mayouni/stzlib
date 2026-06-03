# Narrative
# --------
# */
#
# Extracted from stzListOfEntitiesTest.ring, block #3.
#ERR Error (R16) : Using braces to access unknown object

load "../../stzBase.ring"

pr()

o1 = new stzListOfEntities([]) {
	AddEntity([ :name = "Apple", :type = "Company" ])
	AddEntity([ :name = "Microsoft", :type = "Company" ])
	AddEntity([ :name = "Google", :type = "Company" ])

	Show()

	? FindEntityByName(:microsoft)
	? ContainsEntity(:google)
}

pf()
