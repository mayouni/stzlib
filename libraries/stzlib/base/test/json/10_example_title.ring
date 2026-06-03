# Narrative
# --------
# Example title
#
# Extracted from stzjsontest.ring, block #10.

load "../../stzBase.ring"


pr()

# From JSON string
oJson = new stzJson('{"name": "John", "age": 30 }')

? @@NL( oJson.ToList() )
#-->
'
[
	[ "age", 30 ],
	[ "name", "John" ]
]
'

pf()
# Executed in 0.03 second(s) in Ring 1.22

#========================#
#  STZJSON TEST SAMPLES  #
#========================#
