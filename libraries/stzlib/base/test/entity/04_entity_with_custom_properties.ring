# Narrative
# --------
# Entity with custom properties
#
# Extracted from stzentitytest.ring, block #4.

load "../../stzBase.ring"


pr()

o1 = new stzEntity([
    :name = "toyota",
    :type = "car",
    :model = "camry",
    :year = 2023,
    :color = "blue"
])

? o1.Property("model")
#--> camry

? @@(o1.Properties())
#--> ["name", "type", "created", "model", "year", "color"]

? o1.ContainsProperty("year")
#--> 1

pf()
# Executed in almost 0 second(s) in Ring 1.24
