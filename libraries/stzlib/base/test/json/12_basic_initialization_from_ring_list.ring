# Narrative
# --------
# Basic Initialization from Ring List
#
# Extracted from stzjsontest.ring, block #12.

load "../../stzBase.ring"


pr()

aList = [ ["name", "Alice"], ["age", 25] ]
oJson = new stzJson(aList)

# compact JSON string

? oJson.ToString()
#--> {"age":25,"name":"Alice"}

# Indented JSON string

? oJson.ToStringXT()
#-->
'
{
    "age": 25,
    "name": "Alice"
}
'

pf()
# Executed in 0.04 second(s) in Ring 1.22
