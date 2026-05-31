# Narrative
# --------
# EXTRACTING DIGIT LIST
#
# Extracted from stznumbrextest.ring, block #25.

load "../../../stzBase.ring"


pr()

Nx = Nx("{@Digit+}")
? Nx.Match(1234) #--> TRUE
? @@NL( Nx.MatchedParts() )
#-->
'
[
	[ "Digits", [ 1, 2, 3, 4 ] ],
	[ "Factors", [ 1, 2, 617, 1234 ] ],
	[ "Properties", [ "Even", "Deficient", "Composite" ] ],
	[ "Value", 1234 ]
]
'

pf()
