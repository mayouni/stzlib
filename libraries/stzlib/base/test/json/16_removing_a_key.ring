# Narrative
# --------
# Removing a Key
#
# Extracted from stzjsontest.ring, block #16.

load "../../stzBase.ring"


pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oJson.RemoveKey("age")

? oJson.ToString()
#--> {"name":"John"}

pf()
# Executed in 0.03 second(s) in Ring 1.22
