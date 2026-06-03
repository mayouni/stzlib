# Narrative
# --------
# Getting Keys
#
# Extracted from stzjsontest.ring, block #13.

load "../../stzBase.ring"


pr()

oJson = new stzJson('{"name": "John", "age": 30 }')

? oJson.Keys()
#--> ["age", "name"]  # Note: Order of keys is not guaranteed

pf()
# Executed in 0.02 second(s) in Ring 1.22
