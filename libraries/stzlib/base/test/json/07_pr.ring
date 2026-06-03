# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #7.

load "../../stzBase.ring"


? @@NL( JsonToList('{"name": "John", "age": 30 }') )
#-->
'
[
	[ "name", "John" ],
	[ "age", 30 ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.22
