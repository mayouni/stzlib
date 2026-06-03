# Narrative
# --------
# Basic Initialization from JSON String
#
# Extracted from stzjsontest.ring, block #11.

load "../../stzBase.ring"

pr()

oJson = new stzJson('{"name": "John", "age": 30 }')

? @@NL( oJson.ToList() )
#-->
# Note: Order of key-value pairs may vary due to qt-behavoir (#perf)
# and as stated by the JSON specificztion itself

'
[
	[ "age", 30 ],
	[ "name", "John" ]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24
# Executed in 0.04 second(s) in Ring 1.22
