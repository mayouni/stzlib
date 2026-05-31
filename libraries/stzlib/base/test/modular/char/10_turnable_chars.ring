# Narrative
# --------
# TURNABLE CHARS
#
# Extracted from stzchartest.ring, block #10.

load "../../../stzBase.ring"


pr()

? HowManyTurnableChars()
#--> 141

? @@S( TurnableChars() ) + NL
#--> [ "$", "&", "(", "...", "ꭃ", "ꭐ", "ꭑ" ]

? @@S( TurnableUnicodes() ) + NL
#--> [ 36, 38, 40, "...", 43843, 43856, 43857 ]

? @@S( TurnableUnicodesXT()) # Or ShowShort()
#--> [
#	[ 36, "$" ], [ 38, "&" ], [ 40, "(" ], "...",
#	[ 43843, "ꭃ" ], [ 43856, "ꭐ" ], [ 43857, "ꭑ" ] ]
# ]

? @@S(TurnableCharsXT()) + NL
#--> [ [ "δ", "ƍ" ], [ "Ɑ", "Ɒ" ], [ "ɑ", "ɒ" ], "...", [ "~", "~" ], [ "$", "$" ], [ "€", "€" ] ]

? @@S( TurnableCharsAndTheirUnicodes() )
#--> [ [ "$", 36 ], [ "&", 38 ], [ "(", 40 ], "...", [ "ꭃ", 43843 ], [ "ꭐ", 43856 ], [ "ꭑ", 43857 ] ]

pf()
# Executed in 0.08 second(s) in Ring 1.23
# Executed in 0.30 second(s) in Ring 1.20
