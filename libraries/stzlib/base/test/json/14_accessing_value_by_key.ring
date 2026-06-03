# Narrative
# --------
# Accessing Value by Key
#
# Extracted from stzjsontest.ring, block #14.

load "../../stzBase.ring"


pr()

oJson = new stzJson('{"name": "John", "age": 30 }')

? oJson.Value("name")
#--> "John"

pf()
# Executed in 0.02 second(s) in Ring 1.22
