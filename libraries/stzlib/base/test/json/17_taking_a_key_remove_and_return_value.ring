# Narrative
# --------
# Taking a Key (Remove and Return Value)
#
# Extracted from stzjsontest.ring, block #17.

load "../../stzBase.ring"


pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
vValue = oJson.TakeKey("age")

? vValue
#--> 30

? oJson.ToString()
#--> {"name":"John"}

pf()
# Executed in 0.04 second(s) in Ring 1.22
