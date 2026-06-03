# Narrative
# --------
# Creating basic entities
#
# Extracted from stzentitytest.ring, block #2.

load "../../stzBase.ring"


pr()

o1 = new stzEntity([
    :name = "john",
    :type = "person"
])

? o1.Name()
#--> john

? o1.Type()
#--> person

? o1.Created()
#--> 2025-09-26 14:30:15 (timestamp)

pf()
