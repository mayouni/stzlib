# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #64.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? ShowShortNL(DiacriticsXT())
#-->
'
[
	[ "À", "A", "Capital A, grave accent" ], 
	[ "Á", "A", "Capital A, acute accent" ], 
	[ "Â", "A", "Capital A, circumflex accent" ], 
	"...", 
	[ 1648, "", "Arabic small Alif Mamdoodah", "لٰكن --> لكن" ], 
	[ 1649, 1575, "Arabic Hamzah Wasliah Madhmoomah", "ٱ --> ا" ], 
	[ 1570, 1575, "Arabic ََAlif Mamdoodah", "آ --> ا" ]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.23
