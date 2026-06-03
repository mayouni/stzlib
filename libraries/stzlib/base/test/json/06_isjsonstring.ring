# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #6.

load "../../stzBase.ring"

pr()

cJsonStr = '
{
	"name": "John",
	"age": 30,
	"hobbies": [
		"sport",
		"cinema"
	]
}
'

? IsJsonString(cJsonStr) # Or simply IsJson()
#--> TRUE

pf()
