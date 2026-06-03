# Narrative
# --------
# Adding entities
#
# Extracted from stzentitytest.ring, block #10.

load "../../stzBase.ring"


oList.AddEntity([ :name = "truck", :type = "vehicle", :wheels = 6 ])

? oList.NumberOfEntities()
#--> 5

? oList.HasEntity("truck")
#--> 1
