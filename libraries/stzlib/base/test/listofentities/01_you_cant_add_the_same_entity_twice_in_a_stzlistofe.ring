# Narrative
# --------
# # You can't add the same entity twice in a stzListOfEntities
#
# Extracted from stzListOfEntitiesTest.ring, block #1.

load "../../stzBase.ring"

pr()

# An entity is defined by the pair :name/:type

# The following raises an error because the entity
# :apple/:company is added twice -- caught so pf() still fires.
o1 = new stzListOfEntities([])
try
	o1 {
		AddEntity([ :name = "Apple", :type = "Company" ])
		AddEntity([ :name = "Apple", :type = "Company" ])

		Show()
	}
catch
	? "Expected guard: " + cCatchError
done

pf()
