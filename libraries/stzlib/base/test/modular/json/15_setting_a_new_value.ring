# Narrative
# --------
# Setting a New Value
#
# Extracted from stzjsontest.ring, block #15.

load "../../../stzBase.ring"

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oJson.SetValue("age", 31)

? oJson.ToString()
#--> {"age":31,"name":"John"}  # Note: Key order may vary

pf()
# Executed in 0.04 second(s) in Ring 1.22
