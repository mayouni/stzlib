# Narrative
# --------
# Copying a JSON Object
#
# Extracted from stzjsontest.ring, block #30.

load "../../stzBase.ring"


pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oCopy = oJson.Copy()

? oCopy.ToString()
#-->

pf()
