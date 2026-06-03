# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #47.

load "../../stzBase.ring"


? ShowShortXTNL(LatinDiacriticsXT(), 5)
#-->
'
[
	[ "À", "A", "Capital A, grave accent" ], 
	[ "Á", "A", "Capital A, acute accent" ], 
	[ "Â", "A", "Capital A, circumflex accent" ], 
	[ "Ã", "A", "Capital A, tilde" ], 
	[ "Ä", "A", "Capital A, dieresis or umlaut mark" ], 
	"...", 
	[ "ż", "z", "Small Z, dot accent" ], 
	[ "Ž", "Z", "Capital Z, caron accent" ], 
	[ "ž", "z", "Small z, caron accent" ], 
	[ "ſ", "s", "Small long s" ], 
	[ "ỳ", "y", "Small y" ]
]
'

? ShowShortXT(LatinDiacriticsUnicodes(), 5)
#-->
'
[ 192, 193, 194, 195, 196, "...", 380, 381, 382, 383, 7923 ]
'
	
pf()
# Executed in almost 0 second(s) in Ring 1.23
