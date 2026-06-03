# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #9.

load "../../stzBase.ring"


#NOTE: JSON specification does not impose ordering preservation
# of JSON members, and so does Qt, on witch stzJson is based.
# This ensures parsing of large JSON files is done efficiently.

# From JSON string
oJson = new stzJson('{"name": "John", "age": 30 }')

	# Compact form
	? oJson.ToString()
	#--> {"age":30,"name":"John"}
	
	# Indented form
	? oJson.ToStringXT() + NL
	#-->
	'
	{
	    "age": 30,
	    "name": "John"
	}
	'

# From Ring list
oJson = new stzJson([ ["name", "John"], ["age", 30] ])
? oJson.ToStringXT()
#-->
'
{
    "age": 30,
    "name": "John"
}
'

#NOTE how "age" is returned before "name" (read note at the start of sample)

pf()
# Executed in 0.04 second(s) in Ring 1.22
