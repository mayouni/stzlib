# Narrative
# --------
# Adding entities
#
# Extracted from stzentitytest.ring, block #10.
#ERR Error (R24) : Using uninitialized variable: olist

load "../../stzBase.ring"

pr()

oList.AddEntity([ :name = "truck", :type = "vehicle", :wheels = 6 ])

? oList.NumberOfEntities()
#--> 5

? oList.HasEntity("truck")
#--> 1

pf()
