# Narrative
# --------
# Enable debug
#
# Extracted from stzmatrextest.ring, block #40.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{Size(3x3)}")

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

oMx.EnableDebug()
? oMx.Match(aMatrix)
#--> TRUE
'
Parsing inner pattern: Size(3x3)
>>> Processing part 1: [Size(3x3)]
>>> Parsing as single token
>> cContent: 3x3
>> cType: size
>>> Token result: [ [ "type", "size" ], [ "value", "3x3" ], [ "constraints", [ ] ], [ "min", 1 ], [ "max", 1 ], [ "negated", 0 ] ]
>>> Token length: 6
>>> Final token count: 1
=== Matching Matrix ===
Size: 3x3
Checking token type: size
Negated value: 0
Result before negation: 1
Final result: 1
Result: 1
'

pf()
