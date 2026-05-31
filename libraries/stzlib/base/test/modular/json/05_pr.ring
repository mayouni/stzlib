# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #5.

load "../../../stzBase.ring"


aList = [["name", "John"], ["age", 30]]

? IsHashList(aList)
#--> TRUE

? IsJsonList(aList) # Or simply IsJson()
#--> TRUE

? ListToJson(aList) + NL
#--> {"name":"John","age":30}

? ListToJsonXT(aList) + Nl
#-->
'
{
	"name": "John",
	"age": 30
}
'

? ListToJsonXT([["name", "John"], ["age", 30], ["hobbies", ["sport", "cinema"]]])
#--> Returns
'
{
	"name": "John",
	"age": 30,
	"hobbies": [
		"sport",
		"cinema"
	]
}
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
